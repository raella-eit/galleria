/* eslint no-console: ["error", { allow: ["error"] }] */
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const showToast = (title, message, variant, component, mode = "dismissable") => {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        mode: mode
    });
    component.dispatchEvent(event);
};

const handleError = errorBody => {
    let exceptionMessage;
    if (Array.isArray(errorBody)) {
        exceptionMessage = errorBody.map(e => e.message).join(", ");
    } else if (typeof errorBody === "string") {
        exceptionMessage = errorBody;
    } else if (typeof errorBody.message === "string") {
        exceptionMessage = errorBody.message;
    }
    console.error("An error occurred : " + exceptionMessage);
};

const format = (stringToFormat, ...formattingArguments) => {
    if (typeof stringToFormat !== 'string') throw new Error('\'stringToFormat\' must be a String');
    return stringToFormat.replace(/{(\d+)}/gm, (match, index) =>
        (formattingArguments[index] === undefined ? '' : `${formattingArguments[index]}`));
}

export {
    showToast,
    handleError,
    format
};