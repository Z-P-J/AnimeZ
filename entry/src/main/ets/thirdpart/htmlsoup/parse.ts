import htmlDecode from './html-decode'

const DATASET_ATTR_PREFIX = 'data-'

export interface Attributes {
	[attr: string]: string | boolean | undefined
}
export type Children = (HtmlTag | TextNode)[]
export type AnyNode = Children | HtmlTag | TextNode
export interface HtmlParams {
	type: string
	attributes: Attributes
	children?: Children
	parent: HtmlTag | null
}
export interface DataSet {
	[attr: string]: string
}

export class TextNode {
	constructor(readonly text: string) {}
}
export class HtmlTag {
	readonly type: string
	readonly attributes: Attributes
	children!: Children
	readonly parent: HtmlTag | null

	constructor({type, attributes, children, parent}: HtmlParams) {
		this.type = type
		this.attributes = attributes
		if (children) this.children = children
		this.parent = parent
	}

	setChildren(children: Children) {
		this.children = children
	}
	get child(): TextNode | HtmlTag { //utility function; use if you know there is only one child
		return this.children[0]
	}
	get classes(): Set<string> {
		return typeof this.attributes.class === 'string'
			? new Set(this.attributes.class.split(' '))
			: new Set
	}
	get dataset(): DataSet {
		const dataset: DataSet = {}
		for (const attribute in this.attributes) {
			if (!attribute.startsWith(DATASET_ATTR_PREFIX)) continue
			const value = this.attributes[attribute]
			if (value === undefined) continue

			const dataName = attribute.slice(DATASET_ATTR_PREFIX.length)
				.replace(/-([a-z])/g, (_, c: string) => c.toUpperCase())
			dataset[dataName] = typeof value === 'string' ? value : ''
		}
		return dataset
	}

	get textContent(): string {
		if (this.children) {
			return this.children.map((node) => {
				if (node instanceof TextNode) {
					return node.text
				} else {
					return node.textContent
				}
			}).join('')
		} else {
			return ''
		}
	}

	attr(name: string): string {
		let value = this.attributes[name]
		if (typeof value === 'string') {
			return value
		} else {
			return value ? 'true' : 'false'
		}
	}

	outerHtml(ignoreAttrs: boolean = false) {
		let html = '<' + this.type
		if (!ignoreAttrs) {
			if (this.attributes) {
				for (const attribute in this.attributes) {
					const value = this.attributes[attribute]
					html += ` ${attribute}="${value}"`
				}
			}
		}
		if (this.children) {
			html += '>'
			html += this.children.map((node) => {
				if (node instanceof TextNode) {
					return node.text
				} else {
					return node.outerHtml()
				}

			}).join('')
			html += '</' + this.type + '>'
		} else {
			html += '/>'
		}
		return html
	}

	innerHtml(ignoreAttrs: boolean = false) {
		if (this.children) {
			return this.children.map((node) => {
				if (node instanceof TextNode) {
					return node.text
				} else {
					return node.outerHtml(ignoreAttrs)
				}
			}).join('')
		} else {
			return ''
		}
	}
}

class ReadingState {
	constructor(readonly ignoreWhitespace: boolean) {}
}
const
	READING_TEXT = new ReadingState(false),
	READING_ESCAPE = new ReadingState(false),
	IN_TAG = new ReadingState(false),
	READING_ATTRIBUTE_NAME = new ReadingState(true),
	LOOKING_FOR_VALUE_START = new ReadingState(true),
	READING_ATTRIBUTE_VALUE = new ReadingState(false),
	READING_ESCAPE_ATTRIBUTE = new ReadingState(false)
const WHITESPACE = /^\s$/
const SINGLETON_TAGS = new Set([
	'area',
	'base',
	'br',
	'col',
	'command',
	'embed',
	'hr',
	'img',
	'input',
	'link',
	'meta',
	'param',
	'source'
])

/*
	A tree structure used to contain all the valid non-numeric ampersand codes.
	Each level of the tree contains a mapping of characters to sub-trees.
	If the path through the tree is a valid complete code (as opposed to just the start of one),
	then '' will be in the map.

	Example containing the codes 'abc', 'abcd', and 'def'
	   root
	  /    \
	 'a'  'd'
	  |    |
	 'b'  'e'
	  |    |
	 'c'  'f'
	 / \    \
	'' 'd'  ''
	    |
	   ''
*/
class TextTree {
	private readonly children = new Map<string, TextTree>()

	//Inserts the specified string into the tree,
	//including all necessary sub-trees
	insertWord(word: string): void {
		const firstLetter = word.slice(0, 1) //can be '' if word is empty
		let child = this.children.get(firstLetter)
		if (!child) {
			child = new TextTree
			this.children.set(firstLetter, child)
		}
		if (word) child.insertWord(word.substring(1))
	}
	getChild(letter: string): TextTree | undefined {
		return this.children.get(letter)
	}
}
const AMPERSAND_TEXT_CODES = new TextTree
for (const escapeCode in htmlDecode) AMPERSAND_TEXT_CODES.insertWord(escapeCode)
const AMPERSAND_CODE_CHAR = /^[#\d]$/
//Returns whether the ampersand code starting at index in string
//should be treated as an escape sequence or just normal text
function validAmpersandCode(string: string, index: number): boolean {
	if (AMPERSAND_CODE_CHAR.test(string[index])) return true //if it starts "&1" or "&#", it must start an escape sequence
	//Iterate down levels of the escape code tree and indices in the string
	//If tree is ever undefined, we know no codes start with this sequence
	for (
		let tree: TextTree | undefined = AMPERSAND_TEXT_CODES;
		tree;
		tree = tree.getChild(string[index++])
	) {
		if (string[index] === ';') return !!tree.getChild('') //make sure this a valid complete code, not just the start to one
	}
	return false
}

//Returns whether matchString occurs starting at string[index]
function followedBy(string: string, index: number, matchString: string): boolean {
	const {length} = matchString
	return string.substring(index, index + length) === matchString
}

interface ReadResult {
	children: Children
	length: number
}
const HTML_COMMENT_START = '<!--'
const HTML_COMMENT_END = '-->'
function readChildren(string: string, index: number, parent: HtmlTag | null, trimText: boolean): ReadResult {
	const inScript = parent && parent.type === 'script'
	const originalIndex = index
	const children: Children = []
	let state: ReadingState | null = READING_TEXT,
		inComment = false,
		text = '',
		name: string,
		attributeName: string,
		value: string,
		closingTag: boolean,
		attributes: Attributes,
		escapeCode: string,
		selfClosing: boolean,
		valueEndCharacter: '"' | "'" | null
	for (; state; index++) {
		if (index >= string.length) break
		const char = string[index]
		const whitespace = WHITESPACE.test(char)
		if (state.ignoreWhitespace && whitespace) continue
		switch (state) {
			case READING_TEXT:
				if (char === '<' && (!inScript || (inScript && followedBy(string, index, '</script>'))) && !inComment) {
					if (followedBy(string, index, HTML_COMMENT_START)) {
						text += HTML_COMMENT_START
						inComment = true
						index += HTML_COMMENT_START.length - 1
					}
					else {
						if (trimText) text = text.trim()
						if (text) children.push(new TextNode(text))
						state = IN_TAG
						name = ''
						closingTag = false
						attributes = {}
						selfClosing = false
					}
				}
				else if (char === '&' && !inScript && validAmpersandCode(string, index + 1)) {
					state = READING_ESCAPE
					escapeCode = ''
				}
				else if (inComment && followedBy(string, index, HTML_COMMENT_END)) {
					text += HTML_COMMENT_END
					inComment = false
					index += HTML_COMMENT_END.length - 1
				}
				else text += char
				break
			case READING_ESCAPE:
			case READING_ESCAPE_ATTRIBUTE:
				if (char === ';') {
					let resolvedChar
					if (escapeCode![0] === '#') {
						resolvedChar = String.fromCharCode(Number(escapeCode!.substring(1)))
					}
					else {
						resolvedChar = htmlDecode[escapeCode!]
						if (resolvedChar === undefined) throw new Error("Couldn't decode &" + escapeCode! + ';')
					}
					if (state === READING_ESCAPE) {
						text += resolvedChar
						state = READING_TEXT
					}
					else {
						value! += resolvedChar
						state = READING_ATTRIBUTE_VALUE
					}
				}
				else escapeCode! += char
				break
			case IN_TAG:
				if (whitespace) {
					if (name!) {
						state = READING_ATTRIBUTE_NAME
						attributeName = ''
					}
				}
				else if (char === '/') {
					if (name!) selfClosing = true
					else closingTag = true
				}
				else if (char === '>') {
					if (closingTag!) state = null //we have come to the end of all that had to be read
					else {
						if (SINGLETON_TAGS.has(name!.toLowerCase())) selfClosing = true
						if (selfClosing!) {
							children.push(new HtmlTag({
								type: name!,
								attributes: attributes!,
								children: [],
								parent
							}))
						}
						else {
							const tag = new HtmlTag({type: name!, attributes: attributes!, parent})
							const {children: subChildren, length} = readChildren(string, index + 1, tag, trimText)
							tag.setChildren(subChildren)
							children.push(tag)
							index += length
						}
						text = ''
						state = READING_TEXT
					}
				}
				else {
					if (!closingTag!) name! += char //name is not necessary for a closing tag
				}
				break
			case READING_ATTRIBUTE_NAME:
				const tagChar = char === '/' || char === '>'
				if (char === '=') state = LOOKING_FOR_VALUE_START
				else if (tagChar) {
					if (attributeName!) {
						attributes![attributeName!.toLowerCase()] = true
						attributeName = ''
					}
					if (tagChar) {
						index--
						state = IN_TAG
					}
				}
				else {
					if (WHITESPACE.test(string[index - 1]) && attributeName!) {
						attributes![attributeName!.toLowerCase()] = true
						attributeName = ''
					}
					attributeName! += char
				}
				break
			case LOOKING_FOR_VALUE_START:
				if (char === "'" || char === '"') valueEndCharacter! = char
				else {
					valueEndCharacter = null
					index--
				}
				state = READING_ATTRIBUTE_VALUE
				value = ''
				break
			case READING_ATTRIBUTE_VALUE:
				if (char === valueEndCharacter! || (valueEndCharacter! === null && whitespace)) {
					attributes![attributeName!.toLowerCase()] = value!
					state = READING_ATTRIBUTE_NAME
					attributeName = ''
				}
				else if (valueEndCharacter! === null && (char === '/' || char === '>')) {
					attributes![attributeName!.toLowerCase()] = value!
					index--
					state = IN_TAG
				}
				else {
					if (char === '&' && validAmpersandCode(string, index + 1)) {
						state = READING_ESCAPE_ATTRIBUTE
						escapeCode = ''
					}
					else value! += char
				}
				break
			default:
				throw new Error('Invalid state')
		}
	}
	if (state === READING_TEXT) {
		if (trimText) text = text.trim()
		if (text) children.push(new TextNode(text))
	}
	return {children, length: index - originalIndex}
}

function parse(str: string, trimText = true): AnyNode {
	//Assumes a correctly formatted HTML string
	const root = new HtmlTag({type: '', attributes: {}, parent: null})
	const {children} = readChildren(str, 0, root, trimText)
	root.setChildren(children)
	return children.length === 1 ? children[0] : children
}

export default Object.assign(parse, {HtmlTag, TextNode})