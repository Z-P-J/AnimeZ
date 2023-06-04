
/**
 * 多选监听者
 */
export interface OnSelectChangeObserver<T> {

    /**
     * 进入或退出选择模式
     */
    onSelectionModeChange(isSelectionMode: boolean): void

    /**
     * 选中或取消选中
     */
    onSelectChange(item: T, isSelect: boolean): void

}

/**
 * 多选管理器
 */
export class SelectionManager <T> {
    private selectionMode: boolean = false;
    private observers: OnSelectChangeObserver<T>[] = null
    private readonly selectionSet: Set<T> = new Set<T>()

    toggleSelectionMode() {
        this.clearSelections()
        this.selectionMode = !this.selectionMode
        if (this.observers) {
            this.observers.forEach((o) => {
                o.onSelectionModeChange(this.selectionMode)
            })
        }
    }

    isSelectionMode(): boolean {
        return this.selectionMode
    }

    selectItem(item: T): boolean {
        if (this.selectionSet.has(item)) {
            return false
        }
        this.selectionSet.add(item)
        this.notifySelectionChange(item, true)
        return true
    }

    selectItems(items: T[]) {
        items.forEach((item) => {
            this.selectItem(item)
        })
    }

    unselectItems(items: T[]) {
        items.forEach((item) => {
            this.unselectItem(item)
        })
    }

    unselectItem(item: T): boolean {
        if (this.selectionSet.has(item)) {
            if (this.selectionSet.delete(item)) {
                this.notifySelectionChange(item, false)
                return true;
            }
        }
        return false
    }

    clearSelections() {
        if (this.selectionSet.size > 0) {
            this.selectionSet.forEach((item) => {
                this.unselectItem(item)
            })
            this.selectionSet.clear()
        }
    }

    toggleSelectItem(item: T) {

        if (this.selectItem(item)) {
            return
        }
        this.unselectItem(item)

        //    if (this.selectionSet.has(item)) {
        //      this.selectionSet.delete(item)
        //      this.notifySelectionChange(item, false)
        //    } else {
        //      this.selectionSet.add(item)
        //      this.notifySelectionChange(item, true)
        //    }
    }

    private notifySelectionChange(item: T, isSelect: boolean) {
        if (this.observers) {
            this.observers.forEach((o) => {
                o.onSelectChange(item, isSelect)
            })
        }
    }

    isSelect(item: T): boolean {
        return this.selectionSet.has(item)
    }

    getSelections(): Set<T> {
        return this.selectionSet
    }

    getSelectionCount(): number {
        return this.selectionSet.size
    }

    addObserver(observer: OnSelectChangeObserver<T>) {
        if (!this.observers) {
            this.observers = []
        }
        this.observers.push(observer)
    }

    removeObserver(observer: OnSelectChangeObserver<T>): boolean {
        if (this.observers) {
            let index = this.observers.indexOf(observer);
            if (index >= 0) {
                this.observers.splice(index, 1);
                if (this.observers.length == 0) {
                    this.observers = null;
                }
                return true;
            }
        }
        return false;
    }
}