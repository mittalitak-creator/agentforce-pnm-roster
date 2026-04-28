# Standard Objects Reference: Your 12 Objects → Health Cloud / Salesforce API Names

This document maps the 12 provider-related objects you listed to their **standard** Salesforce Health Cloud (or related product) object API names. Use these when creating sample data or integrating with an org that has Health Cloud or Provider Management.

---

## Summary Table

| Your name | Standard / Health Cloud object | API name (typical) | Type / product |
|-----------|--------------------------------|---------------------|-----------------|
| Healthcare Provider | Healthcare Provider (business-level provider) | **HealthcareProvider** | Health Cloud (standard) |
| Healthcare Provider NPI | Healthcare Provider NPI | **PractitionerNPI** or **HealthCloudGA__PractitionerNPI__c** / **HealthcareProviderNPI** | Health Cloud |
| CareSpecialty | Care Specialty | **CareSpecialty** | Standard (Health Cloud) |
| CareTaxonomy | Care Specialty Taxonomy / Healthcare Taxonomy | **CareSpecialtyTaxonomy** or **HealthcareTaxonomy** | Standard (Health Cloud) |
| HealthcareProviderSpecialty | Healthcare Provider Specialty | **HealthcareProviderSpecialty** or junction from Provider + CareSpecialty | Health Cloud |
| HealthcareProviderTaxonomy | Healthcare Provider Taxonomy | **HealthcareProviderTaxonomy** or similar | Health Cloud |
| Award | Award | **Award** | Standard (Health Cloud) |
| BoardCertification | Board Certification | **BoardCertification** | Standard (Health Cloud) |
| CareService | Care Service | **CareService** | Standard (Health Cloud) |
| HealthcareFacility | Healthcare Facility | **HealthcareFacility** or **HealthCloudGA__HealthcareFacility__c** | Health Cloud |
| HealthcareProviderService | Healthcare Provider Service | **HealthcareProviderService** or junction | Health Cloud |
| HealthcarePractitionerFacility | Healthcare Practitioner Facility | **HealthcarePractitionerFacility** | Health Cloud |

---

## 1. Healthcare Provider

- **Display name:** Healthcare Provider  
- **Standard / Health Cloud:** Represents the provider (individual or organization) at a business level.  
- **API name:** **HealthcareProvider**  
- **Reference:** Health Cloud / Provider Relationship Management; use this object in your org for provider records.  
- **Note:** Some orgs may also have **CarePgmProvHealthcareProvider** (Care Program Healthcare Provider) or **HealthCloudGA__HealthcareProvider__c**; use **HealthcareProvider** when that is the object you see in Object Manager.

---

## 2. Healthcare Provider NPI

- **Display name:** Healthcare Provider NPI  
- **Standard / Health Cloud:** Stores National Provider Identifier (NPI) for a provider.  
- **API name (s):**
  - **PractitionerNPI** – Standard object (practitioner-level NPI).  
  - **HealthCloudGA__PractitionerNPI__c** – Package custom object in some releases.  
  - **HealthcareProviderNPI** – Referenced in Provider Relationship Management / Data Cloud data model.  
- **Reference:** Provider Data Model; Healthcare Provider Relationship Management (Data Cloud).  
- **Note:** Exact API name can be **PractitionerNPI**, **HealthcareProviderNPI**, or a namespaced **__c** object. Check Setup → Object Manager in your org.

---

## 3. CareSpecialty

- **Display name:** Care Specialty  
- **Standard / Health Cloud:** Care specialty (e.g. Cardiology, Internal Medicine).  
- **API name:** **CareSpecialty**  
- **Type:** Standard object (Health Cloud).  
- **Reference:** Soft-builder Health Cloud object list; Provider Relationship Management.

---

## 4. CareTaxonomy

- **Display name:** Care Taxonomy / Healthcare Taxonomy  
- **Standard / Health Cloud:** Taxonomy classification (e.g. NUCC).  
- **API name (s):**
  - **CareSpecialtyTaxonomy** – Links specialty to taxonomy.  
  - **HealthcareTaxonomy** – Taxonomy entity in Provider / Data Cloud models.  
- **Reference:** Provider Relationship Management; Data Cloud Healthcare Provider Relationship Management.  
- **Note:** “CareTaxonomy” may map to **CareSpecialtyTaxonomy** or **HealthcareTaxonomy** depending on model. Check Object Manager.

---

## 5. HealthcareProviderSpecialty

- **Display name:** Healthcare Provider Specialty  
- **Standard / Health Cloud:** Junction: Provider ↔ Care Specialty.  
- **API name:** **HealthcareProviderSpecialty** (or equivalent junction object in Health Cloud / Provider Management).  
- **Reference:** Provider Relationship Management; Provider Data Model.

---

## 6. HealthcareProviderTaxonomy

- **Display name:** Healthcare Provider Taxonomy  
- **Standard / Health Cloud:** Junction: Provider ↔ Taxonomy.  
- **API name:** **HealthcareProviderTaxonomy** (or equivalent in your product).  
- **Reference:** Provider Relationship Management; Data Cloud data model.

---

## 7. Award

- **Display name:** Award  
- **Standard / Health Cloud:** Awards / recognition for providers or facilities.  
- **API name:** **Award**  
- **Type:** Standard object (Health Cloud).  
- **Reference:** Soft-builder object list (Award); Provider Management / Credentials.

---

## 8. BoardCertification

- **Display name:** Board Certification  
- **Standard / Health Cloud:** Board certifications.  
- **API name:** **BoardCertification**  
- **Type:** Standard object (Health Cloud).  
- **Reference:** Soft-builder object list (Board Certification); Credentials objects.

---

## 9. CareService

- **Display name:** Care Service  
- **Standard / Health Cloud:** Type of care service.  
- **API name:** **CareService**  
- **Type:** Standard object (Health Cloud).  
- **Reference:** Soft-builder object list (Care Service); Provider Relationship Management.

---

## 10. HealthcareFacility

- **Display name:** Healthcare Facility  
- **Standard / Health Cloud:** Facility (hospital, clinic, etc.).  
- **API name (s):**
  - **HealthcareFacility** – Standard object in Provider / Health Cloud models.  
  - **HealthCloudGA__HealthcareFacility__c** – Package custom in some orgs.  
- **Reference:** Provider Relationship Management; Discover Credentials and Healthcare Facility Objects (Trailhead).

---

## 11. HealthcareProviderService

- **Display name:** Healthcare Provider Service  
- **Standard / Health Cloud:** Junction: Provider ↔ Care Service.  
- **API name:** **HealthcareProviderService** (or equivalent).  
- **Reference:** Provider Relationship Management.

---

## 12. HealthcarePractitionerFacility

- **Display name:** Healthcare Practitioner Facility  
- **Standard / Health Cloud:** Junction: Practitioner/Provider ↔ Facility.  
- **API name:** **HealthcarePractitionerFacility**  
- **Reference:** Provider Relationship Management; Data Cloud Healthcare Provider Relationship Management.

---

## How to confirm in your org

1. **Setup → Object Manager** – Search for the label or API name (e.g. “Healthcare Provider”, “Care Specialty”, “Award”).  
2. **Health Cloud** – If installed, use **HealthcareProvider** for the main provider object; other standard objects include **Award**, **BoardCertification**, **CareService**, **CareSpecialty**. Some orgs also have **HealthCloudGA__** custom objects.  
3. **Data Cloud / Provider Relationship Management** – Same logical entities may appear as Data Model Objects (DMOs) with different naming; for **Salesforce objects** (not DLOs), use Object Manager.

---

## References

- [Health Cloud Object Reference – Healthcare Provider](https://developer.salesforce.com/docs/atlas.en-us.health_cloud_object_reference.meta/health_cloud_object_reference/sforce_api_objects_carepgmprovhealthcareprovider.htm) (Care Program variant; use **HealthcareProvider** when that is the API name in your org)  
- [Provider Relationship Management Data Model](https://developer.salesforce.com/docs/platform/data-models/guide/provider-relationship-management.html)  
- [Data Cloud – Healthcare Provider Relationship Management](https://developer.salesforce.com/docs/platform/data-models/guide/data-cloud-healthcare-provider-relationship-management.html)  
- [Discover Credentials and Healthcare Facility Objects (Trailhead)](https://trailhead.salesforce.com/content/learn/modules/provider-management-data-model-in-public-sector-solutions/discover-credentials-and-healthcare-facility-objects)  
- [Soft-builder Health Cloud objects list](https://soft-builder.com/en/docs/SamplesDocs/Salesforce_Health_Cloud_Documentation/objects.html) (Award, BoardCertification, CareService, CareSpecialty, HealthcareProvider, etc.)
