// Step 1: Update existing PurchaserPlan records with Line of Business
List<PurchaserPlan> plansToUpdate = [
    SELECT Id, Name, LineOfBusiness 
    FROM PurchaserPlan 
    WHERE Id IN (
        '0SbAAC000000HGz0BM', '0SbAAC000000HH00BM', '0SbAAC000000HH10BM',
        '0SbAAC000000HH20BM', '0SbAAC000000HH30BM'
    )
];

// Update with appropriate LOB values
for (PurchaserPlan plan : plansToUpdate) {
    if (plan.Name.contains('Medicare Advantage')) {
        plan.LineOfBusiness = 'Medicare Advantage';
    } else if (plan.Name.contains('Part D') || plan.Name.contains('PDP')) {
        plan.LineOfBusiness = 'Part D';
    }
}

update plansToUpdate;
System.debug('Updated ' + plansToUpdate.size() + ' PurchaserPlan records with LOB');

// Step 2: Create additional PurchaserPlan records for Commercial and Medicaid
List<PurchaserPlan> newPlans = new List<PurchaserPlan>();

PurchaserPlan commercialPPO = new PurchaserPlan();
commercialPPO.Name = 'Commercial PPO Plan';
commercialPPO.LineOfBusiness = 'Commercial';
commercialPPO.PlanType = 'PPO';
newPlans.add(commercialPPO);

PurchaserPlan commercialHMO = new PurchaserPlan();
commercialHMO.Name = 'Commercial HMO Plan';
commercialHMO.LineOfBusiness = 'Commercial';
commercialHMO.PlanType = 'HMO';
newPlans.add(commercialHMO);

PurchaserPlan medicaidManaged = new PurchaserPlan();
medicaidManaged.Name = 'Medicaid Managed Care';
medicaidManaged.LineOfBusiness = 'Medicaid';
medicaidManaged.PlanType = 'Managed Care';
newPlans.add(medicaidManaged);

PurchaserPlan medicaidFFS = new PurchaserPlan();
medicaidFFS.Name = 'Medicaid Fee-for-Service';
medicaidFFS.LineOfBusiness = 'Medicaid';
medicaidFFS.PlanType = 'Fee-for-Service';
newPlans.add(medicaidFFS);

insert newPlans;
System.debug('Created ' + newPlans.size() + ' new PurchaserPlan records');

// Step 3: Get all members
List<Account> members = [
    SELECT Id, Name, Member_Id__c 
    FROM Account 
    WHERE Member_Id__c LIKE 'MEM%' 
    ORDER BY Member_Id__c 
    LIMIT 10
];

// Step 4: Get all PurchaserPlan records with LOB
List<PurchaserPlan> allPlans = [
    SELECT Id, Name, LineOfBusiness 
    FROM PurchaserPlan 
    WHERE LineOfBusiness != null
    ORDER BY Name
];

System.debug('Found ' + members.size() + ' members');
System.debug('Found ' + allPlans.size() + ' plans with LOB');

// Step 5: Create MemberPlan records - distribute members across plans
List<MemberPlan> memberPlans = new List<MemberPlan>();

Integer planIndex = 0;
for (Account member : members) {
    // Cycle through plans to distribute members
    PurchaserPlan assignedPlan = allPlans[Math.mod(planIndex, allPlans.size())];
    
    MemberPlan mp = new MemberPlan();
    mp.MemberId = member.Id;
    mp.PlanId = assignedPlan.Id;
    mp.Name = member.Name + ' - ' + assignedPlan.Name;
    mp.MemberNumber = member.Member_Id__c;
    mp.Status = 'Active';
    mp.EffectiveFrom = Date.today().addDays(-365); // Active for 1 year
    mp.EffectiveTo = Date.today().addDays(365); // Active for next year
    mp.PrimarySecondaryTertiary = 'Primary';
    mp.RelationshipToSubscriber = 'Self';
    
    memberPlans.add(mp);
    planIndex++;
}

insert memberPlans;

System.debug('✅ SUCCESS! Created ' + memberPlans.size() + ' MemberPlan records');
System.debug('');
System.debug('Summary:');
System.debug('- Updated 5 existing PurchaserPlan records with LOB');
System.debug('- Created 4 new PurchaserPlan records (Commercial & Medicaid)');
System.debug('- Created ' + memberPlans.size() + ' MemberPlan records linking members to plans');
System.debug('');
System.debug('Member Plan Assignments:');
for (MemberPlan mp : memberPlans) {
    Account mem = [SELECT Member_Id__c FROM Account WHERE Id = :mp.MemberId LIMIT 1];
    PurchaserPlan pln = [SELECT LineOfBusiness FROM PurchaserPlan WHERE Id = :mp.PlanId LIMIT 1];
    System.debug('  ' + mem.Member_Id__c + ' → ' + pln.LineOfBusiness);
}
