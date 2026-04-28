// Print required createable fields and Name field info for HealthcareProviderNpi
Schema.SObjectType t = Schema.getGlobalDescribe().get('HealthcareProviderNpi');
if (t == null) t = Schema.getGlobalDescribe().get('HealthcareProviderNPI');
if (t == null) { System.debug('NPI object not found'); return; }
Schema.DescribeSObjectResult descObj = t.getDescribe();
System.debug('Object: ' + descObj.getName());
Map<String, Schema.SObjectField> m = descObj.fields.getMap();
for (String f : m.keySet()) {
    Schema.DescribeFieldResult df = m.get(f).getDescribe();
    Boolean req = df.isCreateable() && !df.isNillable() && !df.isDefaultedOnCreate();
    if (req || f.equalsIgnoreCase('Name')) System.debug((req ? 'REQUIRED ' : '') + f + ' createable=' + df.isCreateable() + ' type=' + df.getType());
}
