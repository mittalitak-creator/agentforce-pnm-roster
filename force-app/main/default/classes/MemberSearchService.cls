/**
 * @description Service class for member search operations
 * Used by Agentforce to identify members
 */
public with sharing class MemberSearchService {
    
    /**
     * @description Searches for a member using various criteria
     * @param requests List of search requests
     * @return List of search results
     */
    @InvocableMethod(label='Search Member' description='Searches for a member using Member ID or name/DOB combination')
    public static List<MemberSearchResult> searchMember(List<MemberSearchRequest> requests) {
        List<MemberSearchResult> results = new List<MemberSearchResult>();
        
        for (MemberSearchRequest request : requests) {
            try {
                MemberSearchResult result = new MemberSearchResult();
                List<Account> foundAccounts = new List<Account>();
                
                // Search logic: Member ID OR (FirstName + LastName + DOB)
                if (String.isNotBlank(request.memberId)) {
                    // Search by Member ID
                    foundAccounts = [
                        SELECT Id, Name, Member_ID__c, FirstName, LastName, PersonBirthdate, Phone, PersonEmail
                        FROM Account 
                        WHERE Member_ID__c = :request.memberId
                        AND IsPersonAccount = true
                        LIMIT 10
                    ];
                } else if (String.isNotBlank(request.firstName) && 
                           String.isNotBlank(request.lastName) && 
                           request.dateOfBirth != null) {
                    // Search by Name + DOB
                    foundAccounts = [
                        SELECT Id, Name, Member_ID__c, FirstName, LastName, PersonBirthdate, Phone, PersonEmail
                        FROM Account 
                        WHERE FirstName = :request.firstName
                        AND LastName = :request.lastName
                        AND PersonBirthdate = :request.dateOfBirth
                        AND IsPersonAccount = true
                        LIMIT 10
                    ];
                } else {
                    result.success = false;
                    result.message = 'Please provide either a Member ID or the combination of First Name, Last Name, and Date of Birth.';
                    results.add(result);
                    continue;
                }
                
                // Handle search results
                if (foundAccounts.isEmpty()) {
                    result.success = false;
                    result.found = false;
                    result.message = 'No member found with the provided information. Please verify the details and try again.';
                    result.matchCount = 0;
                } else if (foundAccounts.size() == 1) {
                    // Single match found
                    Account member = foundAccounts[0];
                    result.success = true;
                    result.found = true;
                    result.memberId = member.Id;
                    result.memberName = member.Name;
                    result.memberIdNumber = member.Member_ID__c;
                    result.dateOfBirth = member.PersonBirthdate;
                    result.matchCount = 1;
                    result.message = 'Great! I found your account:\n' +
                                   '✓ Name: ' + member.Name + '\n' +
                                   '✓ Member ID: ' + member.Member_ID__c + '\n' +
                                   '✓ Date of Birth: ' + (member.PersonBirthdate != null ? member.PersonBirthdate.format() : 'N/A');
                    
                    // Update checklist if provided
                    if (String.isNotBlank(request.checklistId)) {
                        IntakeChecklistManager.updateTaskStatus(request.checklistId, 'Member_Identified', true);
                        Intake_Checklist__c checklist = new Intake_Checklist__c(Id = request.checklistId);
                        checklist.Member__c = member.Id;
                        update checklist;
                    }
                } else {
                    // Multiple matches found
                    result.success = true;
                    result.found = true;
                    result.matchCount = foundAccounts.size();
                    result.message = 'I found ' + foundAccounts.size() + ' members matching your criteria. Please provide additional information to identify the correct account.';
                    result.multipleMatches = new List<String>();
                    for (Account acc : foundAccounts) {
                        result.multipleMatches.add(acc.Name + ' (ID: ' + acc.Member_ID__c + ', DOB: ' + 
                                                  (acc.PersonBirthdate != null ? acc.PersonBirthdate.format() : 'N/A') + ')');
                    }
                }
                
                results.add(result);
                
            } catch (Exception e) {
                MemberSearchResult result = new MemberSearchResult();
                result.success = false;
                result.message = 'Error searching for member: ' + e.getMessage();
                results.add(result);
            }
        }
        
        return results;
    }
    
    // Input/Output classes for Invocable Methods
    public class MemberSearchRequest {
        @InvocableVariable(label='Member ID' description='The member ID to search for')
        public String memberId;
        
        @InvocableVariable(label='First Name' description='Member first name')
        public String firstName;
        
        @InvocableVariable(label='Last Name' description='Member last name')
        public String lastName;
        
        @InvocableVariable(label='Date of Birth' description='Member date of birth')
        public Date dateOfBirth;
        
        @InvocableVariable(label='Checklist ID' description='The intake checklist to update')
        public String checklistId;
    }
    
    public class MemberSearchResult {
        @InvocableVariable
        public Boolean success;
        
        @InvocableVariable
        public Boolean found;
        
        @InvocableVariable
        public String memberId;
        
        @InvocableVariable
        public String memberName;
        
        @InvocableVariable
        public String memberIdNumber;
        
        @InvocableVariable
        public Date dateOfBirth;
        
        @InvocableVariable
        public Integer matchCount;
        
        @InvocableVariable
        public String message;
        
        @InvocableVariable
        public List<String> multipleMatches;
    }
}


