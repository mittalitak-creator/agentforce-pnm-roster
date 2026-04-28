@IsTest
private class RosterStagingActionTest {

    @IsTest
    static void testBlankCrfIdReturnsError() {
        RosterStagingAction.Input inp = new RosterStagingAction.Input();
        inp.crfId = '';
        inp.validatedRowsJson = '[]';

        Test.startTest();
        List<RosterStagingAction.Output> results = RosterStagingAction.execute(
            new List<RosterStagingAction.Input>{ inp }
        );
        Test.stopTest();

        System.assertEquals(false, results[0].success);
        System.assert(results[0].errorMessage.contains('CRF record ID'));
    }

    @IsTest
    static void testEmptyRowsReturnsError() {
        RosterStagingAction.Input inp = new RosterStagingAction.Input();
        inp.crfId = 'FAKE000000000001';
        inp.validatedRowsJson = '';

        Test.startTest();
        List<RosterStagingAction.Output> results = RosterStagingAction.execute(
            new List<RosterStagingAction.Input>{ inp }
        );
        Test.stopTest();

        System.assertEquals(false, results[0].success);
    }

    @IsTest
    static void testAllNewProviders() {
        String rowsJson = JSON.serialize(new List<Map<String, String>>{
            new Map<String, String>{
                'ProviderNpi' => '1234567890',
                'ProviderFirstName' => 'John',
                'ProviderLastName' => 'Doe',
                'CareSpecialty' => 'Cardiology',
                'EffectiveDate' => '2026-07-01'
            }
        });

        RosterStagingAction.Input inp = new RosterStagingAction.Input();
        inp.crfId = 'FAKE000000000001';
        inp.validatedRowsJson = rowsJson;

        Test.startTest();
        List<RosterStagingAction.Output> results = RosterStagingAction.execute(
            new List<RosterStagingAction.Input>{ inp }
        );
        Test.stopTest();

        // No existing HealthcareProvider records in test context — all should be "New"
        System.assertEquals(true, results[0].success);
        System.assertEquals(1, results[0].newCount);
        System.assertEquals(0, results[0].updatedCount);
        System.assertNotEquals(null, results[0].agentNarration);
    }

    @IsTest
    static void testNarrationContainsKeyCounts() {
        String rowsJson = JSON.serialize(new List<Map<String, String>>{
            new Map<String, String>{'ProviderNpi' => '1111111111', 'ProviderFirstName' => 'A', 'ProviderLastName' => 'B'},
            new Map<String, String>{'ProviderNpi' => '2222222222', 'ProviderFirstName' => 'C', 'ProviderLastName' => 'D'}
        });

        RosterStagingAction.Input inp = new RosterStagingAction.Input();
        inp.crfId = 'FAKE000000000002';
        inp.validatedRowsJson = rowsJson;

        Test.startTest();
        List<RosterStagingAction.Output> results = RosterStagingAction.execute(
            new List<RosterStagingAction.Input>{ inp }
        );
        Test.stopTest();

        System.assert(results[0].agentNarration.contains('2'), 'Narration should mention count');
        System.assertEquals(2, results[0].newCount);
    }
}
