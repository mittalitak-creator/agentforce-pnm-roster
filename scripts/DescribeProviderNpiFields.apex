// Run once to see actual field API names on HealthcareProviderNpi
Schema.SObjectType t = Schema.getGlobalDescribe().get('HealthcareProviderNpi');
if (t == null) { System.debug('Object not found. Try HealthcareProviderNPI'); t = Schema.getGlobalDescribe().get('HealthcareProviderNPI'); }
if (t != null) {
    for (String f : t.getDescribe().fields.getMap().keySet()) System.debug(f);
} else { System.debug('Object not found'); }
