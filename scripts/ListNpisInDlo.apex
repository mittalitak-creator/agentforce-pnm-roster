/**
 * Run in Execute Anonymous against the org with the DLO.
 * Tries multiple DLO table names, then prints NPI column values so you can see
 * which NPIs exist and in what format. Use one of these NPIs to test the agent.
 */
List<String> tableNames = new List<String>{
    'CanonicalData_PNM_Template_test__dll',
    'CanonicalData_PNM_Template_MT__dll',
    'CanonicalData_PNM_Template_MT'
};
String npiCol = 'ProviderNpi__c';
String kqCol = 'KQ_ProviderNpi__c';

ConnectApi.CdpQueryOutputV2 response = null;
String usedTable = null;

for (String tableName : tableNames) {
    try {
        String sql = 'SELECT "' + npiCol + '", "' + kqCol + '" FROM "' + tableName + '" LIMIT 10';
        ConnectApi.CdpQueryInput input = new ConnectApi.CdpQueryInput();
        input.sql = sql;
        ConnectApi.CdpQueryOutputV2 res = ConnectApi.CdpQuery.queryAnsiSqlV2(input);
        if (res != null && res.data != null && !res.data.isEmpty()) {
            response = res;
            usedTable = tableName;
            break;
        }
    } catch (Exception e) {
        // Table may not exist or wrong name; try next
        continue;
    }
}

if (response == null || response.data == null || response.data.isEmpty()) {
    System.debug('No rows in any DLO. Tried: ' + tableNames + '. Table may be empty or names may be wrong for this org.');
    System.debug('In Data 360, confirm the exact queryable table API name for your provider DLO and update this script.');
} else {
    System.debug('--- NPIs found in ' + usedTable + ' (first ' + response.data.size() + ' rows) ---');
    for (Integer i = 0; i < response.data.size(); i++) {
        ConnectApi.CdpQueryV2Row row = response.data[i];
        if (row != null && row.rowData != null && !row.rowData.isEmpty()) {
            Object npiVal = row.rowData[0];
            Object kqVal = row.rowData.size() > 1 ? row.rowData[1] : null;
            System.debug('Row ' + (i+1) + ': ProviderNpi__c=' + npiVal + ', KQ_ProviderNpi__c=' + kqVal);
        }
    }
    System.debug('--- Use one of these NPIs in the agent (exactly as shown). DLO table: ' + usedTable + ' ---');
}
