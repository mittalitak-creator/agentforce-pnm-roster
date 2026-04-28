Schema.SObjectType t = Schema.getGlobalDescribe().get('CareTaxonomy');
if (t == null) { System.debug('CareTaxonomy not found'); return; }
for (String f : t.getDescribe().fields.getMap().keySet()) {
    Schema.DescribeFieldResult df = t.getDescribe().fields.getMap().get(f).getDescribe();
    if (df.getType() == Schema.DisplayType.REFERENCE && !df.isNillable() && df.isCreateable())
        System.debug('REFERENCE required: ' + f + ' -> ' + df.getReferenceTo());
}