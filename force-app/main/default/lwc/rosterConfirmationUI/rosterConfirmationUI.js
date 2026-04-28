import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RosterConfirmationUI extends LightningElement {
    /** Validation results from RosterValidationAction */
    @api validationSummary = {};
    /** Staging diff from RosterStagingAction */
    @api stagingSummary = {};
    /** CRF record ID */
    @api crfId;

    @track newSectionOpen = true;
    @track updatedSectionOpen = false;
    @track isConfirming = false;
    @track confirmMessage = '';

    // ── Column definitions ────────────────────────────────────────────────

    newColumns = [
        { label: 'NPI', fieldName: 'npi', type: 'text', cellAttributes: { alignment: 'left' } },
        { label: 'Name', fieldName: 'providerName', type: 'text' },
        { label: 'Specialty', fieldName: 'specialty', type: 'text' },
        { label: 'Network Tier', fieldName: 'networkTier', type: 'text' },
        { label: 'Effective Date', fieldName: 'effectiveDate', type: 'text' }
    ];

    updatedColumns = [
        { label: 'NPI', fieldName: 'npi', type: 'text' },
        { label: 'Name', fieldName: 'providerName', type: 'text' },
        { label: 'Changes', fieldName: 'changedFieldsSummary', type: 'text', wrapText: true }
    ];

    // ── Computed properties ───────────────────────────────────────────────

    get rulesPassedLabel() {
        const passed = (this.validationSummary && this.validationSummary.rulesPassed) || 0;
        return `${passed} rules passed`;
    }

    get warningsLabel() {
        const w = (this.validationSummary && this.validationSummary.warningCount) || 0;
        return `${w} warning${w === 1 ? '' : 's'}`;
    }

    get errorsLabel() {
        const e = (this.validationSummary && this.validationSummary.errorCount) || 0;
        return `${e} error${e === 1 ? '' : 's'}`;
    }

    get skippedLabel() {
        const s = (this.validationSummary && this.validationSummary.skippedRowCount) || 0;
        return `${s} rows skipped`;
    }

    get hasWarnings() {
        return (this.validationSummary && this.validationSummary.warningCount) > 0;
    }

    get hasErrors() {
        return (this.validationSummary && this.validationSummary.errorCount) > 0;
    }

    get hasSkipped() {
        return (this.validationSummary && this.validationSummary.skippedRowCount) > 0;
    }

    get hasNewProviders() {
        return this.stagingSummary && this.stagingSummary.newCount > 0;
    }

    get hasUpdatedProviders() {
        return this.stagingSummary && this.stagingSummary.updatedCount > 0;
    }

    get newBadgeLabel() {
        return `+ ${(this.stagingSummary && this.stagingSummary.newCount) || 0} New`;
    }

    get updatedBadgeLabel() {
        return `~ ${(this.stagingSummary && this.stagingSummary.updatedCount) || 0} Updated`;
    }

    get newSectionClass() {
        return this.newSectionOpen ? 'slds-section slds-is-open' : 'slds-section';
    }

    get updatedSectionClass() {
        return this.updatedSectionOpen ? 'slds-section slds-is-open' : 'slds-section';
    }

    get newSectionHidden() {
        return !this.newSectionOpen;
    }

    get updatedSectionHidden() {
        return !this.updatedSectionOpen;
    }

    get hasValidationWarnings() {
        return this.hasWarnings || this.hasSkipped;
    }

    get validationWarningText() {
        const parts = [];
        if (this.hasErrors) parts.push(`${this.validationSummary.errorCount} rows have errors`);
        if (this.hasWarnings) parts.push(`${this.validationSummary.warningCount} rows have picklist warnings`);
        return parts.join(' · ') + ' — these rows will be skipped during ingestion.';
    }

    // ── Event handlers ────────────────────────────────────────────────────

    toggleNew() {
        this.newSectionOpen = !this.newSectionOpen;
    }

    toggleUpdated() {
        this.updatedSectionOpen = !this.updatedSectionOpen;
    }

    handleDownload() {
        this.dispatchEvent(new CustomEvent('downloadchangereport', {
            detail: { crfId: this.crfId }
        }));
    }

    handleConfirm() {
        this.isConfirming = true;
        this.confirmMessage = 'Confirmed. Triggering DPE Gen AI field mapping now...';
        this.dispatchEvent(new CustomEvent('confirmmapping', {
            detail: { crfId: this.crfId },
            bubbles: true,
            composed: true
        }));
        this.dispatchEvent(new ShowToastEvent({
            title: 'Confirmed',
            message: 'Staging confirmed. Proceeding to field mapping.',
            variant: 'success'
        }));
    }
}
