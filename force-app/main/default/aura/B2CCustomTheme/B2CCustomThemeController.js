({
    init: function (cmp, evt, hlp) {
        var profileSectionVisible = $A.get("$SObjectType.CurrentUser.Id") ? true : false;
        cmp.set("v.profileSectionVisible", profileSectionVisible);
        cmp.set("v.language",$A.get("$Locale.language"));

    },
    handleRouteChange: function (cmp, evt, hlp) {
        document.getElementById('main').scrollTop = 0;
        cmp.set("v.searchIsVisible", true);
        cmp.set('v.searchBarIsVisible', false);
    },
    searchHandler: function (cmp, evt, hlp) {
        var searchBarIsVisible = cmp.get("v.searchBarIsVisible");
        cmp.set('v.searchBarIsVisible', !searchBarIsVisible);
    },
    gotoURL: function (cmp, evt, hlp) {

        var url = window.location.href;
        url = url.substring(0, url.indexOf('/s/') + 3);
        var urlEvent = $A.get("e.force:navigateToURL");

        var searchBarIsVisible = cmp.get("v.searchBarIsVisible");
        if (searchBarIsVisible) cmp.set('v.searchBarIsVisible', !searchBarIsVisible);

        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
        var a = cmp.get('c.closeMap');
        $A.enqueueAction(a);
    },
    // Permet de fermer le bandeau d'information
    closeSMSInfo: function (cmp, event, helper) {
        cmp.set('v.isDisplayedSMSInfo', false);
    },
    mapit: function(cmp,event,helper){
        document.getElementById("22map").contentWindow.postMessage(event.detail.messageObj,"*");
        document.getElementsByClassName("iframe")[0].classList=["iframe vivify driveInTop"];
    },
    closeMap:function(cmp,event,helper){
        document.getElementsByClassName("iframe")[0].classList =["iframe vivify driveOutBottom iframe-hide"];

    }
})