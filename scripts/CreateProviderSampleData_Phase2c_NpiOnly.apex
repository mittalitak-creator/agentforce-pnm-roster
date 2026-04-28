/**
 * Create 5 HealthcareProviderNPI records. Run after RunStep1Only.
 * No lookup helpers in this script (avoids Name-required quirk when helpers are present).
 */
String NS = '';
List<SObject> provs = Database.query('SELECT Id, AccountId, PractitionerId FROM ' + NS + 'HealthcareProvider ORDER BY CreatedDate DESC LIMIT 5');
List<Id> accountIds = new List<Id>();
List<Id> contactIds = new List<Id>();
for (SObject p : provs) {
    accountIds.add((Id)p.get('AccountId'));
    contactIds.add((Id)p.get('PractitionerId'));
}
String npiKey = Schema.getGlobalDescribe().containsKey(NS + 'HealthcareProviderNpi') ? NS + 'HealthcareProviderNpi' : NS + 'HealthcareProviderNPI';
Schema.SObjectType npiType = Schema.getGlobalDescribe().get(npiKey);
Map<String, Schema.SObjectField> npiFields = npiType.getDescribe().fields.getMap();
String npiNameFld = npiFields.get('name') != null ? 'name' : 'Name';
for (Integer i = 0; i < 5; i++) {
    SObject r = npiType.newSObject();
    r.put(npiNameFld, String.valueOf(7000000000L + i));
    if (npiFields.containsKey('AccountId')) r.put('AccountId', accountIds[i]);
    if (npiFields.containsKey('PractitionerId')) r.put('PractitionerId', contactIds[i]);
    insert r;
}
System.debug('Created 5 HealthcareProviderNPI. Run CreateProviderSampleData_Phase2c_JunctionsOnly.apex next.');