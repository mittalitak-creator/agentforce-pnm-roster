# Provider Data from Salesforce CRM Objects

Your **source** is **Salesforce CRM objects**. The Provider Summary action reads from a **flattened DLO**, so you need a **CRM data stream** that copies data from those objects into the DLO.

---

## Flow (two steps – stream target is not selectable)

Data streams **do not** let you choose the flattened DLO as target; each stream **creates its own DLO**. So the flow is:

```
Step 1: Salesforce CRM objects (source)
  HealthcareProvider, HealthcareProviderNPI, CareSpecialty, etc.
        │
        ▼
  CRM data streams (one per object or per stream type)
  • Source: Salesforce object (e.g. HealthcareProviderNpi)
  • Target: **Created by the stream** (e.g. HealthcareProviderNpi_Home__dll) – you cannot select the flattened DLO here
        │
        ▼
  Staging DLOs (one per stream): HealthcareProviderNpi_Home__dll, HealthcareProvider_xxx__dll, …

Step 2: Data Transform (Batch or Streaming)
  • Source: The DLOs created by the streams above
  • Target: **Your existing flattened DLO** (CanonicalData_PNM_Template_test__dll) – selectable here
  • Logic: Join/append and map fields → one row per provider with all columns
        │
        ▼
  Flattened DLO (one row per provider)
        │
        ▼
  Provider Summary action (CdpQuery on DLO by NPI)
```

See **docs/DATA_STREAM_TARGET_AND_FLATTENED_DLO.md** for why the stream target isn’t editable and how to use a transform to fill the flattened DLO.

---

## What you need to do

1. **In Data 360** create (or use) a **Salesforce CRM data stream** where:
   - **Source:** Your CRM objects (HealthcareProvider, HealthcareProviderNPI, and related objects that hold provider name, NPI, awards, licenses, specialty, facility, etc.). You may need a stream per object or a stream that can pull from multiple/related objects depending on your Data Cloud setup.
   - **Target:** Your **flattened DLO** (e.g. `CanonicalData_PNM_Template_MT` or `CanonicalData_PNM_Template_test__dll`).

2. **Configure field mapping** for that stream:
   - Map each **Salesforce field** (from HealthcareProvider, HealthcareProviderNPI, etc.) to the corresponding **DLO field** (e.g. `ProviderNpi__c`, `ProviderFirstName__c`, `ProviderLastName__c`, award, license, specialty columns, etc.). Use your DLO field list (e.g. `docs/DLO_FIELD_MAPPING_CanonicalData_PNM_Template_test.md`) for target column API names.

3. **Create a Batch (or Streaming) Data Transform** whose **target** is your existing flattened DLO; the transform reads from the DLOs created in step 1 and joins/maps into the flattened DLO. Run the transform so the flattened DLO is populated.

4. **Provider Summary action** stays as-is: it only reads from the flattened DLO by NPI. No direct read from CRM at runtime.

---

## Important points

- The **action does not read Salesforce objects directly**. It only queries the **flattened** DLO. That flattened DLO is filled by a **Data Transform**, not directly by the CRM stream (streams create their own DLO per source; see **docs/DATA_STREAM_TARGET_AND_FLATTENED_DLO.md**).
- **No DMO in the middle required** for this path: **CRM objects → streams (staging DLOs) → Data Transform → flattened DLO → action**.
- **Field mapping:** in each stream, map CRM fields → that stream’s DLO; in the transform, map staging DLO fields → flattened DLO fields.

---

## Summary

| Item | Role |
|------|------|
| **Source** | Salesforce CRM objects (HealthcareProvider, HealthcareProviderNPI, CareSpecialty, etc.) |
| **Mechanism** | CRM data stream in Data 360, with field mapping to the flattened DLO |
| **Target** | Flattened DLO (CanonicalData_PNM_Template_MT or _test__dll) |
| **Provider Summary action** | Reads only from the DLO by NPI; does not query CRM |
