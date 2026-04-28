Schema.SObjectType npiType = Schema.getGlobalDescribe().get('HealthcareProviderNpi');
if (npiType == null) npiType = Schema.getGlobalDescribe().get('HealthcareProviderNPI');
Map<String, Schema.SObjectField> npiFields = npiType.getDescribe().fields.getMap();
Schema.SObjectField npiNameF = npiFields.get('name');
if (npiNameF == null) npiNameF = npiFields.get('Name');
String npiNameFld = (npiNameF != null && npiNameF.getDescribe().isCreateable()) ? String.valueOf(npiNameF.getDescribe().getName()) : 'Name';

SObject r = npiType.newSObject();
r.put(npiNameFld, '1234567890');
insert r;
System.debug('Inserted one NPI. Id=' + r.get('Id'));
