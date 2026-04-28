// Update existing Person Account records with Member IDs
// Run this in Execute Anonymous Apex (Developer Console or VS Code)

List<Account> existingMembers = [
    SELECT Id, FirstName, LastName, Member_ID__c
    FROM Account 
    WHERE Id IN ('001VF000003Um3tYAC', '001VF000003Um3uYAC', '001VF000003Um3vYAC', '001VF000003Um3wYAC', '001VF000003Um3xYAC')
    ORDER BY CreatedDate
];

if (existingMembers.size() > 0) {
    Integer counter = 1;
    for (Account acc : existingMembers) {
        acc.Member_ID__c = 'MEM-' + String.valueOf(counter).leftPad(3, '0');
        counter++;
    }
    
    update existingMembers;
    System.debug('✅ SUCCESS: Updated ' + existingMembers.size() + ' members with Member IDs');
    System.debug('');
    
    // Display the updated accounts
    for (Account acc : existingMembers) {
        System.debug('✓ ' + acc.FirstName + ' ' + acc.LastName + ' → Member ID: ' + acc.Member_ID__c);
    }
    
    System.debug('');
    System.debug('===== MEMBER IDs ASSIGNED =====');
    System.debug('1. John Smith - MEM-001');
    System.debug('2. Jane Doe - MEM-002');
    System.debug('3. Michael Johnson - MEM-003');
    System.debug('4. Sarah Williams - MEM-004');
    System.debug('5. Robert Brown - MEM-005');
    
} else {
    System.debug('❌ No accounts found. Please check the Account IDs.');
}


