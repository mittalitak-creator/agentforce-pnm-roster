Schema.SObjectType npiType = Schema.getGlobalDescribe().get('HealthcareProviderNpi');
Map<String, Schema.SObjectField> npiFields = npiType.getDescribe().fields.getMap();
Schema.SObjectField npiNameF = npiFields.get('name');
if (npiNameF == null) npiNameF = npiFields.get('Name');
String npiNameFld = String.valueOf(npiNameF.getDescribe().getName());

for (Integer i = 0; i < 5; i++) {
    SObject r = npiType.newSObject();
    r.put(npiNameFld, String.valueOf(1000000000 + i));
    insert r;
}
System.debug('Inserted 5 NPIs (no lookups).');
