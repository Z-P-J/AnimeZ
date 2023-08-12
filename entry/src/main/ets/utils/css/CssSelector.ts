import Logger from '../Logger';
import { OrNodeFinder } from './NodeFinder';
import { AndNodeFinder } from './NodeFinder';
import { CombineNodeFinder } from './NodeFinder';
import { TagNodeFinder } from './NodeFinder';
import { ClassNodeFinder } from './NodeFinder';
import { IdNodeFinder } from './NodeFinder';
import { NodeFinder, RootNodeFinder, NthChildNodeFinder } from './NodeFinder';
import { AnyNode, Element } from "domhandler";
import * as DomUtils from 'domutils'
import { DomSerializerOptions } from "dom-serializer";

/**
 * 通过css选择器查找html中的dom元素
 * TODO 目前只支持部分选择器，待完善。
 */
export class CssSelector {
    private selector: string;
    private len: number;
    private pos: number = 0;

    private rootFinder: RootNodeFinder = new RootNodeFinder();

    private constructor(selector: string) {
        this.selector = selector;
        this.len = selector.length;
        this.pos = 0;
        this.parse();
    }

    /**
     * 解析选择器字符串为多个NodeFinder，多个NodeFinder组成了一条链表结构，
     * 每当一个NodeFinder查找到对应的Node，会通过nextFinder查找下一个对应的Node，
     * 直到最后一个NodeFinder查找到对应的Node，即为我们根据选择器想要解析获取的dom元素
     */
    private parse() {
        let parentFinder: NodeFinder = this.rootFinder;
        let currentFinder: NodeFinder = this.rootFinder;

        let isOnlyChild: boolean = false;

        let finder: NodeFinder = null;
        while (this.pos < this.len) {
            this.skipWhitespace();
            let ch = this.selector.charAt(this.pos);
            if (ch == '#') {
                ++this.pos;
                let token = this.nextToken();

                if (finder) {
                    if (finder instanceof CombineNodeFinder) {
                        finder.combine(new IdNodeFinder(token));
                    } else {
                        let combineFinder = new AndNodeFinder();
                        combineFinder.combine(finder);
                        combineFinder.combine(new IdNodeFinder(token));
                        finder = combineFinder;
                    }
                } else {
                    finder = new IdNodeFinder(token);
                }
            } else if (ch == '.') {
                ++this.pos;
                let token = this.nextToken();
                if (finder) {
                    if (finder instanceof CombineNodeFinder) {
                        finder.combine(new ClassNodeFinder(token));
                    } else {
                        let combineFinder = new AndNodeFinder();
                        combineFinder.combine(finder);
                        combineFinder.combine(new ClassNodeFinder(token));
                        finder = combineFinder;
                    }
                } else {
                    finder = new ClassNodeFinder(token);
                }
            } else if (ch == '>') {
                ++this.pos;
                isOnlyChild = true;
            } else if (ch == ',') {
                ++this.pos;
                if (finder) {
                    if (!(finder instanceof OrNodeFinder)) {
                        let combineFinder = new OrNodeFinder();
                        combineFinder.combine(finder);
                        finder = combineFinder;
                    }
                } else {
                    let combineFinder = new OrNodeFinder();
                    combineFinder.combine(currentFinder);
                    parentFinder.nextFinder = combineFinder;
                    currentFinder = combineFinder;
                }
            } else if (ch == ':') {
                ++this.pos;
                let token = this.nextToken();
                Logger.e(this, 'parse token=' + token)
                if (token.startsWith('nth-child')) {
                    let index = parseInt(token.substring(token.indexOf('(') + 1, token.indexOf(')'))) - 1
                    Logger.e(this, 'parse index=' + index + " finder=" + JSON.stringify(finder))
                    if (finder) {
                        if (finder instanceof CombineNodeFinder) {
                            finder.combine(new NthChildNodeFinder(index))
                        } else {
                            let combineFinder = new AndNodeFinder();
                            combineFinder.combine(finder);
                            combineFinder.combine(new NthChildNodeFinder(index));
                            finder = combineFinder;
                        }
                    } else {
                        finder = new NthChildNodeFinder(index)
                    }
                } else {
                    throw new Error("no support token: " + token);
                }
            } else if (ch == '+' || ch == '~') {
                // TODO 支持更多的css选择器
                throw new Error("no support char: " + ch);
            } else {
                let token = this.nextToken();
                if (finder) {
                    throw new Error("parse failed at " + this.pos);
                }
                finder = new TagNodeFinder(token)
            }

            if (this.pos < this.len) {
                ch = this.selector.charAt(this.pos);
            } else {
                ch = ' ';
            }
            if ((ch == ' ' || isOnlyChild) && finder) {
                parentFinder = currentFinder;
                currentFinder.nextFinder = finder;
                currentFinder = finder;
                finder = null;
            }
            if (isOnlyChild) {
                currentFinder.nextToFindOnlyChild = true;
                isOnlyChild = false;
            }
        }
        Logger.e(this, 'parse finish! selector=' + this.selector)
    }

    /**
     * 跳过空白符号
     */
    private skipWhitespace() {
        while (this.pos < this.len) {
            if (this.selector.charAt(this.pos) === ' ') {
                ++this.pos;
            } else {
                break;
            }
        }
    }

    /**
     * 解析下一个NodeFinder
     */
    private nextFinder() {
        // TODO
    }

    /**
     * 解析token字符串，即选择器字符串中除了一些特殊字符外的字符串，比如class属性名称、id属性名称、tag名称等
     */
    private nextToken(): string {
        let start = this.pos;
        while (this.pos < this.len) {
            let ch = this.selector.charAt(this.pos);
            if (ch == ' ' || ch == '>' || ch == '.' || ch == '#' || ch == ',' || ch == ':' || ch == '+' || ch == '~') {
                break;
            }
            ++this.pos;
        }
        return this.selector.substring(start, this.pos);
    }

    /**
     * 根据选择器和数量限制查找符合条件的元素
     * @param node
     * @param selector
     * @param limit
     */
    public static find(node: AnyNode, selector: string, limit: number = -1): AnyNode[] {
        let css = new CssSelector(selector);
        return css.rootFinder.find(node, limit);
    }

    /**
     * 根据选择器查找第一个符合条件的元素
     * @param node
     * @param selector
     */
    public static findFirst(node: AnyNode, selector: string): AnyNode {
        let css = new CssSelector(selector);
        return css.rootFinder.findFirst(node);
    }

    public static selectTextContent(root: AnyNode, selector: string): string {
        const node = this.findFirst(root, selector)
        if (node) {
            return DomUtils.textContent(node)
        } else {
            return null
        }
    }

    public static selectAttributeValue(root: AnyNode, selector: string, name: string): string | undefined {
        const node = this.findFirst(root, selector)
        return this.getAttributeValue(node, name)
    }

    public static textContent(node: AnyNode | AnyNode[]): string {
        if (node) {
            return DomUtils.textContent(node)
        } else {
            return null
        }
    }

    public static getAttributeValue(node: AnyNode, name: string): string | undefined {
        if (node && DomUtils.isTag(node)) {
            return DomUtils.getAttributeValue(node, name)
        }
        return null
    }

    public static getInnerHTML(node: AnyNode, options?: DomSerializerOptions): string {
        if (node) {
            return DomUtils.getInnerHTML(node)
        }
        return null
    }

    public static getOuterHTML(node: AnyNode, options?: DomSerializerOptions): string {
        if (node) {
            return DomUtils.getOuterHTML(node)
        }
        return null
    }
}