/**
 * Invocable Action: Read CRF record from Agentforce page context.
 * Called first by the Roster Manager agent on every session start.
 * Returns CRF state fields so the agent can resume from the correct workflow step.
 */
public with sharing class RosterContextAction {

    @InvocableMethod(
        label='Get Roster CRF Context'
        description='Reads the Case Related File record from page context and returns its current workflow stage, status, file name, and related IDs. Call this first on every agent session.'
        category='Provider Roster Management'
    )
    public static List<Output> execute(List<Input> inputs) {
        List<Output> results = new List<Output>();
        for (Input inp : inputs) {
            results.add(getCrfContext(inp.crfRecordId));
        }
        return results;
    }

    private static Output getCrfContext(String crfId) {
        Output out = new Output();

        if (String.isBlank(crfId)) {
            out.success = false;
            out.errorMessage = 'No Case Related File record ID provided. Please open a CRF record and re-invoke the agent, or provide a CRF record ID directly.';
            return out;
        }

        // Support both 18-char Salesforce ID and human-readable Name (e.g. CRF-000000001)
        String whereClause = (crfId.length() == 15 || crfId.length() == 18)
            ? 'WHERE Id = :crfId'
            : 'WHERE Name = :crfId';
        List<SObject> records = Database.query(
            'SELECT Id, Name, ProcessStage, ProcessStatus, ' +
            'SourceDatasetName, TargetDatasetName, ' +
            'ContentDocumentId, CaseId, ProcessDefinitionReferenceId ' +
            'FROM CaseRelatedFile ' +
            + whereClause +
            ' WITH USER_MODE ' +
            'LIMIT 1'
        );

        if (records.isEmpty()) {
            out.success = false;
            out.errorMessage = 'No Case Related File found for "' + crfId + '". Please check the record name or ID and try again.';
            out.agentResumeInstruction = 'ERROR: ' + out.errorMessage;
            return out;
        }

        SObject crf = records[0];
        out.success = true;
        out.crfId = (String) crf.get('Id');
        out.crfName = (String) crf.get('Name');
        out.processStage = (String) crf.get('ProcessStage');
        out.processStatus = (String) crf.get('ProcessStatus');
        out.sourceDatasetName = (String) crf.get('SourceDatasetName');
        out.targetDatasetName = (String) crf.get('TargetDatasetName');
        out.contentDocumentId = (String) crf.get('ContentDocumentId');
        out.caseId = (String) crf.get('CaseId');
        out.processDefinitionReferenceId = (String) crf.get('ProcessDefinitionReferenceId');

        // Derive a plain-English resume instruction for the agent
        out.agentResumeInstruction = buildResumeInstruction(out);
        return out;
    }

    private static String buildResumeInstruction(Output o) {
        String stage = o.processStage;
        String status = o.processStatus;

        if (String.isBlank(stage) && String.isBlank(status)) {
            return 'FRESH: CRF is new. Begin with pre-validation of the attached file, then trigger staging.';
        }
        if (stage == 'Staging' && status == 'InProgress') {
            return 'STAGING_RUNNING: Staging is currently in progress. Poll for completion before proceeding.';
        }
        if (stage == 'Staging' && status == 'Failed') {
            return 'STAGING_FAILED: Staging failed. Show the error to the admin and offer to re-stage after fixing the file.';
        }
        if (stage == 'Staging' && status == 'Complete') {
            return 'STAGED: Staging is complete. TargetDatasetName is set. Resume from Mapping step — trigger DPE Gen AI mapping.';
        }
        if (stage == 'Mapping' && status == 'InReview') {
            return 'MAPPING_IN_REVIEW: Mapping has been reviewed but not yet marked Completed. Prompt admin to open the CRF record and set Mapping status to Completed.';
        }
        if (stage == 'Mapping' && status == 'Complete') {
            return 'MAPPING_COMPLETE: Mapping is done. Offer to trigger DPE ingestion.';
        }
        if (stage == 'Processing' && status == 'InProgress') {
            return 'INGESTION_RUNNING: DPE ingestion is in progress. Notify admin and poll for completion.';
        }
        if (stage == 'Processing' && status == 'Failed') {
            return 'INGESTION_FAILED: DPE ingestion failed. Show error details and advise admin on next steps.';
        }
        if (stage == 'Processing' && status == 'Complete') {
            return 'INGESTION_COMPLETE: Ingestion is fully complete. Show the Post-Ingestion Summary (UI-2) and audit record.';
        }
        return 'UNKNOWN_STATE: Stage=' + stage + ', Status=' + status + '. Review CRF record manually.';
    }

    public class Input {
        @InvocableVariable(
            label='CRF Record ID'
            description='The CRF record ID or record name (e.g. CRF-000000001 or 1FxIf000000blRZKAY). Extract from what the user provides in their message.'
            required=true
        )
        public String crfRecordId;
    }

    public class Output {
        @InvocableVariable(label='Success') public Boolean success;
        @InvocableVariable(label='Error Message') public String errorMessage;
        @InvocableVariable(label='CRF ID') public String crfId;
        @InvocableVariable(label='CRF Name') public String crfName;
        @InvocableVariable(label='Process Stage') public String processStage;
        @InvocableVariable(label='Process Status') public String processStatus;
        @InvocableVariable(label='Source Dataset Name') public String sourceDatasetName;
        @InvocableVariable(label='Target Dataset Name') public String targetDatasetName;
        @InvocableVariable(label='Content Document ID') public String contentDocumentId;
        @InvocableVariable(label='Case ID') public String caseId;
        @InvocableVariable(label='Process Definition Reference ID') public String processDefinitionReferenceId;
        @InvocableVariable(
            label='Agent Resume Instruction'
            description='Plain-English instruction for the agent on which workflow step to resume from, derived from ProcessStage + ProcessStatus.'
        )
        public String agentResumeInstruction;
    }
}
