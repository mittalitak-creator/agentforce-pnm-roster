List<String> desired = new List<String>{
    'Account',
    'Contact',
    'HealthcareProvider',
    'HealthcareProviderNPI',
    'CareSpecialty',
    'HealthcareProviderSpecialty',
    'CareSpecialtyTaxonomy',
    'CareTaxonomy',
    'HealthcareProviderTaxonomy',
    'CareService',
    'HealthcareProviderService',
    'HealthcareServiceDetail',
    'HlthCareProvTreatedCondition',
    'HealthcareFacility',
    'HealthcarePractitionerFacility',
    'CareProviderFacilitySpecialty',
    'HealthcareFacilityNetwork',
    'HealthcarePayerNetwork',
    'Accreditation',
    'PersonEducation',
    'Award',
    'PersonEmployment',
    'BoardCertification',
    'BusinessLicense',
    'CareProviderAdverseAction',
    'InsurancePolicy',
    'ProviderNetworkTier',
    'ProviderNetworkContract'
};

Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
Map<String, String> normalizedToApi = new Map<String, String>();
for (String api : gd.keySet()) {
    normalizedToApi.put(api.toLowerCase().replace('_', '').replace('__c', ''), api);
}

System.debug('=== Object Discovery in current org ===');
for (String d : desired) {
    String key = d.toLowerCase().replace(' ', '').replace('_', '');
    String matchApi = normalizedToApi.get(key);
    if (matchApi == null) {
        // fallback fuzzy match
        for (String api : gd.keySet()) {
            String low = api.toLowerCase();
            if (low.contains(d.toLowerCase().replace(' ', '')) || d.toLowerCase().replace(' ', '').contains(low.replace('__c', ''))) {
                matchApi = api;
                break;
            }
        }
    }

    if (matchApi == null) {
        System.debug('NOT FOUND => ' + d);
    } else {
        Schema.DescribeSObjectResult dsr = gd.get(matchApi).getDescribe();
        System.debug('FOUND => ' + d + ' => ' + matchApi + ' | label=' + dsr.getLabel() + ' | createable=' + dsr.isCreateable());
    }
}
