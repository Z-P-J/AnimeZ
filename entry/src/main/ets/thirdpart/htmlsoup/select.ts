import {Children, HtmlTag, TextNode, AnyNode} from './parse'

const regexEscape = (str: string): string =>
	str.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')
const WHITESPACE = /^\s$/, HTML_COMMENT_START = '<!--', HTML_COMMENT_END = '-->'
function isWhiteSpace(str: string) {
	while (str) {
		if (WHITESPACE.test(str[0])) str = str.trimLeft()
		else if (str.startsWith(HTML_COMMENT_START)) {
			const commentEndIndex = str.indexOf(HTML_COMMENT_END, HTML_COMMENT_START.length)
			if (commentEndIndex >= 0) str = str.slice(commentEndIndex + HTML_COMMENT_END.length)
			else return false
		}
		else return false
	}
	return true
}

const SEPARATOR_CHARS = new Set([',', ' ', '>', '+', '~'])
const isSeparator = (c: string): boolean => SEPARATOR_CHARS.has(c)

class SelectorReadingState {}
const
	TAG = new SelectorReadingState,
	CLASS = new SelectorReadingState,
	ID = new SelectorReadingState,
	ATTRIBUTES = new SelectorReadingState,
	PSEUDOS = new SelectorReadingState

const EXISTING = true, EQUALING = '=', CONTAINING_WHOLE_WORD = '~=', STARTING_WHOLE_WORD = '|=', STARTING = '^=', ENDING = '$=', CONTAINING = '*='
type AttributeTypeString
	= typeof EQUALING
	| typeof CONTAINING_WHOLE_WORD
	| typeof STARTING_WHOLE_WORD
	| typeof STARTING
	| typeof ENDING
	| typeof CONTAINING
type AttributeType = typeof EXISTING | AttributeTypeString
const ATTRIBUTE_TYPES: AttributeTypeString[] = [CONTAINING_WHOLE_WORD, STARTING_WHOLE_WORD, STARTING, ENDING, CONTAINING, EQUALING /*must be matched last*/]
class AttributeMatch {
	constructor(
		readonly attribute: string,
		readonly matchType: AttributeType,
		readonly value?: string
	) {
		if (matchType !== EXISTING && value === undefined) throw new Error('Value not specified')
	}
}
const stripQuotes = (str: string): string =>
	str.length > 1 && str[0] === '"' && str.slice(-1) === '"' ? str.slice(1, -1) : str
const isInt = (n: number): boolean => n === (n | 0)
function matchNth(query: string, matches: HtmlTag[], element: HtmlTag): boolean {
	const error = () => new Error(`Invalid nth query: "${query}"`)
	let interval: number, offset: number
	if (query === 'even') {
		interval = 2
		offset = 0
	}
	else if (query === 'odd') {
		interval = 2
		offset = 1
	}
	else {
		const segments = query.split('n') as [string, string | undefined]
		if (segments.length > 2) throw error()
		const [firstSegment, secondSegment] = segments
		if (secondSegment === undefined) {
			interval = 0
			offset = Number(query)
			if (!isInt(offset)) throw error()
		}
		else {
			if (!firstSegment) interval = 1
			else if (firstSegment === '-') interval = -1
			else {
				interval = Number(firstSegment)
				if (!isInt(interval)) throw error()
			}
			if (secondSegment) {
				offset = Number(secondSegment)
				if (!isInt(offset)) throw error()
			}
			else offset = 0
		}
	}
	let index = offset
	if (interval > 0) {
		while (index <= 0) index += interval
	}
	else if (interval < 0) {
		while (index > matches.length) index += interval
	}
	while (index > 0 && index <= matches.length) {
		if (matches[index - 1] === element) return true
		if (!interval) break // if interval is 0, only check this offset
		index += interval
	}
	return false
}

const
	NTH_CHILD = /^nth-child\((.+)\)$/,
	NTH_LAST_CHILD = /^nth-last-child\((.+)\)$/,
	NTH_OF_TYPE = /^nth-of-type\((.+)\)$/,
	NTH_LAST_OF_TYPE = /^nth-last-of-type\((.+)\)$/

type MatchSet = HtmlTag[]
abstract class Selector {
	abstract findMatches(dom: Children, recursive: boolean, matchSet: MatchSet): void
}
class SingleSelector extends Selector { //selector that doesn't relate different selectors (e.g. div.hide#one:hover but not div > ul.abc)
	private tagName!: string
	private readonly classes: string[] = []
	private id: string | undefined
	private readonly attributes: AttributeMatch[] = []
	private readonly pseudos: string[] = []

	constructor(selectorString: string) {
		super()
		const saveSegment = () => {
			switch (state) {
				case TAG:
					this.tagName = (!name || name === '*') ? '*' : name
					break
				case CLASS:
					this.classes.push(name)
					break
				case ID:
					this.id = name
					break
				case ATTRIBUTES:
					let noAttrMatch = true
					for (const attributeType of ATTRIBUTE_TYPES) {
						let index = name.indexOf(attributeType)
						if (index >= 0) {
							this.attributes.push(new AttributeMatch(
								name.slice(0, index),
								attributeType,
								stripQuotes(name.slice(index + attributeType.length))
							))
							noAttrMatch = false
							break
						}
					}
					if (noAttrMatch) this.attributes.push(new AttributeMatch(name, EXISTING))
					break
				case PSEUDOS: //TODO: :not()
					this.pseudos.push(name)
			}
		}
		let state: SelectorReadingState | null = TAG
		let name = ''
		let inQuotes = false
		for (let i = 0; i < selectorString.length; i++) {
			const char = selectorString[i]
			if (char === '\\') {
				name += selectorString[++i]
				continue
			}
			else if (char === '"') inQuotes = !inQuotes
			else if (inQuotes) {
				name += char
				continue
			}
			let segmentEnd = true
			let newState: SelectorReadingState | null
			if (char === '.') newState = CLASS
			else if (char === '#') newState = ID
			else if (char === '[') newState = ATTRIBUTES
			else if (char === ']') newState = null
			else if (char === ':') newState = PSEUDOS
			else {
				segmentEnd = false
				name += char
			}
			if (segmentEnd) {
				saveSegment()
				state = newState!
				name = ''
			}
		}
		saveSegment()
	}
	findMatches(dom: Children, recursive: boolean, matchSet: MatchSet) {
		if (recursive) {
			this.findMatches(dom, false, matchSet)
			for (const element of dom) {
				if (element instanceof HtmlTag) {
					this.findMatches(element.children, true, matchSet)
				}
			}
			return
		}

		for (const element of dom) {
			if (element instanceof HtmlTag) {
				this.match(dom, element, matchSet)
			}
		}
	}

	private match(dom: Children, element: HtmlTag, matchSet: MatchSet) {
		if (!(this.tagName === '*' || element.type.toLowerCase() === this.tagName)) {
			return
		}
		for (const className of this.classes) {
			if (!element.classes.has(className)) {
				return
			}
		}
		if (this.id !== undefined && element.attributes.id !== this.id) {
			return
		}
		for (const {attribute, matchType, value} of this.attributes) {
			const attributeValue = element.attributes[attribute]
			switch (matchType) {
				case EXISTING:
					if (attributeValue === undefined) return
					break
				case EQUALING:
					if (attributeValue !== value) return
					break
				case CONTAINING_WHOLE_WORD:
					const containingMatch = new RegExp('(?:^|\\s|-)' + regexEscape(value!) + '(?:\\s|-|$)')
					if (!(typeof attributeValue === 'string' && containingMatch.test(attributeValue))) return
					break
				case STARTING_WHOLE_WORD:
					const startingMatch = new RegExp('^' + regexEscape(value!) + '(?:\\s|-|$)')
					if (!(typeof attributeValue === 'string' && startingMatch.test(attributeValue))) return
					break
				case STARTING:
					if (!(typeof attributeValue === 'string' && attributeValue.startsWith(value!))) return
					break
				case ENDING:
					if (!(typeof attributeValue === 'string' && attributeValue.endsWith(value!))) return
					break
				case CONTAINING:
					if (!(typeof attributeValue === 'string' && attributeValue.includes(value!))) return
			}
		}
		for (let i = 0; i < this.pseudos.length; i++) {
			const pseudo = this.pseudos[i]
			let nthChildMatch: RegExpMatchArray | null = null,
				nthLastChildMatch: RegExpMatchArray | null,
				nthOfTypeMatch: RegExpMatchArray | null = null,
				nthLastOfTypeMatch: RegExpMatchArray | null
			if (pseudo === 'checked') {
				if (element.attributes.checked === undefined) return
			}
			else if (pseudo === 'disabled') {
				if (element.attributes.disabled === undefined) return
			}
			else if (pseudo === 'empty') {
				for (const child of element.children) {
					if (!(child instanceof TextNode && isWhiteSpace(child.text))) return
				}
			}
			else if (
				pseudo === 'first-child' ||
				pseudo === 'last-child' ||
				pseudo === 'only-child' ||
				(nthChildMatch = NTH_CHILD.exec(pseudo)) ||
				(nthLastChildMatch = NTH_LAST_CHILD.exec(pseudo))
			) {
				const {parent} = element
				if (!parent) {
					return
				}
				const siblings =
					parent.children.filter(child => child instanceof HtmlTag) as HtmlTag[]
				const match =
						pseudo === 'first-child' ? siblings[0] === element :
							pseudo === 'last-child' ? siblings[siblings.length - 1] === element :
								pseudo === 'only-child' ? siblings.length === 1 :
									nthChildMatch ? matchNth(nthChildMatch[1], siblings, element) :
								matchNth(nthLastChildMatch![1], siblings.slice().reverse(), element)
				if (!match) {
					return
				}
			}
			else if (
				pseudo === 'first-of-type' ||
				pseudo === 'last-of-type' ||
				pseudo === 'only-of-type' ||
				(nthOfTypeMatch = NTH_OF_TYPE.exec(pseudo)) ||
				(nthLastOfTypeMatch = NTH_LAST_OF_TYPE.exec(pseudo))
			) {
				const allMatches: MatchSet = []
				this.pseudos.splice(i, 1)
				this.findMatches(dom, false, allMatches)
				this.pseudos.splice(i, 0, pseudo)
				const firstMatch = () => {
					const [first] = allMatches
					return first
				}
				const lastMatch = () => {
					let match: HtmlTag | undefined
					for (match of allMatches);
					return match
				}
				const match =
						pseudo === 'first-of-type' ? element === firstMatch() :
							pseudo === 'last-of-type' ? element === lastMatch() :
								pseudo === 'only-of-type' ? element === firstMatch() && allMatches.length === 1 :
									nthOfTypeMatch ? matchNth(nthOfTypeMatch[1], [...allMatches], element) :
								matchNth(nthLastOfTypeMatch![1], [...allMatches].reverse(), element)
				if (!match) {
					return
				}
			}
			else if (pseudo === 'indeterminate') {
				switch (element.type) {
					case 'input':
						switch (element.attributes.type) {
							case 'checkbox':
								if (!('indeterminate' in element.attributes)) {
									return
								}
								break
							case 'radio':
								const thisName = element.attributes.name
								if (typeof thisName !== 'string') {
									return
								}
								const {parent} = element
								if (!parent) {
									return
								}
								for (const sibling of parent.children) {
									if (
										sibling instanceof HtmlTag &&
										sibling.type === 'input' &&
										sibling.attributes.type === 'radio' &&
										sibling.attributes.name === thisName &&
										sibling.attributes.checked !== undefined
									) {
										return
									}
								}
								break
							default:
								return
						}
						break
					case 'progress':
						if (element.attributes.value && element.attributes.max) {
							return
						}
						break
					default:
						return
				}
			}
			else if (pseudo === 'optional') {
				if ('required' in element.attributes) {
					return
				}
			}
			else if (pseudo === 'required') {
				if (!('required' in element.attributes)) {
					return
				}
			}
			else if (pseudo === 'root') {
				const {parent} = element
				if (!parent || parent.parent) {
					return
				}
			}
			else throw new Error(`Unknown pseudo-selector: "${pseudo}"`)
		}
		matchSet.push(element)
	}
}
class CommaSelector extends Selector {
	constructor(private readonly selectors: Selector[]) {
		super()
	}
	findMatches(dom: Children, recursive: boolean, matchSet: MatchSet) {
		for (const selector of this.selectors) selector.findMatches(dom, recursive, matchSet)
	}
}
class DescendantSelector extends Selector {
	constructor(private readonly ancestor: Selector, private readonly descendant: Selector) {
		super()
	}
	findMatches(dom: Children, recursive: boolean, matchSet: MatchSet) {
		const ancestorMatches: MatchSet = []
		this.ancestor.findMatches(dom, recursive, ancestorMatches)
		for (const ancestorMatch of ancestorMatches) {
			this.descendant.findMatches(ancestorMatch.children, true, matchSet)
		}
	}
}
class DirectDescendantSelector extends Selector {
	constructor(private readonly parent: Selector, private readonly child: Selector) {
		super()
	}
	findMatches(dom: Children, recursive: boolean, matchSet: MatchSet) {
		const parentMatches: MatchSet = []
		this.parent.findMatches(dom, recursive, parentMatches)
		for (const parentMatch of parentMatches) {
			this.child.findMatches(parentMatch.children, false, matchSet)
		}
	}
}
class AdjacentSelector extends Selector {
	constructor(private readonly before: Selector, private readonly after: Selector) {
		super()
	}
	findMatches(dom: Children, recursive: boolean, matchSet: MatchSet) {
		const beforeMatches: MatchSet = []
		this.before.findMatches(dom, recursive, beforeMatches)
		for (const beforeMatch of beforeMatches) {
			if (!beforeMatch.parent) continue
			const siblings = beforeMatch.parent.children
			const next = siblings[siblings.indexOf(beforeMatch) + 1]
			if (next === undefined) continue
			this.after.findMatches([next], false, matchSet)
		}
	}
}
class AfterSelector extends Selector {
	constructor(private readonly before: Selector, private readonly after: Selector) {
		super()
	}
	findMatches(dom: Children, recursive: boolean, matchSet: MatchSet) {
		const beforeMatches: MatchSet = []
		this.before.findMatches(dom, recursive, beforeMatches)
		for (const beforeMatch of beforeMatches) {
			const {parent} = beforeMatch
			if (!parent) continue

			const siblings = parent.children
			const afterSiblings = siblings.slice(siblings.indexOf(beforeMatch) + 1)
			this.after.findMatches(afterSiblings, false, matchSet)
		}
	}
}
function makeSelector(str: string): Selector {
	for (let i = 1; i + 1 < str.length; i++) {
		if (str[i] === ' ' && (isSeparator(str[i - 1]) || isSeparator(str[i + 1]))) {
			str = str.slice(0, i) + str.slice(i + 1)
			i--
		}
	}
	const selectors: Selector[] = []
	for (const selectorString of str.split(',')) {
		let selectorStart = 0
		const selectorPieces: {selector: Selector, separator: string}[] = []
		let insideParens = 0, insideQuotes = false
		for (let i = 0; i < selectorString.length; i++) {
			const char = selectorString[i]
			if (isSeparator(char) && !(insideParens || insideQuotes)) {
				selectorPieces.push({
					selector: new SingleSelector(selectorString.slice(selectorStart, i)),
					separator: char
				})
				selectorStart = i + 1
			}
			else if (selectorString[i] === '\\') i++
			else if (char === '"') insideQuotes = !insideQuotes
			else if (!insideQuotes) {
				if (char === '[' || char === '(') insideParens++
				else if (char === ']' || char === ')') insideParens--
			}
		}
		let selector: Selector = new SingleSelector(selectorString.slice(selectorStart))
		for (let i = selectorPieces.length - 1; i >= 0; i--) { //build selector from right to left
			const selectorPiece = selectorPieces[i]
			switch (selectorPiece.separator) {
				case ' ':
					selector = new DescendantSelector(selectorPiece.selector, selector)
					break
				case '>':
					selector = new DirectDescendantSelector(selectorPiece.selector, selector)
					break
				case '+':
					selector = new AdjacentSelector(selectorPiece.selector, selector)
					break
				case '~':
					selector = new AfterSelector(selectorPiece.selector, selector)
			}
		}
		selectors.push(selector)
	}
	return new CommaSelector(selectors)
}

export function select(dom: AnyNode, selectorString: string): HtmlTag[] {
	if (!(dom instanceof Array)) dom = [dom]
	const selector = makeSelector(selectorString)
	const matches: MatchSet = []
	selector.findMatches(dom, true, matches)
	return matches
}

export function selectFirst(dom: AnyNode, selectorString: string): HtmlTag {
	const results: MatchSet = select(dom, selectorString)
	if (results.length > 0) {
		return results[0]
	}
	return null
}

export function textContent(dom: AnyNode): string {
	if (dom instanceof HtmlTag) {
		return dom.textContent
	} else if (dom instanceof TextNode) {
		return dom.text
	}
	return '';
}

export function selectTextContent(dom: AnyNode, selectorString: string): string {
	const results: HtmlTag = selectFirst(dom, selectorString)
	if (results) {
		return results.textContent
	}
	return '';
}

export function selectAttributeValue(dom: AnyNode, selectorString: string, name: string): string {
	const results: HtmlTag = selectFirst(dom, selectorString)
	if (results) {
		return results.attr(name)
	}
	return '';
}

export function selectInnerHtml(dom: AnyNode): string {
	if (dom instanceof HtmlTag) {
		return dom.innerHtml()
	} else if (dom instanceof TextNode) {
		return dom.text
	}
	return '';
}