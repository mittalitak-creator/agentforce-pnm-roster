Schema.SObjectType t = Schema.getGlobalDescribe().get('HealthcareProvider');
if (t == null) { System.debug('HealthcareProvider not found'); return; }
System.debug('=== All fields ===');
for (String f : t.getDescribe().fields.getMap().keySet()) System.debug(f);
System.debug('=== Required (createable, not nillable) ===');
for (String f : t.getDescribe().fields.getMap().keySet()) {
    Schema.DescribeFieldResult df = t.getDescribe().fields.getMap().get(f).getDescribe();
    if (df.isCreateable() && !df.isNillable() && !df.isDefaultedOnCreate()) System.debug('REQUIRED: ' + f);
}
