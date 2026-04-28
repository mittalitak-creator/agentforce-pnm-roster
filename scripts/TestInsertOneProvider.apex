Schema.SObjectType t = Schema.getGlobalDescribe().get('HealthcareProvider');
SObject r = t.newSObject();
r.put('name', 'Test Provider 1');
insert r;
System.debug('Inserted: ' + r.Id);
