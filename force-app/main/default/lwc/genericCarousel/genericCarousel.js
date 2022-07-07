import { LightningElement, api, track } from 'lwc';

export default class GenericCarousel extends LightningElement {
    @api buttonLabel
    @track carouselButtonList = [];
    touchstart;
    currentImageIndex = 0;
    @api get itemList() {
        this._itemList;
    }
    set itemList(value) {
        if (value) {
            this._itemList = value;
        } else {
            this._itemList = [];
            this.carouselButtonList = [];
        }

        if (this._itemList.length > 0) {
            this._itemList.forEach(item => {
                this.carouselButtonList.push({
                    id: item.id,
                    cls: "carousel-btn col"
                });
            });
            this.setVisibleItem(this._itemList[0].id, true);
        }
    }

    handleIndicatorClick(event) {
        //TODO navigate to proper item, set classes
    }

    setVisibleItem(id, left) {
        let popInCls = left ? "popInLeft" : "popInRight";
        let popOutCls = left ? "popOutRight" : "popOutLeft";
        this._itemList = this._itemList.map(item => {
            return {
                ...item,
                cls: item.id === id ? "carousel-item active vivify " + popInCls : "carousel-item vivify " + popOutCls
            };
        });
        this.carouselButtonList = this.carouselButtonList.map(button => {
            return {
                ...button,
                cls: button.id === id ? "carousel-btn col active" : "carousel-btn col"
            };
        });
    }

    startTouch(event) {
        if (event.touches.length === 1) {
            //just one finger touched
            this.touchstart = event.touches.item(0).clientX;
        } else {
            //a second finger hit the screen, abort the touch
            this.touchstart = null;
        }
    }
    endTouch(event) {
        var offset = 100;//at least 100px are a swipe
        var left = false;
        if (this.touchstart) {
            //the only finger that hit the screen left it
            var end = event.changedTouches.item(0).clientX;
            if (end > this.touchstart + offset) {
                if (this.currentImageIndex > 0) {
                    this.currentImageIndex--;
                    left = true;
                    this.setVisibleItem(this._itemList[this.currentImageIndex].id, left);
                }
            }
            if (end < this.touchstart - offset) {
                if (this.currentImageIndex < this._itemList.length - 1) {
                    this.currentImageIndex++;
                    left = false;
                    this.setVisibleItem(this._itemList[this.currentImageIndex].id, left);
                }
            }

        }
    }

    next(event){
        event.preventDefault();
        event.stopPropagation();
        if (this.currentImageIndex < this._itemList.length - 1) {
            this.currentImageIndex++;
            this.setVisibleItem(this._itemList[this.currentImageIndex].id, false);
        }
    }

    previous(event){
        event.preventDefault();
        event.stopPropagation();
        if (this.currentImageIndex > 0) {
            this.currentImageIndex--;
            this.setVisibleItem(this._itemList[this.currentImageIndex].id, true);
        }
    }

    handleRedirect(event) {
        this.dispatchEvent(new CustomEvent('redirect', {
            detail: {
                type: event.target.dataset.type,
                id: event.target.dataset.item
            }}));
    }
}