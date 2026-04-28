/**
 * Invocable Action: Run all pre-validation rules (Categories 1–6) on a roster CSV file.
 * Takes only crfId — reads the attached file directly from ContentVersion via ContentDocumentId__c.
 * Agentforce agents cannot supply file contents; the action fetches the file itself.
 */
public with sharing class RosterValidationAction {

    // Required column names (C3)
    private static final Set<String> REQUIRED_COLUMNS = new Set<String>{
        'ProviderNpi', 'ProviderNpiIsActive', 'ProviderFirstName', 'ProviderLastName'
    };

    // Boolean fields that must be exactly TRUE or FALSE (R5, R6)
    private static final Set<String> BOOLEAN_FIELDS = new Set<String>{
        'ProviderNpiIsActive'
    };

    // Date fields expecting yyyy-MM-dd (R3)
    private static final Set<String> DATE_FIELDS = new Set<String>{
        'EffectiveDate', 'TerminationDate', 'StartDate', 'EndDate'
    };

    // DateTime fields expecting yyyy-MM-ddThh:mm:ssZ (R4)
    private static final Set<String> DATETIME_FIELDS = new Set<String>{
        'CreatedDateTime', 'ModifiedDateTime'
    };

    @InvocableMethod(
        label='Validate Roster File'
        description='Runs all pre-validation rules on the roster CSV attached to the CRF record. Pass the CRF record ID — the action fetches the file directly. Returns pass/fail per rule and row errors for agent narration.'
        category='Provider Roster Management'
    )
    public static List<Output> execute(List<Input> inputs) {
        List<Output> results = new List<Output>();
        for (Input inp : inputs) {
            results.add(validate(inp));
        }
        return results;
    }

    private static Output validate(Input inp) {
        Output out = new Output();
        out.ruleResults = new List<RuleResult>();
        out.rowErrors = new List<RowError>();
        out.warnings = new List<RowError>();

        if (String.isBlank(inp.crfId)) {
            out.success = false;
            out.abortReason = 'CRF record ID is required.';
            out.agentNarration = 'Pre-validation aborted: no CRF record ID provided.';
            return out;
        }

        // ── Read file from CRF ContentDocumentId__c ─────────────────────────
        String fileName = '';
        String fileBody = '';
        Long fileSizeBytes = 0;

        try {
            String crfRef = inp.crfId;
            String crfWhere = (crfRef.length() == 15 || crfRef.length() == 18)
                ? 'WHERE Id = :crfRef'
                : 'WHERE Name = :crfRef';
            List<SObject> crfList = Database.query(
                'SELECT ContentDocumentId FROM CaseRelatedFile ' + crfWhere + ' WITH USER_MODE LIMIT 1'
            );
            if (crfList.isEmpty()) {
                out.success = false;
                out.abortReason = 'No Case Related File found for "' + inp.crfId + '". Please check the record name or ID.';
                out.agentNarration = 'Pre-validation aborted: ' + out.abortReason;
                return out;
            }
            String contentDocId = (String) crfList[0].get('ContentDocumentId');
            if (String.isBlank(contentDocId)) {
                out.success = false;
                out.abortReason = 'No file is attached to this CRF record. Please upload a CSV roster file first.';
                out.agentNarration = 'Pre-validation aborted: ' + out.abortReason;
                return out;
            }
            List<ContentVersion> cvList = [
                SELECT Title, FileExtension, ContentSize, VersionData
                FROM ContentVersion
                WHERE ContentDocumentId = :contentDocId
                AND IsLatest = true
                WITH USER_MODE
                LIMIT 1
            ];
            if (cvList.isEmpty()) {
                out.success = false;
                out.abortReason = 'Could not read the attached file. Please re-upload the file and try again.';
                out.agentNarration = 'Pre-validation aborted: ' + out.abortReason;
                return out;
            }
            ContentVersion cv = cvList[0];
            fileName = cv.Title + (cv.FileExtension != null ? '.' + cv.FileExtension : '');
            fileSizeBytes = cv.ContentSize;
            fileBody = cv.VersionData.toString();
        } catch (Exception e) {
            out.success = false;
            out.abortReason = 'Error reading attached file: ' + e.getMessage();
            out.agentNarration = 'Pre-validation aborted: ' + out.abortReason;
            return out;
        }

        // ── Category 1: File Structure ──────────────────────────────────────
        // F1: CSV only
        Boolean isCsv = fileName.toLowerCase().endsWith('.csv');
        out.ruleResults.add(ruleResult('F1', 'File format must be CSV', isCsv,
            isCsv ? null : 'File "' + fileName + '" is not a CSV. Only CSV files are accepted. How to fix: Convert your file to CSV format before uploading.'));
        if (!isCsv) {
            out.success = false;
            out.abortReason = 'File format is not CSV.';
            return out;
        }

        // F3: File size ≤ 5 MB
        Boolean sizeOk = fileSizeBytes <= 5242880;
        out.ruleResults.add(ruleResult('F3', 'File size ≤ 5 MB', sizeOk,
            sizeOk ? null : 'File is ' + (fileSizeBytes / 1048576.0).setScale(1) + ' MB. Maximum allowed size is 5 MB. How to fix: Split the file into smaller batches and upload each separately.'));
        if (!sizeOk) {
            out.success = false;
            out.abortReason = 'File exceeds 5 MB size limit.';
            return out;
        }

        // Parse CSV body
        if (String.isBlank(fileBody)) {
            out.ruleResults.add(ruleResult('F2', 'File must not be empty', false,
                'The file is empty (no content). How to fix: Ensure the file contains a header row and at least one data row.'));
            out.success = false;
            out.abortReason = 'File is empty.';
            return out;
        }

        List<List<String>> rows = parseCsv(fileBody);

        // F2: File not empty
        Boolean hasRows = rows != null && rows.size() > 1;
        out.ruleResults.add(ruleResult('F2', 'File must not be empty', hasRows,
            hasRows ? null : 'The file has no data rows. How to fix: Ensure the file contains a header row and at least one data row.'));
        if (!hasRows) {
            out.success = false;
            out.abortReason = 'File has no data rows.';
            return out;
        }

        // F5: First row is a header (first cell is not purely numeric)
        List<String> headers = rows[0];
        Boolean hasHeader = !isNumeric(headers[0]);
        out.ruleResults.add(ruleResult('F5', 'First row must be a header row', hasHeader,
            hasHeader ? null : 'The first row appears to be a data row, not a header. How to fix: Ensure the first row contains column names.'));
        if (!hasHeader) {
            out.success = false;
            out.abortReason = 'No header row detected.';
            return out;
        }

        // ── Category 2: Column Rules ────────────────────────────────────────
        // C1: Column names ≤ 40 chars, C2: No spaces
        List<String> badLengthCols = new List<String>();
        List<String> spacedCols = new List<String>();
        Map<String, Integer> headerIndex = new Map<String, Integer>();

        for (Integer i = 0; i < headers.size(); i++) {
            String col = headers[i].trim();
            headerIndex.put(col, i);
            if (col.length() > 40) badLengthCols.add(col);
            if (col.contains(' ')) spacedCols.add(col);
        }

        Boolean c1Pass = badLengthCols.isEmpty();
        out.ruleResults.add(ruleResult('C1', 'Column names ≤ 40 characters', c1Pass,
            c1Pass ? null : 'Column names exceed 40 characters: ' + String.join(badLengthCols, ', ') + '. How to fix: Shorten these column names to 40 characters or fewer.'));
        if (!c1Pass) { out.success = false; out.abortReason = 'Column name(s) too long.'; return out; }

        Boolean c2Pass = spacedCols.isEmpty();
        out.ruleResults.add(ruleResult('C2', 'Column names must have no spaces', c2Pass,
            c2Pass ? null : 'Column names contain spaces: ' + String.join(spacedCols, ', ') + '. How to fix: Replace spaces with underscores or use camelCase.'));
        if (!c2Pass) { out.success = false; out.abortReason = 'Column name(s) contain spaces.'; return out; }

        // C3: Required columns present
        List<String> missingCols = new List<String>();
        for (String req : REQUIRED_COLUMNS) {
            if (!headerIndex.containsKey(req)) missingCols.add(req);
        }
        Boolean c3Pass = missingCols.isEmpty();
        out.ruleResults.add(ruleResult('C3', 'Required columns present', c3Pass,
            c3Pass ? null : 'Required columns are missing: ' + String.join(missingCols, ', ') + '. How to fix: Add these columns to your file before uploading.'));
        if (!c3Pass) { out.success = false; out.abortReason = 'Missing required columns: ' + String.join(missingCols, ', '); return out; }

        // C5: Unknown columns (warn only)
        if (inp.knownColumns != null && !inp.knownColumns.isEmpty()) {
            Set<String> known = new Set<String>(inp.knownColumns);
            List<String> unknownCols = new List<String>();
            for (String col : headerIndex.keySet()) {
                if (!known.contains(col) && !REQUIRED_COLUMNS.contains(col)) unknownCols.add(col);
            }
            if (!unknownCols.isEmpty()) {
                RowError w = new RowError();
                w.ruleId = 'C5';
                w.rowNumber = 1;
                w.column = String.join(unknownCols, ', ');
                w.value = '';
                w.message = 'Unknown columns not in DPE mapping config: ' + String.join(unknownCols, ', ') + '. These columns will be ignored during ingestion.';
                w.fixInstruction = 'No action required. These columns will be skipped.';
                w.severity = 'Warning';
                out.warnings.add(w);
            }
        }

        // ── Query org data for cross-system checks ──────────────────────────
        Set<String> validNetworkNames = queryPicklistSet('HealthcarePayerNetwork', 'Name');
        Set<String> validCareSpecialties = queryPicklistSet('CareSpecialty', 'Name');
        Set<String> validCareServices = queryPicklistSet('CareService', 'Name');
        Set<String> validCareTaxonomies = queryPicklistSet('CareTaxonomy', 'Name');
        Set<String> validFacilities = queryPicklistSet('HealthcareFacility', 'Name');

        // Query picklist values for C4 — ProviderClass, ProviderType, Status
        Set<String> validProviderClass = getPicklistValues('HealthcareProvider', 'ProviderClass__c');
        Set<String> validProviderType = getPicklistValues('HealthcareProvider', 'ProviderType__c');

        // ── Row-level validation ────────────────────────────────────────────
        Set<String> seenNpis = new Set<String>();
        Set<String> seenNpiNetwork = new Set<String>();
        Integer validRowCount = 0;
        Integer skippedRowCount = 0;

        Integer npiColIdx = headerIndex.containsKey('ProviderNpi') ? headerIndex.get('ProviderNpi') : -1;
        Integer networkColIdx = headerIndex.containsKey('NetworkName') ? headerIndex.get('NetworkName') : -1;

        for (Integer rowIdx = 1; rowIdx < rows.size(); rowIdx++) {
            List<String> row = rows[rowIdx];
            Integer rowNum = rowIdx + 1;
            Boolean rowHasError = false;

            // Pad short rows
            while (row.size() < headers.size()) row.add('');

            String npiVal = npiColIdx >= 0 ? row[npiColIdx].trim() : '';
            String networkVal = networkColIdx >= 0 ? row[networkColIdx].trim() : '';

            // R7: Required fields not blank
            for (String reqCol : REQUIRED_COLUMNS) {
                Integer colIdx = headerIndex.containsKey(reqCol) ? headerIndex.get(reqCol) : -1;
                if (colIdx >= 0 && String.isBlank(row[colIdx])) {
                    out.rowErrors.add(rowError('R7', rowNum, reqCol, '',
                        'Required field is blank.',
                        'Go to row ' + rowNum + ', column ' + reqCol + ' and enter a value.', 'Error'));
                    rowHasError = true;
                }
            }

            // R1: NPI format — 10 digits numeric
            if (!String.isBlank(npiVal)) {
                Boolean npiFormatOk = isValidNpiFormat(npiVal);
                if (!npiFormatOk) {
                    out.rowErrors.add(rowError('R1', rowNum, 'ProviderNpi', npiVal,
                        'NPI "' + npiVal + '" is invalid — must be exactly 10 digits, numeric.',
                        'Go to row ' + rowNum + ', column ProviderNpi and enter a valid 10-digit NPI.', 'Error'));
                    rowHasError = true;
                } else {
                    // R2: NPI Luhn check
                    if (!isValidNpiLuhn(npiVal)) {
                        out.rowErrors.add(rowError('R2', rowNum, 'ProviderNpi', npiVal,
                            'NPI "' + npiVal + '" fails the Luhn check digit validation.',
                            'Verify the NPI for row ' + rowNum + ' with your source data — the check digit is incorrect.', 'Error'));
                        rowHasError = true;
                    }
                }
            }

            // R3: Date fields
            for (String dateCol : DATE_FIELDS) {
                if (!headerIndex.containsKey(dateCol)) continue;
                String val = row[headerIndex.get(dateCol)].trim();
                if (!String.isBlank(val) && !isValidDateFormat(val)) {
                    out.rowErrors.add(rowError('R3', rowNum, dateCol, val,
                        'Date value "' + val + '" must use format yyyy-MM-dd (e.g. 2025-06-15).',
                        'Go to row ' + rowNum + ', column ' + dateCol + ' and change to yyyy-MM-dd format.', 'Error'));
                    rowHasError = true;
                }
            }

            // R4: DateTime fields
            for (String dtCol : DATETIME_FIELDS) {
                if (!headerIndex.containsKey(dtCol)) continue;
                String val = row[headerIndex.get(dtCol)].trim();
                if (!String.isBlank(val) && !isValidDateTimeFormat(val)) {
                    out.rowErrors.add(rowError('R4', rowNum, dtCol, val,
                        'DateTime value "' + val + '" must use format yyyy-MM-ddThh:mm:ssZ (UTC).',
                        'Go to row ' + rowNum + ', column ' + dtCol + ' and change to ISO 8601 UTC format.', 'Error'));
                    rowHasError = true;
                }
            }

            // R5/R6: Boolean fields must be TRUE or FALSE (exact uppercase)
            for (String boolCol : BOOLEAN_FIELDS) {
                if (!headerIndex.containsKey(boolCol)) continue;
                String val = row[headerIndex.get(boolCol)].trim();
                if (!val.equals('TRUE') && !val.equals('FALSE')) {
                    out.rowErrors.add(rowError('R5', rowNum, boolCol, val,
                        '"' + val + '" is not a valid boolean. Must be exactly TRUE or FALSE (uppercase).',
                        'Go to row ' + rowNum + ', column ' + boolCol + ' and change to TRUE or FALSE.', 'Error'));
                    rowHasError = true;
                }
            }

            // C4: Picklist validation — ProviderClass
            if (headerIndex.containsKey('ProviderClass') && !validProviderClass.isEmpty()) {
                String val = row[headerIndex.get('ProviderClass')].trim();
                if (!String.isBlank(val) && !validProviderClass.contains(val)) {
                    out.rowErrors.add(rowError('C4', rowNum, 'ProviderClass', val,
                        '"' + val + '" is not a valid ProviderClass value. Valid values: ' + String.join(new List<String>(validProviderClass), ', ') + '.',
                        'Go to row ' + rowNum + ', column ProviderClass and change to a valid value.', 'Warning'));
                    rowHasError = true;
                }
            }

            // C4: ProviderType
            if (headerIndex.containsKey('ProviderType') && !validProviderType.isEmpty()) {
                String val = row[headerIndex.get('ProviderType')].trim();
                if (!String.isBlank(val) && !validProviderType.contains(val)) {
                    out.rowErrors.add(rowError('C4', rowNum, 'ProviderType', val,
                        '"' + val + '" is not a valid ProviderType value. Valid values: ' + String.join(new List<String>(validProviderType), ', ') + '.',
                        'Go to row ' + rowNum + ', column ProviderType and change to a valid value.', 'Warning'));
                    rowHasError = true;
                }
            }

            // X1: Duplicate NPI within file
            if (!String.isBlank(npiVal)) {
                if (seenNpis.contains(npiVal)) {
                    out.rowErrors.add(rowError('X1', rowNum, 'ProviderNpi', npiVal,
                        'NPI "' + npiVal + '" appears more than once in this file. Only the first occurrence will be processed.',
                        'Remove the duplicate entry at row ' + rowNum + '.', 'Error'));
                    rowHasError = true;
                } else {
                    seenNpis.add(npiVal);
                }
            }

            // X2: Duplicate NPI + Network within file
            if (!String.isBlank(npiVal) && !String.isBlank(networkVal)) {
                String npiNetworkKey = npiVal + '|' + networkVal;
                if (seenNpiNetwork.contains(npiNetworkKey)) {
                    out.rowErrors.add(rowError('X2', rowNum, 'ProviderNpi+NetworkName', npiVal + ' / ' + networkVal,
                        'Provider NPI "' + npiVal + '" appears twice for network "' + networkVal + '". A provider may only appear once per network.',
                        'Remove the duplicate network entry at row ' + rowNum + '.', 'Error'));
                    rowHasError = true;
                } else {
                    seenNpiNetwork.add(npiNetworkKey);
                }
            }

            // S2: Network name must match org HealthcarePayerNetwork
            if (!String.isBlank(networkVal) && !validNetworkNames.isEmpty() && !validNetworkNames.contains(networkVal)) {
                out.rowErrors.add(rowError('S2', rowNum, 'NetworkName', networkVal,
                    'Network "' + networkVal + '" not found in this org. Existing networks: ' + String.join(new List<String>(validNetworkNames), ', ') + '.',
                    'Verify the network name spelling, or create the HealthcarePayerNetwork record before uploading.', 'Error'));
                rowHasError = true;
            }

            // L1: CareSpecialty lookup
            if (headerIndex.containsKey('CareSpecialty') && !validCareSpecialties.isEmpty()) {
                String val = row[headerIndex.get('CareSpecialty')].trim();
                if (!String.isBlank(val) && !validCareSpecialties.contains(val)) {
                    out.rowErrors.add(rowError('L1', rowNum, 'CareSpecialty', val,
                        'CareSpecialty "' + val + '" does not exist in this org.',
                        'Create the CareSpecialty record in the org first, or correct the spelling in your file.', 'Error'));
                    rowHasError = true;
                }
            }

            // L2: CareService lookup
            if (headerIndex.containsKey('CareService') && !validCareServices.isEmpty()) {
                String val = row[headerIndex.get('CareService')].trim();
                if (!String.isBlank(val) && !validCareServices.contains(val)) {
                    out.rowErrors.add(rowError('L2', rowNum, 'CareService', val,
                        'CareService "' + val + '" does not exist in this org.',
                        'Create the CareService record in the org first, or correct the spelling.', 'Error'));
                    rowHasError = true;
                }
            }

            // L3: CareTaxonomy lookup
            if (headerIndex.containsKey('CareTaxonomy') && !validCareTaxonomies.isEmpty()) {
                String val = row[headerIndex.get('CareTaxonomy')].trim();
                if (!String.isBlank(val) && !validCareTaxonomies.contains(val)) {
                    out.rowErrors.add(rowError('L3', rowNum, 'CareTaxonomy', val,
                        'CareTaxonomy "' + val + '" does not exist in this org.',
                        'Create the CareTaxonomy record in the org first, or correct the spelling.', 'Error'));
                    rowHasError = true;
                }
            }

            // L4: HealthcareFacility lookup
            if (headerIndex.containsKey('HealthcareFacility') && !validFacilities.isEmpty()) {
                String val = row[headerIndex.get('HealthcareFacility')].trim();
                if (!String.isBlank(val) && !validFacilities.contains(val)) {
                    out.rowErrors.add(rowError('L4', rowNum, 'HealthcareFacility', val,
                        'HealthcareFacility "' + val + '" does not exist in this org.',
                        'Create the HealthcareFacility record in the org first, or correct the spelling.', 'Error'));
                    rowHasError = true;
                }
            }

            // L6: BusinessAccountId required when HealthcareFacility is present
            if (headerIndex.containsKey('HealthcareFacility') && headerIndex.containsKey('BusinessAccountId')) {
                String facilityVal = row[headerIndex.get('HealthcareFacility')].trim();
                String baId = row[headerIndex.get('BusinessAccountId')].trim();
                if (!String.isBlank(facilityVal) && String.isBlank(baId)) {
                    out.rowErrors.add(rowError('L6', rowNum, 'BusinessAccountId', '',
                        'BusinessAccountId is required when HealthcareFacility is specified, but is blank on row ' + rowNum + '.',
                        'Add the Salesforce Account ID (18-character) for the facility\'s business account in column BusinessAccountId.', 'Error'));
                    rowHasError = true;
                }
            }

            if (rowHasError) { skippedRowCount++; } else { validRowCount++; }
        }

        // ── Warning-only rules (Category 7) ────────────────────────────────
        // W4: >20% removal — evaluated by RosterStagingAction post-diff
        // W2, W3: specialty/tier change — evaluated by RosterStagingAction post-diff

        // ── Summary ────────────────────────────────────────────────────────
        out.totalRowsInFile = rows.size() - 1;
        out.validRowCount = validRowCount;
        out.skippedRowCount = skippedRowCount;
        out.warningCount = out.warnings.size();
        out.errorCount = out.rowErrors.size();

        Boolean anyAbortErrors = out.abortReason != null;
        out.success = !anyAbortErrors && out.rowErrors.isEmpty();
        out.hasBlockingErrors = !out.rowErrors.isEmpty();

        // Build validatedRowsJson for StageRosterFile — valid rows only
        Set<Integer> skippedRowNums = new Set<Integer>();
        for (RowError re : out.rowErrors) {
            if (re.rowNumber != null) skippedRowNums.add(re.rowNumber);
        }
        List<Map<String, String>> validRows = new List<Map<String, String>>();
        for (Integer rowIdx = 1; rowIdx < rows.size(); rowIdx++) {
            Integer rowNum = rowIdx + 1;
            if (!skippedRowNums.contains(rowNum)) {
                List<String> row = rows[rowIdx];
                Map<String, String> rowMap = new Map<String, String>();
                for (Integer ci = 0; ci < headers.size(); ci++) {
                    rowMap.put(headers[ci].trim(), ci < row.size() ? row[ci] : '');
                }
                validRows.add(rowMap);
            }
        }
        out.validatedRowsJson = JSON.serialize(validRows);

        out.agentNarration = buildNarration(out);
        return out;
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    private static RuleResult ruleResult(String id, String name, Boolean passed, String errorMsg) {
        RuleResult r = new RuleResult();
        r.ruleId = id;
        r.ruleName = name;
        r.passed = passed;
        r.errorMessage = passed ? null : errorMsg;
        return r;
    }

    private static RowError rowError(String ruleId, Integer rowNum, String col, String val, String msg, String fix, String severity) {
        RowError e = new RowError();
        e.ruleId = ruleId;
        e.rowNumber = rowNum;
        e.column = col;
        e.value = val;
        e.message = msg;
        e.fixInstruction = 'How to fix: ' + fix;
        e.severity = severity;
        return e;
    }

    private static Boolean isNumeric(String s) {
        return s != null && s.trim().isNumeric();
    }

    private static Boolean isValidNpiFormat(String npi) {
        return npi != null && npi.length() == 10 && npi.isNumeric();
    }

    // NPI Luhn check (mod-10 algorithm — standard NPI check digit)
    private static Boolean isValidNpiLuhn(String npi) {
        // Prepend '80840' per NPI standard before running Luhn
        String fullNpi = '80840' + npi;
        Integer sum = 0;
        Boolean alternate = false;
        for (Integer i = fullNpi.length() - 1; i >= 0; i--) {
            Integer digit = Integer.valueOf(fullNpi.substring(i, i + 1));
            if (alternate) {
                digit *= 2;
                if (digit > 9) digit -= 9;
            }
            sum += digit;
            alternate = !alternate;
        }
        return Math.mod(sum, 10) == 0;
    }

    // yyyy-MM-dd
    private static Boolean isValidDateFormat(String val) {
        if (val == null || val.length() != 10) return false;
        return val.mid(4,1) == '-' && val.mid(7,1) == '-'
            && val.substring(0,4).isNumeric()
            && val.substring(5,7).isNumeric()
            && val.substring(8,10).isNumeric();
    }

    // yyyy-MM-ddThh:mm:ssZ
    private static Boolean isValidDateTimeFormat(String val) {
        if (val == null || val.length() < 20) return false;
        return isValidDateFormat(val.substring(0, 10))
            && val.mid(10, 1) == 'T'
            && val.endsWith('Z');
    }

    private static Set<String> queryPicklistSet(String objectName, String fieldName) {
        Set<String> vals = new Set<String>();
        try {
            String q = 'SELECT ' + fieldName + ' FROM ' + objectName + ' WITH USER_MODE LIMIT 5000';
            for (SObject rec : Database.query(q)) {
                String v = (String) rec.get(fieldName);
                if (!String.isBlank(v)) vals.add(v);
            }
        } catch (Exception e) {
            // Object may not exist in org — return empty set; validation skips gracefully
        }
        return vals;
    }

    private static Set<String> getPicklistValues(String objectName, String fieldApiName) {
        Set<String> vals = new Set<String>();
        try {
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
            if (objType == null) return vals;
            Schema.DescribeFieldResult dfr = objType.getDescribe().fields.getMap().get(fieldApiName)?.getDescribe();
            if (dfr == null) return vals;
            for (Schema.PicklistEntry pe : dfr.getPicklistValues()) {
                if (pe.isActive()) vals.add(pe.getValue());
            }
        } catch (Exception e) {
            // Field may not exist — skip gracefully
        }
        return vals;
    }

    // Simple CSV parser — handles quoted fields with embedded commas/newlines
    private static List<List<String>> parseCsv(String body) {
        List<List<String>> allRows = new List<List<String>>();
        List<String> currentRow = new List<String>();
        String currentField = '';
        Boolean inQuotes = false;

        for (Integer i = 0; i < body.length(); i++) {
            String ch = body.substring(i, i + 1);
            String nextCh = (i + 1 < body.length()) ? body.substring(i + 1, i + 2) : '';

            if (inQuotes) {
                if (ch == '"' && nextCh == '"') {
                    currentField += '"';
                    i++;
                } else if (ch == '"') {
                    inQuotes = false;
                } else {
                    currentField += ch;
                }
            } else {
                if (ch == '"') {
                    inQuotes = true;
                } else if (ch == ',') {
                    currentRow.add(currentField);
                    currentField = '';
                } else if (ch == '\n' || ch == '\r') {
                    if (ch == '\r' && nextCh == '\n') i++;
                    currentRow.add(currentField);
                    currentField = '';
                    if (!currentRow.isEmpty()) allRows.add(currentRow);
                    currentRow = new List<String>();
                } else {
                    currentField += ch;
                }
            }
        }
        // Last field/row
        currentRow.add(currentField);
        if (!currentRow.isEmpty() && !(currentRow.size() == 1 && String.isBlank(currentRow[0]))) {
            allRows.add(currentRow);
        }
        return allRows;
    }

    private static String buildNarration(Output o) {
        if (o.abortReason != null) {
            return 'Pre-validation ABORTED: ' + o.abortReason + ' Please fix the issue and re-upload the file.';
        }
        List<String> parts = new List<String>();
        parts.add('Pre-validation complete for ' + o.totalRowsInFile + ' rows.');
        if (o.errorCount == 0 && o.warningCount == 0) {
            parts.add('All rules passed — ' + o.validRowCount + ' valid rows ready to stage.');
        } else {
            if (o.errorCount > 0) parts.add(o.errorCount + ' row error(s) found — affected rows will be skipped.');
            if (o.warningCount > 0) parts.add(o.warningCount + ' warning(s) — rows will be skipped during ingest.');
            parts.add(o.validRowCount + ' valid rows ready to proceed.');
        }
        return String.join(parts, ' ');
    }

    // ── Input / Output classes ────────────────────────────────────────────

    public class Input {
        @InvocableVariable(label='CRF Record ID' required=true
            description='The CRF record ID or record name (e.g. CRF-000000001 or 1FxIf000000blRZKAY). Extract from what the user provides.')
        public String crfId;
        @InvocableVariable(label='Known Column Names (from DPE mapping)') public List<String> knownColumns;
    }

    public class Output {
        @InvocableVariable(label='Success') public Boolean success;
        @InvocableVariable(label='Has Blocking Errors') public Boolean hasBlockingErrors;
        @InvocableVariable(label='Abort Reason') public String abortReason;
        @InvocableVariable(label='Total Rows In File') public Integer totalRowsInFile;
        @InvocableVariable(label='Valid Row Count') public Integer validRowCount;
        @InvocableVariable(label='Skipped Row Count') public Integer skippedRowCount;
        @InvocableVariable(label='Error Count') public Integer errorCount;
        @InvocableVariable(label='Warning Count') public Integer warningCount;
        @InvocableVariable(label='Rule Results') public List<RuleResult> ruleResults;
        @InvocableVariable(label='Row Errors') public List<RowError> rowErrors;
        @InvocableVariable(label='Warnings') public List<RowError> warnings;
        @InvocableVariable(label='Agent Narration') public String agentNarration;
        @InvocableVariable(label='Validated Rows JSON'
            description='JSON array of valid row maps. Pass directly to StageRosterFile — do not modify.')
        public String validatedRowsJson;
    }

    public class RuleResult {
        @InvocableVariable(label='Rule ID') public String ruleId;
        @InvocableVariable(label='Rule Name') public String ruleName;
        @InvocableVariable(label='Passed') public Boolean passed;
        @InvocableVariable(label='Error Message') public String errorMessage;
    }

    public class RowError {
        @InvocableVariable(label='Rule ID') public String ruleId;
        @InvocableVariable(label='Row Number') public Integer rowNumber;
        @InvocableVariable(label='Column') public String column;
        @InvocableVariable(label='Value') public String value;
        @InvocableVariable(label='Message') public String message;
        @InvocableVariable(label='Fix Instruction') public String fixInstruction;
        @InvocableVariable(label='Severity') public String severity;
    }
}
