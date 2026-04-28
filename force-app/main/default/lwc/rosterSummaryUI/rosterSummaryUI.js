import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RosterSummaryUI extends NavigationMixin(LightningElement) {
    /** Audit log data from RosterAuditService */
    @api auditLog = {};

    @track skippedSectionOpen = false;

    skippedColumns = [
        { label: 'Row', fieldName: 'rowNumber', type: 'number', initialWidth: 80 },
        { label: 'Column', fieldName: 'column', type: 'text' },
        { label: 'Value', fieldName: 'value', type: 'text' },
        { label: 'Issue', fieldName: 'message', type: 'text', wrapText: true },
        { label: 'How to Fix', fieldName: 'fixInstruction', type: 'text', wrapText: true }
    ];

    // ── Computed properties ───────────────────────────────────────────────

    get isSuccess() {
        return this.auditLog && this.auditLog.status === 'Success';
    }

    get hasSkipped() {
        return this.auditLog && this.auditLog.rowsSkipped > 0;
    }

    get skippedBadgeLabel() {
        return `⚠ ${(this.auditLog && this.auditLog.rowsSkipped) || 0} Skipped`;
    }

    get skippedSectionClass() {
        return this.skippedSectionOpen ? 'slds-section slds-is-open' : 'slds-section';
    }

    get skippedSectionHidden() {
        return !this.skippedSectionOpen;
    }

    get hasSkippedDetail() {
        return this.skippedRows && this.skippedRows.length > 0;
    }

    get skippedRows() {
        if (!this.auditLog || !this.auditLog.skippedRowsDetail) return [];
        try {
            return JSON.parse(this.auditLog.skippedRowsDetail);
        } catch (e) {
            return [];
        }
    }

    get durationLabel() {
        if (!this.auditLog || !this.auditLog.ingestStart || !this.auditLog.ingestEnd) return '—';
        const start = new Date(this.auditLog.ingestStart);
        const end = new Date(this.auditLog.ingestEnd);
        const diffMs = end - start;
        if (diffMs < 0) return '—';
        const mins = Math.floor(diffMs / 60000);
        const secs = Math.floor((diffMs % 60000) / 1000);
        return mins > 0 ? `${mins} min ${secs} sec` : `${secs} sec`;
    }

    // ── Event handlers ────────────────────────────────────────────────────

    toggleSkipped() {
        this.skippedSectionOpen = !this.skippedSectionOpen;
    }

    handleViewAuditRecord() {
        if (!this.auditLog || !this.auditLog.id) return;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.auditLog.id,
                actionName: 'view'
            }
        });
    }

    handleDownloadAudit() {
        this.dispatchEvent(new CustomEvent('downloadauditreport', {
            detail: { auditLogId: this.auditLog && this.auditLog.id }
        }));
    }

    handleUploadAnother() {
        this.dispatchEvent(new CustomEvent('uploadanotheroster', {
            bubbles: true,
            composed: true
        }));
        this.dispatchEvent(new ShowToastEvent({
            title: 'Starting new upload',
            message: 'Ready to upload a new roster file.',
            variant: 'success'
        }));
    }
}
