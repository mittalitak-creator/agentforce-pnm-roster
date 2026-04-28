@IsTest
private class RosterAuditServiceTest {

    @IsTest
    static void testFinalizeCreatesAuditLog() {
        // Create an in-progress audit log
        Roster_Audit_Log__c log = new Roster_Audit_Log__c(
            CRF_Id__c = 'FAKECRF000000001',
            Status__c = 'In Progress',
            File_Name__c = 'test_roster.csv',
            Ingest_Start__c = Datetime.now()
        );
        insert log;

        Test.startTest();
        RosterAuditService.finalizeAuditLog(
            'FAKECRF000000001',
            log.Id,
            'Success',
            23,    // added
            41,    // updated
            5,     // skipped
            790,   // noChange
            'JOB-001',
            null,
            null
        );
        Test.stopTest();

        Roster_Audit_Log__c updated = [
            SELECT Status__c, Rows_Added__c, Rows_Updated__c, Rows_Skipped__c,
                   Rows_No_Change__c, Total_Rows__c, Ingest_End__c
            FROM Roster_Audit_Log__c WHERE Id = :log.Id
        ];
        System.assertEquals('Success', updated.Status__c);
        System.assertEquals(23, (Integer) updated.Rows_Added__c);
        System.assertEquals(41, (Integer) updated.Rows_Updated__c);
        System.assertEquals(859, (Integer) updated.Total_Rows__c);
        System.assertNotEquals(null, updated.Ingest_End__c);
    }

    @IsTest
    static void testFinalizeWithoutAuditLogIdFindsLogByCrf() {
        Roster_Audit_Log__c log = new Roster_Audit_Log__c(
            CRF_Id__c = 'FAKECRF000000002',
            Status__c = 'In Progress',
            Ingest_Start__c = Datetime.now()
        );
        insert log;

        Test.startTest();
        RosterAuditService.finalizeAuditLog(
            'FAKECRF000000002', null, 'Success', 10, 5, 0, 100, 'JOB-002', null, null
        );
        Test.stopTest();

        Roster_Audit_Log__c updated = [
            SELECT Status__c FROM Roster_Audit_Log__c WHERE Id = :log.Id
        ];
        System.assertEquals('Success', updated.Status__c);
    }

    @IsTest
    static void testBuildSummaryParagraph() {
        Roster_Audit_Log__c log = new Roster_Audit_Log__c(
            Rows_Added__c = 23,
            Rows_Updated__c = 41,
            Rows_Skipped__c = 5,
            Rows_No_Change__c = 790,
            Ingest_End__c = Datetime.now()
        );
        insert log;

        String para = RosterAuditService.buildSummaryParagraph(log);
        System.assert(para.contains('23'), para);
        System.assert(para.contains('41'), para);
        System.assert(para.contains('5'), para);
        System.assert(para.contains('790'), para);
    }

    @IsTest
    static void testGetAuditLogReturnsNullForBlankId() {
        Roster_Audit_Log__c result = RosterAuditService.getAuditLog('');
        System.assertNotEquals(null, result == null ? 'null' : result.Id);
        System.assertEquals(null, result);
    }
}
