import { LightningElement, track } from 'lwc';
import createChecklist from '@salesforce/apex/IntakeChecklistManager.createChecklist';
import searchMember from '@salesforce/apex/MemberSearchService.searchMember';
import captureComplaint from '@salesforce/apex/ComplaintCaptureService.captureComplaint';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AgIntakeForm extends LightningElement {
    @track currentStep = 1;
    @track checklistId;
    @track memberId;
    @track memberName;
    @track progressPercentage = 0;
    @track tasksCompleted = [];
    
    // Form data
    @track formData = {
        // Step 1: Member Search
        memberId: '',
        firstName: '',
        lastName: '',
        dateOfBirth: '',
        
        // Step 2: Case Type
        caseType: '',
        
        // Step 3: Complaint Details
        category: '',
        subCategory: '',
        narrative: ''
    };
    
    @track showMemberResults = false;
    @track memberNotFound = false;
    @track multipleMembers = false;
    
    // Picklist options
    get caseTypeOptions() {
        return [
            { label: 'Appeal', value: 'Appeal' },
            { label: 'Grievance', value: 'Grievance' },
            { label: 'Dispute', value: 'Dispute' }
        ];
    }
    
    get categoryOptions() {
        if (this.formData.caseType === 'Appeal') {
            return [
                { label: 'Medical Necessity', value: 'Medical Necessity' },
                { label: 'Pharmacy (Part D)', value: 'Pharmacy (Part D)' },
                { label: 'Benefit Denial', value: 'Benefit Denial' },
                { label: 'Reimbursement', value: 'Reimbursement' }
            ];
        } else if (this.formData.caseType === 'Grievance') {
            return [
                { label: 'Quality of Care (QOC)', value: 'Quality of Care (QOC)' },
                { label: 'Access to Care', value: 'Access to Care' },
                { label: 'Interpersonal', value: 'Interpersonal' },
                { label: 'Administrative', value: 'Administrative' },
                { label: 'Timeliness', value: 'Timeliness' }
            ];
        }
        return [];
    }
    
    // Step visibility
    get isStep1() { return this.currentStep === 1; }
    get isStep2() { return this.currentStep === 2; }
    get isStep3() { return this.currentStep === 3; }
    get isStep4() { return this.currentStep === 4; }
    
    get showPrevious() { return this.currentStep > 1; }
    get showNext() { return this.currentStep < 4; }
    get showSubmit() { return this.currentStep === 4; }
    
    // Progress bar
    get progressValue() {
        return (this.currentStep / 4) * 100;
    }
    
    connectedCallback() {
        // Create checklist when component loads
        this.initializeIntake();
    }
    
    async initializeIntake() {
        try {
            const result = await createChecklist({ 
                requests: [{ 
                    conversationId: 'LWC-' + Date.now(),
                    caseType: ''
                }] 
            });
            
            if (result && result.length > 0) {
                this.checklistId = result[0].checklistId;
                this.progressPercentage = result[0].progressPercentage || 0;
                console.log('Checklist created:', this.checklistId);
            }
        } catch (error) {
            this.showToast('Error', 'Failed to initialize intake', 'error');
            console.error('Error creating checklist:', error);
        }
    }
    
    handleInputChange(event) {
        const field = event.target.dataset.field;
        this.formData[field] = event.target.value;
    }
    
    async handleSearchMember() {
        try {
            const result = await searchMember({
                requests: [{
                    memberId: this.formData.memberId,
                    firstName: this.formData.firstName,
                    lastName: this.formData.lastName,
                    dateOfBirth: this.formData.dateOfBirth,
                    checklistId: this.checklistId
                }]
            });
            
            if (result && result.length > 0) {
                const searchResult = result[0];
                
                if (searchResult.success && searchResult.found && searchResult.matchCount === 1) {
                    // Single member found
                    this.memberId = searchResult.memberId;
                    this.memberName = searchResult.memberName;
                    this.showMemberResults = true;
                    this.memberNotFound = false;
                    this.progressPercentage = 14; // Member Identified = 14%
                    this.tasksCompleted.push('✓ Member Identified');
                    this.showToast('Success', searchResult.message, 'success');
                } else if (searchResult.matchCount > 1) {
                    // Multiple members found
                    this.multipleMembers = true;
                    this.showToast('Multiple Matches', searchResult.message, 'warning');
                } else {
                    // No member found
                    this.memberNotFound = true;
                    this.showToast('Not Found', searchResult.message, 'error');
                }
            }
        } catch (error) {
            this.showToast('Error', 'Failed to search member', 'error');
            console.error('Error searching member:', error);
        }
    }
    
    handleNext() {
        if (this.validateCurrentStep()) {
            this.currentStep++;
            
            // If moving to step 3, capture complaint details
            if (this.currentStep === 3) {
                this.updateChecklistCaseType();
            }
        }
    }
    
    handlePrevious() {
        this.currentStep--;
    }
    
    async updateChecklistCaseType() {
        // Update checklist with case type when user selects it
        if (this.formData.caseType && this.checklistId) {
            // Note: Would need an update method in Apex, for now just tracking locally
            this.progressPercentage = 14; // Already at 14% from member identification
        }
    }
    
    async handleSubmit() {
        if (!this.validateCurrentStep()) return;
        
        try {
            // Capture complaint details
            const result = await captureComplaint({
                requests: [{
                    caseType: this.formData.caseType,
                    category: this.formData.category,
                    subCategory: this.formData.subCategory,
                    narrative: this.formData.narrative,
                    checklistId: this.checklistId
                }]
            });
            
            if (result && result.length > 0) {
                const captureResult = result[0];
                
                if (captureResult.success) {
                    this.progressPercentage = 29; // 14% + 15% = 29%
                    this.tasksCompleted.push('✓ Complaint Details Captured');
                    this.showToast('Success', 'Intake completed successfully!', 'success');
                    
                    // Show success view
                    this.currentStep = 4;
                } else {
                    this.showToast('Validation Error', captureResult.message, 'error');
                }
            }
        } catch (error) {
            this.showToast('Error', 'Failed to capture complaint details', 'error');
            console.error('Error capturing complaint:', error);
        }
    }
    
    validateCurrentStep() {
        if (this.currentStep === 1) {
            // Validate member search
            if (!this.memberId && !this.memberName) {
                this.showToast('Required', 'Please search and identify a member first', 'warning');
                return false;
            }
            return true;
        } else if (this.currentStep === 2) {
            // Validate case type
            if (!this.formData.caseType) {
                this.showToast('Required', 'Please select a case type', 'warning');
                return false;
            }
            return true;
        } else if (this.currentStep === 3) {
            // Validate complaint details
            if (!this.formData.category) {
                this.showToast('Required', 'Please select a category', 'warning');
                return false;
            }
            if (!this.formData.narrative) {
                this.showToast('Required', 'Please provide a narrative', 'warning');
                return false;
            }
            return true;
        }
        return true;
    }
    
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    
    handleStartNew() {
        // Reset form
        this.currentStep = 1;
        this.memberId = null;
        this.memberName = null;
        this.progressPercentage = 0;
        this.tasksCompleted = [];
        this.formData = {
            memberId: '',
            firstName: '',
            lastName: '',
            dateOfBirth: '',
            caseType: '',
            category: '',
            subCategory: '',
            narrative: ''
        };
        this.showMemberResults = false;
        this.memberNotFound = false;
        this.multipleMembers = false;
        
        // Create new checklist
        this.initializeIntake();
    }
}
