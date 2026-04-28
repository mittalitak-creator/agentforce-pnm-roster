// Create 5 Mock Claims
List<Account> members = [SELECT Id, Member_Id__c FROM Account WHERE Member_Id__c LIKE 'MEM%' ORDER BY Member_Id__c];
List<Case> cases = [SELECT Id, CaseNumber FROM Case WHERE CaseNumber IN ('00001003', '00001004', '00001007') ORDER BY CaseNumber];

if (members.isEmpty()) {
    System.debug('ERROR: No members found');
} else {
    List<Claim__c> claims = new List<Claim__c>();
    
    // Claim 1: Denied Pharmacy Claim (related to Case 00001003)
    claims.add(new Claim__c(
        Member__c = members[0].Id, // MEM001
        Related_Case__c = cases.isEmpty() ? null : cases[0].Id,
        Claim_Status__c = 'Denied',
        Claim_Type__c = 'Pharmacy',
        Service_Date__c = Date.today().addDays(-45),
        Claim_Amount__c = 850.00,
        Paid_Amount__c = 0.00,
        Finalized_Date__c = Date.today().addDays(-30),
        Denial_Reason__c = 'Not Covered',
        Provider_Name__c = 'Walgreens Pharmacy #4567',
        Service_Description__c = 'Eliquis 5mg - 60 tablets. Prescription filled for anticoagulation therapy.'
    ));
    
    // Claim 2: Denied Hospital Claim (related to Case 00001004)
    claims.add(new Claim__c(
        Member__c = members[1].Id, // MEM002
        Related_Case__c = cases.size() > 1 ? cases[1].Id : null,
        Claim_Status__c = 'Denied',
        Claim_Type__c = 'Medical',
        Service_Date__c = Date.today().addDays(-20),
        Claim_Amount__c = 15000.00,
        Paid_Amount__c = 0.00,
        Finalized_Date__c = Date.today().addDays(-10),
        Denial_Reason__c = 'Not Medically Necessary',
        Provider_Name__c = 'Springfield General Hospital',
        Service_Description__c = 'Emergency admission for chest pain evaluation. 2-day inpatient stay with cardiac monitoring and stress test.'
    ));
    
    // Claim 3: Approved Medical Claim
    claims.add(new Claim__c(
        Member__c = members[2].Id, // MEM003
        Claim_Status__c = 'Paid',
        Claim_Type__c = 'Medical',
        Service_Date__c = Date.today().addDays(-60),
        Claim_Amount__c = 350.00,
        Paid_Amount__c = 280.00,
        Finalized_Date__c = Date.today().addDays(-45),
        Provider_Name__c = 'Family Health Clinic',
        Service_Description__c = 'Annual physical examination with lab work.'
    ));
    
    // Claim 4: Denied DME Claim (related to Case 00001007)
    claims.add(new Claim__c(
        Member__c = members[4].Id, // MEM005
        Related_Case__c = cases.size() > 2 ? cases[2].Id : null,
        Claim_Status__c = 'Denied',
        Claim_Type__c = 'DME',
        Service_Date__c = Date.today().addDays(-35),
        Claim_Amount__c = 4500.00,
        Paid_Amount__c = 0.00,
        Finalized_Date__c = Date.today().addDays(-25),
        Denial_Reason__c = 'Not Medically Necessary',
        Provider_Name__c = 'MedEquip Supply Co',
        Service_Description__c = 'Motorized wheelchair with tilt-in-space functionality for patient with severe arthritis.'
    ));
    
    // Claim 5: Pending Dental Claim
    claims.add(new Claim__c(
        Member__c = members[3].Id, // MEM004
        Claim_Status__c = 'Pending',
        Claim_Type__c = 'Dental',
        Service_Date__c = Date.today().addDays(-15),
        Claim_Amount__c = 1200.00,
        Paid_Amount__c = 0.00,
        Provider_Name__c = 'Bright Smile Dental',
        Service_Description__c = 'Root canal treatment on tooth #14 with crown placement.'
    ));
    
    try {
        insert claims;
        System.debug('======================================');
        System.debug('SUCCESS: Created ' + claims.size() + ' claims');
        System.debug('======================================');
        
        List<Claim__c> insertedClaims = [SELECT Name, Claim_Type__c, Claim_Status__c, Member__r.Member_Id__c FROM Claim__c WHERE Id IN :claims];
        for (Claim__c claim : insertedClaims) {
            System.debug('Created: ' + claim.Name + ' - ' + claim.Claim_Type__c + ' (' + claim.Claim_Status__c + ') - Member: ' + claim.Member__r.Member_Id__c);
        }
        System.debug('======================================');
    } catch (Exception e) {
        System.debug('ERROR creating claims: ' + e.getMessage());
        System.debug('Stack trace: ' + e.getStackTraceString());
    }
}
