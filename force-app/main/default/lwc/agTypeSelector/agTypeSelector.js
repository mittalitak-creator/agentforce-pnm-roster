import { LightningElement, api } from 'lwc';

export default class AgTypeSelector extends LightningElement {
    @api selectedType;
    
    typeOptions = [
        {
            value: 'Appeal',
            label: 'Appeal',
            description: 'A request to review a decision about coverage, payment, or services.',
            examples: 'Examples: Denied claim, prior auth denial, formulary exception'
        },
        {
            value: 'Grievance',
            label: 'Grievance',
            description: 'A complaint about service quality, access to care, or provider behavior.',
            examples: 'Examples: Wait times, staff behavior, billing issues, quality concerns'
        }
    ];

    handleTypeSelect(event) {
        this.selectedType = event.currentTarget.dataset.value;
        
        // Dispatch event to notify parent or flow
        const selectEvent = new CustomEvent('typeselect', {
            detail: { selectedType: this.selectedType }
        });
        this.dispatchEvent(selectEvent);
    }

    get isAppealSelected() {
        return this.selectedType === 'Appeal';
    }

    get isGrievanceSelected() {
        return this.selectedType === 'Grievance';
    }
}
