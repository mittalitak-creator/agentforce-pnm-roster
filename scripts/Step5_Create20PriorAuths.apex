// Create 20 Prior Auth Records on CareRequest
// Record Type: Prior_Auth (012AAC00000vYMjYBM)

List<Account> members = [SELECT Id, Member_Id__c FROM Account WHERE Member_Id__c LIKE 'MEM%' ORDER BY Member_Id__c LIMIT 5];
Id priorAuthRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'CareRequest' AND DeveloperName = 'Prior_Auth' LIMIT 1].Id;

if (members.isEmpty()) {
    System.debug('ERROR: No members found');
} else {
    List<CareRequest> priorAuths = new List<CareRequest>();
    
    // Prior Auth 1-4: MEM001 (Approved, Denied, Pending, Approved)
    priorAuths.add(new CareRequest(
        RecordTypeId = priorAuthRecordTypeId,
        MemberId = members[0].Id,
        MemberIdentificationNumber = 'MEM001',
        Authorization_Reference_Identifier__c = 'PA-2024-001',
        MemberStatus = 'Approved',
        Organization_Received_Date__c = DateTime.now().addDays(-90)
    ));
    
    priorAuths.add(new CareRequest(
        RecordTypeId = priorAuthRecordTypeId,
        MemberId = members[0].Id,
        MemberIdentificationNumber = 'MEM001',
        Authorization_Reference_Identifier__c = 'PA-2024-002',
        MemberStatus = 'Denied',
        Organization_Received_Date__c = DateTime.now().addDays(-60)
    ));
    
    priorAuths.add(new CareRequest(
        RecordTypeId = priorAuthRecordTypeId,
        MemberId = members[0].Id,
        MemberIdentificationNumber = 'MEM001',
        Authorization_Reference_Identifier__c = 'PA-2024-003',
        MemberStatus = 'Pending',
        Organization_Received_Date__c = DateTime.now().addDays(-10)
    ));
    
    priorAuths.add(new CareRequest(
        RecordTypeId = priorAuthRecordTypeId,
        MemberId = members[0].Id,
        MemberIdentificationNumber = 'MEM001',
        Authorization_Reference_Identifier__c = 'PA-2024-004',
        MemberStatus = 'Approved',
        Organization_Received_Date__c = DateTime.now().addDays(-45)
    ));
    
    // Prior Auth 5-8: MEM002
    priorAuths.add(new CareRequest(
        RecordTypeId = priorAuthRecordTypeId,
        MemberId = members[1].Id,
        MemberIdentificationNumber = 'MEM002',
        Authorization_Reference_Identifier__c = 'PA-2024-005',
        MemberStatus = 'Approved',
        Organization_Received_Date__c = DateTime.now().addDays(-75)
    ));
    
    priorAuths.add(new CareRequest(
        RecordTypeId = priorAuthRecordTypeId,
        MemberId = members[1].Id,
        MemberIdentificationNumber = 'MEM002',
        Authorization_Reference_Identifier__c = 'PA-2024-006',
        MemberStatus = 'Denied',
        Organization_Received_Date__c = DateTime.now().addDays(-30)
    ));
    
    priorAuths.add(new CareRequest(
        RecordTypeId = priorAuthRecordTypeId,
        MemberId = members[1].Id,
        MemberIdentificationNumber = 'MEM002',
        Authorization_Reference_Identifier__c = 'PA-2024-007',
        MemberStatus = 'Pending',
        Organization_Received_Date__c = DateTime.now().addDays(-5)
    ));
    
    priorAuths.add(new CareRequest(
        RecordTypeId = priorAuthRecordTypeId,
        MemberId = members[1].Id,
        MemberIdentificationNumber = 'MEM002',
        Authorization_Reference_Identifier__c = 'PA-2024-008',
        MemberStatus = 'Expired',
        Organization_Received_Date__c = DateTime.now().addDays(-180)
    ));
    
    // Prior Auth 9-12: MEM003
    priorAuths.add(new CareRequest(
        RecordTypeId = priorAuthRecordTypeId,
        MemberId = members[2].Id,
        MemberIdentificationNumber = 'MEM003',
        Authorization_Reference_Identifier__c = 'PA-2024-009',
        MemberStatus = 'Approved',
        Organization_Received_Date__c = DateTime.now().addDays(-100)
    ));
    
    priorAuths.add(new CareRequest(
        RecordTypeId = priorAuthRecordTypeId,
        MemberId = members[2].Id,
        MemberIdentificationNumber = 'MEM003',
        Authorization_Reference_Identifier__c = 'PA-2024-010',
        MemberStatus = 'Denied',
        Organization_Received_Date__c = DateTime.now().addDays(-50)
    ));
    
    priorAuths.add(new CareRequest(
        RecordTypeId = priorAuthRecordTypeId,
        MemberId = members[2].Id,
        MemberIdentificationNumber = 'MEM003',
        Authorization_Reference_Identifier__c = 'PA-2024-011',
        MemberStatus = 'Pending',
        Organization_Received_Date__c = DateTime.now().addDays(-8)
    ));
    
    priorAuths.add(new CareRequest(
        RecordTypeId = priorAuthRecordTypeId,
        MemberId = members[2].Id,
        MemberIdentificationNumber = 'MEM003',
        Authorization_Reference_Identifier__c = 'PA-2024-012',
        MemberStatus = 'Approved',
        Organization_Received_Date__c = DateTime.now().addDays(-35)
    ));
    
    // Prior Auth 13-16: MEM004
    priorAuths.add(new CareRequest(
        RecordTypeId = priorAuthRecordTypeId,
        MemberId = members[3].Id,
        MemberIdentificationNumber = 'MEM004',
        Authorization_Reference_Identifier__c = 'PA-2024-013',
        MemberStatus = 'Approved',
        Organization_Received_Date__c = DateTime.now().addDays(-85)
    ));
    
    priorAuths.add(new CareRequest(
        RecordTypeId = priorAuthRecordTypeId,
        MemberId = members[3].Id,
        MemberIdentificationNumber = 'MEM004',
        Authorization_Reference_Identifier__c = 'PA-2024-014',
        MemberStatus = 'Denied',
        Organization_Received_Date__c = DateTime.now().addDays(-40)
    ));
    
    priorAuths.add(new CareRequest(
        RecordTypeId = priorAuthRecordTypeId,
        MemberId = members[3].Id,
        MemberIdentificationNumber = 'MEM004',
        Authorization_Reference_Identifier__c = 'PA-2024-015',
        MemberStatus = 'Pending',
        Organization_Received_Date__c = DateTime.now().addDays(-12)
    ));
    
    priorAuths.add(new CareRequest(
        RecordTypeId = priorAuthRecordTypeId,
        MemberId = members[3].Id,
        MemberIdentificationNumber = 'MEM004',
        Authorization_Reference_Identifier__c = 'PA-2024-016',
        MemberStatus = 'Cancelled',
        Organization_Received_Date__c = DateTime.now().addDays(-20)
    ));
    
    // Prior Auth 17-20: MEM005
    priorAuths.add(new CareRequest(
        RecordTypeId = priorAuthRecordTypeId,
        MemberId = members[4].Id,
        MemberIdentificationNumber = 'MEM005',
        Authorization_Reference_Identifier__c = 'PA-2024-017',
        MemberStatus = 'Approved',
        Organization_Received_Date__c = DateTime.now().addDays(-70)
    ));
    
    priorAuths.add(new CareRequest(
        RecordTypeId = priorAuthRecordTypeId,
        MemberId = members[4].Id,
        MemberIdentificationNumber = 'MEM005',
        Authorization_Reference_Identifier__c = 'PA-2024-018',
        MemberStatus = 'Denied',
        Organization_Received_Date__c = DateTime.now().addDays(-25)
    ));
    
    priorAuths.add(new CareRequest(
        RecordTypeId = priorAuthRecordTypeId,
        MemberId = members[4].Id,
        MemberIdentificationNumber = 'MEM005',
        Authorization_Reference_Identifier__c = 'PA-2024-019',
        MemberStatus = 'Pending',
        Organization_Received_Date__c = DateTime.now().addDays(-7)
    ));
    
    priorAuths.add(new CareRequest(
        RecordTypeId = priorAuthRecordTypeId,
        MemberId = members[4].Id,
        MemberIdentificationNumber = 'MEM005',
        Authorization_Reference_Identifier__c = 'PA-2024-020',
        MemberStatus = 'Approved',
        Organization_Received_Date__c = DateTime.now().addDays(-55)
    ));
    
    try {
        insert priorAuths;
        System.debug('======================================');
        System.debug('SUCCESS: Created ' + priorAuths.size() + ' prior auth records');
        System.debug('======================================');
        
        List<CareRequest> insertedPriorAuths = [
            SELECT Id, Name, Authorization_Reference_Identifier__c, MemberStatus, 
                   MemberIdentificationNumber 
            FROM CareRequest 
            WHERE Id IN :priorAuths
            ORDER BY Authorization_Reference_Identifier__c
        ];
        
        for (CareRequest pa : insertedPriorAuths) {
            System.debug('Created: ' + pa.Authorization_Reference_Identifier__c + 
                        ' - ' + pa.Name + ' (' + pa.MemberStatus + ') - Member: ' + pa.MemberIdentificationNumber);
        }
        System.debug('======================================');
    } catch (Exception e) {
        System.debug('ERROR creating prior auths: ' + e.getMessage());
        System.debug('Stack trace: ' + e.getStackTraceString());
    }
}
