public class ProjectManagementUtility {
    
    public static void updateMilestoneCompletionPercentages(Set<Id> milestoneIds) {
        
        Map<Id, List<Todo__c>> milestoneToTodosMap = new Map<Id, List<Todo__c>>();
        Set<Id> projectIds = new Set<Id>();
        
        
        Map<Id, Id> milestoneToProjectMap = new Map<Id, Id>();
        for (Milestone__c m : [SELECT Id, Project__c FROM Milestone__c WHERE Id IN :milestoneIds]) {
            milestoneToProjectMap.put(m.Id, m.Project__c);
            projectIds.add(m.Project__c);
        }
        
        
        for (Todo__c todo : [SELECT Id, Milestone__c, Status__c FROM Todo__c WHERE Milestone__c IN :milestoneIds]) {
            if (!milestoneToTodosMap.containsKey(todo.Milestone__c)) {
                milestoneToTodosMap.put(todo.Milestone__c, new List<Todo__c>());
            }
            milestoneToTodosMap.get(todo.Milestone__c).add(todo);
        }
        
        
        List<Milestone__c> milestonesToUpdate = new List<Milestone__c>();
        for (Id milestoneId : milestoneToTodosMap.keySet()) {
            List<Todo__c> todos = milestoneToTodosMap.get(milestoneId);
            
            
            Decimal completedTodos = 0;
            for (Todo__c todo : todos) {
                if (todo.Status__c == 'Complete') {
                    completedTodos++;
                }
            }
            
            
            Decimal percentComplete = (todos.size() > 0) ? (completedTodos / todos.size()) : 0;
            
            milestonesToUpdate.add(new Milestone__c(
                Id = milestoneId,
                Percent_Complete__c = percentComplete
            ));
        }
        
        if (!milestonesToUpdate.isEmpty()) {
            update milestonesToUpdate;
            
            
            updateProjectCompletionPercentages(projectIds);
        }
    }
    
    public static void updateProjectCompletionPercentages(Set<Id> projectIds) {
        
        Map<Id, List<Milestone__c>> projectToMilestonesMap = new Map<Id, List<Milestone__c>>();
        
        
        for (Milestone__c milestone : [SELECT Id, Project__c, Percent_Complete__c FROM Milestone__c WHERE Project__c IN :projectIds]) {
            if (!projectToMilestonesMap.containsKey(milestone.Project__c)) {
                projectToMilestonesMap.put(milestone.Project__c, new List<Milestone__c>());
            }
            projectToMilestonesMap.get(milestone.Project__c).add(milestone);
        }
        
        
        List<Project__c> projectsToUpdate = new List<Project__c>();
        for (Id projectId : projectToMilestonesMap.keySet()) {
            List<Milestone__c> milestones = projectToMilestonesMap.get(projectId);
            
            
            Decimal totalPercentComplete = 0;
            for (Milestone__c milestone : milestones) {
                totalPercentComplete += milestone.Percent_Complete__c;
            }
            
            
            Decimal percentComplete = (milestones.size() > 0) ? (totalPercentComplete / milestones.size()) : 0;
            
            projectsToUpdate.add(new Project__c(
                Id = projectId,
                Percent_Complete__c = percentComplete
            ));
        }
        
        if (!projectsToUpdate.isEmpty()) {
            update projectsToUpdate;
        }
    }
}