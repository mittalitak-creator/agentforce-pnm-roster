// Run only: 5 Accounts, 5 Contacts, 5 HealthcareProviders
String NS = '';
List<Id> accountIds = new List<Id>();
List<Id> contactIds = new List<Id>();
List<Id> providerIds = new List<Id>();

for (Integer i = 1; i <= 5; i++) {
    Account a = new Account(Name = 'Provider Org ' + i);
    insert a;
    accountIds.add(a.Id);
}
for (Integer i = 0; i < 5; i++) {
    Contact c = new Contact(FirstName = 'Provider', LastName = 'Contact' + (i+1), AccountId = accountIds[i]);
    insert c;
    contactIds.add(c.Id);
}

Schema.SObjectType providerType = Schema.getGlobalDescribe().get(NS + 'HealthcareProvider');
Schema.SObjectField nameFld = providerType.getDescribe().fields.getMap().get('name');
if (nameFld == null) nameFld = providerType.getDescribe().fields.getMap().get('Name');
for (Integer i = 1; i <= 5; i++) {
    SObject r = providerType.newSObject();
    if (nameFld != null) r.put(nameFld, 'Provider ' + i); else r.put('name', 'Provider ' + i);
    r.put('AccountId', accountIds[i-1]);
    r.put('PractitionerId', contactIds[i-1]);
    r.put('ProviderType', 'Hospital');
    r.put('ProviderClass', 'Medical Group');
    r.put('EffectiveFrom', Date.newInstance(2021, 2, 1));
    r.put('EffectiveTo', Date.newInstance(2034, 2, 27));
    r.put('Status', 'Active');
    r.put('IsActive', true);
    insert r;
    providerIds.add(r.Id);
}
System.debug('Step 1 OK: 5 Accounts, 5 Contacts, 5 HealthcareProviders. Provider IDs: ' + providerIds);
