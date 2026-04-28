// STEP 1: Create Mock Members ONLY (doesn't depend on new Case fields)
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
    System.debug('======================================');
    System.debug('SUCCESS: Created ' + members.size() + ' test members');
    System.debug('======================================');
    for (Account m : members) {
        System.debug('Created: ' + m.Member_Id__c + ' - ' + m.FirstName + ' ' + m.LastName);
    }
    System.debug('======================================');
} catch (Exception e) {
    System.debug('ERROR creating members: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
