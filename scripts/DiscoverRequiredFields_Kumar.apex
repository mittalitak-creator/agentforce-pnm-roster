List<String> objects = new List<String>{
    'Account','Contact','HealthcareProvider','HealthcareProviderNPI','CareSpecialty',
    'HealthcareProviderSpecialty','CareSpecialtyTaxonomy','CareTaxonomy','HealthcareProviderTaxonomy',
    'CareService','HealthcareProviderService','HealthcareServiceDetail','HlthCareProvTreatedCondition',
    'HealthcareFacility','HealthcarePractitionerFacility','CareProviderFacilitySpecialty',
    'HealthcareFacilityNetwork','HealthcarePayerNetwork','Accreditation','PersonEducation',
    'Award','PersonEmployment','BoardCertification','BusinessLicense','CareProviderAdverseAction',
    'InsurancePolicy','ProviderNetworkTier','ProviderNetworkContract'
};

Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
for (String api : objects) {
    Schema.DescribeSObjectResult d = gd.get(api).getDescribe();
    List<String> req = new List<String>();
    for (Schema.SObjectField f : d.fields.getMap().values()) {
        Schema.DescribeFieldResult fd = f.getDescribe();
        if (fd.isCreateable() && !fd.isNillable() && !fd.isDefaultedOnCreate() && !fd.isAutoNumber()) {
            req.add(fd.getName() + ' [' + String.valueOf(fd.getType()) + ']');
        }
    }
    req.sort();
    System.debug('REQ => ' + api + ' => ' + req);
}
