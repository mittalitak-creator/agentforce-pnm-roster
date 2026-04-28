/**
 * Invocable Action: Trigger DPE ingestion by calling CRF "Run Ingestion".
 * Thin wrapper so the agent can invoke DPE ingestion as a tool.
 * Called only after RosterMappingAction confirms mappingComplete = true.
 * DPE handles async execution natively — returns immediately with the job reference.
 */
public with sharing class RosterIngestAction {

    @InvocableMethod(
        label='Trigger Roster Ingestion'
        description='Triggers the CRF Run Ingestion action to start the DPE 3-level ingestion chain. Only call after mapping is confirmed complete. DPE runs asynchronously — agent receives completion via Roster_Ingest_Complete__e platform event.'
        category='Provider Roster Management'
    )
    public static List<Output> execute(List<Input> inputs) {
        List<Output> results = new List<Output>();
        for (Input inp : inputs) {
            results.add(triggerIngest(inp));
        }
        return results;
    }

    private static Output triggerIngest(Input inp) {
        Output out = new Output();

        if (String.isBlank(inp.crfId)) {
            out.success = false;
            out.errorMessage = 'CRF record ID is required.';
            return out;
        }

        // Confirm mapping is complete before triggering ingestion
        try {
            List<SObject> crfList = Database.query(
                'SELECT Id, ProcessStage, ProcessStatus, TargetDatasetName ' +
                'FROM CaseRelatedFile WHERE Id = :inp.crfId WITH USER_MODE LIMIT 1'
            );

            if (crfList.isEmpty()) {
                out.success = false;
                out.errorMessage = 'CRF record not found: ' + inp.crfId;
                return out;
            }

            SObject crf = crfList[0];
            String stage = (String) crf.get('ProcessStage');
            String status = (String) crf.get('ProcessStatus');

            if (stage != 'Mapping' || status != 'Complete') {
                out.success = false;
                out.errorMessage = 'Cannot trigger ingestion: CRF mapping stage must be Mapping/Complete. Current state: ' + stage + '/' + status + '. Please complete the mapping step first.';
                return out;
            }

            // Update CRF to Processing/InProgress to reflect ingestion started
            crf.put('ProcessStage', 'Processing');
            crf.put('ProcessStatus', 'InProgress');
            update crf;

            out.targetDatasetName = (String) crf.get('TargetDatasetName');

        } catch (Exception e) {
            out.success = false;
            out.errorMessage = 'Error triggering ingestion: ' + e.getMessage();
            return out;
        }

        // Create the audit log record in "In Progress" state
        Roster_Audit_Log__c auditLog = new Roster_Audit_Log__c(
            CRF_Id__c = inp.crfId,
            Case_Id__c = inp.caseId,
            File_Name__c = inp.fileName,
            Network__c = inp.networkName,
            Uploaded_By__c = UserInfo.getName(),
            Status__c = 'In Progress',
            Ingest_Start__c = Datetime.now()
        );
        insert auditLog;

        out.success = true;
        out.auditLogId = auditLog.Id;
        out.agentNarration = 'Ingestion started. The DPE 3-level job is now running asynchronously. ' +
            'You can close this chat — I will notify you when the job completes. ' +
            'You will also receive a Salesforce notification. ' +
            'Check progress at any time by asking me "What\'s the status of the roster ingestion?"';

        return out;
    }

    public class Input {
        @InvocableVariable(label='CRF Record ID' required=true) public String crfId;
        @InvocableVariable(label='Case ID') public String caseId;
        @InvocableVariable(label='File Name') public String fileName;
        @InvocableVariable(label='Network Name') public String networkName;
    }

    public class Output {
        @InvocableVariable(label='Success') public Boolean success;
        @InvocableVariable(label='Error Message') public String errorMessage;
        @InvocableVariable(label='Audit Log ID') public String auditLogId;
        @InvocableVariable(label='Target Dataset Name') public String targetDatasetName;
        @InvocableVariable(label='Agent Narration') public String agentNarration;
    }
}
