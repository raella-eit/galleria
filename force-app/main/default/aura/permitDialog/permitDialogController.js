({
    doInit: function(component, event, helper) {
        //get record type Id
        component.set("v.selectedRecordId", component.get("v.pageReference").state.recordTypeId);
        //get object api name
        component.set("v.objectApiName", component.get("v.pageReference").attributes.objectApiName);
    }
})