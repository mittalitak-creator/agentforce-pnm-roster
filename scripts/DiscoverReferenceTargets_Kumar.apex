List<String> objects = new List<String>{
    'CareSpecialtyTaxonomy','HealthcareProviderService','HealthcareServiceDetail',
    'HlthCareProvTreatedCondition','HealthcareFacility','PersonEmployment',
    'InsurancePolicy','ProviderNetworkTier','ProviderNetworkContract'
};
Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

for (String api : objects) {
    Schema.DescribeSObjectResult d = gd.get(api).getDescribe();
    for (Schema.SObjectField f : d.fields.getMap().values()) {
        Schema.DescribeFieldResult fd = f.getDescribe();
        if (fd.isCreateable() && !fd.isNillable() && fd.getType() == Schema.DisplayType.REFERENCE) {
            List<String> targets = new List<String>();
            for (Schema.SObjectType rt : fd.getReferenceTo()) {
                targets.add(rt.getDescribe().getName());
            }
            targets.sort();
            System.debug('REF => ' + api + '.' + fd.getName() + ' => ' + targets);
        }
    }
}
