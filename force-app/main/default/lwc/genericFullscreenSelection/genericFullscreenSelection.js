import { LightningElement, api, wire } from 'lwc';
import ALL from "@salesforce/label/c.FILTER_ALL_LABEL";
import lang from '@salesforce/i18n/lang';

export default class GenericFullscreenSelection extends LightningElement {
    _options = [];
    _selected;
    isVisible = false;
    lastScrollTop = 0;
    get selected() {
        return this._selected;
    }
    set selected(value) {
        if (value) {
            this._selected = value;
            const selectedEvent = new CustomEvent('select', { detail: this.selected.split(",") });
            this.dispatchEvent(selectedEvent);
        } else {
            this._selected = undefined;
        }
    }

    @api hasIcons = false;

    //[{value:'',label:''}]
    @api get options() {
        return this._options;
    };

    set options(value) {
        if (value) {
            this._options = value;
        } else {
            this._options = [];
        }
    }
    @api addAll = false;

    language = lang;

    get isEnglish() {
        return this.language !== 'ar';
    }

    get availableOptions() {
        let result = this._options.map(option => {
            let optionSelected = this.selected && this.selected === option.value;
            let float = this.isEnglish ? "float-start" : "float-end";
            return {
                ...option,
                isSelected: optionSelected,
                cls: optionSelected ? "text-decoration-none fw-bold " + float + " text-uppercase" : "text-decoration-none " + float + " text-uppercase"
            };
        });
        let allValue = this._options.map(option => option.value).toString();
        let isAllSelected = !this.selected || this.selected === allValue;
        let float = this.isEnglish ? "float-start" : "float-end";
        if (this.addAll) {
            result.unshift({
                value: allValue,
                label: ALL,
                isSelected: isAllSelected,
                cls: isAllSelected ? "text-decoration-none fw-bold " + float + " text-uppercase" : "text-decoration-none " + float + " text-uppercase"
            });
            if (!this.selected) {
                this.selected = allValue;
            }
        }
        return result;
    }

    handleSelectionChange(event) {
        event.preventDefault();
        this.selected = event.currentTarget.dataset.value;
        this.toggle();
    }

    @api toggle() {
        this.isVisible = !this.isVisible;
    }

    get containerCls() {
        return this.isVisible ? "position-fixed bg-override container-fluid p-0 fixed-top  text-white h-100 d-block" :
            "position-fixed container-fluid p-0 fixed-top  text-white h-100 d-none";
    }

    handleImageError(el) {
        var element = el;
        element.remove();
    }

    get imageCls() {
        return this.isEnglish ? "float-end pad-ajust-cls" : "float-start pad-ajust-cls";
    }
}