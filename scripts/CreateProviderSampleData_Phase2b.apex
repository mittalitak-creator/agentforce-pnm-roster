/**
 * Phase 2b: Create 5 records each in Award, BoardCertification, HealthcareFacility.
 * Run after RunStep2Part1_TaxonomyOnly.apex (Taxonomy, Specialty, Service).
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
List<Id> providerIds = new List<Id>();
List<Id> accountIds = new List<Id>();
for (SObject p : provs) {
    providerIds.add(p.Id);
    accountIds.add((Id)p.get('AccountId'));
}
Schema.SObjectType awardType = Schema.getGlobalDescribe().get(NS + 'Award');
if (awardType == null) awardType = Schema.getGlobalDescribe().get('Award');
String awardProv = null;
String awardAccount = null;
for (String f : awardType.getDescribe().fields.getMap().keySet()) {
    Schema.DescribeFieldResult df = awardType.getDescribe().fields.getMap().get(f).getDescribe();
    if (df.getType() != Schema.DisplayType.REFERENCE) continue;
    if (df.getReferenceTo() != null && !df.getReferenceTo().isEmpty()) {
        String ref = String.valueOf(df.getReferenceTo()[0]);
        if (ref.contains('HealthcareProvider')) awardProv = f;
        if (ref == 'Account') awardAccount = f;
    }
}
List<SObject> awards = new List<SObject>();
for (Integer i = 0; i < 5; i++) {
    SObject r = awardType.newSObject();
    r.put(nameFieldFromType(awardType), new List<String>{ 'Excellence in Patient Care', 'Top Provider Award', 'Quality Care Recognition', 'Patient Choice Award', 'Clinical Excellence Award' }[i]);
    if (awardProv != null) r.put(awardProv, providerIds[i]);
    r.put('AccountId', accountIds[i]);
    awards.add(r);
}
insert awards;
System.debug('Created 5 Award.');

Schema.SObjectType certType = Schema.getGlobalDescribe().get(NS + 'BoardCertification');
if (certType == null) certType = Schema.getGlobalDescribe().get('BoardCertification');
String certProv = null;
for (String f : certType.getDescribe().fields.getMap().keySet()) {
    Schema.DescribeFieldResult df = certType.getDescribe().fields.getMap().get(f).getDescribe();
    if (df.getType() == Schema.DisplayType.REFERENCE && df.getReferenceTo() != null && !df.getReferenceTo().isEmpty()
        && String.valueOf(df.getReferenceTo()[0]).contains('HealthcareProvider')) { certProv = f; break; }
}
List<SObject> certs = new List<SObject>();
for (Integer i = 0; i < 5; i++) {
    SObject r = certType.newSObject();
    r.put(nameFieldFromType(certType), new List<String>{ 'American Board of Internal Medicine', 'American Board of Family Medicine', 'American Board of Pediatrics', 'American Board of Orthopaedic Surgery', 'Board Certified Cardiology' }[i]);
    if (certProv != null) r.put(certProv, providerIds[i]);
    certs.add(r);
}
insert certs;
System.debug('Created 5 BoardCertification.');

Schema.SObjectType facType = Schema.getGlobalDescribe().get(NS + 'HealthcareFacility');
if (facType == null) facType = Schema.getGlobalDescribe().get('HealthcareFacility');
List<SObject> facilities = new List<SObject>();
for (String name : new List<String>{ 'Springfield General Hospital', 'Metro Care Clinic', 'Family Health Center', 'Children\'s Medical Center', 'Regional Orthopedic Institute' }) {
    SObject r = facType.newSObject();
    r.put(nameFieldFromType(facType), name);
    facilities.add(r);
}
insert facilities;
System.debug('Created 5 HealthcareFacility. Phase 2b done. Run CreateProviderSampleData_Phase2c.apex for NPI and junction records.');