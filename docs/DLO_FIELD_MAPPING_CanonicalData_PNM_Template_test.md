# DLO Field Mapping – CanonicalData_PNM_Template_test__dll

Used by **ProviderSummaryAction.cls** for the Get Provider Summary agentic action.  
Source: DLO metadata (PDF export from Data Cloud). Table has **485 fields**; below are the ones used in the summary.

## Table and NPI

| Purpose        | API name                          |
|----------------|-----------------------------------|
| DLO table      | `CanonicalData_PNM_Template_test__dll` |
| NPI (lookup)   | `ProviderNpi__c`                  |
| NPI (key qual) | `KQ_ProviderNpi__c`               |

## Provider name (built from)

- `ProviderSalutation__c`
- `ProviderFirstName__c`
- `ProviderMiddleName__c`
- `ProviderLastName__c`
- `ProviderTitle__c`

## Award

- `Award1Name__c`, `Award2Name__c`, … `Award5Name__c`
- `Award1AwardedBy__c`, …

## License

- `BusinessLicense1LicenseNumber__c`, `BusinessLicense1Name__c`
- (Similar for 2–5: `BusinessLicense2*__c`, …)

## Specialty

- `CareSpecialty1Name__c`, `CareSpecialty2Name__c`, … `CareSpecialty5Name__c`
- `CareServiceName__c`

## Address / location (mailing preferred)

- City: `ProviderMailingCity__c`, `ProviderBillingCity__c`, `ProviderOtherCity__c`
- State: `ProviderMailingState__c`, `ProviderBillingState__c`, `ProviderOtherState__c`
- Zip: `ProviderMailingPostalCode__c`, `ProviderBillingPostalCode__c`, `ProviderOtherPostalCode__c`

## Status

- `ProviderStatus__c`, `ProviderIsActive__c`

## Other useful fields (not yet in summary)

- `ProviderType__c`, `ProviderClass__c`
- `ProviderEmail__c`, `ProviderPhone__c`, `ProviderFax__c`
- `ProviderEffectiveFrom__c`, `ProviderEffectiveTo__c`
- `CareTaxonomy1Code__c`, … `CareTaxonomy5Code__c`
- `Facility1Name__c`, … `Facility5Name__c`
