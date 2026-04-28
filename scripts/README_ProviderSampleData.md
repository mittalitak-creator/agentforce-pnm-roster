# Provider Sample Data Scripts

## Goal

Create **5 records in each** of these 12 **standard** objects (no custom objects or custom fields):

| # | Object API name |
|---|------------------|
| 1 | HealthcareProvider |
| 2 | HealthcareProviderNPI |
| 3 | CareTaxonomy |
| 4 | HealthcareProviderTaxonomy |
| 5 | CareSpecialty |
| 6 | HealthcareProviderSpecialty |
| 7 | Award |
| 8 | CareService |
| 9 | HealthcareProviderService |
| 10 | BoardCertification |
| 11 | HealthcareFacility |
| 12 | HealthcarePractitionerFacility |

## Recommended run order (phased, to avoid org-specific issues)

Run these in **Execute Anonymous** (Developer Console or `sf apex run --file <script> --target-org <alias>`) in order:

1. **RunStep1Only.apex** – 5 Accounts, 5 Contacts, 5 HealthcareProviders.
2. **RunStep2Part1_TaxonomyOnly.apex** – 5 CareTaxonomy, 5 CareSpecialty, 5 CareService.
3. **CreateProviderSampleData_Phase2b.apex** – 5 Award, 5 BoardCertification, 5 HealthcareFacility.  
   - If you get “Account is a required field” on Award, ensure Award has AccountId set (script sets it from provider accounts). Some orgs have validation rules that require Account.
4. **CreateProviderSampleData_Phase2c.apex** – 5 HealthcareProviderNPI, 5 HealthcareProviderTaxonomy, 5 HealthcareProviderSpecialty, 5 HealthcareProviderService, 5 HealthcarePractitionerFacility.

After step 4 you will have 5 records in each of the 12 objects.

**Alternative:** To create only 5 NPIs (e.g. after step 1), run **TestNpiWithLookups.apex** once.

## Single-script option (may hit org-specific errors)

**CreateProviderSampleData.apex** attempts all 12 object types in one run. In some orgs it can fail with “Required fields are missing: [Name]” or “Account is a required field” due to describe/validation quirks; the phased scripts above avoid that.

## If your org uses a namespace

If these objects are in a managed package (e.g. Health Cloud), the API name in code may include a prefix. At the top of the script, set:

```apex
String NS = 'HealthCloudGA__';  // or your package namespace
```

and ensure the object names in `getGlobalDescribe().get(NS + 'HealthcareProvider')` match what you see in **Setup → Object Manager** (e.g. `HealthcareProvider` vs `HealthCloudGA__HealthcareProvider__c`). If the full API name is `HealthCloudGA__HealthcareProvider__c`, use `NS = 'HealthCloudGA__'` and the script uses `HealthcareProvider` – you may need to change the suffix to `__c` for package custom objects (e.g. `NS + 'HealthcareProvider__c'`) if your describe shows that.

## If a field name is wrong

The script uses these **standard** field names for lookups and values:

- **HealthcareProviderId** – lookup to HealthcareProvider (on NPI, Taxonomy, Specialty, Service, PractitionerFacility, and optionally Award, BoardCertification)
- **CareTaxonomyId** – lookup to CareTaxonomy
- **CareSpecialtyId** – lookup to CareSpecialty
- **CareServiceId** – lookup to CareService
- **HealthcareFacilityId** – lookup to HealthcareFacility
- **Name** – primary name/label on each object (and NPI value on HealthcareProviderNPI)

If your org uses different standard field API names (e.g. **TaxonomyId** instead of **CareTaxonomyId**), edit the script and replace the field name in the `r.put('...', ...)` call for that object. Use **Setup → Object Manager → [Object] → Fields** to confirm API names.

## No custom objects or fields

This script does **not** create or reference any custom objects or custom fields. It uses only the standard objects and standard fields listed above.
