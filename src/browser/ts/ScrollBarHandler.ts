export class ScrollbarHandler {
    private _cachedWidth = 0;
    private readonly _element: HTMLElement;
    private readonly _scrollArea: HTMLElement | null;
    private readonly _sidebar: HTMLElement | null;
    private readonly _originalMinWidth: number;
    private _adjustment_scheduled = false;

    constructor(element: HTMLElement) {
        this._element = element;
        this._scrollArea = this._element?.parentElement;
        this._sidebar = document.getElementById('sidebar');
        const style = globalThis.getComputedStyle(this._element);
        // Note: assumes values were set in pixels
        this._originalMinWidth = Number.parseInt(style.getPropertyValue('min-width')) || 0;
        window.addEventListener('resize', this.adjust.bind(this), true);
        if (this._scrollArea && this._sidebar)
            this._scrollArea.addEventListener('scroll', this.adjust.bind(this), true);
    }

    /**
     * registerCenteredElement
     */
    static registerCenteredElement(el: HTMLElement) {
        const centeredElement = new ScrollbarHandler(el);
        centeredElement.adjust();
    }
    /**
     * get
     */
    public get scrollbarWidth() {
        if (this._cachedWidth)
            return this._cachedWidth;
        const element = document.createElement('div');
        element.style.position = 'absolute';
        element.style.left = '-1000px';
        element.style.width = '200px';
        element.style.height = '200px';
        element.style.overflow = 'auto';
        const subElement = document.createElement('div');
        subElement.style.height = '500px';
        element.appendChild(subElement);
        document.body.appendChild(element);
        const width = element.getBoundingClientRect().width;
        const inner_width = subElement.getBoundingClientRect().width;
        element.remove();
        this._cachedWidth = width - inner_width;
        return this._cachedWidth;
    }

    private adjust(): void {
        if (!this._element?.style || this._adjustment_scheduled)
            return;

        this._adjustment_scheduled = true;
        globalThis.requestAnimationFrame(this.actual_adjust_bound);
    }

    private get actual_adjust_bound() {
        return this.actual_adjust.bind(this);
    }

    private actual_adjust() {
        this._adjustment_scheduled = false;
        const availableWidth = window.innerWidth - this.scrollbarWidth;
        const elementWidth = this._element.getBoundingClientRect().width;
        this._element.style.marginInlineStart = Math.max(0, Math.floor((availableWidth - elementWidth) / 2)) + 'px';

        if (this._sidebar && this._scrollArea) {
            if (document.documentElement.dir === 'rtl')
                this._sidebar.style.marginInlineStart = this._scrollArea?.clientWidth +
                    this._scrollArea?.scrollLeft - this._scrollArea?.scrollWidth + 'px';
            else
                this._sidebar.style.marginInlineStart = -1 * this._scrollArea.scrollLeft + 'px';

            this._sidebar.style.bottom = this._scrollArea.clientWidth < this._originalMinWidth ?
                this.scrollbarWidth + 'px' : '';
        }
    }

    public isRegistered() {
        return this._element !== null;
    }

}
