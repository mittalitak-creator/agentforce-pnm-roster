// Create 20 Additional Claims using CreateClaimAction
// Distributed across 5 members with various statuses and types

List<Account> members = [SELECT Id, Member_Id__c FROM Account WHERE Member_Id__c LIKE 'MEM%' ORDER BY Member_Id__c];
List<Case> cases = [SELECT Id, CaseNumber FROM Case WHERE CaseNumber IN ('00001003', '00001004', '00001007') ORDER BY CaseNumber];

if (members.isEmpty()) {
    System.debug('ERROR: No members found');
} else {
    List<CreateClaimAction.ClaimRequest> requests = new List<CreateClaimAction.ClaimRequest>();
    
    // ===== MEM001 Claims (5 claims) =====
    
    // Claim 6: Paid Vision Claim
    CreateClaimAction.ClaimRequest req6 = new CreateClaimAction.ClaimRequest();
    req6.memberId = members[0].Id;
    req6.claimStatus = 'Paid';
    req6.claimType = 'Vision';
    req6.serviceDate = Date.today().addDays(-90);
    req6.claimAmount = 250.00;
    req6.paidAmount = 200.00;
    req6.finalizedDate = Date.today().addDays(-75);
    req6.providerName = 'Vision Care Center';
    req6.serviceDescription = 'Annual eye exam and prescription glasses';
    requests.add(req6);
    
    // Claim 7: Approved Medical Claim
    CreateClaimAction.ClaimRequest req7 = new CreateClaimAction.ClaimRequest();
    req7.memberId = members[0].Id;
    req7.claimStatus = 'Approved';
    req7.claimType = 'Medical';
    req7.serviceDate = Date.today().addDays(-25);
    req7.claimAmount = 1500.00;
    req7.finalizedDate = Date.today().addDays(-10);
    req7.providerName = 'Orthopedic Specialists';
    req7.serviceDescription = 'MRI scan for knee injury evaluation';
    requests.add(req7);
    
    // Claim 8: Submitted Pharmacy Claim
    CreateClaimAction.ClaimRequest req8 = new CreateClaimAction.ClaimRequest();
    req8.memberId = members[0].Id;
    req8.claimStatus = 'Submitted';
    req8.claimType = 'Pharmacy';
    req8.serviceDate = Date.today().addDays(-5);
    req8.claimAmount = 425.00;
    req8.providerName = 'CVS Pharmacy #1234';
    req8.serviceDescription = 'Insulin prescription - 3 month supply';
    requests.add(req8);
    
    // Claim 9: Denied Dental Claim
    CreateClaimAction.ClaimRequest req9 = new CreateClaimAction.ClaimRequest();
    req9.memberId = members[0].Id;
    req9.claimStatus = 'Denied';
    req9.claimType = 'Dental';
    req9.serviceDate = Date.today().addDays(-50);
    req9.claimAmount = 1800.00;
    req9.paidAmount = 0.00;
    req9.finalizedDate = Date.today().addDays(-35);
    req9.denialReason = 'Not Covered';
    req9.providerName = 'Premier Dental Group';
    req9.serviceDescription = 'Cosmetic teeth whitening procedure';
    requests.add(req9);
    
    // Claim 10: Paid Medical Claim
    CreateClaimAction.ClaimRequest req10 = new CreateClaimAction.ClaimRequest();
    req10.memberId = members[0].Id;
    req10.claimStatus = 'Paid';
    req10.claimType = 'Medical';
    req10.serviceDate = Date.today().addDays(-120);
    req10.claimAmount = 3500.00;
    req10.paidAmount = 2800.00;
    req10.finalizedDate = Date.today().addDays(-100);
    req10.providerName = 'City Hospital ER';
    req10.serviceDescription = 'Emergency room visit for severe migraine';
    requests.add(req10);
    
    // ===== MEM002 Claims (4 claims) =====
    
    // Claim 11: Pending Pharmacy Claim
    CreateClaimAction.ClaimRequest req11 = new CreateClaimAction.ClaimRequest();
    req11.memberId = members[1].Id;
    req11.claimStatus = 'Pending';
    req11.claimType = 'Pharmacy';
    req11.serviceDate = Date.today().addDays(-8);
    req11.claimAmount = 650.00;
    req11.providerName = 'Rite Aid Pharmacy';
    req11.serviceDescription = 'Blood pressure medication - Lisinopril 90-day supply';
    requests.add(req11);
    
    // Claim 12: Denied DME Claim
    CreateClaimAction.ClaimRequest req12 = new CreateClaimAction.ClaimRequest();
    req12.memberId = members[1].Id;
    req12.claimStatus = 'Denied';
    req12.claimType = 'DME';
    req12.serviceDate = Date.today().addDays(-55);
    req12.claimAmount = 2200.00;
    req12.paidAmount = 0.00;
    req12.finalizedDate = Date.today().addDays(-40);
    req12.denialReason = 'Out of Network';
    req12.providerName = 'Home Medical Equipment Inc';
    req12.serviceDescription = 'CPAP machine for sleep apnea';
    requests.add(req12);
    
    // Claim 13: Paid Vision Claim
    CreateClaimAction.ClaimRequest req13 = new CreateClaimAction.ClaimRequest();
    req13.memberId = members[1].Id;
    req13.claimStatus = 'Paid';
    req13.claimType = 'Vision';
    req13.serviceDate = Date.today().addDays(-70);
    req13.claimAmount = 180.00;
    req13.paidAmount = 150.00;
    req13.finalizedDate = Date.today().addDays(-60);
    req13.providerName = 'LensCrafters';
    req13.serviceDescription = 'Contact lenses - 6 month supply';
    requests.add(req13);
    
    // Claim 14: Approved Medical Claim
    CreateClaimAction.ClaimRequest req14 = new CreateClaimAction.ClaimRequest();
    req14.memberId = members[1].Id;
    req14.claimStatus = 'Approved';
    req14.claimType = 'Medical';
    req14.serviceDate = Date.today().addDays(-18);
    req14.claimAmount = 5200.00;
    req14.finalizedDate = Date.today().addDays(-5);
    req14.providerName = 'Regional Surgical Center';
    req14.serviceDescription = 'Outpatient surgery - arthroscopic knee procedure';
    requests.add(req14);
    
    // ===== MEM003 Claims (4 claims) =====
    
    // Claim 15: Submitted Medical Claim
    CreateClaimAction.ClaimRequest req15 = new CreateClaimAction.ClaimRequest();
    req15.memberId = members[2].Id;
    req15.claimStatus = 'Submitted';
    req15.claimType = 'Medical';
    req15.serviceDate = Date.today().addDays(-3);
    req15.claimAmount = 450.00;
    req15.providerName = 'Family Practice Associates';
    req15.serviceDescription = 'Follow-up visit with cardiologist';
    requests.add(req15);
    
    // Claim 16: Denied Pharmacy Claim
    CreateClaimAction.ClaimRequest req16 = new CreateClaimAction.ClaimRequest();
    req16.memberId = members[2].Id;
    req16.claimStatus = 'Denied';
    req16.claimType = 'Pharmacy';
    req16.serviceDate = Date.today().addDays(-40);
    req16.claimAmount = 1200.00;
    req16.paidAmount = 0.00;
    req16.finalizedDate = Date.today().addDays(-28);
    req16.denialReason = 'Experimental Treatment';
    req16.providerName = 'Specialty Pharmacy Network';
    req16.serviceDescription = 'Biologic medication for rheumatoid arthritis - Humira';
    requests.add(req16);
    
    // Claim 17: Paid Dental Claim
    CreateClaimAction.ClaimRequest req17 = new CreateClaimAction.ClaimRequest();
    req17.memberId = members[2].Id;
    req17.claimStatus = 'Paid';
    req17.claimType = 'Dental';
    req17.serviceDate = Date.today().addDays(-85);
    req17.claimAmount = 800.00;
    req17.paidAmount = 640.00;
    req17.finalizedDate = Date.today().addDays(-70);
    req17.providerName = 'Smile Dental Care';
    req17.serviceDescription = 'Two dental fillings and cleaning';
    requests.add(req17);
    
    // Claim 18: Pending DME Claim
    CreateClaimAction.ClaimRequest req18 = new CreateClaimAction.ClaimRequest();
    req18.memberId = members[2].Id;
    req18.claimStatus = 'Pending';
    req18.claimType = 'DME';
    req18.serviceDate = Date.today().addDays(-12);
    req18.claimAmount = 850.00;
    req18.providerName = 'Diabetes Supply Company';
    req18.serviceDescription = 'Continuous glucose monitor system';
    requests.add(req18);
    
    // ===== MEM004 Claims (4 claims) =====
    
    // Claim 19: Approved Pharmacy Claim
    CreateClaimAction.ClaimRequest req19 = new CreateClaimAction.ClaimRequest();
    req19.memberId = members[3].Id;
    req19.claimStatus = 'Approved';
    req19.claimType = 'Pharmacy';
    req19.serviceDate = Date.today().addDays(-22);
    req19.claimAmount = 320.00;
    req19.finalizedDate = Date.today().addDays(-10);
    req19.providerName = 'Safeway Pharmacy';
    req19.serviceDescription = 'Cholesterol medication - Atorvastatin 90-day supply';
    requests.add(req19);
    
    // Claim 20: Denied Medical Claim
    CreateClaimAction.ClaimRequest req20 = new CreateClaimAction.ClaimRequest();
    req20.memberId = members[3].Id;
    req20.claimStatus = 'Denied';
    req20.claimType = 'Medical';
    req20.serviceDate = Date.today().addDays(-48);
    req20.claimAmount = 8500.00;
    req20.paidAmount = 0.00;
    req20.finalizedDate = Date.today().addDays(-30);
    req20.denialReason = 'Not Medically Necessary';
    req20.providerName = 'Advanced Spine Center';
    req20.serviceDescription = 'Spinal fusion surgery for chronic back pain';
    requests.add(req20);
    
    // Claim 21: Submitted Vision Claim
    CreateClaimAction.ClaimRequest req21 = new CreateClaimAction.ClaimRequest();
    req21.memberId = members[3].Id;
    req21.claimStatus = 'Submitted';
    req21.claimType = 'Vision';
    req21.serviceDate = Date.today().addDays(-6);
    req21.claimAmount = 420.00;
    req21.providerName = 'Eye Care Associates';
    req21.serviceDescription = 'Progressive lens glasses with anti-glare coating';
    requests.add(req21);
    
    // Claim 22: Paid Medical Claim
    CreateClaimAction.ClaimRequest req22 = new CreateClaimAction.ClaimRequest();
    req22.memberId = members[3].Id;
    req22.claimStatus = 'Paid';
    req22.claimType = 'Medical';
    req22.serviceDate = Date.today().addDays(-95);
    req22.claimAmount = 2800.00;
    req22.paidAmount = 2240.00;
    req22.finalizedDate = Date.today().addDays(-80);
    req22.providerName = 'Cardiology Specialists';
    req22.serviceDescription = 'Cardiac stress test and echocardiogram';
    requests.add(req22);
    
    // ===== MEM005 Claims (3 claims) =====
    
    // Claim 23: Pending Medical Claim
    CreateClaimAction.ClaimRequest req23 = new CreateClaimAction.ClaimRequest();
    req23.memberId = members[4].Id;
    req23.claimStatus = 'Pending';
    req23.claimType = 'Medical';
    req23.serviceDate = Date.today().addDays(-14);
    req23.claimAmount = 6200.00;
    req23.providerName = 'Memorial Hospital';
    req23.serviceDescription = '3-day inpatient stay for pneumonia treatment';
    requests.add(req23);
    
    // Claim 24: Denied Dental Claim
    CreateClaimAction.ClaimRequest req24 = new CreateClaimAction.ClaimRequest();
    req24.memberId = members[4].Id;
    req24.claimStatus = 'Denied';
    req24.claimType = 'Dental';
    req24.serviceDate = Date.today().addDays(-32);
    req24.claimAmount = 3200.00;
    req24.paidAmount = 0.00;
    req24.finalizedDate = Date.today().addDays(-20);
    req24.denialReason = 'Duplicate Claim';
    req24.providerName = 'Advanced Dental Implants';
    req24.serviceDescription = 'Dental implant placement - upper molar';
    requests.add(req24);
    
    // Claim 25: Approved Pharmacy Claim
    CreateClaimAction.ClaimRequest req25 = new CreateClaimAction.ClaimRequest();
    req25.memberId = members[4].Id;
    req25.claimStatus = 'Approved';
    req25.claimType = 'Pharmacy';
    req25.serviceDate = Date.today().addDays(-16);
    req25.claimAmount = 580.00;
    req25.finalizedDate = Date.today().addDays(-8);
    req25.providerName = 'Target Pharmacy';
    req25.serviceDescription = 'Asthma inhaler - Advair 3-month supply';
    requests.add(req25);
    
    // Call the Apex action
    System.debug('======================================');
    System.debug('CREATING 20 ADDITIONAL CLAIMS');
    System.debug('======================================');
    
    List<CreateClaimAction.ClaimResult> results = CreateClaimAction.createClaim(requests);
    
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
    System.debug('Total claims in org should now be: ' + (5 + successCount));
    System.debug('======================================');
}
