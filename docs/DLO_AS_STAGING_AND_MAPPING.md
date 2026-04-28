# Is the DLO Used the Right Way? Do I Map DLO to DMOs?

## Short answer

- **Yes**, using a **flattened DLO** as the place the Provider Summary action queries is the right approach.
- The DLO is **empty** because nothing is **feeding** it yet. You don’t “map the DLO to DMOs.” You **map DMOs (and/or other sources) into this DLO** with a **data stream**, so the flattened table gets rows.

---

## Two different uses of “DLO”

| Use | Role | Who fills it |
|-----|------|----------------|
| **Staging DLO** | Raw landing table for ingestion (e.g. from files, APIs). | Ingestion / data streams (CRM, external). |
| **Flattened DLO** (your case) | One wide table per provider (NPI, name, awards, licenses, specialty, etc.) for easy querying. | A **data stream** that **maps from DMOs (or Salesforce objects) into this DLO**. |

Your **CanonicalData_PNM_Template_test** / **CanonicalData_PNM_Template_MT** is a **flattened DLO**: it’s meant to be the **target** of a mapping, not a staging table you then map “to” DMOs.

---

## How data should flow for Provider Summary

```
┌─────────────────────────────────────────────────────────────────────────┐
│  SOURCES (pick one or combine)                                          │
│  • Salesforce objects (HealthcareProvider, HealthcareProviderNPI, etc.)  │
│  • Data Cloud DMOs (Provider, NPI, Award, Specialty, …)                 │
│  • External system (file, API) → staging DLO                            │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  DATA STREAM (in Data 360)                                               │
│  Maps sources → flattened DLO                                           │
│  • Source: DMOs (or SF objects / staging DLO)                           │
│  • Target: CanonicalData_PNM_Template_MT (or _test__dll)               │
│  • Field mapping: Provider NPI, name, awards, licenses, specialty, etc. │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  FLATTENED DLO (one row per provider, 485 columns)                       │
│  CanonicalData_PNM_Template_MT / CanonicalData_PNM_Template_test__dll   │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  PROVIDER SUMMARY ACTION (Apex)                                          │
│  SELECT * FROM "CanonicalData_PNM_Template_..." WHERE "ProviderNpi__c"  │
│  = :npi LIMIT 1 → format summary                                        │
└─────────────────────────────────────────────────────────────────────────┘
```

So: **DMOs (or SF objects) → data stream → flattened DLO → action**. The action only reads the DLO; it does not talk to DMOs or Salesforce at runtime.

---

## Do I need to “map this DLO to individual DMOs”?

**No.** You need the **opposite**:

- **Map DMOs (and related objects) into this DLO** via a **data stream** in Data 360.

That stream:

1. **Source:** Your normalized data:
   - Either **Data Cloud DMOs** (e.g. HealthcareProvider, HealthcareProviderNPI, CareSpecialty, Award, etc.), or  
   - **Salesforce objects** (if you’re not using DMOs for this flow), or  
   - A **staging DLO** that already has raw provider data.
2. **Target:** The **flattened DLO** (e.g. `CanonicalData_PNM_Template_MT` or `CanonicalData_PNM_Template_test__dll`).
3. **Mapping:** Map fields from the source(s) to the flattened DLO’s columns (ProviderNpi__c, provider name, award, license, specialty, city, state, zip, etc. per your DLO field list).

Until this stream exists and has run, the flattened DLO will have **no rows**, so the Provider Summary action will always say “no provider found.”

---

## What to do next

1. **In Data 360 (your org)**  
   - Open the **flattened DLO** (CanonicalData_PNM_Template_MT or _test__dll) and confirm its **field API names** (they’re already documented in `DLO_FIELD_MAPPING_CanonicalData_PNM_Template_test.md` for the _test object).
2. **Create or fix the data stream** that populates this DLO:
   - **If data is in DMOs:** Configure a stream that reads from the relevant DMOs (and their relationships), flattens them, and writes into this DLO (field-to-field mapping).
   - **If data is in Salesforce objects:** Use a CRM data stream that reads from HealthcareProvider, HealthcareProviderNPI, etc., and maps into this DLO.
   - **If data is in a staging DLO:** Configure a stream from that staging DLO into this flattened DLO.
3. **Run the stream** (on a schedule or on demand) so the flattened DLO gets rows.
4. **Re-run** `scripts/ListNpisInDlo.apex` to confirm NPIs appear; then test the Provider Summary action with one of those NPIs.

---

## Summary

| Question | Answer |
|----------|--------|
| Are we using the DLO in the right way? | **Yes.** Querying a single flattened DLO by NPI is the right design for the Provider Summary action. |
| Why is the DLO empty? | No data stream is **feeding** this DLO yet (no mapping from DMOs or other sources **into** it). |
| Is a separate "DLO mapping" step needed? | **No.** The flattened DLO does not need its own mapping. It is the **target** of the stream; the stream maps source fields → DLO fields. |
| For each data stream, map stream/source fields to target? | **Yes.** In each data stream you configure **field mapping**: source/stream fields → target object fields (DMO or DLO). |
| Do I map “this DLO to DMOs”? | **No.** You **map DMOs (and/or other sources) into this DLO** via a data stream so the DLO has data for the action to read. |
