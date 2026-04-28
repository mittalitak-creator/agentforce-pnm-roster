// Create sample denied claims data
// This script creates sample Claim__c records with denied status

// Get some existing member accounts to associate with claims
List<Account> members = [SELECT Id, Name, Member_ID__c FROM Account WHERE IsPersonAccount = true LIMIT 5];

if (members.isEmpty()) {
    System.debug('No Person Accounts found. Please create member accounts first.');
} else {
    List<Claim__c> claims = new List<Claim__c>();
    
    // Claim 1 - Denied Medical Service
    Claim__c claim1 = new Claim__c();
    claim1.Name = 'CLM-2024-0001';
    claim1.Member__c = members[0].Id;
    claim1.Status__c = 'Denied';
    claim1.Claim_Type__c = 'Institutional';
    claim1.Total_Amount__c = 5000.00;
    claim1.Claimed_Amount__c = 5000.00;
    claim1.Paid_Amount__c = 0.00;
    claim1.Service_Start_Date__c = Date.today().addDays(-60);
    claim1.Service_End_Date__c = Date.today().addDays(-60);
    claim1.Received_Date__c = Date.today().addDays(-45);
    claim1.Description__c = 'MRI scan - denied due to lack of prior authorization';
    claims.add(claim1);
    
    // Claim 2 - Denied Pharmacy Claim
    Claim__c claim2 = new Claim__c();
    claim2.Name = 'CLM-2024-0002';
    claim2.Member__c = members[1].Id;
    claim2.Status__c = 'Denied';
    claim2.Claim_Type__c = 'Pharmacy';
    claim2.Total_Amount__c = 1200.00;
    claim2.Claimed_Amount__c = 1200.00;
    claim2.Paid_Amount__c = 0.00;
    claim2.Service_Start_Date__c = Date.today().addDays(-30);
    claim2.Service_End_Date__c = Date.today().addDays(-30);
    claim2.Received_Date__c = Date.today().addDays(-25);
    claim2.Description__c = 'Specialty medication - denied as not on formulary';
    claims.add(claim2);
    
    // Claim 3 - Denied Outpatient Service
    Claim__c claim3 = new Claim__c();
    claim3.Name = 'CLM-2024-0003';
    claim3.Member__c = members[2].Id;
    claim3.Status__c = 'Denied';
    claim3.Claim_Type__c = 'Professional';
    claim3.Total_Amount__c = 2500.00;
    claim3.Claimed_Amount__c = 2500.00;
    claim3.Paid_Amount__c = 0.00;
    claim3.Service_Start_Date__c = Date.today().addDays(-90);
    claim3.Service_End_Date__c = Date.today().addDays(-90);
    claim3.Received_Date__c = Date.today().addDays(-80);
    claim3.Description__c = 'Physical therapy sessions - denied as exceeds benefit limit';
    claims.add(claim3);
    
    // Claim 4 - Denied Surgical Procedure
    Claim__c claim4 = new Claim__c();
    claim4.Name = 'CLM-2024-0004';
    claim4.Member__c = members[3].Id;
    claim4.Status__c = 'Denied';
    claim4.Claim_Type__c = 'Institutional';
    claim4.Total_Amount__c = 15000.00;
    claim4.Claimed_Amount__c = 15000.00;
    claim4.Paid_Amount__c = 0.00;
    claim4.Service_Start_Date__c = Date.today().addDays(-120);
    claim4.Service_End_Date__c = Date.today().addDays(-118);
    claim4.Received_Date__c = Date.today().addDays(-100);
    claim4.Description__c = 'Elective surgery - denied as not medically necessary';
    claims.add(claim4);
    
    // Claim 5 - Denied DME
    Claim__c claim5 = new Claim__c();
    claim5.Name = 'CLM-2024-0005';
    claim5.Member__c = members[4].Id;
    claim5.Status__c = 'Denied';
    claim5.Claim_Type__c = 'Professional';
    claim5.Total_Amount__c = 800.00;
    claim5.Claimed_Amount__c = 800.00;
    claim5.Paid_Amount__c = 0.00;
    claim5.Service_Start_Date__c = Date.today().addDays(-45);
    claim5.Service_End_Date__c = Date.today().addDays(-45);
    claim5.Received_Date__c = Date.today().addDays(-40);
    claim5.Description__c = 'Durable Medical Equipment - denied as non-covered service';
    claims.add(claim5);
    
    try {
        insert claims;
        System.debug('Successfully created ' + claims.size() + ' denied claims:');
        for (Claim__c c : claims) {
            System.debug('Claim: ' + c.Name + ' - ' + c.Description__c);
        }
    } catch (Exception e) {
        System.debug('Error creating claims: ' + e.getMessage());
    }
}

