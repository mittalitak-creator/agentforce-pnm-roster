import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import searchMember from '@salesforce/apex/MemberSearchAction.searchMember';
import createAGCase from '@salesforce/apex/CreateAGCaseAction.createAGCase';

export default class AgIntakeFlow extends LightningElement {
    // Step tracking
    @track currentStep = 'search'; // search, confirm, caseType, details, success
    
    // Member search
    @track memberId = '';
    @track firstName = '';
    @track lastName = '';
    @track dateOfBirth;
    @track isSearching = false;
    
    // Member details
    @track memberFound = false;
    @track memberDetails = {};
    @track accountId;
    @track lineOfBusiness;
    
    // Case type
    @track selectedCaseType;
    @track showCaseTypeSelection = false;
    
    // Details form
    @track showDetailsForm = false;
    @track selectedAppealType;
    @track selectedAppealSubType;
    @track selectedGrievanceType;
    @track selectedGrievanceSubType;
    @track selectedServiceType;
    @track reason = '';
    @track isUrgent = false;
    @track isSubmitting = false;
    
    // Success
    @track caseCreated = false;
    @track createdCase = {};
    
    // Options
    caseTypeOptions = [
        { label: 'Appeal', value: 'Appeal' },
        { label: 'Grievance', value: 'Grievance' }
    ];
    
    appealTypeOptions = [
        { label: 'Inpatient Hospital Services', value: 'Inpatient Hospital Services' },
        { label: 'Outpatient Services', value: 'Outpatient Services' },
        { label: 'Part D Drug - Formulary', value: 'Part D Drug - Formulary' },
        { label: 'Part D Drug - Prior Auth', value: 'Part D Drug - Prior Auth' },
        { label: 'DME', value: 'DME' }
    ];
    
    appealSubTypeOptions = [
        { label: 'Hospital Stay', value: 'Hospital Stay' },
        { label: 'Surgery', value: 'Surgery' },
        { label: 'Emergency Room', value: 'Emergency Room' },
        { label: 'Specialist Consultation', value: 'Specialist Consultation' },
        { label: 'Diagnostic Test', value: 'Diagnostic Test' },
        { label: 'Home Health Care', value: 'Home Health Care' },
        { label: 'Skilled Nursing Facility', value: 'Skilled Nursing Facility' },
        { label: 'Medication Coverage', value: 'Medication Coverage' },
        { label: 'Formulary Exception', value: 'Formulary Exception' },
        { label: 'Medical Equipment', value: 'Medical Equipment' },
        { label: 'Prosthetics', value: 'Prosthetics' },
        { label: 'Therapy Services', value: 'Therapy Services' },
        { label: 'Other', value: 'Other' }
    ];
    
    grievanceTypeOptions = [
        { label: 'Quality of Care', value: 'Quality of Care' },
        { label: 'Wait Time', value: 'Wait Time' },
        { label: 'Provider Communication', value: 'Provider Communication' },
        { label: 'Billing Issue', value: 'Billing Issue' },
        { label: 'Network Access', value: 'Network Access' }
    ];
    
    grievanceSubTypeOptions = [
        { label: 'Quality of Medical Care', value: 'Quality of Medical Care' },
        { label: 'Quality of Facility', value: 'Quality of Facility' },
        { label: 'Waiting Room Time', value: 'Waiting Room Time' },
        { label: 'Appointment Availability', value: 'Appointment Availability' },
        { label: 'Provider Attitude', value: 'Provider Attitude' },
        { label: 'Language Barrier', value: 'Language Barrier' },
        { label: 'Incorrect Billing', value: 'Incorrect Billing' },
        { label: 'Unexpected Costs', value: 'Unexpected Costs' },
        { label: 'Provider Not Available', value: 'Provider Not Available' },
        { label: 'Provider Not in Network', value: 'Provider Not in Network' },
        { label: 'Customer Service', value: 'Customer Service' },
        { label: 'Benefits Information', value: 'Benefits Information' },
        { label: 'Privacy Concern', value: 'Privacy Concern' },
        { label: 'Discrimination', value: 'Discrimination' },
        { label: 'Other', value: 'Other' }
    ];
    
    serviceTypeOptions = [
        { label: 'Pre-Service', value: 'Pre-Service' },
        { label: 'Post-Service', value: 'Post-Service' }
    ];
    
    // Computed properties
    get isAppeal() {
        return this.selectedCaseType === 'Appeal';
    }
    
    get isGrievance() {
        return this.selectedCaseType === 'Grievance';
    }
    
    get detailsFormTitle() {
        return this.isAppeal ? 'Appeal Details' : 'Grievance Details';
    }
    
    get detailsFormIcon() {
        return this.isAppeal ? 'standard:approval' : 'standard:case_comment';
    }
    
    get showAppealSubType() {
        return this.selectedAppealType && this.selectedAppealType !== '';
    }
    
    get showGrievanceSubType() {
        return this.selectedGrievanceType && this.selectedGrievanceType !== '';
    }
    
    get priorityClass() {
        return this.createdCase.priority === 'High' ? 'slds-theme_error' : '';
    }
    
    // Handlers
    handleMemberIdChange(event) {
        this.memberId = event.target.value;
    }
    
    handleFirstNameChange(event) {
        this.firstName = event.target.value;
    }
    
    handleLastNameChange(event) {
        this.lastName = event.target.value;
    }
    
    handleDobChange(event) {
        this.dateOfBirth = event.target.value;
    }
    
    handleSearchMember() {
        if (!this.memberId && (!this.firstName || !this.lastName || !this.dateOfBirth)) {
            this.showToast('Error', 'Please provide either Member ID or Name and Date of Birth', 'error');
            return;
        }
        
        this.isSearching = true;
        
        const request = {
            memberId: this.memberId || null,
            firstName: this.firstName || null,
            lastName: this.lastName || null,
            dateOfBirth: this.dateOfBirth || null
        };
        
        searchMember({ requests: [request] })
            .then(result => {
                if (result && result.length > 0 && result[0].success) {
                    const member = result[0];
                    this.accountId = member.accountId;
                    this.memberDetails = {
                        memberId: member.memberId,
                        fullName: `${member.firstName} ${member.lastName}`,
                        dateOfBirth: member.dateOfBirth,
                        lineOfBusiness: member.lineOfBusiness,
                        phone: member.phone,
                        email: member.email
                    };
                    this.lineOfBusiness = member.lineOfBusiness;
                    this.memberFound = true;
                    this.currentStep = 'confirm';
                } else {
                    this.showToast('Not Found', result[0].errorMessage || 'Member not found', 'warning');
                }
            })
            .catch(error => {
                this.showToast('Error', 'Error searching for member: ' + error.body.message, 'error');
            })
            .finally(() => {
                this.isSearching = false;
            });
    }
    
    handleConfirmMember() {
        this.showCaseTypeSelection = true;
        this.currentStep = 'caseType';
    }
    
    handleCaseTypeChange(event) {
        this.selectedCaseType = event.detail.value;
        this.showDetailsForm = true;
        this.currentStep = 'details';
    }
    
    handleAppealTypeChange(event) {
        this.selectedAppealType = event.detail.value;
    }
    
    handleAppealSubTypeChange(event) {
        this.selectedAppealSubType = event.detail.value;
    }
    
    handleGrievanceTypeChange(event) {
        this.selectedGrievanceType = event.detail.value;
    }
    
    handleGrievanceSubTypeChange(event) {
        this.selectedGrievanceSubType = event.detail.value;
    }
    
    handleServiceTypeChange(event) {
        this.selectedServiceType = event.detail.value;
    }
    
    handleReasonChange(event) {
        this.reason = event.target.value;
    }
    
    handleUrgencyChange(event) {
        this.isUrgent = event.target.checked;
    }
    
    handleBack() {
        if (this.currentStep === 'details') {
            this.showDetailsForm = false;
            this.currentStep = 'caseType';
        } else if (this.currentStep === 'caseType') {
            this.showCaseTypeSelection = false;
            this.currentStep = 'confirm';
        }
    }
    
    handleSubmitCase() {
        if (!this.validateForm()) {
            return;
        }
        
        this.isSubmitting = true;
        
        const caseRequest = {
            accountId: this.accountId,
            memberId: this.memberDetails.memberId,
            lineOfBusiness: this.lineOfBusiness,
            caseType: this.selectedCaseType,
            appealType: this.selectedAppealType || null,
            grievanceType: this.selectedGrievanceType || null,
            appealSubType: this.selectedAppealSubType || null,
            grievanceSubType: this.selectedGrievanceSubType || null,
            serviceType: this.selectedServiceType,
            reason: this.reason,
            isUrgent: this.isUrgent
        };
        
        createAGCase({ requests: [caseRequest] })
            .then(result => {
                if (result && result.length > 0 && result[0].success) {
                    this.createdCase = {
                        caseNumber: result[0].caseNumber,
                        caseId: result[0].caseId,
                        status: result[0].status,
                        priority: result[0].priority,
                        createdDate: new Date().toISOString()
                    };
                    this.caseCreated = true;
                    this.currentStep = 'success';
                    this.showDetailsForm = false;
                    this.showToast('Success', 'Case created successfully!', 'success');
                } else {
                    this.showToast('Error', result[0].errorMessage || 'Failed to create case', 'error');
                }
            })
            .catch(error => {
                this.showToast('Error', 'Error creating case: ' + error.body.message, 'error');
            })
            .finally(() => {
                this.isSubmitting = false;
            });
    }
    
    validateForm() {
        if (!this.selectedServiceType) {
            this.showToast('Required', 'Please select Service Type', 'warning');
            return false;
        }
        if (!this.reason || this.reason.trim() === '') {
            this.showToast('Required', 'Please provide a reason', 'warning');
            return false;
        }
        if (this.isAppeal && !this.selectedAppealType) {
            this.showToast('Required', 'Please select Appeal Type', 'warning');
            return false;
        }
        if (this.isGrievance && !this.selectedGrievanceType) {
            this.showToast('Required', 'Please select Grievance Type', 'warning');
            return false;
        }
        return true;
    }
    
    handleReset() {
        // Reset all data
        this.currentStep = 'search';
        this.memberId = '';
        this.firstName = '';
        this.lastName = '';
        this.dateOfBirth = null;
        this.memberFound = false;
        this.showCaseTypeSelection = false;
        this.showDetailsForm = false;
        this.caseCreated = false;
        this.selectedCaseType = null;
        this.selectedAppealType = null;
        this.selectedAppealSubType = null;
        this.selectedGrievanceType = null;
        this.selectedGrievanceSubType = null;
        this.selectedServiceType = null;
        this.reason = '';
        this.isUrgent = false;
    }
    
    handleViewCase() {
        // Navigate to case record
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.createdCase.caseId,
                objectApiName: 'Case',
                actionName: 'view'
            }
        });
    }
    
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}
