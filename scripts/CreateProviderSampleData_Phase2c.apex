/**
 * Phase 2c: Create 5 HealthcareProviderNPI + junction records (HealthcareProviderTaxonomy, Specialty, Service, PractitionerFacility).
 * Run after Phase2b. Requires: 5 HealthcareProvider, 5 CareTaxonomy, 5 CareSpecialty, 5 CareService, 5 HealthcareFacility.
 */
String NS = '';
String lookupFieldTo(String objectApiName, String targetObjectApiName) {
    Schema.SObjectType t = Schema.getGlobalDescribe().get(NS + objectApiName);
    if (t == null) t = Schema.getGlobalDescribe().get(objectApiName);
    if (t == null) return null;
    Set<String> targets = new Set<String>{ NS + targetObjectApiName, targetObjectApiName };
    for (String f : t.getDescribe().fields.getMap().keySet()) {
        Schema.DescribeFieldResult df = t.getDescribe().fields.getMap().get(f).getDescribe();
        if (df.getType() == Schema.DisplayType.REFERENCE && df.getReferenceTo() != null && !df.getReferenceTo().isEmpty()
            && targets.contains(String.valueOf(df.getReferenceTo()[0]))) return f;
    }
    return null;
}
String providerLookupField(String objectApiName) { return lookupFieldTo(objectApiName, 'HealthcareProvider'); }

List<SObject> provs = Database.query('SELECT Id, AccountId, PractitionerId FROM ' + NS + 'HealthcareProvider ORDER BY CreatedDate DESC LIMIT 5');
List<Id> providerIds = new List<Id>();
List<Id> accountIds = new List<Id>();
List<Id> contactIds = new List<Id>();
for (SObject p : provs) {
    providerIds.add(p.Id);
    accountIds.add((Id)p.get('AccountId'));
    contactIds.add((Id)p.get('PractitionerId'));
}
List<SObject> taxonomies = Database.query('SELECT Id FROM ' + NS + 'CareTaxonomy ORDER BY CreatedDate DESC LIMIT 5');
List<SObject> specialties = Database.query('SELECT Id FROM ' + NS + 'CareSpecialty ORDER BY CreatedDate DESC LIMIT 5');
List<SObject> services = Database.query('SELECT Id FROM ' + NS + 'CareService ORDER BY CreatedDate DESC LIMIT 5');
List<SObject> facilities = Database.query('SELECT Id FROM ' + NS + 'HealthcareFacility ORDER BY CreatedDate DESC LIMIT 5');
List<Id> taxonomyIds = new List<Id>();
List<Id> specialtyIds = new List<Id>();
List<Id> serviceIds = new List<Id>();
List<Id> facilityIds = new List<Id>();
for (SObject r : taxonomies) taxonomyIds.add(r.Id);
for (SObject r : specialties) specialtyIds.add(r.Id);
for (SObject r : services) serviceIds.add(r.Id);
for (SObject r : facilities) facilityIds.add(r.Id);

// NPI first (no helper calls yet)
String npiKey = Schema.getGlobalDescribe().containsKey(NS + 'HealthcareProviderNpi') ? NS + 'HealthcareProviderNpi' : NS + 'HealthcareProviderNPI';
Schema.SObjectType npiType = Schema.getGlobalDescribe().get(npiKey);
Map<String, Schema.SObjectField> npiFields = npiType.getDescribe().fields.getMap();
String npiNameFld = npiFields.get('name') != null ? 'name' : 'Name';
for (Integer i = 0; i < 5; i++) {
    SObject r = npiType.newSObject();
    r.put(npiNameFld, String.valueOf(6000000000L + i));
    if (npiFields.containsKey('AccountId')) r.put('AccountId', accountIds[i]);
    if (npiFields.containsKey('PractitionerId')) r.put('PractitionerId', contactIds[i]);
    insert r;
}
System.debug('Created 5 HealthcareProviderNPI.');

// Junctions (now use helpers)
String ptProv = providerLookupField(NS + 'HealthcareProviderTaxonomy'); if (ptProv == null) ptProv = 'HealthcareProviderId';
String ptTax = lookupFieldTo('HealthcareProviderTaxonomy', 'CareTaxonomy'); if (ptTax == null) ptTax = 'CareTaxonomyId';
for (Integer i = 0; i < 5; i++) {
    SObject r = Schema.getGlobalDescribe().get(NS + 'HealthcareProviderTaxonomy').newSObject();
    r.put(ptProv, providerIds[i]); r.put(ptTax, taxonomyIds[i]);
    insert r;
}
System.debug('Created 5 HealthcareProviderTaxonomy.');
String psProv = providerLookupField(NS + 'HealthcareProviderSpecialty'); if (psProv == null) psProv = 'HealthcareProviderId';
String psSpec = lookupFieldTo('HealthcareProviderSpecialty', 'CareSpecialty'); if (psSpec == null) psSpec = 'CareSpecialtyId';
for (Integer i = 0; i < 5; i++) {
    SObject r = Schema.getGlobalDescribe().get(NS + 'HealthcareProviderSpecialty').newSObject();
    r.put(psProv, providerIds[i]); r.put(psSpec, specialtyIds[i]);
    insert r;
}
System.debug('Created 5 HealthcareProviderSpecialty.');
String psvcProv = providerLookupField(NS + 'HealthcareProviderService'); if (psvcProv == null) psvcProv = 'HealthcareProviderId';
String psvcSvc = lookupFieldTo('HealthcareProviderService', 'CareService'); if (psvcSvc == null) psvcSvc = 'CareServiceId';
for (Integer i = 0; i < 5; i++) {
    SObject r = Schema.getGlobalDescribe().get(NS + 'HealthcareProviderService').newSObject();
    r.put(psvcProv, providerIds[i]); r.put(psvcSvc, serviceIds[i]);
    insert r;
}
System.debug('Created 5 HealthcareProviderService.');
String pfProv = providerLookupField(NS + 'HealthcarePractitionerFacility'); if (pfProv == null) pfProv = 'HealthcareProviderId';
String pfFac = lookupFieldTo('HealthcarePractitionerFacility', 'HealthcareFacility'); if (pfFac == null) pfFac = 'HealthcareFacilityId';
if (facilityIds.size() >= 5) {
for (Integer i = 0; i < 5; i++) {
    SObject r = Schema.getGlobalDescribe().get(NS + 'HealthcarePractitionerFacility').newSObject();
    r.put(pfProv, providerIds[i]); r.put(pfFac, facilityIds[i]);
    insert r;
}
System.debug('Created 5 HealthcarePractitionerFacility.');
} else System.debug('Skipped HealthcarePractitionerFacility (need 5 HealthcareFacility from Phase2b).');
System.debug('Phase 2c done.');