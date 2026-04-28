Schema.SObjectType t = Schema.getGlobalDescribe().get('HealthcareProvider');
for (String k : t.getDescribe().fields.getMap().keySet()) {
    Schema.DescribeFieldResult df = t.getDescribe().fields.getMap().get(k).getDescribe();
    String label = df.getLabel();
    if (label.toLowerCase().contains('name') || label.toLowerCase().contains('account') || k.toLowerCase().contains('name') || k.toLowerCase().contains('account'))
        System.debug('API=' + k + ' Label=' + label + ' createable=' + df.isCreateable() + ' nillable=' + df.isNillable());
}
