Schema.SObjectType t = Schema.getGlobalDescribe().get('CareTaxonomy');
if (t == null) { System.debug('CareTaxonomy not found'); return; }
for (String f : t.getDescribe().fields.getMap().keySet()) {
    Schema.DescribeFieldResult df = t.getDescribe().fields.getMap().get(f).getDescribe();
    if (df.getLabel().toLowerCase().contains('account') || f.toLowerCase().contains('account'))
        System.debug('FIELD: ' + f + ' label=' + df.getLabel() + ' nillable=' + df.isNillable());
}