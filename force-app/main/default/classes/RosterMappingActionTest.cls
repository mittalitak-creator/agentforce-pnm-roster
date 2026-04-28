@IsTest
private class RosterMappingActionTest {

    @IsTest
    static void testTriggerBlankCrfReturnsError() {
        RosterMappingAction.Input inp = new RosterMappingAction.Input();
        inp.mode = RosterMappingAction.MODE_TRIGGER;
        inp.crfId = '';
        inp.orgBaseUrl = 'https://test.salesforce.com';

        Test.startTest();
        List<RosterMappingAction.Output> results = RosterMappingAction.execute(
            new List<RosterMappingAction.Input>{ inp }
        );
        Test.stopTest();

        System.assertEquals(false, results[0].success);
    }

    @IsTest
    static void testPollBlankCrfReturnsError() {
        RosterMappingAction.Input inp = new RosterMappingAction.Input();
        inp.mode = RosterMappingAction.MODE_POLL;
        inp.crfId = '';

        Test.startTest();
        List<RosterMappingAction.Output> results = RosterMappingAction.execute(
            new List<RosterMappingAction.Input>{ inp }
        );
        Test.stopTest();

        System.assertEquals(false, results[0].success);
    }

    @IsTest
    static void testPollInvalidIdReturnsError() {
        RosterMappingAction.Input inp = new RosterMappingAction.Input();
        inp.mode = RosterMappingAction.MODE_POLL;
        inp.crfId = 'NOTAVALIDID00000';

        Test.startTest();
        List<RosterMappingAction.Output> results = RosterMappingAction.execute(
            new List<RosterMappingAction.Input>{ inp }
        );
        Test.stopTest();

        System.assertEquals(false, results[0].success);
    }
}
