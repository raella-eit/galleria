import { LightningElement } from 'lwc';

export default class ChatWrapper extends LightningElement {
    chatClick() {
        if (this.template.querySelectorAll('.outter-wrapper')[0]) {
            let chatEvent = new CustomEvent(
                        'chatEvent',
                        {
                            detail: {
                                startChat: true
                            },
                            bubbles: true,
                            cancelable: true
                        }
                    );
            this.template.querySelectorAll('.outter-wrapper')[0].dispatchEvent(chatEvent);
        }
    }
}