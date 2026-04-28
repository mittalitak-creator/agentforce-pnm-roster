// Create 20 Prior Auth Records using CreatePriorAuthAction
List<Account> members = [SELECT Id, Member_Id__c FROM Account WHERE Member_Id__c LIKE 'MEM%' ORDER BY Member_Id__c LIMIT 5];

if (members.isEmpty()) {
    System.debug('ERROR: No members found');
} else {
    List<CreatePriorAuthAction.PriorAuthRequest> requests = new List<CreatePriorAuthAction.PriorAuthRequest>();
    
    // Prior Auth 1-4: MEM001
    CreatePriorAuthAction.PriorAuthRequest req1 = new CreatePriorAuthAction.PriorAuthRequest();
    req1.memberId = members[0].Id;
    req1.memberIdentificationNumber = 'MEM001';
    req1.authorizationId = 'PA-2024-001';
    req1.status = 'Approved';
    req1.organizationReceivedDate = DateTime.now().addDays(-90);
    requests.add(req1);
    
    CreatePriorAuthAction.PriorAuthRequest req2 = new CreatePriorAuthAction.PriorAuthRequest();
    req2.memberId = members[0].Id;
    req2.memberIdentificationNumber = 'MEM001';
    req2.authorizationId = 'PA-2024-002';
    req2.status = 'Denied';
    req2.organizationReceivedDate = DateTime.now().addDays(-60);
    requests.add(req2);
    
    CreatePriorAuthAction.PriorAuthRequest req3 = new CreatePriorAuthAction.PriorAuthRequest();
    req3.memberId = members[0].Id;
    req3.memberIdentificationNumber = 'MEM001';
    req3.authorizationId = 'PA-2024-003';
    req3.status = 'Pending';
    req3.organizationReceivedDate = DateTime.now().addDays(-10);
    requests.add(req3);
    
    CreatePriorAuthAction.PriorAuthRequest req4 = new CreatePriorAuthAction.PriorAuthRequest();
    req4.memberId = members[0].Id;
    req4.memberIdentificationNumber = 'MEM001';
    req4.authorizationId = 'PA-2024-004';
    req4.status = 'Approved';
    req4.organizationReceivedDate = DateTime.now().addDays(-45);
    requests.add(req4);
    
    // Prior Auth 5-8: MEM002
    CreatePriorAuthAction.PriorAuthRequest req5 = new CreatePriorAuthAction.PriorAuthRequest();
    req5.memberId = members[1].Id;
    req5.memberIdentificationNumber = 'MEM002';
    req5.authorizationId = 'PA-2024-005';
    req5.status = 'Approved';
    req5.organizationReceivedDate = DateTime.now().addDays(-75);
    requests.add(req5);
    
    CreatePriorAuthAction.PriorAuthRequest req6 = new CreatePriorAuthAction.PriorAuthRequest();
    req6.memberId = members[1].Id;
    req6.memberIdentificationNumber = 'MEM002';
    req6.authorizationId = 'PA-2024-006';
    req6.status = 'Denied';
    req6.organizationReceivedDate = DateTime.now().addDays(-30);
    requests.add(req6);
    
    CreatePriorAuthAction.PriorAuthRequest req7 = new CreatePriorAuthAction.PriorAuthRequest();
    req7.memberId = members[1].Id;
    req7.memberIdentificationNumber = 'MEM002';
    req7.authorizationId = 'PA-2024-007';
    req7.status = 'Pending';
    req7.organizationReceivedDate = DateTime.now().addDays(-5);
    requests.add(req7);
    
    CreatePriorAuthAction.PriorAuthRequest req8 = new CreatePriorAuthAction.PriorAuthRequest();
    req8.memberId = members[1].Id;
    req8.memberIdentificationNumber = 'MEM002';
    req8.authorizationId = 'PA-2024-008';
    req8.status = 'Expired';
    req8.organizationReceivedDate = DateTime.now().addDays(-180);
    requests.add(req8);
    
    // Prior Auth 9-12: MEM003
    CreatePriorAuthAction.PriorAuthRequest req9 = new CreatePriorAuthAction.PriorAuthRequest();
    req9.memberId = members[2].Id;
    req9.memberIdentificationNumber = 'MEM003';
    req9.authorizationId = 'PA-2024-009';
    req9.status = 'Approved';
    req9.organizationReceivedDate = DateTime.now().addDays(-100);
    requests.add(req9);
    
    CreatePriorAuthAction.PriorAuthRequest req10 = new CreatePriorAuthAction.PriorAuthRequest();
    req10.memberId = members[2].Id;
    req10.memberIdentificationNumber = 'MEM003';
    req10.authorizationId = 'PA-2024-010';
    req10.status = 'Denied';
    req10.organizationReceivedDate = DateTime.now().addDays(-50);
    requests.add(req10);
    
    CreatePriorAuthAction.PriorAuthRequest req11 = new CreatePriorAuthAction.PriorAuthRequest();
    req11.memberId = members[2].Id;
    req11.memberIdentificationNumber = 'MEM003';
    req11.authorizationId = 'PA-2024-011';
    req11.status = 'Pending';
    req11.organizationReceivedDate = DateTime.now().addDays(-8);
    requests.add(req11);
    
    CreatePriorAuthAction.PriorAuthRequest req12 = new CreatePriorAuthAction.PriorAuthRequest();
    req12.memberId = members[2].Id;
    req12.memberIdentificationNumber = 'MEM003';
    req12.authorizationId = 'PA-2024-012';
    req12.status = 'Approved';
    req12.organizationReceivedDate = DateTime.now().addDays(-35);
    requests.add(req12);
    
    // Prior Auth 13-16: MEM004
    CreatePriorAuthAction.PriorAuthRequest req13 = new CreatePriorAuthAction.PriorAuthRequest();
    req13.memberId = members[3].Id;
    req13.memberIdentificationNumber = 'MEM004';
    req13.authorizationId = 'PA-2024-013';
    req13.status = 'Approved';
    req13.organizationReceivedDate = DateTime.now().addDays(-85);
    requests.add(req13);
    
    CreatePriorAuthAction.PriorAuthRequest req14 = new CreatePriorAuthAction.PriorAuthRequest();
    req14.memberId = members[3].Id;
    req14.memberIdentificationNumber = 'MEM004';
    req14.authorizationId = 'PA-2024-014';
    req14.status = 'Denied';
    req14.organizationReceivedDate = DateTime.now().addDays(-40);
    requests.add(req14);
    
    CreatePriorAuthAction.PriorAuthRequest req15 = new CreatePriorAuthAction.PriorAuthRequest();
    req15.memberId = members[3].Id;
    req15.memberIdentificationNumber = 'MEM004';
    req15.authorizationId = 'PA-2024-015';
    req15.status = 'Pending';
    req15.organizationReceivedDate = DateTime.now().addDays(-12);
    requests.add(req15);
    
    CreatePriorAuthAction.PriorAuthRequest req16 = new CreatePriorAuthAction.PriorAuthRequest();
    req16.memberId = members[3].Id;
    req16.memberIdentificationNumber = 'MEM004';
    req16.authorizationId = 'PA-2024-016';
    req16.status = 'Cancelled';
    req16.organizationReceivedDate = DateTime.now().addDays(-20);
    requests.add(req16);
    
    // Prior Auth 17-20: MEM005
    CreatePriorAuthAction.PriorAuthRequest req17 = new CreatePriorAuthAction.PriorAuthRequest();
    req17.memberId = members[4].Id;
    req17.memberIdentificationNumber = 'MEM005';
    req17.authorizationId = 'PA-2024-017';
    req17.status = 'Approved';
    req17.organizationReceivedDate = DateTime.now().addDays(-70);
    requests.add(req17);
    
    CreatePriorAuthAction.PriorAuthRequest req18 = new CreatePriorAuthAction.PriorAuthRequest();
    req18.memberId = members[4].Id;
    req18.memberIdentificationNumber = 'MEM005';
    req18.authorizationId = 'PA-2024-018';
    req18.status = 'Denied';
    req18.organizationReceivedDate = DateTime.now().addDays(-25);
    requests.add(req18);
    
    CreatePriorAuthAction.PriorAuthRequest req19 = new CreatePriorAuthAction.PriorAuthRequest();
    req19.memberId = members[4].Id;
    req19.memberIdentificationNumber = 'MEM005';
    req19.authorizationId = 'PA-2024-019';
    req19.status = 'Pending';
    req19.organizationReceivedDate = DateTime.now().addDays(-7);
    requests.add(req19);
    
    CreatePriorAuthAction.PriorAuthRequest req20 = new CreatePriorAuthAction.PriorAuthRequest();
    req20.memberId = members[4].Id;
    req20.memberIdentificationNumber = 'MEM005';
    req20.authorizationId = 'PA-2024-020';
    req20.status = 'Approved';
    req20.organizationReceivedDate = DateTime.now().addDays(-55);
    requests.add(req20);
    
    // Call the Apex action
    System.debug('======================================');
    System.debug('CREATING 20 PRIOR AUTH RECORDS');
    System.debug('======================================');
    
    List<CreatePriorAuthAction.PriorAuthResult> results = CreatePriorAuthAction.createPriorAuth(requests);
    
    Integer successCount = 0;
    Integer failureCount = 0;
    
    for (CreatePriorAuthAction.PriorAuthResult result : results) {
        if (result.success) {
            successCount++;
            System.debug('✓ SUCCESS: ' + result.message);
        } else {
            failureCount++;
            System.debug('✗ FAILURE: ' + result.message);
        }
    }
    
    System.debug('======================================');
    System.debug('SUMMARY: ' + successCount + ' succeeded, ' + failureCount + ' failed');
    System.debug('======================================');
}
