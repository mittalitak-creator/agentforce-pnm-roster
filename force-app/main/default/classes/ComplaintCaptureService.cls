/**
 * @description Service class for capturing complaint/appeal details
 * Used by Agentforce during intake
 */
public with sharing class ComplaintCaptureService {
    
    /**
     * @description Captures complaint details and validates category based on type
     * @param requests List of complaint capture requests
     * @return List of capture results
     */
    @InvocableMethod(label='Capture Complaint Details' description='Captures and validates complaint/appeal information')
    public static List<ComplaintResult> captureComplaint(List<ComplaintRequest> requests) {
        List<ComplaintResult> results = new List<ComplaintResult>();
        
        for (ComplaintRequest request : requests) {
            try {
                ComplaintResult result = new ComplaintResult();
                result.caseCreationTimestamp = Datetime.now();
                
                // Validate category based on case type
                Boolean validCategory = validateCategoryForType(request.caseType, request.category);
                
                if (!validCategory) {
                    result.success = false;
                    result.message = 'The category "' + request.category + '" is not valid for ' + request.caseType + ' cases. ' +
                                   'Please select from the appropriate categories.';
                    result.validCategories = getValidCategories(request.caseType);
                    results.add(result);
                    continue;
                }
                
                result.success = true;
                result.caseType = request.caseType;
                result.category = request.category;
                result.subCategory = request.subCategory;
                result.narrative = request.narrative;
                result.message = 'Complaint details captured:\n' +
                               '✓ Type: ' + request.caseType + '\n' +
                               '✓ Category: ' + request.category + 
                               (String.isNotBlank(request.subCategory) ? '\n✓ Sub-Category: ' + request.subCategory : '');
                
                // Update checklist if provided
                if (String.isNotBlank(request.checklistId)) {
                    IntakeChecklistManager.updateTaskStatus(request.checklistId, 'Complaint_Details_Captured', true);
                    
                    Intake_Checklist__c checklist = new Intake_Checklist__c(Id = request.checklistId);
                    if (String.isNotBlank(request.caseType)) {
                        checklist.Case_Type__c = request.caseType;
                    }
                    update checklist;
                }
                
                results.add(result);
                
            } catch (Exception e) {
                ComplaintResult result = new ComplaintResult();
                result.success = false;
                result.message = 'Error capturing complaint details: ' + e.getMessage();
                results.add(result);
            }
        }
        
        return results;
    }
    
    /**
     * @description Validates if a category is appropriate for the case type
     */
    private static Boolean validateCategoryForType(String caseType, String category) {
        if (String.isBlank(caseType) || String.isBlank(category)) {
            return false;
        }
        
        Set<String> grievanceCategories = new Set<String>{
            'Quality of Care (QOC)', 'Access to Care', 'Interpersonal', 
            'Administrative', 'Timeliness'
        };
        
        Set<String> appealCategories = new Set<String>{
            'Medical Necessity', 'Pharmacy (Part D)', 'Benefit Denial', 'Reimbursement'
        };
        
        if (caseType == 'Grievance') {
            return grievanceCategories.contains(category);
        } else if (caseType == 'Appeal') {
            return appealCategories.contains(category);
        }
        
        return false;
    }
    
    /**
     * @description Gets valid categories for a case type
     */
    private static List<String> getValidCategories(String caseType) {
        if (caseType == 'Grievance') {
            return new List<String>{
                'Quality of Care (QOC)', 'Access to Care', 'Interpersonal', 
                'Administrative', 'Timeliness'
            };
        } else if (caseType == 'Appeal') {
            return new List<String>{
                'Medical Necessity', 'Pharmacy (Part D)', 'Benefit Denial', 'Reimbursement'
            };
        }
        return new List<String>();
    }
    
    // Input/Output classes for Invocable Methods
    public class ComplaintRequest {
        @InvocableVariable(label='Case Type' description='Appeal or Grievance' required=true)
        public String caseType;
        
        @InvocableVariable(label='Category' description='Primary category' required=true)
        public String category;
        
        @InvocableVariable(label='Sub-Category' description='Sub-category')
        public String subCategory;
        
        @InvocableVariable(label='Narrative' description='Member narrative/description')
        public String narrative;
        
        @InvocableVariable(label='Checklist ID' description='The intake checklist to update')
        public String checklistId;
    }
    
    public class ComplaintResult {
        @InvocableVariable
        public Boolean success;
        
        @InvocableVariable
        public String message;
        
        @InvocableVariable
        public String caseType;
        
        @InvocableVariable
        public String category;
        
        @InvocableVariable
        public String subCategory;
        
        @InvocableVariable
        public String narrative;
        
        @InvocableVariable
        public Datetime caseCreationTimestamp;
        
        @InvocableVariable
        public List<String> validCategories;
    }
}


