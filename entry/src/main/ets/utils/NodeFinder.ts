import Logger from './Logger';
import { NodeWithChildren, AnyNode } from "domhandler";
import * as DomUtils from 'domutils'

/**
 * 查找对应的Dom元素
 */
export class NodeFinder {
    nextFinder: NodeFinder;
    isOnlyChild: boolean = false;
    nextToFindOnlyChild: boolean = false;

    isTarget(parent: NodeWithChildren, child: AnyNode): boolean {
        throw new Error("You must override this method!");
    }
}

/**
 * 根元素查找器
 */
export class RootNodeFinder extends NodeFinder {
    public find(node: AnyNode, limit: number = -1): AnyNode[] {
        let results: AnyNode[] = [];
        if (!node) {
            return results;
        }

        if (this.nextFinder.isTarget(node.parent, node)) {
            results.push(node);
        }

        if (limit > 0 && results.length == limit) {
            return results;
        }

        if (DomUtils.hasChildren(node)) {
            this.nextFinder.isOnlyChild = this.nextToFindOnlyChild;
            this.findNodes(this.nextFinder, node, limit, results);
        }
        return results;
    }

    public findFirst(parent: AnyNode): AnyNode {
        let results = this.find(parent, 1);
        if (results.length == 1) {
            return results[0];
        }
        return null;
    }

    findNodes(finder: NodeFinder, parent: NodeWithChildren, limit: number, results: AnyNode[]) {
        if (results.length == limit) {
            return;
        }
        // TODO nth-child是并列关系
        if (finder instanceof NthChildNodeFinder) {
            if (finder.index < parent.childNodes.length) {
                let value = parent.childNodes[finder.index]
                if (finder.nextFinder) {
                    if (DomUtils.hasChildren(value)) {
                        finder.nextFinder.isOnlyChild = finder.nextToFindOnlyChild;
                        this.findNodes(finder.nextFinder, value, limit, results);
                    }
                } else {
                    results.push(value);
                }
            }
            return
        }
        for (let value of parent.childNodes) {
            if (results.length == limit) {
                break;
            }
            if (finder.isTarget(parent, value)) {
                if (finder.nextFinder) {
                    if (DomUtils.hasChildren(value)) {
                        finder.nextFinder.isOnlyChild = finder.nextToFindOnlyChild;
                        this.findNodes(finder.nextFinder, value, limit, results);
                    }
                } else {
                    results.push(value);
                }
            }
            if (finder.isOnlyChild) {
                continue;
            }
            if (DomUtils.hasChildren(value)) {
                this.findNodes(finder, value, limit, results);
            }
        }
    }

    isTarget(parent: NodeWithChildren, child: AnyNode): boolean {
        return true;
    }
}

/**
 * 组合查找器，将多个NodeFinder组合在一起
 */
export class CombineNodeFinder extends NodeFinder {
    protected finders: NodeFinder[] = [];

    combine(finder: NodeFinder) {
        this.finders.push(finder);
    }
}

/**
 * 与逻辑组合查找器
 */
export class AndNodeFinder extends CombineNodeFinder {
    isTarget(parent: NodeWithChildren, child: AnyNode): boolean {
        for (let finder of this.finders) {
            if (!finder.isTarget(parent, child)) {
                return false;
            }
        }
        return true;
    }
}

/**
 * 或逻辑组合查找器
 */
export class OrNodeFinder extends CombineNodeFinder {
    combine(finder: NodeFinder) {
        if (finder instanceof NthChildNodeFinder) {
            let last = this.finders[this.finders.length - 1]
            if (last instanceof CombineNodeFinder) {
                last.combine(finder);
            } else {
                let combineFinder = new AndNodeFinder();
                combineFinder.combine(last);
                combineFinder.combine(finder);
                this.finders[this.finders.length - 1] = combineFinder;
            }
            return
        }
        super.combine(finder);
    }

    isTarget(parent: NodeWithChildren, child: AnyNode): boolean {
        for (let finder of this.finders) {
            if (finder.isTarget(parent, child)) {
                return true;
            }
        }
        return false;
    }
}

/**
 * 根据类属性查找元素
 */
export class ClassNodeFinder extends NodeFinder {
    private className: string;

    constructor(className: string) {
        super();
        this.className = className;
    }

    isTarget(parent: NodeWithChildren, child: AnyNode): boolean {
        if (DomUtils.isTag(child)) {
            let classes = DomUtils.getAttributeValue(child, "class");
            if (!classes || !classes.includes(this.className)) {
                return false;
            }
            return true;
        }
        return false;
    }
}

/**
 * 根据id属性查找元素
 */
export class IdNodeFinder extends NodeFinder {
    private id: string = null;

    constructor(id: string) {
        super();
        this.id = id;
    }

    isTarget(parent: NodeWithChildren, child: AnyNode): boolean {
        if (DomUtils.isTag(child)) {
            let id = DomUtils.getAttributeValue(child, "id");
            return this.id === id;
        }
        return false;
    }
}

/**
 * 根据元素tag查找元素
 */
export class TagNodeFinder extends NodeFinder {
    private tag: string = null;

    constructor(tag: string) {
        super();
        this.tag = tag;
    }

    isTarget(parent: NodeWithChildren, child: AnyNode): boolean {
        return DomUtils.isTag(child) && this.tag === child.tagName;
    }
}

/**
 * 根据nth-child查找元素
 */
export class NthChildNodeFinder extends NodeFinder {
    readonly index: number = 0;

    constructor(index: number) {
        super();
        this.index = index;
    }

    isTarget(parent: NodeWithChildren, child: AnyNode): boolean {
        if (this.index < parent.childNodes.length) {
            return parent.childNodes[this.index] == child;
        }
        return false;
    }
}