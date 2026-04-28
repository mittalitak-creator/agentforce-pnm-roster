// Create sample denied prior authorization (CareRequest) data
// This script creates sample CareRequest records with denied status

// Get some existing member accounts to associate with care requests
List<Account> members = [SELECT Id, Name, Member_ID__c FROM Account WHERE IsPersonAccount = true LIMIT 5];

if (members.isEmpty()) {
    System.debug('No Person Accounts found. Please create member accounts first.');
} else {
    List<CareRequest> careRequests = new List<CareRequest>();
    
    // Care Request 1 - Denied Prior Auth for Specialist Visit
    CareRequest cr1 = new CareRequest();
    cr1.AccountId = members[0].Id;
    cr1.Status = 'Denied';
    cr1.Type = 'Prior Authorization';
    cr1.Category = 'Specialist Consultation';
    cr1.Priority = 'Standard';
    cr1.RequestedStartDate = Date.today().addDays(-30);
    cr1.RequestedEndDate = Date.today().addDays(-30);
    cr1.Description = 'Prior auth for cardiologist consultation - denied due to lack of medical necessity documentation';
    careRequests.add(cr1);
    
    // Care Request 2 - Denied Prior Auth for Imaging
    CareRequest cr2 = new CareRequest();
    cr2.AccountId = members[1].Id;
    cr2.Status = 'Denied';
    cr2.Type = 'Prior Authorization';
    cr2.Category = 'Diagnostic Imaging';
    cr2.Priority = 'Standard';
    cr2.RequestedStartDate = Date.today().addDays(-45);
    cr2.RequestedEndDate = Date.today().addDays(-45);
    cr2.Description = 'CT scan prior authorization - denied as not meeting clinical criteria';
    careRequests.add(cr2);
    
    // Care Request 3 - Denied Prior Auth for Medication
    CareRequest cr3 = new CareRequest();
    cr3.AccountId = members[2].Id;
    cr3.Status = 'Denied';
    cr3.Type = 'Prior Authorization';
    cr3.Category = 'Pharmacy';
    cr3.Priority = 'Expedited';
    cr3.RequestedStartDate = Date.today().addDays(-20);
    cr3.RequestedEndDate = Date.today().addDays(-20);
    cr3.Description = 'Prior auth for specialty medication - denied, formulary alternatives available';
    careRequests.add(cr3);
    
    // Care Request 4 - Denied Prior Auth for Surgery
    CareRequest cr4 = new CareRequest();
    cr4.AccountId = members[3].Id;
    cr4.Status = 'Denied';
    cr4.Type = 'Prior Authorization';
    cr4.Category = 'Surgical Procedure';
    cr4.Priority = 'Standard';
    cr4.RequestedStartDate = Date.today().addDays(-60);
    cr4.RequestedEndDate = Date.today().addDays(-58);
    cr4.Description = 'Prior auth for knee replacement surgery - denied, conservative treatment not exhausted';
    careRequests.add(cr4);
    
    // Care Request 5 - Denied Prior Auth for Home Health
    CareRequest cr5 = new CareRequest();
    cr5.AccountId = members[4].Id;
    cr5.Status = 'Denied';
    cr5.Type = 'Prior Authorization';
    cr5.Category = 'Home Health Services';
    cr5.Priority = 'Standard';
    cr5.RequestedStartDate = Date.today().addDays(-15);
    cr5.RequestedEndDate = Date.today().addDays(15);
    cr5.Description = 'Prior auth for home health services - denied, does not meet homebound criteria';
    careRequests.add(cr5);
    
    try {
        insert careRequests;
        System.debug('Successfully created ' + careRequests.size() + ' denied prior authorization requests:');
        for (CareRequest cr : careRequests) {
            System.debug('Care Request ID: ' + cr.Id + ' - ' + cr.Description);
        }
    } catch (Exception e) {
        System.debug('Error creating care requests: ' + e.getMessage());
    }
}

