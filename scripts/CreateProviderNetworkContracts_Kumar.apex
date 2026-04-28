List<Contract> contracts = [
    SELECT Id, StartDate, EndDate
    FROM Contract
    WHERE Status = 'Draft'
    ORDER BY CreatedDate DESC
    LIMIT 5
];
List<HealthcarePayerNetwork> nets = [
    SELECT Id
    FROM HealthcarePayerNetwork
    ORDER BY CreatedDate DESC
    LIMIT 5
];
List<HealthcareProvider> provs = [
    SELECT Id
    FROM HealthcareProvider
    ORDER BY CreatedDate DESC
    LIMIT 5
];

Integer n = Math.min(contracts.size(), Math.min(nets.size(), provs.size()));
List<ProviderNetworkContract> rows = new List<ProviderNetworkContract>();
for (Integer i = 0; i < n; i++) {
    Date sd = contracts[i].StartDate != null ? contracts[i].StartDate : Date.today();
    Date ed = contracts[i].EndDate != null ? contracts[i].EndDate : sd.addMonths(12);
    ProviderNetworkContract p = new ProviderNetworkContract();
    p.ContractId = contracts[i].Id;
    p.HealthcarePayerNetworkId = nets[i].Id;
    p.HealthcareProviderId = provs[i].Id;
    p.StartDate = sd;
    p.EndDate = ed;
    rows.add(p);
}

Database.SaveResult[] sr = Database.insert(rows, false);
Integer ok = 0;
for (Integer i = 0; i < sr.size(); i++) {
    if (sr[i].isSuccess()) {
        ok++;
    } else {
        for (Database.Error e : sr[i].getErrors()) {
            System.debug('ProviderNetworkContract ERR [' + i + '] => ' + e.getStatusCode() + ': ' + e.getMessage());
        }
    }
}
System.debug('ProviderNetworkContract created => ' + ok + '/' + rows.size());
