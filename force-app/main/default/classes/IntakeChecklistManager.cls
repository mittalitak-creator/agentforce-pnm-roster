/**
 * @description Manager class for Intake Checklist operations
 * Used by Agentforce to track intake progress
 */
public with sharing class IntakeChecklistManager {
    
    /**
     * @description Creates a new intake checklist
     * @param conversationId The Agentforce conversation ID
     * @param caseType Appeal or Grievance
     * @return The created checklist record
     */
    @InvocableMethod(label='Create Intake Checklist' description='Creates a new intake checklist for the conversation')
    public static List<ChecklistResult> createChecklist(List<ChecklistRequest> requests) {
        List<ChecklistResult> results = new List<ChecklistResult>();
        
        for (ChecklistRequest request : requests) {
            try {
                Intake_Checklist__c checklist = new Intake_Checklist__c();
                checklist.Conversation_ID__c = request.conversationId;
                checklist.Case_Type__c = request.caseType;
                
                insert checklist;
                
                ChecklistResult result = new ChecklistResult();
                result.checklistId = checklist.Id;
                result.success = true;
                result.message = 'Intake checklist created successfully! I\'ll guide you through ' + 
                               (String.isNotBlank(request.caseType) ? 'the ' + request.caseType + ' intake process.' : 'collecting all necessary information.');
                result.progressPercentage = 0;
                results.add(result);
                
            } catch (Exception e) {
                ChecklistResult result = new ChecklistResult();
                result.success = false;
                result.message = 'Error creating checklist: ' + e.getMessage();
                results.add(result);
            }
        }
        
        return results;
    }
    
    /**
     * @description Updates a specific task status on the checklist
     */
    public static void updateTaskStatus(Id checklistId, String taskName, Boolean completed) {
        Intake_Checklist__c checklist = [SELECT Id FROM Intake_Checklist__c WHERE Id = :checklistId LIMIT 1];
        
        switch on taskName {
            when 'Member_Identified' {
                checklist.Member_Identified__c = completed;
            }
            when 'Complaint_Details_Captured' {
                checklist.Complaint_Details_Captured__c = completed;
            }
            when 'Intake_Basics_Set' {
                checklist.Intake_Basics_Set__c = completed;
            }
            when 'Service_Type_Determined' {
                checklist.Service_Type_Determined__c = completed;
            }
            when 'Late_Filing_Checked' {
                checklist.Late_Filing_Checked__c = completed;
            }
            when 'AOR_Validated' {
                checklist.AOR_Validated__c = completed;
            }
            when 'Case_Created' {
                checklist.Case_Created__c = completed;
            }
        }
        
        update checklist;
    }
    
    /**
     * @description Gets the current progress of a checklist
     */
    public static ChecklistProgress getChecklistProgress(Id checklistId) {
        Intake_Checklist__c checklist = [
            SELECT Id, Progress_Percentage__c, 
                   Member_Identified__c, Complaint_Details_Captured__c,
                   Intake_Basics_Set__c, Service_Type_Determined__c,
                   Late_Filing_Checked__c, AOR_Validated__c, Case_Created__c
            FROM Intake_Checklist__c 
            WHERE Id = :checklistId 
            LIMIT 1
        ];
        
        ChecklistProgress progress = new ChecklistProgress();
        progress.progressPercentage = checklist.Progress_Percentage__c != null ? checklist.Progress_Percentage__c : 0;
        progress.tasksCompleted = new List<String>();
        progress.tasksPending = new List<String>();
        
        if (checklist.Member_Identified__c) {
            progress.tasksCompleted.add('✓ Member Identified');
        } else {
            progress.tasksPending.add('○ Identify Member');
        }
        
        if (checklist.Complaint_Details_Captured__c) {
            progress.tasksCompleted.add('✓ Complaint Details Captured');
        } else {
            progress.tasksPending.add('○ Capture Complaint Details');
        }
        
        if (checklist.Intake_Basics_Set__c) {
            progress.tasksCompleted.add('✓ Intake Basics Set');
        } else {
            progress.tasksPending.add('○ Set Intake Basics');
        }
        
        if (checklist.Service_Type_Determined__c) {
            progress.tasksCompleted.add('✓ Service Type Determined');
        } else {
            progress.tasksPending.add('○ Determine Service Type');
        }
        
        if (checklist.Late_Filing_Checked__c) {
            progress.tasksCompleted.add('✓ Late Filing Checked');
        } else {
            progress.tasksPending.add('○ Check Late Filing');
        }
        
        if (checklist.AOR_Validated__c) {
            progress.tasksCompleted.add('✓ AOR Validated');
        } else {
            progress.tasksPending.add('○ Validate AOR');
        }
        
        if (checklist.Case_Created__c) {
            progress.tasksCompleted.add('✓ Case Created');
        } else {
            progress.tasksPending.add('○ Create Case');
        }
        
        return progress;
    }
    
    // Input/Output classes for Invocable Methods
    public class ChecklistRequest {
        @InvocableVariable(required=false)
        public String conversationId;
        
        @InvocableVariable(required=false)
        public String caseType;
    }
    
    public class ChecklistResult {
        @InvocableVariable
        public String checklistId;
        
        @InvocableVariable
        public Boolean success;
        
        @InvocableVariable
        public String message;
        
        @InvocableVariable
        public Decimal progressPercentage;
    }
    
    public class ChecklistProgress {
        public Decimal progressPercentage;
        public List<String> tasksCompleted;
        public List<String> tasksPending;
    }
}


