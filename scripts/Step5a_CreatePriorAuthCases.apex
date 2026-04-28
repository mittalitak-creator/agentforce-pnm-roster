// Step 1: Create 20 Cases for Prior Auth Records
List<Account> members = [SELECT Id, Member_Id__c FROM Account WHERE Member_Id__c LIKE 'MEM%' ORDER BY Member_Id__c LIMIT 5];

if (members.isEmpty()) {
    System.debug('ERROR: No members found');
} else {
    List<Case> priorAuthCases = new List<Case>();
    
    // Cases for MEM001 (4 cases)
    priorAuthCases.add(new Case(
        Subject = 'Prior Auth PA-2024-001',
        Status = 'New',
        Origin = 'Phone',
        AccountId = members[0].Id
    ));
    priorAuthCases.add(new Case(
        Subject = 'Prior Auth PA-2024-002',
        Status = 'New',
        Origin = 'Phone',
        AccountId = members[0].Id
    ));
    priorAuthCases.add(new Case(
        Subject = 'Prior Auth PA-2024-003',
        Status = 'New',
        Origin = 'Phone',
        AccountId = members[0].Id
    ));
    priorAuthCases.add(new Case(
        Subject = 'Prior Auth PA-2024-004',
        Status = 'New',
        Origin = 'Phone',
        AccountId = members[0].Id
    ));
    
    // Cases for MEM002 (4 cases)
    priorAuthCases.add(new Case(
        Subject = 'Prior Auth PA-2024-005',
        Status = 'New',
        Origin = 'Phone',
        AccountId = members[1].Id
    ));
    priorAuthCases.add(new Case(
        Subject = 'Prior Auth PA-2024-006',
        Status = 'New',
        Origin = 'Phone',
        AccountId = members[1].Id
    ));
    priorAuthCases.add(new Case(
        Subject = 'Prior Auth PA-2024-007',
        Status = 'New',
        Origin = 'Phone',
        AccountId = members[1].Id
    ));
    priorAuthCases.add(new Case(
        Subject = 'Prior Auth PA-2024-008',
        Status = 'New',
        Origin = 'Phone',
        AccountId = members[1].Id
    ));
    
    // Cases for MEM003 (4 cases)
    priorAuthCases.add(new Case(
        Subject = 'Prior Auth PA-2024-009',
        Status = 'New',
        Origin = 'Phone',
        AccountId = members[2].Id
    ));
    priorAuthCases.add(new Case(
        Subject = 'Prior Auth PA-2024-010',
        Status = 'New',
        Origin = 'Phone',
        AccountId = members[2].Id
    ));
    priorAuthCases.add(new Case(
        Subject = 'Prior Auth PA-2024-011',
        Status = 'New',
        Origin = 'Phone',
        AccountId = members[2].Id
    ));
    priorAuthCases.add(new Case(
        Subject = 'Prior Auth PA-2024-012',
        Status = 'New',
        Origin = 'Phone',
        AccountId = members[2].Id
    ));
    
    // Cases for MEM004 (4 cases)
    priorAuthCases.add(new Case(
        Subject = 'Prior Auth PA-2024-013',
        Status = 'New',
        Origin = 'Phone',
        AccountId = members[3].Id
    ));
    priorAuthCases.add(new Case(
        Subject = 'Prior Auth PA-2024-014',
        Status = 'New',
        Origin = 'Phone',
        AccountId = members[3].Id
    ));
    priorAuthCases.add(new Case(
        Subject = 'Prior Auth PA-2024-015',
        Status = 'New',
        Origin = 'Phone',
        AccountId = members[3].Id
    ));
    priorAuthCases.add(new Case(
        Subject = 'Prior Auth PA-2024-016',
        Status = 'New',
        Origin = 'Phone',
        AccountId = members[3].Id
    ));
    
    // Cases for MEM005 (4 cases)
    priorAuthCases.add(new Case(
        Subject = 'Prior Auth PA-2024-017',
        Status = 'New',
        Origin = 'Phone',
        AccountId = members[4].Id
    ));
    priorAuthCases.add(new Case(
        Subject = 'Prior Auth PA-2024-018',
        Status = 'New',
        Origin = 'Phone',
        AccountId = members[4].Id
    ));
    priorAuthCases.add(new Case(
        Subject = 'Prior Auth PA-2024-019',
        Status = 'New',
        Origin = 'Phone',
        AccountId = members[4].Id
    ));
    priorAuthCases.add(new Case(
        Subject = 'Prior Auth PA-2024-020',
        Status = 'New',
        Origin = 'Phone',
        AccountId = members[4].Id
    ));
    
    try {
        insert priorAuthCases;
        System.debug('======================================');
        System.debug('SUCCESS: Created ' + priorAuthCases.size() + ' cases for prior auth records');
        System.debug('======================================');
        
        for (Case c : priorAuthCases) {
            System.debug('Created Case: ' + c.Id + ' - ' + c.Subject);
        }
        System.debug('======================================');
        System.debug('NEXT STEP: Run Step5b_CreatePriorAuthCareRequests.apex');
        System.debug('======================================');
    } catch (Exception e) {
        System.debug('ERROR creating cases: ' + e.getMessage());
        System.debug('Stack trace: ' + e.getStackTraceString());
    }
}
