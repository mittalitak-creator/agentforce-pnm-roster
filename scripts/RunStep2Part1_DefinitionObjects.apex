/**
 * Part 1: Create 5 records each in CareTaxonomy, CareSpecialty, CareService, Award, BoardCertification, HealthcareFacility.
 * No lookup helpers - only nameFieldFromType. Run this first, then RunStep2Part2_JunctionAndNpi.apex.
 */
String NS = '';
String nameFieldFromType(Schema.SObjectType t) {
    if (t == null) return 'Name';
    Map<String, Schema.SObjectField> m = t.getDescribe().fields.getMap();
    Schema.SObjectField f = m.get('name');
    if (f == null) f = m.get('Name');
    return (f != null && f.getDescribe().isCreateable()) ? String.valueOf(f.getDescribe().getName()) : 'Name';
}
List<SObject> provs = Database.query('SELECT Id, AccountId FROM ' + NS + 'HealthcareProvider ORDER BY CreatedDate DESC LIMIT 5');
if (provs.size() < 5) { System.assert(false, 'Need 5 HealthcareProvider records. Run RunStep1Only.apex first.'); }

// CareTaxonomy
Schema.SObjectType taxType = Schema.getGlobalDescribe().get(NS + 'CareTaxonomy');
if (taxType == null) taxType = Schema.getGlobalDescribe().get('CareTaxonomy');
List<SObject> taxonomies = new List<SObject>();
for (String name : new List<String>{ '207R00000X', '207RC0000X', '207RI0001X', '207V00000X', '208D00000X' }) {
    SObject r = taxType.newSObject();
    r.put(nameFieldFromType(taxType), name);
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
System.debug('Created 5 CareService.');

// Award
Schema.SObjectType awardType = Schema.getGlobalDescribe().get(NS + 'Award');
if (awardType == null) awardType = Schema.getGlobalDescribe().get('Award');
List<Id> providerIds = new List<Id>();
for (SObject p : provs) providerIds.add(p.Id);
String awardProv = null;
for (String f : awardType.getDescribe().fields.getMap().keySet()) {
    Schema.DescribeFieldResult df = awardType.getDescribe().fields.getMap().get(f).getDescribe();
    if (df.getType() == Schema.DisplayType.REFERENCE && df.getReferenceTo() != null && !df.getReferenceTo().isEmpty()
        && String.valueOf(df.getReferenceTo()[0]).contains('HealthcareProvider')) { awardProv = f; break; }
}
List<SObject> awards = new List<SObject>();
List<String> awardNames = new List<String>{ 'Excellence in Patient Care', 'Top Provider Award', 'Quality Care Recognition', 'Patient Choice Award', 'Clinical Excellence Award' };
for (Integer i = 0; i < 5; i++) {
    SObject r = awardType.newSObject();
    r.put(nameFieldFromType(awardType), awardNames[i]);
    if (awardProv != null) r.put(awardProv, providerIds[i]);
    awards.add(r);
}
insert awards;
System.debug('Created 5 Award.');

// BoardCertification
Schema.SObjectType certType = Schema.getGlobalDescribe().get(NS + 'BoardCertification');
if (certType == null) certType = Schema.getGlobalDescribe().get('BoardCertification');
String certProv = null;
for (String f : certType.getDescribe().fields.getMap().keySet()) {
    Schema.DescribeFieldResult df = certType.getDescribe().fields.getMap().get(f).getDescribe();
    if (df.getType() == Schema.DisplayType.REFERENCE && df.getReferenceTo() != null && !df.getReferenceTo().isEmpty()
        && String.valueOf(df.getReferenceTo()[0]).contains('HealthcareProvider')) { certProv = f; break; }
}
List<SObject> certs = new List<SObject>();
List<String> certNames = new List<String>{ 'American Board of Internal Medicine', 'American Board of Family Medicine', 'American Board of Pediatrics', 'American Board of Orthopaedic Surgery', 'Board Certified Cardiology' };
for (Integer i = 0; i < 5; i++) {
    SObject r = certType.newSObject();
    r.put(nameFieldFromType(certType), certNames[i]);
    if (certProv != null) r.put(certProv, providerIds[i]);
    certs.add(r);
}
insert certs;
System.debug('Created 5 BoardCertification.');

// HealthcareFacility
Schema.SObjectType facType = Schema.getGlobalDescribe().get(NS + 'HealthcareFacility');
if (facType == null) facType = Schema.getGlobalDescribe().get('HealthcareFacility');
List<SObject> facilities = new List<SObject>();
for (String name : new List<String>{ 'Springfield General Hospital', 'Metro Care Clinic', 'Family Health Center', 'Children\'s Medical Center', 'Regional Orthopedic Institute' }) {
    SObject r = facType.newSObject();
    r.put(nameFieldFromType(facType), name);
    facilities.add(r);
}
insert facilities;
System.debug('Created 5 HealthcareFacility. Part 1 done. Run RunStep2Part2_JunctionAndNpi.apex next.');