// Use existing Accounts and Contacts - create only 5 HealthcareProviders
List<Account> accts = [SELECT Id FROM Account ORDER BY CreatedDate DESC LIMIT 5];
List<Contact> cons = [SELECT Id FROM Contact ORDER BY CreatedDate DESC LIMIT 5];
if (accts.size() < 5 || cons.size() < 5) {
    System.debug('Need at least 5 Accounts and 5 Contacts. Found Account=' + accts.size() + ' Contact=' + cons.size());
} else {
    Schema.SObjectType t = Schema.getGlobalDescribe().get('HealthcareProvider');
    for (Integer i = 0; i < 5; i++) {
        SObject r = t.newSObject();
        r.put('name', 'Provider ' + (i+1));
        r.put('AccountId', accts[i].Id);
        r.put('PractitionerId', cons[i].Id);
        r.put('ProviderType', 'Hospital');
        r.put('ProviderClass', 'Medical Group');
        r.put('EffectiveFrom', Date.newInstance(2021, 2, 1));
        r.put('EffectiveTo', Date.newInstance(2034, 2, 27));
        r.put('Status', 'Active');
        r.put('IsActive', true);
        insert r;
        System.debug('Created Provider ' + (i+1) + ': ' + r.get('Id'));
    }
    System.debug('Done - 5 HealthcareProviders created.');
}
