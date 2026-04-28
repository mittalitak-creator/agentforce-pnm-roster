// Insert one HealthcareProvider with same config as Test Provider 1 (AccountId, PractitionerId, etc.)
Account a = new Account(Name = 'Minimal Test Org');
insert a;
Contact c = new Contact(LastName = 'MinimalContact', AccountId = a.Id);
insert c;
Schema.SObjectType t = Schema.getGlobalDescribe().get('HealthcareProvider');
SObject r = t.newSObject();
r.put('name', 'Apex Provider 1');
r.put('AccountId', a.Id);
r.put('PractitionerId', c.Id);
r.put('ProviderType', 'Hospital');
r.put('ProviderClass', 'Medical Group');
r.put('EffectiveFrom', Date.newInstance(2021, 2, 1));
r.put('EffectiveTo', Date.newInstance(2034, 2, 27));
r.put('Status', 'Active');
r.put('IsActive', true);
insert r;
System.debug('Inserted HealthcareProvider: ' + r.get('Id'));
