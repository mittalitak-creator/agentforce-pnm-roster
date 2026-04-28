// Update Cases to use Prior Auth Record Type
Id priorAuthRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Prior_Auth' LIMIT 1].Id;

List<Case> priorAuthCases = [
    SELECT Id, Subject
    FROM Case 
    WHERE Subject LIKE 'Prior Auth PA-2024-%'
];

if (priorAuthCases.isEmpty()) {
    System.debug('ERROR: No prior auth cases found');
} else {
    for (Case c : priorAuthCases) {
        c.RecordTypeId = priorAuthRecordTypeId;
    }
    
    try {
        update priorAuthCases;
        System.debug('======================================');
        System.debug('SUCCESS: Updated ' + priorAuthCases.size() + ' cases to Prior Auth record type');
        System.debug('======================================');
        System.debug('NEXT STEP: Run Step5b_CreatePriorAuthCareRequests.apex');
        System.debug('======================================');
    } catch (Exception e) {
        System.debug('ERROR updating cases: ' + e.getMessage());
        System.debug('Stack trace: ' + e.getStackTraceString());
    }
}
