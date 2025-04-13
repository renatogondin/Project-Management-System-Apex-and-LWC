trigger TodoTrigger on Todo__c (after insert, after update, after delete, after undelete) {
    Set<Id> milestoneIds = new Set<Id>();
    
    
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        for (Todo__c todo : Trigger.new) {
            milestoneIds.add(todo.Milestone__c);
        }
    }
    
    if (Trigger.isUpdate || Trigger.isDelete) {
        for (Todo__c todo : Trigger.isDelete ? Trigger.old : Trigger.new) {
            milestoneIds.add(todo.Milestone__c);
        }
    }
    
    
    if (!milestoneIds.isEmpty()) {
        ProjectManagementUtility.updateMilestoneCompletionPercentages(milestoneIds);
    }
}