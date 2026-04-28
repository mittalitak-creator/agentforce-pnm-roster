@IsTest
private class RosterIngestActionTest {

    @IsTest
    static void testBlankCrfReturnsError() {
        RosterIngestAction.Input inp = new RosterIngestAction.Input();
        inp.crfId = '';

        Test.startTest();
        List<RosterIngestAction.Output> results = RosterIngestAction.execute(
            new List<RosterIngestAction.Input>{ inp }
        );
        Test.stopTest();

        System.assertEquals(false, results[0].success);
        System.assert(results[0].errorMessage.contains('CRF record ID'));
    }

    @IsTest
    static void testInvalidCrfReturnsError() {
        RosterIngestAction.Input inp = new RosterIngestAction.Input();
        inp.crfId = 'NOTFOUND00000001';
        inp.caseId = 'CASE0000000001';
        inp.fileName = 'test.csv';

        Test.startTest();
        List<RosterIngestAction.Output> results = RosterIngestAction.execute(
            new List<RosterIngestAction.Input>{ inp }
        );
        Test.stopTest();

        System.assertEquals(false, results[0].success);
    }
}
