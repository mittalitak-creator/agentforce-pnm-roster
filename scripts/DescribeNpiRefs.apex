Schema.SObjectType t = Schema.getGlobalDescribe().get('HealthcareProviderNpi');
if (t == null) { System.debug('Npi object not found'); return; }
for (String f : t.getDescribe().fields.getMap().keySet()) {
    Schema.DescribeFieldResult df = t.getDescribe().fields.getMap().get(f).getDescribe();
    if (df.getType() == Schema.DisplayType.REFERENCE && df.getReferenceTo() != null && !df.getReferenceTo().isEmpty())
        System.debug('REF: ' + f + ' -> ' + df.getReferenceTo()[0]);
}
