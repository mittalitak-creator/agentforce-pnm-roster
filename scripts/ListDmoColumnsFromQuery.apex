/**
 * Run in Execute Anonymous (Developer Console or sf apex run) against the org
 * that has the Data Cloud DMO CanonicalData_PNM_Template_test__dll.
 * Uses CdpQuery SELECT * LIMIT 1 and prints all column API names from the response metadata.
 * Replace npiValue with a valid NPI from your mock data if the table has no rows without a filter.
 */
String tableName = 'CanonicalData_PNM_Template_test__dll';
String npiColumn = 'ProviderNpi__c';
String npiValue = '1234567890'; // Replace with a valid NPI from your mock data, or use LIMIT 1 only

String sql = 'SELECT * FROM "' + tableName + '" LIMIT 1';
// If you need to filter by NPI to get a row: sql = 'SELECT * FROM "' + tableName + '" WHERE "' + npiColumn + '" = \'' + String.escapeSingleQuotes(npiValue) + '\' LIMIT 1';

ConnectApi.CdpQueryInput input = new ConnectApi.CdpQueryInput();
input.sql = sql;
ConnectApi.CdpQueryOutputV2 response = ConnectApi.CdpQuery.queryAnsiSqlV2(input);

if (response == null || response.metadata == null) {
    System.debug('No response or metadata. Check table name and org has Data Cloud access.');
} else {
    System.debug('--- Column API names for ' + tableName + ' ---');
    List<String> columns = new List<String>(response.metadata.keySet());
    columns.sort();
    for (String colName : columns) {
        System.debug(colName);
    }
    System.debug('--- End column list (' + columns.size() + ' columns) ---');
}
