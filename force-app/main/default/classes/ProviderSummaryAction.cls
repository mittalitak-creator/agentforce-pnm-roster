/**
 * @description Invocable action for Agentforce: get a single provider summary from
 *              CanonicalData_PNM_Template_test__dll DLO in Data Cloud.
 *              Query by NPI and return a formatted summary message + optional structured fields.
 *              Field API names aligned with DLO metadata (485 fields).
 */
public with sharing class ProviderSummaryAction {

    /** DLO table name in Data 360 (use double quotes in SQL if case-sensitive). */
    private static final String DLO_TABLE = 'CanonicalData_PNM_Template_test__dll';
    /** NPI column API name in the DLO. */
    private static final String NPI_COLUMN = 'ProviderNpi__c';
    /** Key qualifier NPI column (fallback if ProviderNpi__c returns no rows). */
    private static final String NPI_COLUMN_KQ = 'KQ_ProviderNpi__c';

    /**
     * @description Get provider summary by NPI from the PNM canonical DLO.
     * @param requests List of one request (NPI required).
     * @return List of one result (success, summaryMessage, and optional structured fields).
     */
    @InvocableMethod(
        label='Get Provider Summary'
        description='Returns a single provider summary from the PNM canonical DLO by NPI (provider, NPI, award, license, specialty, etc.)'
        category='Provider Summary'
    )
    public static List<ProviderSummaryResult> getProviderSummary(List<ProviderSummaryRequest> requests) {
        List<ProviderSummaryResult> results = new List<ProviderSummaryResult>();
        if (requests == null || requests.isEmpty()) {
            results.add(buildErrorResult('No request provided. Please supply an NPI.'));
            return results;
        }
        ProviderSummaryRequest req = requests[0];
        if (String.isBlank(req.npi)) {
            results.add(buildErrorResult('NPI is required to get a provider summary.'));
            return results;
        }
        results.add(processProviderSummary(req.npi.trim()));
        return results;
    }

    private static ProviderSummaryResult processProviderSummary(String npi) {
        ProviderSummaryResult result = new ProviderSummaryResult();
        try {
            String safeNpi = String.escapeSingleQuotes(npi);
            ConnectApi.CdpQueryOutputV2 response = runDloQuery(NPI_COLUMN, safeNpi);
            if (response == null || response.data == null || response.data.isEmpty()) {
                response = runDloQuery(NPI_COLUMN_KQ, safeNpi);
            }
            if (response == null || response.data == null || response.data.isEmpty()) {
                result.success = false;
                result.summaryMessage = 'No provider found for NPI ' + npi + '.';
                result.errorMessage = result.summaryMessage;
                return result;
            }

            ConnectApi.CdpQueryV2Row row = response.data[0];
            Map<String, Object> rowMap = buildRowMap(response.metadata, row);
            result.success = true;
            result.summaryMessage = formatSummaryMessage(npi, rowMap);
            result.errorMessage = null;
            // Structured fields – API names from CanonicalData_PNM_Template_test__dll
            result.providerName = getProviderNameFromRow(rowMap);
            result.npi = npi;
            result.award = getString(rowMap, new List<String>{ 'Award1Name__c', 'Award2Name__c', 'Award1AwardedBy__c' });
            result.license = getString(rowMap, new List<String>{ 'BusinessLicense1LicenseNumber__c', 'BusinessLicense1Name__c' });
            result.specialty = getString(rowMap, new List<String>{ 'CareSpecialty1Name__c', 'CareSpecialty2Name__c', 'CareServiceName__c' });
            result.city = getString(rowMap, new List<String>{ 'ProviderMailingCity__c', 'ProviderBillingCity__c', 'ProviderOtherCity__c' });
            result.state = getString(rowMap, new List<String>{ 'ProviderMailingState__c', 'ProviderBillingState__c', 'ProviderOtherState__c' });
            result.zip = getString(rowMap, new List<String>{ 'ProviderMailingPostalCode__c', 'ProviderBillingPostalCode__c', 'ProviderOtherPostalCode__c' });
        } catch (Exception e) {
            result.success = false;
            result.summaryMessage = 'Unable to retrieve provider summary for NPI ' + npi + '.';
            result.errorMessage = result.summaryMessage + ' Error: ' + e.getMessage();
        }
        return result;
    }

    /** Run DLO query by NPI using the given column name (ProviderNpi__c or KQ_ProviderNpi__c). */
    private static ConnectApi.CdpQueryOutputV2 runDloQuery(String npiColumn, String safeNpi) {
        String sql = 'SELECT * FROM "' + DLO_TABLE + '" WHERE "' + npiColumn + '" = \'' + safeNpi + '\' LIMIT 1';
        ConnectApi.CdpQueryInput input = new ConnectApi.CdpQueryInput();
        input.sql = sql;
        return ConnectApi.CdpQuery.queryAnsiSqlV2(input);
    }

    /** Build map of column name (lowercase) -> value from metadata order and rowData. */
    private static Map<String, Object> buildRowMap(Map<String, ConnectApi.CdpQueryMetadataItem> metadata, ConnectApi.CdpQueryV2Row row) {
        Map<String, Object> rowMap = new Map<String, Object>();
        if (metadata == null || row == null || row.rowData == null) {
            return rowMap;
        }
        List<ColumnOrder> columnOrders = new List<ColumnOrder>();
        for (String colName : metadata.keySet()) {
            ConnectApi.CdpQueryMetadataItem item = metadata.get(colName);
            if (item != null && item.placeInOrder != null) {
                columnOrders.add(new ColumnOrder(item.placeInOrder, colName));
            }
        }
        columnOrders.sort();
        List<String> orderedColumns = new List<String>();
        for (ColumnOrder co : columnOrders) {
            orderedColumns.add(co.columnName);
        }
        List<Object> values = row.rowData;
        for (Integer i = 0; i < orderedColumns.size() && i < values.size(); i++) {
            rowMap.put(orderedColumns[i].toLowerCase(), values[i]);
        }
        return rowMap;
    }

    /** Wrapper for column order used when parsing CdpQuery metadata. */
    private class ColumnOrder implements Comparable {
        private Integer placeInOrder;
        private String columnName;
        ColumnOrder(Integer placeInOrder, String columnName) {
            this.placeInOrder = placeInOrder;
            this.columnName = columnName;
        }
        public Integer compareTo(Object other) {
            ColumnOrder o = (ColumnOrder) other;
            return this.placeInOrder - o.placeInOrder;
        }
    }

    /** Build provider display name from Salutation, FirstName, MiddleName, LastName, Title. */
    private static String getProviderNameFromRow(Map<String, Object> rowMap) {
        if (rowMap == null) return null;
        List<String> parts = new List<String>();
        String s = getString(rowMap, new List<String>{ 'ProviderSalutation__c' });
        if (String.isNotBlank(s)) parts.add(s);
        String f = getString(rowMap, new List<String>{ 'ProviderFirstName__c' });
        if (String.isNotBlank(f)) parts.add(f);
        String m = getString(rowMap, new List<String>{ 'ProviderMiddleName__c' });
        if (String.isNotBlank(m)) parts.add(m);
        String l = getString(rowMap, new List<String>{ 'ProviderLastName__c' });
        if (String.isNotBlank(l)) parts.add(l);
        String t = getString(rowMap, new List<String>{ 'ProviderTitle__c' });
        if (String.isNotBlank(t)) parts.add(t);
        if (parts.isEmpty()) return null;
        return String.join(parts, ' ').trim();
    }

    /** First non-blank string from rowMap for given possible keys (case-insensitive). */
    private static String getString(Map<String, Object> rowMap, List<String> possibleKeys) {
        if (rowMap == null) {
            return null;
        }
        for (String key : possibleKeys) {
            Object val = rowMap.get(key.toLowerCase());
            if (val != null && String.isNotBlank(String.valueOf(val))) {
                return String.valueOf(val).trim();
            }
        }
        return null;
    }

    private static String formatSummaryMessage(String npi, Map<String, Object> rowMap) {
        List<String> lines = new List<String>();
        String name = getProviderNameFromRow(rowMap);
        if (String.isNotBlank(name)) {
            lines.add('Provider: ' + name);
        }
        lines.add('NPI: ' + npi);
        String specialty = getString(rowMap, new List<String>{ 'CareSpecialty1Name__c', 'CareSpecialty2Name__c', 'CareServiceName__c' });
        if (String.isNotBlank(specialty)) {
            lines.add('Specialty: ' + specialty);
        }
        String award = getString(rowMap, new List<String>{ 'Award1Name__c', 'Award2Name__c', 'Award1AwardedBy__c' });
        if (String.isNotBlank(award)) {
            lines.add('Award: ' + award);
        }
        String license = getString(rowMap, new List<String>{ 'BusinessLicense1LicenseNumber__c', 'BusinessLicense1Name__c' });
        if (String.isNotBlank(license)) {
            lines.add('License: ' + license);
        }
        String city = getString(rowMap, new List<String>{ 'ProviderMailingCity__c', 'ProviderBillingCity__c', 'ProviderOtherCity__c' });
        String state = getString(rowMap, new List<String>{ 'ProviderMailingState__c', 'ProviderBillingState__c', 'ProviderOtherState__c' });
        String zip = getString(rowMap, new List<String>{ 'ProviderMailingPostalCode__c', 'ProviderBillingPostalCode__c', 'ProviderOtherPostalCode__c' });
        if (String.isNotBlank(city) || String.isNotBlank(state) || String.isNotBlank(zip)) {
            List<String> loc = new List<String>();
            if (String.isNotBlank(city)) loc.add(city);
            if (String.isNotBlank(state)) loc.add(state);
            if (String.isNotBlank(zip)) loc.add(zip);
            lines.add('Location: ' + String.join(loc, ', '));
        }
        String status = getString(rowMap, new List<String>{ 'ProviderStatus__c', 'ProviderIsActive__c' });
        if (String.isNotBlank(status)) {
            lines.add('Status: ' + status);
        }
        if (lines.isEmpty()) {
            return 'Provider found for NPI ' + npi + '. (No additional details in the record.)';
        }
        return String.join(lines, '. ');
    }

    private static ProviderSummaryResult buildErrorResult(String msg) {
        ProviderSummaryResult r = new ProviderSummaryResult();
        r.success = false;
        r.summaryMessage = msg;
        r.errorMessage = msg;
        return r;
    }

    // --- Request / Result inner classes ---

    public class ProviderSummaryRequest {
        @InvocableVariable(label='NPI' description='National Provider Identifier (required)' required=true)
        public String npi;
    }

    public class ProviderSummaryResult {
        @InvocableVariable(label='Success' description='Whether the summary was retrieved')
        public Boolean success;
        @InvocableVariable(label='Summary Message' description='Formatted summary for the agent to read')
        public String summaryMessage;
        @InvocableVariable(label='Error Message' description='Error message if failed')
        public String errorMessage;
        @InvocableVariable(label='Provider Name' description='Provider name from DLO')
        public String providerName;
        @InvocableVariable(label='NPI' description='NPI')
        public String npi;
        @InvocableVariable(label='Award' description='Award from DLO')
        public String award;
        @InvocableVariable(label='License' description='License from DLO')
        public String license;
        @InvocableVariable(label='Specialty' description='Specialty from DLO')
        public String specialty;
        @InvocableVariable(label='City' description='City from DLO')
        public String city;
        @InvocableVariable(label='State' description='State from DLO')
        public String state;
        @InvocableVariable(label='Zip' description='Zip/Postal code from DLO')
        public String zip;
    }
}
