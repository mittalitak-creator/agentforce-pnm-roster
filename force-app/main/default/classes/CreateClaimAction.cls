public class CreateClaimAction {
    
    @InvocableMethod(
        label='Create Claim'
        description='Creates a claim record with member and service details'
        category='A&G Intake'
    )
    public static List<ClaimResult> createClaim(List<ClaimRequest> requests) {
        List<ClaimResult> results = new List<ClaimResult>();
        List<Claim__c> claimsToInsert = new List<Claim__c>();
        
        for (ClaimRequest req : requests) {
            Claim__c newClaim = new Claim__c();
            
            // Set required and basic fields
            if (req.memberId != null) {
                newClaim.Member__c = req.memberId;
            }
            
            if (req.relatedCaseId != null) {
                newClaim.Related_Case__c = req.relatedCaseId;
            }
            
            if (req.claimStatus != null) {
                newClaim.Claim_Status__c = req.claimStatus;
            }
            
            if (req.claimType != null) {
                newClaim.Claim_Type__c = req.claimType;
            }
            
            if (req.serviceDate != null) {
                newClaim.Service_Date__c = req.serviceDate;
            }
            
            if (req.claimAmount != null) {
                newClaim.Claim_Amount__c = req.claimAmount;
            }
            
            if (req.paidAmount != null) {
                newClaim.Paid_Amount__c = req.paidAmount;
            }
            
            if (req.finalizedDate != null) {
                newClaim.Finalized_Date__c = req.finalizedDate;
            }
            
            if (req.denialReason != null) {
                newClaim.Denial_Reason__c = req.denialReason;
            }
            
            if (req.providerName != null) {
                newClaim.Provider_Name__c = req.providerName;
            }
            
            if (req.serviceDescription != null) {
                newClaim.Service_Description__c = req.serviceDescription;
            }
            
            claimsToInsert.add(newClaim);
        }
        
        try {
            insert claimsToInsert;
            
            // Query back the created claims to get all details
            List<Claim__c> createdClaims = [
                SELECT Id, Name, Claim_Type__c, Claim_Status__c, Claim_Amount__c, 
                       Service_Date__c, Provider_Name__c, Member__c
                FROM Claim__c 
                WHERE Id IN :claimsToInsert
            ];
            
            for (Claim__c claim : createdClaims) {
                ClaimResult result = new ClaimResult();
                result.success = true;
                result.claimId = claim.Id;
                result.claimNumber = claim.Name;
                result.claimType = claim.Claim_Type__c;
                result.claimStatus = claim.Claim_Status__c;
                result.message = 'Claim ' + claim.Name + ' created successfully';
                results.add(result);
            }
            
        } catch (DmlException e) {
            ClaimResult result = new ClaimResult();
            result.success = false;
            result.message = 'Error creating claim: ' + e.getMessage();
            results.add(result);
        }
        
        return results;
    }
    
    public class ClaimRequest {
        @InvocableVariable(required=true label='Member ID')
        public Id memberId;
        
        @InvocableVariable(label='Related Case ID')
        public Id relatedCaseId;
        
        @InvocableVariable(required=true label='Claim Status')
        public String claimStatus;
        
        @InvocableVariable(required=true label='Claim Type')
        public String claimType;
        
        @InvocableVariable(required=true label='Service Date')
        public Date serviceDate;
        
        @InvocableVariable(required=true label='Claim Amount')
        public Decimal claimAmount;
        
        @InvocableVariable(label='Paid Amount')
        public Decimal paidAmount;
        
        @InvocableVariable(label='Finalized Date')
        public Date finalizedDate;
        
        @InvocableVariable(label='Denial Reason')
        public String denialReason;
        
        @InvocableVariable(label='Provider Name')
        public String providerName;
        
        @InvocableVariable(label='Service Description')
        public String serviceDescription;
    }
    
    public class ClaimResult {
        @InvocableVariable
        public Boolean success;
        
        @InvocableVariable
        public String message;
        
        @InvocableVariable
        public Id claimId;
        
        @InvocableVariable
        public String claimNumber;
        
        @InvocableVariable
        public String claimType;
        
        @InvocableVariable
        public String claimStatus;
    }
}
