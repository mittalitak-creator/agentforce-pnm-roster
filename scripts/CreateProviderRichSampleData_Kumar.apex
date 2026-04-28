/*
 * Creates 5 sample records per requested provider-related object in Kumar-org.
 * Uses dynamic field assignment so it can run across org variations.
 */
public class ProviderSampleDataLoaderKumar {
    private Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    private Map<String, List<Id>> idsByObject = new Map<String, List<Id>>();
    private Map<String, Integer> successByObject = new Map<String, Integer>();

    private SObject rec(String obj) {
        return gd.get(obj).newSObject();
    }
    private Boolean hasCreateableField(SObject s, String fieldApi) {
        Map<String, Schema.SObjectField> fm = s.getSObjectType().getDescribe().fields.getMap();
        return fm.containsKey(fieldApi) && fm.get(fieldApi).getDescribe().isCreateable();
    }
    private void putIf(SObject s, String fieldApi, Object val) {
        if (val == null) return;
        if (!hasCreateableField(s, fieldApi)) return;
        try {
            s.put(fieldApi, val);
        } catch (Exception e) {
            System.debug('PUT_SKIP [' + s.getSObjectType() + '.' + fieldApi + '] => ' + e.getMessage());
        }
    }
    private void putFirst(SObject s, List<String> candidates, Object val) {
        for (String c : candidates) {
            if (hasCreateableField(s, c)) {
                s.put(c, val);
                return;
            }
        }
    }
    private Id pick(String obj, Integer i) {
        List<Id> ids = idsByObject.get(obj);
        if (ids == null || ids.isEmpty()) return null;
        return ids[Math.mod(i, ids.size())];
    }
    private List<Id> insertAndTrack(String obj, List<SObject> rows) {
        List<Id> out = new List<Id>();
        if (rows.isEmpty()) return out;
        Database.SaveResult[] sr = Database.insert(rows, false);
        Integer ok = 0;
        for (Integer i = 0; i < sr.size(); i++) {
            if (sr[i].isSuccess()) {
                ok++;
                out.add(sr[i].getId());
            } else {
                for (Database.Error e : sr[i].getErrors()) {
                    System.debug('INSERT_ERR [' + obj + '][' + i + '] => ' + e.getStatusCode() + ': ' + e.getMessage());
                }
            }
        }
        idsByObject.put(obj, out);
        successByObject.put(obj, ok);
        System.debug('CREATED => ' + obj + ': ' + ok + '/' + rows.size());
        return out;
    }

    public void run() {
        Date today = Date.today();
        String usageTypeVal = null;
        if (gd.containsKey('ProblemDefinition')) {
            Map<String, Schema.SObjectField> fm = gd.get('ProblemDefinition').getDescribe().fields.getMap();
            if (fm.containsKey('UsageType')) {
                for (Schema.PicklistEntry pe : fm.get('UsageType').getDescribe().getPicklistValues()) {
                    if (pe.isActive()) {
                        usageTypeVal = pe.getValue();
                        break;
                    }
                }
            }
        }

        // Supporting records needed by required lookups.
        List<SObject> conditions = new List<SObject>();
        List<String> condNames = new List<String>{'Hypertension','Coronary Artery Disease','Asthma','Diabetes','Migraine'};
        for (Integer i = 0; i < 5; i++) {
            SObject p = rec('ProblemDefinition');
            putIf(p, 'Name', condNames[i]);
            putFirst(p, new List<String>{'ProblemName', 'DisplayLabel'}, condNames[i]);
            putFirst(p, new List<String>{'UsageType', 'UsageType__c'}, usageTypeVal);
            conditions.add(p);
        }
        insertAndTrack('ProblemDefinition', conditions);

        // Account (5)
        List<SObject> accounts = new List<SObject>();
        for (Integer i = 1; i <= 5; i++) {
            SObject a = rec('Account');
            putIf(a, 'Name', 'Provider Account ' + i);
            putFirst(a, new List<String>{'Phone'}, '415-555-10' + String.valueOf(i).leftPad(2, '0'));
            putFirst(a, new List<String>{'BillingCity'}, i <= 3 ? 'San Francisco' : 'Oakland');
            putFirst(a, new List<String>{'BillingCountryCode', 'BillingCountry'}, 'US');
            putFirst(a, new List<String>{'BillingStateCode', 'BillingState'}, 'CA');
            putFirst(a, new List<String>{'BillingPostalCode'}, '9410' + i);
            putFirst(a, new List<String>{'Type'}, i <= 2 ? 'Customer - Direct' : 'Partner');
            accounts.add(a);
        }
        insertAndTrack('Account', accounts);

        // Contract (5) - needed by ProviderNetworkContract
        List<SObject> contracts = new List<SObject>();
        for (Integer i = 0; i < 5; i++) {
            SObject c = rec('Contract');
            putIf(c, 'AccountId', pick('Account', i));
            putIf(c, 'StartDate', today.addDays(-30));
            putIf(c, 'ContractTerm', 12);
            putIf(c, 'Status', 'Draft');
            putIf(c, 'OwnerExpirationNotice', 30);
            contracts.add(c);
        }
        insertAndTrack('Contract', contracts);

        // Contact (5)
        List<String> firsts = new List<String>{'Albert','Maya','Ravi','Elena','Noah'};
        List<String> lasts = new List<String>{'Silva','Patel','Khanna','Rivera','Chen'};
        List<SObject> contacts = new List<SObject>();
        for (Integer i = 0; i < 5; i++) {
            SObject c = rec('Contact');
            putIf(c, 'FirstName', firsts[i]);
            putIf(c, 'LastName', lasts[i]);
            putIf(c, 'Email', firsts[i].toLowerCase() + '.' + lasts[i].toLowerCase() + '@example.org');
            putIf(c, 'Phone', '415-555-20' + String.valueOf(i + 1).leftPad(2, '0'));
            putIf(c, 'AccountId', pick('Account', i));
            contacts.add(c);
        }
        insertAndTrack('Contact', contacts);

        // Healthcare Provider (5) - includes individual + group providers.
        List<SObject> providers = new List<SObject>();
        List<String> provNames = new List<String>{
            'Albert Silva MD',
            'Maya Patel DO',
            'Ravi Khanna MD',
            'BayCare Group Practice',
            'Golden State Provider Group'
        };
        for (Integer i = 0; i < 5; i++) {
            SObject hp = rec('HealthcareProvider');
            putIf(hp, 'Name', provNames[i]);
            putFirst(hp, new List<String>{'AccountId'}, pick('Account', i));
            putFirst(hp, new List<String>{'PrimaryContactId', 'ContactId'}, pick('Contact', i));
            putFirst(hp, new List<String>{'ProviderType', 'ProviderType__c'}, i <= 2 ? 'Individual' : 'Group');
            putFirst(hp, new List<String>{'Status', 'ProviderStatus', 'ProviderStatus__c'}, i == 0 ? 'Pending' : 'Active');
            providers.add(hp);
        }
        insertAndTrack('HealthcareProvider', providers);

        // Healthcare Facility (5)
        List<SObject> facilities = new List<SObject>();
        List<String> facNames = new List<String>{'ABC Clinic','Downtown Clinic','Sunrise Medical Center','Mission Family Care','NorthBay Specialty Hub'};
        for (Integer i = 0; i < 5; i++) {
            SObject f = rec('HealthcareFacility');
            putIf(f, 'Name', facNames[i]);
            putIf(f, 'AccountId', pick('Account', i));
            putFirst(f, new List<String>{'City', 'FacilityCity__c'}, i < 3 ? 'San Francisco' : 'San Jose');
            putFirst(f, new List<String>{'State', 'FacilityState__c'}, 'CA');
            facilities.add(f);
        }
        insertAndTrack('HealthcareFacility', facilities);

        // Healthcare Provider NPI (5)
        List<SObject> npis = new List<SObject>();
        for (Integer i = 0; i < 5; i++) {
            SObject n = rec('HealthcareProviderNPI');
            putIf(n, 'Name', String.valueOf(1234567890 + i));
            putFirst(n, new List<String>{'HealthcareProviderId', 'ProviderId'}, pick('HealthcareProvider', i));
            npis.add(n);
        }
        insertAndTrack('HealthcareProviderNPI', npis);

        // Care Specialty (5)
        List<String> specNames = new List<String>{'Cardiology','Internal Medicine','Radiology','Family Medicine','Endocrinology'};
        List<SObject> specs = new List<SObject>();
        for (Integer i = 0; i < 5; i++) {
            SObject s = rec('CareSpecialty');
            putIf(s, 'Name', specNames[i]);
            specs.add(s);
        }
        insertAndTrack('CareSpecialty', specs);

        // Care Taxonomy (5)
        List<String> taxNames = new List<String>{'NUCC Cardiology','NUCC Internal Medicine','NUCC Radiology','NUCC Family Practice','NUCC Endocrinology'};
        List<SObject> tax = new List<SObject>();
        for (Integer i = 0; i < 5; i++) {
            SObject t = rec('CareTaxonomy');
            putIf(t, 'Name', taxNames[i]);
            tax.add(t);
        }
        insertAndTrack('CareTaxonomy', tax);

        // Care Specialty Taxonomy (5)
        List<SObject> st = new List<SObject>();
        for (Integer i = 0; i < 5; i++) {
            SObject x = rec('CareSpecialtyTaxonomy');
            putIf(x, 'CareSpecialtyId', pick('CareSpecialty', i));
            putIf(x, 'CareTaxonomyId', pick('CareTaxonomy', i));
            st.add(x);
        }
        insertAndTrack('CareSpecialtyTaxonomy', st);

        // Provider Specialty (5) + Provider Taxonomy (5)
        List<SObject> pSpecs = new List<SObject>();
        List<SObject> pTax = new List<SObject>();
        for (Integer i = 0; i < 5; i++) {
            SObject ps = rec('HealthcareProviderSpecialty');
            putIf(ps, 'Name', 'Provider Specialty ' + (i + 1));
            putFirst(ps, new List<String>{'HealthcareProviderId', 'ProviderId'}, pick('HealthcareProvider', Math.mod(i, 3))); // multiple providers attached to first few individual providers
            putFirst(ps, new List<String>{'CareSpecialtyId', 'SpecialtyId'}, pick('CareSpecialty', i));
            pSpecs.add(ps);

            SObject pt = rec('HealthcareProviderTaxonomy');
            putIf(pt, 'Name', 'Provider Taxonomy ' + (i + 1));
            putFirst(pt, new List<String>{'HealthcareProviderId', 'ProviderId'}, pick('HealthcareProvider', Math.mod(i, 3)));
            putFirst(pt, new List<String>{'CareTaxonomyId', 'TaxonomyId'}, pick('CareTaxonomy', i));
            pTax.add(pt);
        }
        insertAndTrack('HealthcareProviderSpecialty', pSpecs);
        insertAndTrack('HealthcareProviderTaxonomy', pTax);

        // Care Service (5)
        List<String> svcNames = new List<String>{'Echocardiogram','ECG','Stress Testing','Consultation','Telehealth Follow-up'};
        List<SObject> svcs = new List<SObject>();
        for (Integer i = 0; i < 5; i++) {
            SObject s = rec('CareService');
            putIf(s, 'Name', svcNames[i]);
            svcs.add(s);
        }
        insertAndTrack('CareService', svcs);

        // Provider Service (5)
        List<SObject> pSvc = new List<SObject>();
        for (Integer i = 0; i < 5; i++) {
            SObject ps = rec('HealthcareProviderService');
            putIf(ps, 'Name', 'Provider Service ' + (i + 1));
            putIf(ps, 'ProviderId', pick('HealthcareProvider', Math.mod(i, 3)));
            putIf(ps, 'CareServiceId', pick('CareService', i));
            pSvc.add(ps);
        }
        insertAndTrack('HealthcareProviderService', pSvc);

        // Healthcare Service Detail (5)
        List<SObject> sDetail = new List<SObject>();
        for (Integer i = 0; i < 5; i++) {
            SObject d = rec('HealthcareServiceDetail');
            putIf(d, 'CareServiceId', pick('CareService', i));
            putFirst(d, new List<String>{'Name', 'DetailName__c'}, 'Service Detail ' + (i + 1));
            sDetail.add(d);
        }
        insertAndTrack('HealthcareServiceDetail', sDetail);

        // Provider Treated Condition (5)
        List<SObject> tr = new List<SObject>();
        for (Integer i = 0; i < 5; i++) {
            SObject tc = rec('HlthCareProvTreatedCondition');
            putIf(tc, 'Name', 'Treated Condition ' + (i + 1));
            putIf(tc, 'HealthcareProviderId', pick('HealthcareProvider', Math.mod(i, 3)));
            putIf(tc, 'ConditionId', pick('ProblemDefinition', i));
            tr.add(tc);
        }
        insertAndTrack('HlthCareProvTreatedCondition', tr);

        // Practitioner Facility (5): link multiple providers to facilities and one group provider relationship where possible.
        List<SObject> pf = new List<SObject>();
        for (Integer i = 0; i < 5; i++) {
            SObject x = rec('HealthcarePractitionerFacility');
            putIf(x, 'Name', 'Practitioner Facility ' + (i + 1));
            putFirst(x, new List<String>{'HealthcareProviderId', 'ProviderId', 'PractitionerId'}, pick('HealthcareProvider', Math.mod(i, 3)));
            putFirst(x, new List<String>{'HealthcareFacilityId', 'FacilityId'}, pick('HealthcareFacility', Math.mod(i, 2))); // multiple providers on first two facilities
            putFirst(x, new List<String>{'GroupProviderId', 'ParentHealthcareProviderId', 'ParentProviderId'}, pick('HealthcareProvider', 3 + Math.mod(i, 2)));
            pf.add(x);
        }
        insertAndTrack('HealthcarePractitionerFacility', pf);

        // Care Provider Facility Specialty (5)
        List<SObject> cfs = new List<SObject>();
        for (Integer i = 0; i < 5; i++) {
            SObject x = rec('CareProviderFacilitySpecialty');
            putIf(x, 'Name', 'Facility Specialty ' + (i + 1));
            putFirst(x, new List<String>{'CareSpecialtyId', 'SpecialtyId'}, pick('CareSpecialty', i));
            putFirst(x, new List<String>{'HealthcareFacilityId', 'FacilityId'}, pick('HealthcareFacility', Math.mod(i, 2)));
            putFirst(x, new List<String>{'HealthcarePractitionerFacilityId', 'PractitionerFacilityId'}, pick('HealthcarePractitionerFacility', i));
            cfs.add(x);
        }
        insertAndTrack('CareProviderFacilitySpecialty', cfs);

        // Payer network (5) and facility network (5)
        List<SObject> payerNetworks = new List<SObject>();
        List<String> netNames = new List<String>{'PPO Gold','HMO Silver','PPO Platinum','EPO Select','MediPlus Core'};
        for (Integer i = 0; i < 5; i++) {
            SObject pn = rec('HealthcarePayerNetwork');
            putIf(pn, 'Name', netNames[i]);
            payerNetworks.add(pn);
        }
        insertAndTrack('HealthcarePayerNetwork', payerNetworks);

        List<SObject> facNet = new List<SObject>();
        for (Integer i = 0; i < 5; i++) {
            SObject fn = rec('HealthcareFacilityNetwork');
            putIf(fn, 'Name', 'Facility Network ' + (i + 1));
            putFirst(fn, new List<String>{'HealthcareFacilityId', 'FacilityId'}, pick('HealthcareFacility', i));
            putFirst(fn, new List<String>{'HealthcarePayerNetworkId', 'PayerNetworkId'}, pick('HealthcarePayerNetwork', i));
            facNet.add(fn);
        }
        insertAndTrack('HealthcareFacilityNetwork', facNet);

        // Accreditation, PersonEducation, Award, PersonEmployment, BoardCertification, BusinessLicense, AdverseAction
        List<SObject> accred = new List<SObject>();
        List<SObject> edu = new List<SObject>();
        List<SObject> awards = new List<SObject>();
        List<SObject> emp = new List<SObject>();
        List<SObject> cert = new List<SObject>();
        List<SObject> lic = new List<SObject>();
        List<SObject> adverse = new List<SObject>();
        for (Integer i = 0; i < 5; i++) {
            SObject a = rec('Accreditation');
            putIf(a, 'Name', 'Accreditation ' + (i + 1));
            putFirst(a, new List<String>{'HealthcareProviderId', 'ProviderId'}, pick('HealthcareProvider', Math.mod(i, 3)));
            putFirst(a, new List<String>{'HealthcareFacilityId', 'FacilityId'}, pick('HealthcareFacility', i));
            accred.add(a);

            SObject e = rec('PersonEducation');
            putIf(e, 'Name', 'Education ' + (i + 1));
            putFirst(e, new List<String>{'RelatedPersonId', 'PersonId', 'ContactId'}, pick('Contact', i));
            edu.add(e);

            SObject aw = rec('Award');
            putIf(aw, 'Name', 'Top Performer ' + (2021 + i));
            putFirst(aw, new List<String>{'HealthcareProviderId', 'ProviderId'}, pick('HealthcareProvider', Math.mod(i, 3)));
            putFirst(aw, new List<String>{'HealthcareFacilityId', 'FacilityId'}, pick('HealthcareFacility', i));
            awards.add(aw);

            SObject pe = rec('PersonEmployment');
            putIf(pe, 'Name', 'Employment ' + (i + 1));
            putIf(pe, 'RelatedPersonId', pick('Contact', i));
            putFirst(pe, new List<String>{'HealthcareProviderId', 'EmployerId', 'AccountId'}, pick('HealthcareProvider', 3 + Math.mod(i, 2)));
            emp.add(pe);

            SObject bc = rec('BoardCertification');
            putIf(bc, 'Name', 'Board Cert ' + specNames[i]);
            putFirst(bc, new List<String>{'HealthcareProviderId', 'ProviderId'}, pick('HealthcareProvider', Math.mod(i, 3)));
            putFirst(bc, new List<String>{'CareSpecialtyId', 'SpecialtyId'}, pick('CareSpecialty', i));
            cert.add(bc);

            SObject bl = rec('BusinessLicense');
            putIf(bl, 'Name', 'LIC-CA-' + String.valueOf(1000 + i));
            // attach to individuals + group + facility where fields are available
            putFirst(bl, new List<String>{'HealthcareProviderId', 'ProviderId'}, pick('HealthcareProvider', i));
            putFirst(bl, new List<String>{'HealthcareFacilityId', 'FacilityId'}, pick('HealthcareFacility', Math.mod(i, 2)));
            putFirst(bl, new List<String>{'ExpirationDate', 'ExpiryDate'}, today.addDays(45 + (i * 30)));
            lic.add(bl);

            SObject aa = rec('CareProviderAdverseAction');
            putIf(aa, 'Name', 'Adverse Action ' + (i + 1));
            putFirst(aa, new List<String>{'HealthcareProviderId', 'ProviderId'}, pick('HealthcareProvider', Math.mod(i, 3)));
            putFirst(aa, new List<String>{'Status', 'ActionStatus'}, i < 2 ? 'Active' : 'Closed');
            adverse.add(aa);
        }
        insertAndTrack('Accreditation', accred);
        insertAndTrack('PersonEducation', edu);
        insertAndTrack('Award', awards);
        insertAndTrack('PersonEmployment', emp);
        insertAndTrack('BoardCertification', cert);
        insertAndTrack('BusinessLicense', lic);
        insertAndTrack('CareProviderAdverseAction', adverse);

        // Insurance Policy (5)
        List<SObject> pol = new List<SObject>();
        for (Integer i = 0; i < 5; i++) {
            SObject p = rec('InsurancePolicy');
            putIf(p, 'Name', 'POL-' + String.valueOf(9000 + i));
            putIf(p, 'NameInsuredId', pick('Account', i));
            putFirst(p, new List<String>{'Status'}, i < 3 ? 'Active' : 'Draft');
            pol.add(p);
        }
        insertAndTrack('InsurancePolicy', pol);

        // Provider Network Tier (5)
        List<SObject> tiers = new List<SObject>();
        List<String> tierNames = new List<String>{'Tier 1','Tier 2','Tier 3','Tier 1','Tier 2'};
        for (Integer i = 0; i < 5; i++) {
            SObject t = rec('ProviderNetworkTier');
            putIf(t, 'Name', tierNames[i]);
            putIf(t, 'ProviderNetworkId', pick('HealthcarePayerNetwork', i));
            tiers.add(t);
        }
        insertAndTrack('ProviderNetworkTier', tiers);

        // Provider Network Contract (5)
        List<SObject> pnc = new List<SObject>();
        for (Integer i = 0; i < 5; i++) {
            SObject c = rec('ProviderNetworkContract');
            putIf(c, 'ContractId', pick('Contract', i));
            putIf(c, 'HealthcarePayerNetworkId', pick('HealthcarePayerNetwork', i));
            putIf(c, 'HealthcareProviderId', pick('HealthcareProvider', i));
            putIf(c, 'StartDate', today.addMonths(-6));
            putIf(c, 'EndDate', today.addMonths(12));
            pnc.add(c);
        }
        insertAndTrack('ProviderNetworkContract', pnc);

        System.debug('=== FINAL CREATED COUNTS ===');
        for (String k : successByObject.keySet()) {
            System.debug(k + ' => ' + successByObject.get(k));
        }
    }
}

new ProviderSampleDataLoaderKumar().run();
