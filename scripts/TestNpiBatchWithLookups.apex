List<SObject> provs = Database.query('SELECT Id, AccountId, PractitionerId FROM HealthcareProvider ORDER BY CreatedDate DESC LIMIT 5');
List<Id> accountIds = new List<Id>();
List<Id> contactIds = new List<Id>();
for (SObject p : provs) {
    accountIds.add((Id)p.get('AccountId'));
    contactIds.add((Id)p.get('PractitionerId'));
}
Schema.SObjectType npiType = Schema.getGlobalDescribe().get('HealthcareProviderNpi');
Map<String, Schema.SObjectField> npiFields = npiType.getDescribe().fields.getMap();
String npiNameFld = npiFields.get('name') != null ? 'name' : 'Name';
List<SObject> npis = new List<SObject>();
for (Integer i = 0; i < 5; i++) {
    SObject r = npiType.newSObject();
    r.put(npiNameFld, String.valueOf(4000000000L + i));
    if (npiFields.containsKey('AccountId')) r.put('AccountId', accountIds[i]);
    if (npiFields.containsKey('PractitionerId')) r.put('PractitionerId', contactIds[i]);
    npis.add(r);
}
insert npis;
System.debug('Batch inserted 5 NPIs with lookups.');