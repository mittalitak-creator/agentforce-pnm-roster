// Create Sample Person Account Records for A&G Member Search
// Run this in Execute Anonymous Apex (Developer Console or VS Code)

List<Account> memberAccounts = new List<Account>();

// Person Account 1 - John Smith
memberAccounts.add(new Account(
    FirstName = 'John',
    LastName = 'Smith',
    Member_ID__c = 'MEM-001',
    PersonBirthdate = Date.newInstance(1985, 3, 15),
    PersonEmail = 'john.smith@example.com',
    Phone = '(555) 123-4567',
    PersonMailingStreet = '123 Main Street',
    PersonMailingCity = 'San Francisco',
    PersonMailingState = 'CA',
    PersonMailingPostalCode = '94102',
    PersonMailingCountry = 'USA'
));

// Person Account 2 - Jane Doe
memberAccounts.add(new Account(
    FirstName = 'Jane',
    LastName = 'Doe',
    Member_ID__c = 'MEM-002',
    PersonBirthdate = Date.newInstance(1990, 7, 22),
    PersonEmail = 'jane.doe@example.com',
    Phone = '(555) 234-5678',
    PersonMailingStreet = '456 Oak Avenue',
    PersonMailingCity = 'Los Angeles',
    PersonMailingState = 'CA',
    PersonMailingPostalCode = '90001',
    PersonMailingCountry = 'USA'
));

// Person Account 3 - Michael Johnson
memberAccounts.add(new Account(
    FirstName = 'Michael',
    LastName = 'Johnson',
    Member_ID__c = 'MEM-003',
    PersonBirthdate = Date.newInstance(1978, 11, 8),
    PersonEmail = 'michael.johnson@example.com',
    Phone = '(555) 345-6789',
    PersonMailingStreet = '789 Pine Road',
    PersonMailingCity = 'San Diego',
    PersonMailingState = 'CA',
    PersonMailingPostalCode = '92101',
    PersonMailingCountry = 'USA'
));

// Person Account 4 - Sarah Williams
memberAccounts.add(new Account(
    FirstName = 'Sarah',
    LastName = 'Williams',
    Member_ID__c = 'MEM-004',
    PersonBirthdate = Date.newInstance(1995, 5, 30),
    PersonEmail = 'sarah.williams@example.com',
    Phone = '(555) 456-7890',
    PersonMailingStreet = '321 Elm Street',
    PersonMailingCity = 'Sacramento',
    PersonMailingState = 'CA',
    PersonMailingPostalCode = '95814',
    PersonMailingCountry = 'USA'
));

// Person Account 5 - Robert Brown
memberAccounts.add(new Account(
    FirstName = 'Robert',
    LastName = 'Brown',
    Member_ID__c = 'MEM-005',
    PersonBirthdate = Date.newInstance(1982, 9, 12),
    PersonEmail = 'robert.brown@example.com',
    Phone = '(555) 567-8901',
    PersonMailingStreet = '654 Maple Drive',
    PersonMailingCity = 'Fresno',
    PersonMailingState = 'CA',
    PersonMailingPostalCode = '93721',
    PersonMailingCountry = 'USA'
));

// Insert the records
try {
    insert memberAccounts;
    System.debug('SUCCESS: Created ' + memberAccounts.size() + ' Person Account records');
    
    // Display the created accounts with their IDs
    for (Account acc : memberAccounts) {
        System.debug('Created Account: ' + acc.FirstName + ' ' + acc.LastName + ' - Member ID: ' + acc.Member_ID__c + ' (ID: ' + acc.Id + ')');
    }
    
    System.debug('');
    System.debug('===== MEMBER SEARCH TEST DATA =====');
    System.debug('Use these to test the A&G Intake Flow:');
    System.debug('');
    System.debug('1. John Smith - Member ID: MEM-001 - DOB: 03/15/1985');
    System.debug('2. Jane Doe - Member ID: MEM-002 - DOB: 07/22/1990');
    System.debug('3. Michael Johnson - Member ID: MEM-003 - DOB: 11/08/1978');
    System.debug('4. Sarah Williams - Member ID: MEM-004 - DOB: 05/30/1995');
    System.debug('5. Robert Brown - Member ID: MEM-005 - DOB: 09/12/1982');
    
} catch (DmlException e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('');
    System.debug('IMPORTANT: Person Accounts must be enabled in your org!');
    System.debug('Go to Setup -> Account Settings -> Enable Person Accounts');
}
