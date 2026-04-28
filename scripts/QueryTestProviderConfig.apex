// Query the manually created 'Test Provider 1' - list all populated fields to replicate in script
Schema.SObjectType t = Schema.getGlobalDescribe().get('HealthcareProvider');
List<String> fieldNames = new List<String>();
for (String f : t.getDescribe().fields.getMap().keySet()) {
    if (t.getDescribe().fields.getMap().get(f).getDescribe().isAccessible())
        fieldNames.add(f);
}
String soql = 'SELECT ' + String.join(fieldNames, ',') + ' FROM HealthcareProvider WHERE Name = \'Test Provider 1\' LIMIT 1';
List<SObject> rows = Database.query(soql);
if (rows.isEmpty()) {
    System.debug('No HealthcareProvider found with Name = Test Provider 1');
} else {
    SObject r = rows[0];
    System.debug('=== HealthcareProvider Test Provider 1 - populated fields ===');
    for (String f : fieldNames) {
        Object val = r.get(f);
        if (val != null && String.valueOf(val) != '')
            System.debug(f + ' = ' + val);
    }
}
