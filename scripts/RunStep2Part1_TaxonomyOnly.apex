String NS = '';
String nameFieldFromType(Schema.SObjectType t) {
    if (t == null) return 'Name';
    Map<String, Schema.SObjectField> m = t.getDescribe().fields.getMap();
    Schema.SObjectField f = m.get('name');
    if (f == null) f = m.get('Name');
    return (f != null && f.getDescribe().isCreateable()) ? String.valueOf(f.getDescribe().getName()) : 'Name';
}
List<SObject> provs = Database.query('SELECT Id, AccountId FROM ' + NS + 'HealthcareProvider ORDER BY CreatedDate DESC LIMIT 5');
Schema.SObjectType taxType = Schema.getGlobalDescribe().get(NS + 'CareTaxonomy');
if (taxType == null) taxType = Schema.getGlobalDescribe().get('CareTaxonomy');
String taxNameFld = nameFieldFromType(taxType);
List<SObject> taxonomies = new List<SObject>();
for (Integer i = 0; i < 5; i++) {
    SObject r = taxType.newSObject();
    r.put(taxNameFld, new List<String>{ '207R00000X', '207RC0000X', '207RI0001X', '207V00000X', '208D00000X' }[i]);
    taxonomies.add(r);
}
insert taxonomies;
System.debug('Created 5 CareTaxonomy.');
// CareSpecialty
Schema.SObjectType specType = Schema.getGlobalDescribe().get(NS + 'CareSpecialty');
if (specType == null) specType = Schema.getGlobalDescribe().get('CareSpecialty');
List<SObject> specialties = new List<SObject>();
for (String name : new List<String>{ 'Cardiology', 'Internal Medicine', 'Family Medicine', 'Pediatrics', 'Orthopedic Surgery' }) {
    SObject r = specType.newSObject();
    r.put(nameFieldFromType(specType), name);
    specialties.add(r);
}
insert specialties;
System.debug('Created 5 CareSpecialty.');
// CareService
Schema.SObjectType svcType = Schema.getGlobalDescribe().get(NS + 'CareService');
if (svcType == null) svcType = Schema.getGlobalDescribe().get('CareService');
List<SObject> services = new List<SObject>();
for (String name : new List<String>{ 'Primary Care', 'Consultation', 'Surgery', 'Diagnostic Imaging', 'Preventive Care' }) {
    SObject r = svcType.newSObject();
    r.put(nameFieldFromType(svcType), name);
    services.add(r);
}
insert services;
System.debug('Created 5 CareTaxonomy, 5 CareSpecialty, 5 CareService. Run CreateProviderSampleData_Phase2b.apex next for Award, BoardCertification, HealthcareFacility.');