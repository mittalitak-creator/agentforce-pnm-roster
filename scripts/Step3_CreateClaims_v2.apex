// Create 5 Mock Claims using CreateClaimAction
List<Account> members = [SELECT Id, Member_Id__c FROM Account WHERE Member_Id__c LIKE 'MEM%' ORDER BY Member_Id__c];
List<Case> cases = [SELECT Id, CaseNumber FROM Case WHERE CaseNumber IN ('00001003', '00001004', '00001007') ORDER BY CaseNumber];

if (members.isEmpty()) {
    System.debug('ERROR: No members found');
} else {
    List<CreateClaimAction.ClaimRequest> requests = new List<CreateClaimAction.ClaimRequest>();
    
    // Claim 1: Denied Pharmacy Claim (related to Case 00001003)
    CreateClaimAction.ClaimRequest req1 = new CreateClaimAction.ClaimRequest();
    req1.memberId = members[0].Id;
    req1.relatedCaseId = cases.isEmpty() ? null : cases[0].Id;
    req1.claimStatus = 'Denied';
    req1.claimType = 'Pharmacy';
    req1.serviceDate = Date.today().addDays(-45);
    req1.claimAmount = 850.00;
    req1.paidAmount = 0.00;
    req1.finalizedDate = Date.today().addDays(-30);
    req1.denialReason = 'Not Covered';
    req1.providerName = 'Walgreens Pharmacy #4567';
    req1.serviceDescription = 'Eliquis 5mg - 60 tablets. Prescription filled for anticoagulation therapy.';
    requests.add(req1);
    
    // Claim 2: Denied Hospital Claim (related to Case 00001004)
    CreateClaimAction.ClaimRequest req2 = new CreateClaimAction.ClaimRequest();
    req2.memberId = members[1].Id;
    req2.relatedCaseId = cases.size() > 1 ? cases[1].Id : null;
    req2.claimStatus = 'Denied';
    req2.claimType = 'Medical';
    req2.serviceDate = Date.today().addDays(-20);
    req2.claimAmount = 15000.00;
    req2.paidAmount = 0.00;
    req2.finalizedDate = Date.today().addDays(-10);
    req2.denialReason = 'Not Medically Necessary';
    req2.providerName = 'Springfield General Hospital';
    req2.serviceDescription = 'Emergency admission for chest pain evaluation. 2-day inpatient stay with cardiac monitoring and stress test.';
    requests.add(req2);
    
    // Claim 3: Approved Medical Claim
    CreateClaimAction.ClaimRequest req3 = new CreateClaimAction.ClaimRequest();
    req3.memberId = members[2].Id;
    req3.claimStatus = 'Paid';
    req3.claimType = 'Medical';
    req3.serviceDate = Date.today().addDays(-60);
    req3.claimAmount = 350.00;
    req3.paidAmount = 280.00;
    req3.finalizedDate = Date.today().addDays(-45);
    req3.providerName = 'Family Health Clinic';
    req3.serviceDescription = 'Annual physical examination with lab work.';
    requests.add(req3);
    
    // Claim 4: Denied DME Claim (related to Case 00001007)
    CreateClaimAction.ClaimRequest req4 = new CreateClaimAction.ClaimRequest();
    req4.memberId = members[4].Id;
    req4.relatedCaseId = cases.size() > 2 ? cases[2].Id : null;
    req4.claimStatus = 'Denied';
    req4.claimType = 'DME';
    req4.serviceDate = Date.today().addDays(-35);
    req4.claimAmount = 4500.00;
    req4.paidAmount = 0.00;
    req4.finalizedDate = Date.today().addDays(-25);
    req4.denialReason = 'Not Medically Necessary';
    req4.providerName = 'MedEquip Supply Co';
    req4.serviceDescription = 'Motorized wheelchair with tilt-in-space functionality for patient with severe arthritis.';
    requests.add(req4);
    
    // Claim 5: Pending Dental Claim
    CreateClaimAction.ClaimRequest req5 = new CreateClaimAction.ClaimRequest();
    req5.memberId = members[3].Id;
    req5.claimStatus = 'Pending';
    req5.claimType = 'Dental';
    req5.serviceDate = Date.today().addDays(-15);
    req5.claimAmount = 1200.00;
    req5.paidAmount = 0.00;
    req5.providerName = 'Bright Smile Dental';
    req5.serviceDescription = 'Root canal treatment on tooth #14 with crown placement.';
    requests.add(req5);
    
    // Call the Apex action
    List<CreateClaimAction.ClaimResult> results = CreateClaimAction.createClaim(requests);
    
    System.debug('======================================');
    System.debug('CLAIMS CREATION RESULTS');
    System.debug('======================================');
    
    Integer successCount = 0;
    Integer failureCount = 0;
    
    for (CreateClaimAction.ClaimResult result : results) {
        if (result.success) {
            successCount++;
            System.debug('✓ SUCCESS: ' + result.message + ' (ID: ' + result.claimId + ')');
        } else {
            failureCount++;
            System.debug('✗ FAILURE: ' + result.message);
        }
    }
    
    System.debug('======================================');
    System.debug('SUMMARY: ' + successCount + ' succeeded, ' + failureCount + ' failed');
    System.debug('======================================');
}
