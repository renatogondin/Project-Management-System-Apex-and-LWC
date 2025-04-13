import { LightningElement, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getUserList from '@salesforce/apex/ProjectManagerController.getUserList';
import createProject from '@salesforce/apex/ProjectManagerController.createProject';
import createMilestone from '@salesforce/apex/ProjectManagerController.createMilestone';
import createTodo from '@salesforce/apex/ProjectManagerController.createTodo';
import getProject from '@salesforce/apex/ProjectManagerController.getProject';
import updateTodoStatus from '@salesforce/apex/ProjectManagerController.updateTodoStatus';

import CURRENT_USER_ID from '@salesforce/user/Id';

export default class ProjectManager extends LightningElement {
    @track showNewProjectForm = true;
    @track projectData;
    @track error;
    @track ownerOptions = [];
    @track isTodoFormVisible = false;
    
    @track newProject = {
        name: '',
        ownerId: CURRENT_USER_ID
    };
    
    @track showMilestoneForm = false;
    @track newMilestone = {
        name: ''
    };
    
    @track showTodoForm = false;
    @track activeMilestoneId;
    @track newTodo = {
        name: ''
    };
    
    connectedCallback() {
        this.loadUsers();
    }
    
    loadUsers() {
        getUserList()
            .then(result => {
                this.ownerOptions = result.map(user => {
                    return { label: user.Name, value: user.Id };
                });
            })
            .catch(error => {
                this.error = 'Error loading users: ' + error.message;
            });
    }
    
    get projectPercentComplete() {
        return this.projectData ? this.projectData.project.Percent_Complete__c * 100 : 0;
    }
    
    get hasMilestones() {
        return this.projectData && this.projectData.milestones && this.projectData.milestones.length > 0;
    }
    
    hasTodos(milestoneWrapper) {
        return milestoneWrapper.todos && milestoneWrapper.todos.length > 0;
    }
    
    
    isTodoComplete(todo) {
        return todo.Status__c === 'Complete';
    }
    
    getTodoClass(todo) {
        return todo.Status__c === 'Complete' ? 'slds-text-color_success slds-text-title_bold' : '';
    }
    
    handleProjectNameChange(event) {
        this.newProject.name = event.target.value;
    }
    
    handleOwnerChange(event) {
        this.newProject.ownerId = event.target.value;
    }
    
    handleMilestoneNameChange(event) {
        this.newMilestone.name = event.target.value;
    }
    
    handleTodoNameChange(event) {
        this.newTodo.name = event.target.value;
    }
    
    createProject() {
        if (!this.newProject.name) {
            this.showToast('Error', 'Project name is required', 'error');
            return;
        }
        
        createProject({ name: this.newProject.name, ownerId: this.newProject.ownerId })
            .then(result => {
                this.showNewProjectForm = false;
                this.loadProject(result.Id);
                this.showToast('Success', 'Project created successfully', 'success');
            })
            .catch(error => {
                this.error = 'Error creating project: ' + error.message;
            });
    }
    
    loadProject(projectId) {
        getProject({ projectId })
            .then(result => {
                // Add hasTodos property to each milestone wrapper
                if (result.milestones) {
                    result.milestones.forEach(milestoneWrapper => {
                        milestoneWrapper.hasTodos = 
                            milestoneWrapper.todos && milestoneWrapper.todos.length > 0;
                    });
                }
                this.projectData = result;
                this.error = null;
            })
            .catch(error => {
                this.error = 'Error loading project: ' + error.message;
            });
    }
    
    showAddMilestoneForm() {
        this.showMilestoneForm = true;
        this.newMilestone = { name: '' };
    }
    
    hideAddMilestoneForm() {
        this.showMilestoneForm = false;
    }
    
    createMilestone() {
        if (!this.newMilestone.name) {
            this.showToast('Error', 'Milestone name is required', 'error');
            return;
        }
        
        createMilestone({ name: this.newMilestone.name, projectId: this.projectData.project.Id })
            .then(() => {
                this.showMilestoneForm = false;
                this.loadProject(this.projectData.project.Id);
                this.showToast('Success', 'Milestone created successfully', 'success');
            })
            .catch(error => {
                this.error = 'Error creating milestone: ' + error.message;
            });
    }
    
    showAddTodoForm(event) {
        const milestoneId = event.target.dataset.milestoneId;
        this.activeMilestoneId = milestoneId;
        this.showTodoForm = true;
        this.newTodo = { name: '' };
        
        // Update all DOM elements with matching milestone ID
        this.template.querySelectorAll('[data-milestone-id]').forEach(element => {
            const elementMilestoneId = element.dataset.milestoneId;
            if (elementMilestoneId === milestoneId) {
                element.isTodoFormVisible = true;
            } else {
                element.isTodoFormVisible = false;
            }
        });
    }
    
    hideAddTodoForm() {
        this.showTodoForm = false;
        this.activeMilestoneId = null;
        
        // Reset visibility for all milestone elements
        this.template.querySelectorAll('[data-milestone-id]').forEach(element => {
            element.isTodoFormVisible = false;
        });
    }
    
    createTodo() {
        if (!this.newTodo.name) {
            this.showToast('Error', 'Todo name is required', 'error');
            return;
        }
        
        createTodo({ name: this.newTodo.name, milestoneId: this.activeMilestoneId })
            .then(() => {
                this.showTodoForm = false;
                this.activeMilestoneId = null;
                this.loadProject(this.projectData.project.Id);
                this.showToast('Success', 'Todo created successfully', 'success');
            })
            .catch(error => {
                this.error = 'Error creating todo: ' + error.message;
            });
    }
    
    handleTodoStatusChange(event) {
        const todoId = event.target.dataset.todoId;
        const status = event.target.checked ? 'Complete' : 'Not Started';
        
        updateTodoStatus({ todoId, status })
            .then(() => {
                this.loadProject(this.projectData.project.Id);
            })
            .catch(error => {
                this.error = 'Error updating todo: ' + error.message;
            });
    }
    
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}