public with sharing class ProjectManagerController {
    
    @AuraEnabled
    public static Project__c createProject(String name, Id ownerId) {
        Project__c project = new Project__c(
            Name = name,
            Owner__c = ownerId,
            Percent_Complete__c = 0
        );
        
        try {
            insert project;
            return project;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating project: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Milestone__c createMilestone(String name, Id projectId) {
        Milestone__c milestone = new Milestone__c(
            Name = name,
            Project__c = projectId,
            Percent_Complete__c = 0
        );
        
        try {
            insert milestone;
            return milestone;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating milestone: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Todo__c createTodo(String name, Id milestoneId) {
        Todo__c todo = new Todo__c(
            Name = name,
            Milestone__c = milestoneId,
            Status__c = 'Not Started'
        );
        
        try {
            insert todo;
            return todo;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating todo: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static ProjectWrapper getProject(Id projectId) {
        ProjectWrapper wrapper = new ProjectWrapper();
        
        try {
            
            wrapper.project = [SELECT Id, Name, Owner__c, Status__c, Percent_Complete__c 
                              FROM Project__c WHERE Id = :projectId LIMIT 1];
            
            
            wrapper.milestones = new List<MilestoneWrapper>();
            List<Milestone__c> milestones = [SELECT Id, Name, Status__c, Percent_Complete__c 
                                            FROM Milestone__c WHERE Project__c = :projectId];
            
            Set<Id> milestoneIds = new Set<Id>();
            for (Milestone__c milestone : milestones) {
                milestoneIds.add(milestone.Id);
            }
            
            
            Map<Id, List<Todo__c>> milestoneToTodosMap = new Map<Id, List<Todo__c>>();
            for (Todo__c todo : [SELECT Id, Name, Status__c, Milestone__c 
                                FROM Todo__c WHERE Milestone__c IN :milestoneIds]) {
                if (!milestoneToTodosMap.containsKey(todo.Milestone__c)) {
                    milestoneToTodosMap.put(todo.Milestone__c, new List<Todo__c>());
                }
                milestoneToTodosMap.get(todo.Milestone__c).add(todo);
            }
            
            
            for (Milestone__c milestone : milestones) {
                MilestoneWrapper mw = new MilestoneWrapper();
                mw.milestone = milestone;
                mw.todos = milestoneToTodosMap.containsKey(milestone.Id) 
                    ? milestoneToTodosMap.get(milestone.Id) 
                    : new List<Todo__c>();
                wrapper.milestones.add(mw);
            }
            
            return wrapper;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving project: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateTodoStatus(Id todoId, String status) {
        try {
            update new Todo__c(Id = todoId, Status__c = status);
        } catch (Exception e) {
            throw new AuraHandledException('Error updating todo: ' + e.getMessage());
        }
    }
    
    
    public class ProjectWrapper {
        @AuraEnabled public Project__c project;
        @AuraEnabled public List<MilestoneWrapper> milestones;
    }
    
    public class MilestoneWrapper {
        @AuraEnabled public Milestone__c milestone;
        @AuraEnabled public List<Todo__c> todos;
    }

    @AuraEnabled(cacheable=true)
    public static List<User> getUserList(){
        return [SELECT Id, Name FROM User WHERE ID IN (SELECT Owner__c FROM Project__c WHERE Owner__c != null)];
    }
}