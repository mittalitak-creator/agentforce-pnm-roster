Schema.SObjectType t = Schema.getGlobalDescribe().get('Award');
if (t == null) { System.debug('Award not found'); return; }
for (String f : t.getDescribe().fields.getMap().keySet()) {
    Schema.DescribeFieldResult df = t.getDescribe().fields.getMap().get(f).getDescribe();
    if (!df.isNillable() && df.isCreateable() || df.getLabel().toLowerCase().contains('account') || f.toLowerCase().contains('account'))
        System.debug(f + ' label=' + df.getLabel() + ' ref=' + df.getReferenceTo() + ' nillable=' + df.isNillable());
}