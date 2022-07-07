public class FeedItemTriggerHelper {
    public static void sendFeedItemEmail(list <FeedItem> feedItemsList){
        
        List<String> groupId = new List<String>();
        String feedBody;

        for (FeedItem feed : feedItemsList){
            
            groupId.add(feed.ParentId);
            feedBody = feed.Body;
            feedbody = feedBody?.substringAfter('>');
            feedbody = feedBody?.substringBefore('<');
        }
        
        List <CollaborationGroupMember> collaborationGroupMembersList = [SELECT Member.Contact.Additional_Email__c
                                                                         FROM CollaborationGroupMember
                                                                         WHERE CollaborationGroupId IN: groupId
                                                                         AND CollaborationRole != 'Admin'
                                                                         AND CollaborationGroupMember.Member.Contact.Additional_Email__c != null];
        List<String> groupMembersEamilsList = new List<String>();
        
        if(!collaborationGroupMembersList.isEmpty()){
            for(CollaborationGroupMember collaborationGroupMemb : collaborationGroupMembersList){
                groupMembersEamilsList.add(collaborationGroupMemb.Member.Contact.Additional_Email__c);
            }
        }
        
        if(!groupMembersEamilsList.isEmpty()){
            sendAdditionalEmail(groupMembersEamilsList, feedbody);
        }
    }
    
    private static void sendAdditionalEmail (List <String> emailsList, String feedbody){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        String[] toAddresses = emailsList;
        email.setSenderDisplayName(Label.B2B_Additional_Email_Sender_Name);
        email.subject = Label.B2B_Additional_Email_Subject;
        email.setToAddresses(toAddresses);
        email.setHtmlBody(Label.B2B_Additional_Email_Part_1+feedbody+Label.B2B_Additional_Email_Part_2);
        
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
    
}