String NS = '';
String nameFieldFromType(Schema.SObjectType t) {
    if (t == null) return 'Name';
    Map<String, Schema.SObjectField> m = t.getDescribe().fields.getMap();
    Schema.SObjectField f = m.get('name');
    if (f == null) f = m.get('Name');
    return (f != null && f.getDescribe().isCreateable()) ? String.valueOf(f.getDescribe().getName()) : 'Name';
}
List<SObject> provs = Database.query('SELECT Id, AccountId, PractitionerId FROM ' + NS + 'HealthcareProvider ORDER BY CreatedDate DESC LIMIT 5');
List<Id> providerIds = new List<Id>();
for (SObject p : provs) { providerIds.add(p.Id); }
List<Id> taxonomyIds = new List<Id>();

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
insert taxonomies;
System.debug('Created 5 CareTaxonomy records.');