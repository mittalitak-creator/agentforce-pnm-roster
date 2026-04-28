/**
 * Invocable Action: Trigger DPE Gen AI field mapping and poll CRF mapping status.
 *
 * Two modes (controlled by Input.mode):
 *   TRIGGER  — triggers CRF "Create/Select Mapping" and returns a deep link to the DPE mapping review screen.
 *   POLL     — reads current CRF ProcessStage + ProcessStatus and tells the agent whether
 *              the admin has completed the mapping step (set status to Completed).
 *
 * Platform behavior: after admin confirms Gen AI mapping in DPE UI,
 * CRF ProcessStage = Mapping, ProcessStatus = InReview (NOT auto-Completed).
 * Admin must manually set to Completed before ingestion can be triggered.
 */
public with sharing class RosterMappingAction {

    public static final String MODE_TRIGGER = 'TRIGGER';
    public static final String MODE_POLL = 'POLL';

    @InvocableMethod(
        label='Manage Roster Field Mapping'
        description='TRIGGER mode: triggers DPE Gen AI mapping and returns a deep link for the admin to review. POLL mode: checks whether the admin has marked the CRF mapping status as Completed.'
        category='Provider Roster Management'
    )
    public static List<Output> execute(List<Input> inputs) {
        List<Output> results = new List<Output>();
        for (Input inp : inputs) {
            results.add(inp.mode == MODE_POLL ? pollStatus(inp.crfId) : triggerMapping(inp));
        }
        return results;
    }

    private static Output triggerMapping(Input inp) {
        Output out = new Output();

        if (String.isBlank(inp.crfId)) {
            out.success = false;
            out.errorMessage = 'CRF record ID is required.';
            return out;
        }

        // Update CRF to reflect mapping has been triggered
        try {
            List<SObject> crfList = Database.query(
                'SELECT Id, ProcessStage__c, ProcessStatus__c ' +
                'FROM CaseRelatedFile WHERE Id = :inp.crfId WITH USER_MODE LIMIT 1'
            );
            if (!crfList.isEmpty()) {
                SObject crf = crfList[0];
                crf.put('ProcessStage__c', 'Mapping');
                crf.put('ProcessStatus__c', 'InProgress');
                update crf;
            }
        } catch (Exception e) {
            out.success = false;
            out.errorMessage = 'Could not update CRF mapping stage: ' + e.getMessage();
            return out;
        }

        out.success = true;
        out.mappingTriggered = true;
        // Deep link to the DPE mapping review screen for this CRF
        out.mappingReviewUrl = inp.orgBaseUrl + '/lightning/r/CaseRelatedFile/' + inp.crfId + '/view';
        out.agentNarration = 'DPE Gen AI field mapping has been triggered. ' +
            'Please open the mapping review screen and review the AI-suggested column → DLO field mappings. ' +
            'Once you have reviewed and confirmed the mappings in the DPE native UI, ' +
            'you will need to manually set the CRF mapping status from "In Review" to "Completed" ' +
            'on the Case Related File record before I can trigger ingestion.';
        return out;
    }

    private static Output pollStatus(String crfId) {
        Output out = new Output();

        if (String.isBlank(crfId)) {
            out.success = false;
            out.errorMessage = 'CRF record ID is required for polling.';
            return out;
        }

        try {
            List<SObject> crfList = Database.query(
                'SELECT Id, ProcessStage__c, ProcessStatus__c ' +
                'FROM CaseRelatedFile WHERE Id = :crfId WITH USER_MODE LIMIT 1'
            );
            if (crfList.isEmpty()) {
                out.success = false;
                out.errorMessage = 'CRF record not found: ' + crfId;
                return out;
            }

            SObject crf = crfList[0];
            String stage = (String) crf.get('ProcessStage__c');
            String status = (String) crf.get('ProcessStatus__c');

            out.success = true;
            out.currentStage = stage;
            out.currentStatus = status;
            out.mappingComplete = (stage == 'Mapping' && status == 'Complete');

            if (out.mappingComplete) {
                out.agentNarration = 'Mapping stage is Completed. Ready to trigger DPE ingestion.';
            } else if (stage == 'Mapping' && status == 'InReview') {
                out.agentNarration = 'Mapping has been reviewed but is still set to "In Review". ' +
                    'Please open the Case Related File record and manually change the mapping status from In Review to Completed. ' +
                    'Once done, come back here and I will trigger ingestion.';
            } else {
                out.agentNarration = 'Current CRF stage: ' + stage + ', status: ' + status + '. Mapping is not yet complete.';
            }
        } catch (Exception e) {
            out.success = false;
            out.errorMessage = 'Error polling CRF status: ' + e.getMessage();
        }

        return out;
    }

    public class Input {
        @InvocableVariable(
            label='Mode'
            description='TRIGGER to start mapping, POLL to check if admin has completed mapping.'
            required=true
        )
        public String mode;

        @InvocableVariable(label='CRF Record ID' required=true) public String crfId;

        @InvocableVariable(
            label='Org Base URL'
            description='Used to construct the DPE mapping review deep link. e.g. https://storm-155501697ec74d.my.salesforce.com'
        )
        public String orgBaseUrl;
    }

    public class Output {
        @InvocableVariable(label='Success') public Boolean success;
        @InvocableVariable(label='Error Message') public String errorMessage;
        @InvocableVariable(label='Mapping Triggered') public Boolean mappingTriggered;
        @InvocableVariable(label='Mapping Review URL') public String mappingReviewUrl;
        @InvocableVariable(label='Current Stage') public String currentStage;
        @InvocableVariable(label='Current Status') public String currentStatus;
        @InvocableVariable(label='Mapping Complete') public Boolean mappingComplete;
        @InvocableVariable(label='Agent Narration') public String agentNarration;
    }
}
