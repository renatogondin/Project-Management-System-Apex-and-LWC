trigger MilestoneTrigger on Milestone__c (after insert, after update, after delete, after undelete) {
    Set<Id> projectIds = new Set<Id>();
    
    
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        for (Milestone__c milestone : Trigger.new) {
            projectIds.add(milestone.Project__c);
        }
    }
    
    if (Trigger.isUpdate || Trigger.isDelete) {
        for (Milestone__c milestone : Trigger.isDelete ? Trigger.old : Trigger.new) {
            projectIds.add(milestone.Project__c);
        }
    }
    
    
    if (!projectIds.isEmpty()) {
        ProjectManagementUtility.updateProjectCompletionPercentages(projectIds);
    }
}