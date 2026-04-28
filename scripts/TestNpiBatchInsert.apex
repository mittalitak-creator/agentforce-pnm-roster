Schema.SObjectType npiType = Schema.getGlobalDescribe().get('HealthcareProviderNpi');
Map<String, Schema.SObjectField> npiFields = npiType.getDescribe().fields.getMap();
String npiNameFld = npiFields.get('name') != null ? 'name' : 'Name';
List<SObject> npis = new List<SObject>();
for (Integer i = 0; i < 5; i++) {
    SObject r = npiType.newSObject();
    r.put(npiNameFld, String.valueOf(3000000000L + i));
    npis.add(r);
}
insert npis;
System.debug('Batch inserted 5 NPIs.');