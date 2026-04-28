/**
 * Service: Finalize the Roster_Audit_Log__c record after DPE ingestion completes.
 * Invoked by a Platform Event trigger on Roster_Ingest_Complete__e.
 * Fires Roster_Ingest_Complete__e to wake up the Agentforce conversation with UI-2.
 */
public with sharing class RosterAuditService {

    /**
     * Called from a trigger on Roster_Ingest_Complete__e (or directly by test/admin).
     * Updates the in-progress audit log with final counts and fires a completion event.
     */
    public static void finalizeAuditLog(
        String crfId,
        String auditLogId,
        String status,
        Integer rowsAdded,
        Integer rowsUpdated,
        Integer rowsSkipped,
        Integer rowsNoChange,
        String jobId,
        String errorDetails,
        String skippedRowsDetail
    ) {
        if (String.isBlank(auditLogId)) {
            // Try to find an in-progress audit log for this CRF
            List<Roster_Audit_Log__c> logs = [
                SELECT Id FROM Roster_Audit_Log__c
                WHERE CRF_Id__c = :crfId AND Status__c = 'In Progress'
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            if (!logs.isEmpty()) auditLogId = logs[0].Id;
        }

        if (!String.isBlank(auditLogId)) {
            Integer total = (rowsAdded != null ? rowsAdded : 0)
                          + (rowsUpdated != null ? rowsUpdated : 0)
                          + (rowsSkipped != null ? rowsSkipped : 0)
                          + (rowsNoChange != null ? rowsNoChange : 0);

            Roster_Audit_Log__c log = new Roster_Audit_Log__c(
                Id = auditLogId,
                Status__c = status,
                Rows_Added__c = rowsAdded,
                Rows_Updated__c = rowsUpdated,
                Rows_Skipped__c = rowsSkipped,
                Rows_No_Change__c = rowsNoChange,
                Total_Rows__c = total,
                Job_Id__c = jobId,
                Error_Details__c = errorDetails,
                Skipped_Rows_Detail__c = skippedRowsDetail,
                Ingest_End__c = Datetime.now()
            );
            update log;
        }

        // Fire platform event to wake up the Agentforce conversation
        Roster_Ingest_Complete__e evt = new Roster_Ingest_Complete__e(
            CRF_Id__c = crfId,
            Audit_Log_Id__c = auditLogId,
            Status__c = status
        );
        EventBus.publish(evt);
    }

    /**
     * Convenience method for Agentforce to retrieve audit summary for UI-2.
     */
    public static Roster_Audit_Log__c getAuditLog(String auditLogId) {
        if (String.isBlank(auditLogId)) return null;
        List<Roster_Audit_Log__c> logs = [
            SELECT Id, Name, File_Name__c, Uploaded_By__c, Network__c,
                   Total_Rows__c, Rows_Added__c, Rows_Updated__c, Rows_Skipped__c,
                   Rows_No_Change__c, Status__c, Error_Details__c,
                   Skipped_Rows_Detail__c, Ingest_Start__c, Ingest_End__c,
                   Job_Id__c, CRF_Id__c, Case_Id__c
            FROM Roster_Audit_Log__c
            WHERE Id = :auditLogId
            WITH USER_MODE
            LIMIT 1
        ];
        return logs.isEmpty() ? null : logs[0];
    }

    /**
     * Build the plain-English "What Changed" paragraph for UI-2.
     */
    public static String buildSummaryParagraph(Roster_Audit_Log__c log) {
        if (log == null) return 'Audit record not found.';

        String dateStr = log.Ingest_End__c != null
            ? log.Ingest_End__c.format('MMMM d, yyyy \'at\' h:mm a')
            : 'recently';

        Integer added = log.Rows_Added__c != null ? (Integer) log.Rows_Added__c : 0;
        Integer updated = log.Rows_Updated__c != null ? (Integer) log.Rows_Updated__c : 0;
        Integer skipped = log.Rows_Skipped__c != null ? (Integer) log.Rows_Skipped__c : 0;
        Integer noChange = log.Rows_No_Change__c != null ? (Integer) log.Rows_No_Change__c : 0;

        List<String> parts = new List<String>();
        parts.add('Your roster was processed on ' + dateStr + '.');
        if (added > 0) parts.add(added + ' new provider' + (added == 1 ? ' is' : 's are') + ' now active in the network.');
        if (updated > 0) parts.add(updated + ' existing provider' + (updated == 1 ? ' had their record' : 's had their records') + ' updated.');
        if (skipped > 0) parts.add(skipped + ' row' + (skipped == 1 ? ' was' : 's were') + ' skipped due to validation warnings — see details below.');
        if (noChange > 0) parts.add(noChange + ' provider' + (noChange == 1 ? ' had' : 's had') + ' no changes.');
        parts.add('Audit record: ' + log.Name + '.');

        return String.join(parts, ' ');
    }
}
