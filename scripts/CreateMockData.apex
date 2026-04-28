/**
 * @description Script to create mock A&G data
 * Run this in Developer Console → Execute Anonymous
 */

// STEP 1: Create Mock Members (Person Accounts)
List<Account> members = new List<Account>();

members.add(new Account(
    FirstName = 'John',
    LastName = 'Doe',
    PersonBirthdate = Date.newInstance(1960, 5, 15),
    PersonEmail = 'john.doe@example.com',
    Phone = '555-1001',
    Member_Id__c = 'MEM001',
    PersonMailingStreet = '123 Main Street',
    PersonMailingCity = 'Springfield',
    PersonMailingState = 'IL',
    PersonMailingPostalCode = '62701'
));

members.add(new Account(
    FirstName = 'Jane',
    LastName = 'Smith',
    PersonBirthdate = Date.newInstance(1965, 8, 20),
    PersonEmail = 'jane.smith@example.com',
    Phone = '555-1002',
    Member_Id__c = 'MEM002',
    PersonMailingStreet = '456 Oak Avenue',
    PersonMailingCity = 'Chicago',
    PersonMailingState = 'IL',
    PersonMailingPostalCode = '60601'
));

members.add(new Account(
    FirstName = 'Robert',
    LastName = 'Johnson',
    PersonBirthdate = Date.newInstance(1955, 3, 10),
    PersonEmail = 'robert.johnson@example.com',
    Phone = '555-1003',
    Member_Id__c = 'MEM003',
    PersonMailingStreet = '789 Pine Road',
    PersonMailingCity = 'Naperville',
    PersonMailingState = 'IL',
    PersonMailingPostalCode = '60540'
));

members.add(new Account(
    FirstName = 'Maria',
    LastName = 'Garcia',
    PersonBirthdate = Date.newInstance(1970, 11, 25),
    PersonEmail = 'maria.garcia@example.com',
    Phone = '555-1004',
    Member_Id__c = 'MEM004',
    PersonMailingStreet = '321 Elm Street',
    PersonMailingCity = 'Rockford',
    PersonMailingState = 'IL',
    PersonMailingPostalCode = '61101'
));

members.add(new Account(
    FirstName = 'David',
    LastName = 'Lee',
    PersonBirthdate = Date.newInstance(1968, 7, 5),
    PersonEmail = 'david.lee@example.com',
    Phone = '555-1005',
    Member_Id__c = 'MEM005',
    PersonMailingStreet = '654 Maple Drive',
    PersonMailingCity = 'Peoria',
    PersonMailingState = 'IL',
    PersonMailingPostalCode = '61602'
));

try {
    insert members;
    System.debug('✅ SUCCESS: Created ' + members.size() + ' test members');
    System.debug('Member IDs: MEM001, MEM002, MEM003, MEM004, MEM005');
} catch (Exception e) {
    System.debug('❌ ERROR creating members: ' + e.getMessage());
}

// STEP 2: Create Mock A&G Cases
List<Case> agCases = new List<Case>();

// Get the member IDs we just created
List<Account> createdMembers = [SELECT Id, Member_Id__c FROM Account WHERE Member_Id__c IN ('MEM001', 'MEM002', 'MEM003', 'MEM004', 'MEM005')];

if (!createdMembers.isEmpty()) {
    // Appeal Case 1 - Part D Drug
    agCases.add(new Case(
        AccountId = createdMembers[0].Id,
        Subject = 'Appeal - Part D Drug - Formulary',
        Description = 'Requesting formulary exception for prescribed medication',
        Origin = 'Phone',
        Status = 'New',
        Priority = 'High',
        AG_Type__c = 'Appeal',
        Appeal_Type__c = 'Part D Drug - Formulary',
        Member_Id__c = 'MEM001',
        LOB__c = 'Medicare Advantage',
        Reason_For_Request__c = 'The prescribed medication (Eliquis) is not on the formulary. Alternative medications cause adverse effects including nausea and dizziness.',
        Organization_Received_Date__c = DateTime.now()
    ));
    
    // Appeal Case 2 - Inpatient Services
    agCases.add(new Case(
        AccountId = createdMembers[1].Id,
        Subject = 'Appeal - Inpatient Hospital Services',
        Description = 'Denial of emergency hospital admission coverage',
        Origin = 'Email',
        Status = 'New',
        Priority = 'High',
        AG_Type__c = 'Appeal',
        Appeal_Type__c = 'Inpatient Hospital Services',
        Member_Id__c = 'MEM002',
        LOB__c = 'Medicare Advantage',
        Reason_For_Request__c = 'Emergency admission for chest pain was denied as not medically necessary. Patient presented with acute symptoms requiring immediate care.',
        Organization_Received_Date__c = DateTime.now().addDays(-2)
    ));
    
    // Grievance Case 1 - Quality of Care
    agCases.add(new Case(
        AccountId = createdMembers[2].Id,
        Subject = 'Grievance - Quality of Care',
        Description = 'Complaint about provider quality of care',
        Origin = 'Web',
        Status = 'New',
        Priority = 'Medium',
        AG_Type__c = 'Grievance',
        Grievance_Type__c = 'Quality of Care',
        Member_Id__c = 'MEM003',
        LOB__c = 'Commercial',
        Reason_For_Request__c = 'Primary care physician did not perform adequate examination during visit. Symptoms were dismissed without proper diagnostic testing.',
        Organization_Received_Date__c = DateTime.now().addDays(-1)
    ));
    
    // Grievance Case 2 - Wait Time
    agCases.add(new Case(
        AccountId = createdMembers[3].Id,
        Subject = 'Grievance - Wait Time',
        Description = 'Complaint about excessive wait times',
        Origin = 'Phone',
        Status = 'New',
        Priority = 'Low',
        AG_Type__c = 'Grievance',
        Grievance_Type__c = 'Wait Time',
        Member_Id__c = 'MEM004',
        LOB__c = 'Medicare Advantage',
        Reason_For_Request__c = 'Waited 3 hours past scheduled appointment time. No explanation or apology provided by office staff.',
        Organization_Received_Date__c = DateTime.now().addDays(-3)
    ));
    
    // Appeal Case 3 - DME
    agCases.add(new Case(
        AccountId = createdMembers[4].Id,
        Subject = 'Appeal - DME',
        Description = 'Denial of durable medical equipment coverage',
        Origin = 'Fax',
        Status = 'New',
        Priority = 'Medium',
        AG_Type__c = 'Appeal',
        Appeal_Type__c = 'DME',
        Member_Id__c = 'MEM005',
        LOB__c = 'Part D',
        Reason_For_Request__c = 'Request for motorized wheelchair was denied. Patient has limited mobility due to severe arthritis and cannot use manual wheelchair.',
        Organization_Received_Date__c = DateTime.now().addDays(-5)
    ));
    
    try {
        insert agCases;
        System.debug('✅ SUCCESS: Created ' + agCases.size() + ' A&G cases');
        
        // Display case numbers
        List<Case> insertedCases = [SELECT CaseNumber, Subject FROM Case WHERE Id IN :agCases];
        for (Case c : insertedCases) {
            System.debug('Created: ' + c.CaseNumber + ' - ' + c.Subject);
        }
    } catch (Exception e) {
        System.debug('❌ ERROR creating cases: ' + e.getMessage());
    }
} else {
    System.debug('❌ ERROR: No members found. Please run member creation first.');
}

System.debug('');
System.debug('========================================');
System.debug('MOCK DATA CREATION COMPLETE');
System.debug('========================================');
System.debug('Members: 5 created (MEM001-MEM005)');
System.debug('Cases: 5 created (3 Appeals, 2 Grievances)');
System.debug('');
System.debug('Next steps:');
System.debug('1. Verify in Salesforce UI: Accounts tab and Cases tab');
System.debug('2. Test Member Search with MEM001, MEM002, etc.');
System.debug('3. Test Case Status with case numbers shown above');
System.debug('========================================');
