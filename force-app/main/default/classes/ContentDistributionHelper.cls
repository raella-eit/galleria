public without sharing class ContentDistributionHelper {
    /**
     * @description Retrieves the content distribution entries for a given set of content versions
     * @author enassif-ext@dlpk.fr | 09-29-2021
     * @param contentVersionIdSet
     * @return List<ContentDistribution>
     **/
    public static List<ContentDistribution> getContentDistributionList(Set<Id> contentVersionIdSet){
        return [SELECT ContentDownloadUrl, ContentVersionId,ContentDocumentId
                FROM ContentDistribution
                WHERE ContentVersionId = : contentVersionIdSet];
    }
}