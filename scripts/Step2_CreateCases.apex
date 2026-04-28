// STEP 2: Create A&G Cases using CreateAGCaseAction
// This uses our deployed Apex action which should work with the new fields

// Get member accounts
List<Account> members = [SELECT Id, Member_Id__c FROM Account WHERE Member_Id__c IN ('MEM001', 'MEM002', 'MEM003', 'MEM004', 'MEM005') ORDER BY Member_Id__c];

if (members.isEmpty()) {
    System.debug('ERROR: No members found. Please run Step1 first.');
} else {
    System.debug('Found ' + members.size() + ' members to create cases for');
    
    List<CreateAGCaseAction.AGCaseRequest> requests = new List<CreateAGCaseAction.AGCaseRequest>();
    
    // Case 1: Appeal - Part D Drug
    CreateAGCaseAction.AGCaseRequest req1 = new CreateAGCaseAction.AGCaseRequest();
    req1.accountId = members[0].Id; // MEM001
    req1.memberId = 'MEM001';
    req1.agType = 'Appeal';
    req1.appealType = 'Part D Drug - Formulary';
    req1.lob = 'Medicare Advantage';
    req1.reason = 'Requesting formulary exception for prescribed medication (Eliquis). Alternative medications cause adverse effects including nausea and dizziness.';
    req1.isUrgent = true;
    requests.add(req1);
    
    // Case 2: Appeal - Inpatient Services
    CreateAGCaseAction.AGCaseRequest req2 = new CreateAGCaseAction.AGCaseRequest();
    req2.accountId = members[1].Id; // MEM002
    req2.memberId = 'MEM002';
    req2.agType = 'Appeal';
    req2.appealType = 'Inpatient Hospital Services';
    req2.lob = 'Medicare Advantage';
    req2.reason = 'Denial of emergency hospital admission coverage. Emergency admission for chest pain was denied as not medically necessary.';
    req2.isUrgent = true;
    requests.add(req2);
    
    // Case 3: Grievance - Quality of Care
    CreateAGCaseAction.AGCaseRequest req3 = new CreateAGCaseAction.AGCaseRequest();
    req3.accountId = members[2].Id; // MEM003
    req3.memberId = 'MEM003';
    req3.agType = 'Grievance';
    req3.grievanceType = 'Quality of Care';
    req3.lob = 'Commercial';
    req3.reason = 'Primary care physician did not perform adequate examination during visit. Symptoms were dismissed without proper diagnostic testing.';
    req3.isUrgent = false;
    requests.add(req3);
    
    // Case 4: Grievance - Wait Time
    CreateAGCaseAction.AGCaseRequest req4 = new CreateAGCaseAction.AGCaseRequest();
    req4.accountId = members[3].Id; // MEM004
    req4.memberId = 'MEM004';
    req4.agType = 'Grievance';
    req4.grievanceType = 'Wait Time';
    req4.lob = 'Medicare Advantage';
    req4.reason = 'Waited 3 hours past scheduled appointment time. No explanation or apology provided by office staff.';
    req4.isUrgent = false;
    requests.add(req4);
    
    // Case 5: Appeal - DME
    CreateAGCaseAction.AGCaseRequest req5 = new CreateAGCaseAction.AGCaseRequest();
    req5.accountId = members[4].Id; // MEM005
    req5.memberId = 'MEM005';
    req5.agType = 'Appeal';
    req5.appealType = 'DME';
    req5.lob = 'Part D';
    req5.reason = 'Request for motorized wheelchair was denied. Patient has limited mobility due to severe arthritis and cannot use manual wheelchair.';
    req5.isUrgent = false;
    requests.add(req5);
    
    // Create all cases using our Apex action
    System.debug('======================================');
    System.debug('Creating ' + requests.size() + ' A&G cases...');
    System.debug('======================================');
    
    List<CreateAGCaseAction.AGCaseResult> results = CreateAGCaseAction.createAGCase(requests);
    
    Integer successCount = 0;
    Integer failCount = 0;
    
    for (CreateAGCaseAction.AGCaseResult result : results) {
        if (result.success) {
            successCount++;
            System.debug('✅ SUCCESS: ' + result.caseNumber + ' - ' + result.message.substring(0, 50) + '...');
        } else {
            failCount++;
            System.debug('❌ FAILED: ' + result.errorMessage);
        }
    }
    
    System.debug('======================================');
    System.debug('CASE CREATION COMPLETE');
    System.debug('======================================');
    System.debug('Successful: ' + successCount);
    System.debug('Failed: ' + failCount);
    System.debug('======================================');
}
