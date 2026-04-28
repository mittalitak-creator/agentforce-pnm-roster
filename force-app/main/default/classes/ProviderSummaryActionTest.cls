/**
 * @description Test for ProviderSummaryAction (Get Provider Summary from DLO).
 */
@IsTest
private class ProviderSummaryActionTest {

    @IsTest
    static void testEmptyRequest() {
        List<ProviderSummaryAction.ProviderSummaryRequest> requests = new List<ProviderSummaryAction.ProviderSummaryRequest>();
        List<ProviderSummaryAction.ProviderSummaryResult> results = ProviderSummaryAction.getProviderSummary(requests);
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(false, results[0].success, 'Should fail when no request provided');
        System.assert(String.isNotBlank(results[0].errorMessage), 'Error message should be set');
    }

    @IsTest
    static void testNullRequest() {
        List<ProviderSummaryAction.ProviderSummaryResult> results = ProviderSummaryAction.getProviderSummary(null);
        System.assertNotEquals(null, results);
        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].success);
    }

    @IsTest
    static void testBlankNpi() {
        ProviderSummaryAction.ProviderSummaryRequest req = new ProviderSummaryAction.ProviderSummaryRequest();
        req.npi = '';
        List<ProviderSummaryAction.ProviderSummaryRequest> requests = new List<ProviderSummaryAction.ProviderSummaryRequest>{ req };
        List<ProviderSummaryAction.ProviderSummaryResult> results = ProviderSummaryAction.getProviderSummary(requests);
        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].success, 'Should fail when NPI is blank');
        System.assert(String.isNotBlank(results[0].errorMessage));
    }

    @IsTest
    static void testWhitespaceOnlyNpi() {
        ProviderSummaryAction.ProviderSummaryRequest req = new ProviderSummaryAction.ProviderSummaryRequest();
        req.npi = '   ';
        List<ProviderSummaryAction.ProviderSummaryRequest> requests = new List<ProviderSummaryAction.ProviderSummaryRequest>{ req };
        List<ProviderSummaryAction.ProviderSummaryResult> results = ProviderSummaryAction.getProviderSummary(requests);
        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].success);
    }

    @IsTest
    static void testValidNpiInvocation() {
        // With a real NPI: may succeed if DLO has data in this org, or fail with "no provider found" / exception
        ProviderSummaryAction.ProviderSummaryRequest req = new ProviderSummaryAction.ProviderSummaryRequest();
        req.npi = '1234567890';
        List<ProviderSummaryAction.ProviderSummaryRequest> requests = new List<ProviderSummaryAction.ProviderSummaryRequest>{ req };
        List<ProviderSummaryAction.ProviderSummaryResult> results = ProviderSummaryAction.getProviderSummary(requests);
        System.assertNotEquals(null, results);
        System.assertEquals(1, results.size());
        // Result is either success (provider found) or not (no row / error)
        System.assertNotEquals(null, results[0].success);
        System.assert(results[0].success == true || String.isNotBlank(results[0].summaryMessage) || String.isNotBlank(results[0].errorMessage));
    }
}
