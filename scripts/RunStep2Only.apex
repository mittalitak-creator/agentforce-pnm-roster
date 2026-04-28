/**
 * Creates 5 records in objects 2-12 using EXISTING HealthcareProviders.
 * Run after RunStep1Only.apex (or after creating 5 Accounts, 5 Contacts, 5 HealthcareProviders).
 */
String NS = '';

String lookupFieldTo(String objectApiName, String targetObjectApiName) {
    Schema.SObjectType t = Schema.getGlobalDescribe().get(NS + objectApiName);
    if (t == null) t = Schema.getGlobalDescribe().get(objectApiName);
    if (t == null) return null;
    Set<String> targets = new Set<String>{ NS + targetObjectApiName, targetObjectApiName };
    for (String f : t.getDescribe().fields.getMap().keySet()) {
        Schema.DescribeFieldResult df = t.getDescribe().fields.getMap().get(f).getDescribe();
        if (df.getType() == Schema.DisplayType.REFERENCE && df.getReferenceTo() != null && !df.getReferenceTo().isEmpty())
            if (targets.contains(String.valueOf(df.getReferenceTo()[0]))) return f;
    }
    return null;
}
String providerLookupField(String objectApiName) { return lookupFieldTo(objectApiName, 'HealthcareProvider'); }

// Get createable name field from SObjectType (some objects use 'name' not 'Name')
String nameFieldFromType(Schema.SObjectType t) {
    if (t == null) return 'Name';
    Map<String, Schema.SObjectField> m = t.getDescribe().fields.getMap();
    Schema.SObjectField f = m.get('name');
    if (f == null) f = m.get('Name');
    return (f != null && f.getDescribe().isCreateable()) ? String.valueOf(f.getDescribe().getName()) : 'Name';
}

// Query existing 5 providers (most recent)
List<SObject> provs = Database.query('SELECT Id, AccountId, PractitionerId FROM ' + NS + 'HealthcareProvider ORDER BY CreatedDate DESC LIMIT 5');
if (provs.size() < 5) {
    System.assert(false, 'Need 5 HealthcareProvider records. Run RunStep1Only.apex first.');
}
List<Id> providerIds = new List<Id>();
List<Id> accountIds = new List<Id>();
List<Id> contactIds = new List<Id>();
for (SObject p : provs) {
    providerIds.add(p.Id);
    accountIds.add((Id)p.get('AccountId'));
    contactIds.add((Id)p.get('PractitionerId'));
}

List<Id> taxonomyIds = new List<Id>();
List<Id> specialtyIds = new List<Id>();
List<Id> serviceIds = new List<Id>();
List<Id> facilityIds = new List<Id>();

// --- 2. HealthcareProviderNPI (5 records) - insert one-by-one with resolved name field ---
String npiObjKey = (Schema.getGlobalDescribe().containsKey(NS + 'HealthcareProviderNpi') ? NS + 'HealthcareProviderNpi' : NS + 'HealthcareProviderNPI');
Schema.SObjectType npiType = Schema.getGlobalDescribe().get(npiObjKey);
if (npiType != null) {
    Map<String, Schema.SObjectField> npiFields = npiType.getDescribe().fields.getMap();
    String npiNameFld = (npiFields.get('name') != null) ? 'name' : 'Name';
    for (Integer i = 0; i < 5; i++) {
        SObject r = npiType.newSObject();
        r.put(npiNameFld, String.valueOf(5000000000L + i));
        if (npiFields.containsKey('AccountId')) r.put('AccountId', accountIds[i]);
        if (npiFields.containsKey('PractitionerId')) r.put('PractitionerId', contactIds[i]);
        insert r;
    }
    System.debug('Created 5 HealthcareProviderNPI records.');
}

// --- 3. CareTaxonomy (5 records) ---
List<String> taxNames = new List<String>{ '207R00000X', '207RC0000X', '207RI0001X', '207V00000X', '208D00000X' };
Schema.SObjectType taxType = Schema.getGlobalDescribe().get(NS + 'CareTaxonomy');
if (taxType == null) taxType = Schema.getGlobalDescribe().get('CareTaxonomy');
String taxNameFld = nameFieldFromType(taxType);
List<SObject> taxonomies = new List<SObject>();
for (Integer i = 0; i < 5; i++) {
    SObject r = taxType.newSObject();
    r.put(taxNameFld, taxNames[i]);
    taxonomies.add(r);
}
try { insert taxonomies; for (SObject r : taxonomies) taxonomyIds.add(r.Id); System.debug('Created 5 CareTaxonomy records.'); } catch (DmlException e) { System.assert(false, 'FAILED at CareTaxonomy: ' + e.getDmlMessage(0)); }

// --- 4. HealthcareProviderTaxonomy (5 records) ---
String ptObj = NS + 'HealthcareProviderTaxonomy';
String ptProv = providerLookupField(ptObj); if (ptProv == null) ptProv = 'HealthcareProviderId';
String ptTax = lookupFieldTo('HealthcareProviderTaxonomy', 'CareTaxonomy'); if (ptTax == null) ptTax = 'CareTaxonomyId';
List<SObject> providerTaxonomies = new List<SObject>();
for (Integer i = 0; i < 5; i++) {
    SObject r = Schema.getGlobalDescribe().get(ptObj).newSObject();
    r.put(ptProv, providerIds[i]); r.put(ptTax, taxonomyIds[i]);
    providerTaxonomies.add(r);
}
insert providerTaxonomies;
System.debug('Created 5 HealthcareProviderTaxonomy records.');

// --- 5. CareSpecialty (5 records) ---
List<String> specNames = new List<String>{ 'Cardiology', 'Internal Medicine', 'Family Medicine', 'Pediatrics', 'Orthopedic Surgery' };
Schema.SObjectType specType = Schema.getGlobalDescribe().get(NS + 'CareSpecialty');
if (specType == null) specType = Schema.getGlobalDescribe().get('CareSpecialty');
String specNameFld = nameFieldFromType(specType);
List<SObject> specialties = new List<SObject>();
for (Integer i = 0; i < 5; i++) {
    SObject r = specType.newSObject();
    r.put(specNameFld, specNames[i]);
    specialties.add(r);
}
insert specialties;
for (SObject r : specialties) specialtyIds.add(r.Id);
System.debug('Created 5 CareSpecialty records.');

// --- 6. HealthcareProviderSpecialty (5 records) ---
String psObj = NS + 'HealthcareProviderSpecialty';
String psProv = providerLookupField(psObj); if (psProv == null) psProv = 'HealthcareProviderId';
String psSpec = lookupFieldTo('HealthcareProviderSpecialty', 'CareSpecialty'); if (psSpec == null) psSpec = 'CareSpecialtyId';
List<SObject> providerSpecialties = new List<SObject>();
for (Integer i = 0; i < 5; i++) {
    SObject r = Schema.getGlobalDescribe().get(psObj).newSObject();
    r.put(psProv, providerIds[i]); r.put(psSpec, specialtyIds[i]);
    providerSpecialties.add(r);
}
insert providerSpecialties;
System.debug('Created 5 HealthcareProviderSpecialty records.');

// --- 7. Award (5 records) ---
List<String> awardNames = new List<String>{ 'Excellence in Patient Care', 'Top Provider Award', 'Quality Care Recognition', 'Patient Choice Award', 'Clinical Excellence Award' };
String awardObj = NS + 'Award';
Schema.SObjectType awardType = Schema.getGlobalDescribe().get(awardObj);
if (awardType == null) awardType = Schema.getGlobalDescribe().get('Award');
String awardNameFld = nameFieldFromType(awardType);
String awardProv = providerLookupField(awardObj);
List<SObject> awards = new List<SObject>();
for (Integer i = 0; i < 5; i++) {
    SObject r = awardType.newSObject();
    r.put(awardNameFld, awardNames[i]);
    if (awardProv != null) r.put(awardProv, providerIds[i]);
    awards.add(r);
}
insert awards;
System.debug('Created 5 Award records.');

// --- 8. CareService (5 records) ---
List<String> svcNames = new List<String>{ 'Primary Care', 'Consultation', 'Surgery', 'Diagnostic Imaging', 'Preventive Care' };
Schema.SObjectType svcType = Schema.getGlobalDescribe().get(NS + 'CareService');
if (svcType == null) svcType = Schema.getGlobalDescribe().get('CareService');
String svcNameFld = nameFieldFromType(svcType);
List<SObject> services = new List<SObject>();
for (Integer i = 0; i < 5; i++) {
    SObject r = svcType.newSObject();
    r.put(svcNameFld, svcNames[i]);
    services.add(r);
}
insert services;
for (SObject r : services) serviceIds.add(r.Id);
System.debug('Created 5 CareService records.');

// --- 9. HealthcareProviderService (5 records) ---
String psvcObj = NS + 'HealthcareProviderService';
String psvcProv = providerLookupField(psvcObj); if (psvcProv == null) psvcProv = 'HealthcareProviderId';
String psvcSvc = lookupFieldTo('HealthcareProviderService', 'CareService'); if (psvcSvc == null) psvcSvc = 'CareServiceId';
List<SObject> providerServices = new List<SObject>();
for (Integer i = 0; i < 5; i++) {
    SObject r = Schema.getGlobalDescribe().get(psvcObj).newSObject();
    r.put(psvcProv, providerIds[i]); r.put(psvcSvc, serviceIds[i]);
    providerServices.add(r);
}
insert providerServices;
System.debug('Created 5 HealthcareProviderService records.');

// --- 10. BoardCertification (5 records) ---
List<String> certNames = new List<String>{ 'American Board of Internal Medicine', 'American Board of Family Medicine', 'American Board of Pediatrics', 'American Board of Orthopaedic Surgery', 'Board Certified Cardiology' };
String certObj = NS + 'BoardCertification';
Schema.SObjectType certType = Schema.getGlobalDescribe().get(certObj);
if (certType == null) certType = Schema.getGlobalDescribe().get('BoardCertification');
String certNameFld = nameFieldFromType(certType);
String certProv = providerLookupField(certObj);
List<SObject> certs = new List<SObject>();
for (Integer i = 0; i < 5; i++) {
    SObject r = certType.newSObject();
    r.put(certNameFld, certNames[i]);
    if (certProv != null) r.put(certProv, providerIds[i]);
    certs.add(r);
}
insert certs;
System.debug('Created 5 BoardCertification records.');

// --- 11. HealthcareFacility (5 records) ---
List<String> facilityNames = new List<String>{ 'Springfield General Hospital', 'Metro Care Clinic', 'Family Health Center', 'Children\'s Medical Center', 'Regional Orthopedic Institute' };
Schema.SObjectType facType = Schema.getGlobalDescribe().get(NS + 'HealthcareFacility');
if (facType == null) facType = Schema.getGlobalDescribe().get('HealthcareFacility');
String facNameFld = nameFieldFromType(facType);
List<SObject> facilities = new List<SObject>();
for (Integer i = 0; i < 5; i++) {
    SObject r = facType.newSObject();
    r.put(facNameFld, facilityNames[i]);
    facilities.add(r);
}
insert facilities;
for (SObject r : facilities) facilityIds.add(r.Id);
System.debug('Created 5 HealthcareFacility records.');

// --- 12. HealthcarePractitionerFacility (5 records) ---
String pfObj = NS + 'HealthcarePractitionerFacility';
String pfProv = providerLookupField(pfObj); if (pfProv == null) pfProv = 'HealthcareProviderId';
String pfFac = lookupFieldTo('HealthcarePractitionerFacility', 'HealthcareFacility'); if (pfFac == null) pfFac = 'HealthcareFacilityId';
List<SObject> practitionerFacilities = new List<SObject>();
for (Integer i = 0; i < 5; i++) {
    SObject r = Schema.getGlobalDescribe().get(pfObj).newSObject();
    r.put(pfProv, providerIds[i]); r.put(pfFac, facilityIds[i]);
    practitionerFacilities.add(r);
}
insert practitionerFacilities;
System.debug('Created 5 HealthcarePractitionerFacility records.');

System.debug('Done. 5 records created in each of objects 2-12.');
