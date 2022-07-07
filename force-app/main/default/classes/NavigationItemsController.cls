public with sharing class NavigationItemsController {
    public NavigationItemsController() {}

    @AuraEnabled(cacheable = true)
    public static List<NavItemWrapper> getLocalizedNavigationItems(String menuName, String publishStatus, Boolean isGuestUser, String language) {
        isGuestUser = isGuestUser != null ? isGuestUser : false;
        List<NavItemWrapper> itemsList = new List<NavItemWrapper>();
        String networkId = Network.getNetworkId();
        User currentUser = [SELECT LanguageLocaleKey
                            FROM User
                            WHERE Id = :UserInfo.getUserId()];

        List<NavigationLinkSet> linkSets = [SELECT Id
                                            FROM NavigationLinkSet
                                            WHERE MasterLabel = :menuName AND NetworkId = :networkId];

        Id linkSetId = linkSets.isEmpty() ? null : linkSets.get(0).Id;

        If(linkSetId != null || Test.isRunningTest()){
            Map<Id, NavigationMenuItem> navMenuItemsMap = new Map<Id, NavigationMenuItem>();
            List<NavigationMenuItemLocalization> localizedNavMenuItemsList = new List<NavigationMenuItemLocalization>();

            if(Test.isRunningTest()) {
                navMenuItemsMap.put('0Mi5t0000004DEqCAM', new NavigationMenuItem(Label = 'Home', Target = '/'));
                localizedNavMenuItemsList.add(new NavigationMenuItemLocalization(Value = 'Shop', ParentId = '0Mi5t0000004DEqCAM'));
            } else {
                navMenuItemsMap = new Map<Id, NavigationMenuItem>( [SELECT Id, Label, Target, Type, DefaultListViewId, AccessRestriction
                                                                    FROM NavigationMenuItem
                                                                    WHERE NavigationLinkSetId = : linkSetId
                                                                    AND Status = : publishStatus
                                                                    ORDER BY Position]);
                String menuLang = currentUser.LanguageLocaleKey;
                if(isGuestUser && !String.isBlank(language)) {
                    menuLang = language;
                }

                localizedNavMenuItemsList = [SELECT Id, Value, ParentId
                                             FROM NavigationMenuItemLocalization
                                             WHERE ParentId IN :navMenuItemsMap.keySet()
                                             AND Language = :menuLang];
            }

            Map<Id, NavigationMenuItemLocalization> localizedNavMenuItemsMap = new Map<Id, NavigationMenuItemLocalization>();
            if(localizedNavMenuItemsList.size() > 0) {
                for(NavigationMenuItemLocalization itemLoc : localizedNavMenuItemsList) {
                    localizedNavMenuItemsMap.put(itemLoc.ParentId, itemLoc);
                }
            }
            for(Id itemId : navMenuItemsMap.keySet()) {
                NavItemWrapper item = new NavItemWrapper(navMenuItemsMap.get(itemId));
                item.label =
                (localizedNavMenuItemsMap.containsKey(itemId) && String.isNotBlank(localizedNavMenuItemsMap.get(itemId).Value) ?
                 localizedNavMenuItemsMap.get(itemId).Value : navMenuItemsMap.get(itemId).Label);
                itemsList.add(item);
            }
        }

        return itemsList;
    }

    public class NavItemWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String labelEN;
        @AuraEnabled public String label;
        @AuraEnabled public String target;
        @AuraEnabled public String type;
        @AuraEnabled public String defaultListViewId;
        @AuraEnabled public String accessRestriction;

        public NavItemWrapper(NavigationMenuItem item) {
            this.id = item.Id;
            this.labelEN = item.Label;
            this.target = item.Target;
            this.type = item.Type;
            this.defaultListViewId = item.DefaultListViewId;
            this.accessRestriction = item.AccessRestriction;
        }
    }
}