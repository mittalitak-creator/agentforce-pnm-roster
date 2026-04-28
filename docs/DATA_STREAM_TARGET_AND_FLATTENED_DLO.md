# Data Stream Target vs Flattened DLO – Why You Can’t Select the Target

## What you’re seeing

- When you create a **data stream** (e.g. **HealthcareProviderNpi_Home**), the UI **does not let you choose the target object**.
- The stream **creates its own DLO** as the target (e.g. **HealthcareProviderNpi_Home__dll**).
- You need data in the **flattened** DLO (**CanonicalData_PNM_Template_test__dll**) for the Provider Summary action, but there is **no option to select that as the stream’s target**.

This is expected behavior in Data Cloud for this type of stream.

---

## How it works: two steps

### Step 1: Data streams → one DLO per source

- Each **CRM (or other) data stream** has a **fixed pattern**: source object → **new DLO created by the stream**.
- You **cannot** point that stream at an existing DLO like `CanonicalData_PNM_Template_test__dll`.
- So you get:
  - HealthcareProvider stream → e.g. **HealthcareProvider_xxx__dll**
  - HealthcareProviderNpi_Home stream → **HealthcareProviderNpi_Home__dll**
  - (and so on for other sources)

Those DLOs are the **staging / source DLOs** for the next step.

### Step 2: Data transform → flattened DLO

- The **flattened** DLO (e.g. **CanonicalData_PNM_Template_test__dll**) is meant to be filled by a **Data Transform** (Batch or Streaming), not directly by the CRM stream.
- In the transform you:
  - **Source:** The DLOs created by your streams (and/or DMOs).
  - **Target:** Your **flattened DLO** (CanonicalData_PNM_Template_test__dll).
  - **Logic:** Join/append/aggregate so that one row per provider is written with all needed columns (NPI, name, award, license, specialty, etc.).

So: **Streams create DLOs; a transform fills the flattened DLO from those DLOs.**

---

## What to do

1. **Keep using the streams as they are.**  
   Let each stream create its target DLO (e.g. HealthcareProviderNpi_Home__dll). That’s the correct first step.

2. **Create a Batch Data Transform (or Streaming Data Transform)** in Data 360 where:
   - **Inputs:** Add **all** DLOs from your streams (e.g. all 10) as **input nodes** in the **same** transform. You need **one** transform, not one per stream.
   - **Logic:** Join/append and map fields so you build one row per provider with the schema of your flattened DLO (use your DLO field list, e.g. ProviderNpi__c, ProviderFirstName__c, …).
   - **Output:** **CanonicalData_PNM_Template_test__dll** (your existing flattened DLO) as the **target** of the transform.

3. **Run the transform** (schedule or on demand). After it runs, the flattened DLO will have rows and the Provider Summary action will find providers by NPI.

---

## Where to configure the transform

- In **Data 360**, look for **Batch Data Transforms** (or **Data Transforms** / **Recipes**) and **Streaming Data Transforms**.
- Use the transform’s **output** (or “target object”) setting to select your **existing** flattened DLO (**CanonicalData_PNM_Template_test__dll**). Transforms typically allow choosing an existing DLO as the target, unlike the stream UI.

---

## Summary

| Step | Tool | Source | Target |
|------|------|--------|--------|
| 1 | Data stream (CRM) | Salesforce object (e.g. HealthcareProviderNpi) | **New** DLO created by stream (e.g. HealthcareProviderNpi_Home__dll) – target **not** selectable |
| 2 | Batch / Streaming Data Transform | DLOs from step 1 (and/or DMOs) | **Existing** flattened DLO (CanonicalData_PNM_Template_test__dll) – target **is** selectable here |

So: you **don’t** edit the stream to point at the flattened DLO. You **add one transform** that reads all stream-created DLOs (e.g. all 10) and writes into the flattened DLO. **One transform, many inputs, one output.**
