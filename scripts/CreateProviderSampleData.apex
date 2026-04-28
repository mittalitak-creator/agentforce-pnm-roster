/**
 * Create 5 records in each of the 12 Health Cloud provider standard objects.
 * Uses ONLY standard objects and standard fields (no custom objects or custom fields).
 *
 * Objects (in dependency order):
 *   HealthcareProvider, HealthcareProviderNPI, CareTaxonomy, HealthcareProviderTaxonomy,
 *   CareSpecialty, HealthcareProviderSpecialty, Award, CareService, HealthcareProviderService,
 *   BoardCertification, HealthcareFacility, HealthcarePractitionerFacility
 *
 * Run in Developer Console → Execute Anonymous (Open Log).
 * If your org uses a namespace for Health Cloud, set NS below (e.g. 'HealthCloudGA__').
 */
String NS = ''; // e.g. 'HealthCloudGA__' if objects are in a package namespace

// Resolve lookup field name to a given reference object (e.g. HealthcareProvider, CareTaxonomy)
String lookupFieldTo(String objectApiName, String targetObjectApiName) {
    Schema.SObjectType t = Schema.getGlobalDescribe().get(objectApiName);
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

List<Id> providerIds = new List<Id>();
List<Id> accountIds = new List<Id>();
List<Id> contactIds = new List<Id>();
List<Id> taxonomyIds = new List<Id>();
List<Id> specialtyIds = new List<Id>();
List<Id> serviceIds = new List<Id>();
List<Id> facilityIds = new List<Id>();

// --- 1a. Accounts & Contacts (one at a time) ---
try {
    for (Integer i = 1; i <= 5; i++) {
        Account a = new Account(Name = 'Provider Org ' + i);
        insert a;
        accountIds.add(a.Id);
    }
    for (Integer i = 0; i < 5; i++) {
        Contact c = new Contact(FirstName = 'Provider', LastName = 'Contact' + (i+1), AccountId = accountIds[i]);
        insert c;
        contactIds.add(c.Id);
    }
    System.debug('Created 5 Accounts and 5 Contacts.');
} catch (DmlException e) {
    System.debug('FAILED at Account/Contact: ' + e.getDmlType(0) + ' ' + e.getDmlMessage(0) + ' Fields: ' + e.getDmlFieldNames(0));
    System.assert(false, 'FAILED at Account/Contact: ' + e.getDmlMessage(0) + ' Fields: ' + e.getDmlFieldNames(0));
}

// --- 1b. HealthcareProvider (5 records) - insert one at a time ---
try {
Schema.SObjectType providerType = Schema.getGlobalDescribe().get(NS + 'HealthcareProvider');
Schema.SObjectField nameFld = providerType.getDescribe().fields.getMap().get('name');
if (nameFld == null) nameFld = providerType.getDescribe().fields.getMap().get('Name');
for (Integer i = 1; i <= 5; i++) {
    SObject r = providerType.newSObject();
    if (nameFld != null) r.put(nameFld, 'Provider ' + i); else r.put('name', 'Provider ' + i);
    r.put('AccountId', accountIds[i-1]);
    r.put('PractitionerId', contactIds[i-1]);
    r.put('ProviderType', 'Hospital');
    r.put('ProviderClass', 'Medical Group');
    r.put('EffectiveFrom', Date.newInstance(2021, 2, 1));
    r.put('EffectiveTo', Date.newInstance(2034, 2, 27));
    r.put('Status', 'Active');
    r.put('IsActive', true);
    insert r;
    providerIds.add(r.Id);
}
System.debug('Created 5 HealthcareProvider records.');
} catch (DmlException e) {
    System.debug('FAILED at HealthcareProvider: ' + e.getDmlType(0) + ' ' + e.getDmlMessage(0) + ' Fields: ' + e.getDmlFieldNames(0));
    System.assert(false, 'FAILED at HealthcareProvider: ' + e.getDmlMessage(0) + ' Fields: ' + e.getDmlFieldNames(0));
}

// --- 2. HealthcareProviderNPI (5 records) ---
String npiObjKey = (Schema.getGlobalDescribe().containsKey(NS + 'HealthcareProviderNpi') ? NS + 'HealthcareProviderNpi' : NS + 'HealthcareProviderNPI');
List<SObject> npis = new List<SObject>();
for (Integer i = 0; i < 5; i++) {
    SObject r = Schema.getGlobalDescribe().get(npiObjKey).newSObject();
    r.put('Name', String.valueOf(1000000000 + i)); // 10-digit NPI-style
    if (r.getSObjectType().getDescribe().fields.getMap().containsKey('AccountId')) r.put('AccountId', accountIds[i]);
    if (r.getSObjectType().getDescribe().fields.getMap().containsKey('PractitionerId')) r.put('PractitionerId', contactIds[i]);
    npis.add(r);
}
insert npis;
System.debug('Created 5 HealthcareProviderNPI records.');

// --- 3. CareTaxonomy (5 records) ---
List<String> taxNames = new List<String>{ '207R00000X', '207RC0000X', '207RI0001X', '207V00000X', '208D00000X' };
List<SObject> taxonomies = new List<SObject>();
for (Integer i = 0; i < 5; i++) {
    SObject r = Schema.getGlobalDescribe().get(NS + 'CareTaxonomy').newSObject();
    r.put('Name', taxNames[i]);
    taxonomies.add(r);
}
insert taxonomies;
for (SObject r : taxonomies) taxonomyIds.add(r.Id);
System.debug('Created 5 CareTaxonomy records.');

// --- 4. HealthcareProviderTaxonomy (5 records) ---
String ptObj = NS + 'HealthcareProviderTaxonomy';
String ptProv = providerLookupField(ptObj); if (ptProv == null) ptProv = 'HealthcareProviderId';
String ptTax = lookupFieldTo(ptObj, 'CareTaxonomy'); if (ptTax == null) ptTax = 'CareTaxonomyId';
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
List<SObject> specialties = new List<SObject>();
for (Integer i = 0; i < 5; i++) {
    SObject r = Schema.getGlobalDescribe().get(NS + 'CareSpecialty').newSObject();
    r.put('Name', specNames[i]);
    specialties.add(r);
}
insert specialties;
for (SObject r : specialties) specialtyIds.add(r.Id);
System.debug('Created 5 CareSpecialty records.');

// --- 6. HealthcareProviderSpecialty (5 records) ---
String psObj = NS + 'HealthcareProviderSpecialty';
String psProv = providerLookupField(psObj); if (psProv == null) psProv = 'HealthcareProviderId';
String psSpec = lookupFieldTo(psObj, 'CareSpecialty'); if (psSpec == null) psSpec = 'CareSpecialtyId';
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
List<SObject> awards = new List<SObject>();
String awardObj = NS + 'Award';
String awardProv = providerLookupField(awardObj);
for (Integer i = 0; i < 5; i++) {
    SObject r = Schema.getGlobalDescribe().get(awardObj).newSObject();
    r.put('Name', awardNames[i]);
    if (awardProv != null) r.put(awardProv, providerIds[i]);
    awards.add(r);
}
insert awards;
System.debug('Created 5 Award records.');

// --- 8. CareService (5 records) ---
List<String> svcNames = new List<String>{ 'Primary Care', 'Consultation', 'Surgery', 'Diagnostic Imaging', 'Preventive Care' };
List<SObject> services = new List<SObject>();
for (Integer i = 0; i < 5; i++) {
    SObject r = Schema.getGlobalDescribe().get(NS + 'CareService').newSObject();
    r.put('Name', svcNames[i]);
    services.add(r);
}
insert services;
for (SObject r : services) serviceIds.add(r.Id);
System.debug('Created 5 CareService records.');

// --- 9. HealthcareProviderService (5 records) ---
String psvcObj = NS + 'HealthcareProviderService';
String psvcProv = providerLookupField(psvcObj); if (psvcProv == null) psvcProv = 'HealthcareProviderId';
String psvcSvc = lookupFieldTo(psvcObj, 'CareService'); if (psvcSvc == null) psvcSvc = 'CareServiceId';
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
List<SObject> certs = new List<SObject>();
String certObj = NS + 'BoardCertification';
String certProv = providerLookupField(certObj);
for (Integer i = 0; i < 5; i++) {
    SObject r = Schema.getGlobalDescribe().get(certObj).newSObject();
    r.put('Name', certNames[i]);
    if (certProv != null) r.put(certProv, providerIds[i]);
    certs.add(r);
}
insert certs;
System.debug('Created 5 BoardCertification records.');

// --- 11. HealthcareFacility (5 records) ---
List<String> facilityNames = new List<String>{ 'Springfield General Hospital', 'Metro Care Clinic', 'Family Health Center', 'Children\'s Medical Center', 'Regional Orthopedic Institute' };
List<SObject> facilities = new List<SObject>();
for (Integer i = 0; i < 5; i++) {
    SObject r = Schema.getGlobalDescribe().get(NS + 'HealthcareFacility').newSObject();
    r.put('Name', facilityNames[i]);
    facilities.add(r);
}
insert facilities;
for (SObject r : facilities) facilityIds.add(r.Id);
System.debug('Created 5 HealthcareFacility records.');

// --- 12. HealthcarePractitionerFacility (5 records) ---
String pfObj = NS + 'HealthcarePractitionerFacility';
String pfProv = providerLookupField(pfObj); if (pfProv == null) pfProv = 'HealthcareProviderId';
String pfFac = lookupFieldTo(pfObj, 'HealthcareFacility'); if (pfFac == null) pfFac = 'HealthcareFacilityId';
List<SObject> practitionerFacilities = new List<SObject>();
for (Integer i = 0; i < 5; i++) {
    SObject r = Schema.getGlobalDescribe().get(pfObj).newSObject();
    r.put(pfProv, providerIds[i]); r.put(pfFac, facilityIds[i]);
    practitionerFacilities.add(r);
}
insert practitionerFacilities;
System.debug('Created 5 HealthcarePractitionerFacility records.');

System.debug('Done. 5 records created in each of the 12 standard objects.');
