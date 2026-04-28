Schema.SObjectType t = Schema.getGlobalDescribe().get('HealthcareProviderNpi');
if (t == null) return;
for (String f : t.getDescribe().fields.getMap().keySet()) {
    Schema.DescribeFieldResult df = t.getDescribe().fields.getMap().get(f).getDescribe();
    if (df.isCreateable() && !df.isNillable() && !df.isDefaultedOnCreate()) System.debug('REQUIRED: ' + f);
}
