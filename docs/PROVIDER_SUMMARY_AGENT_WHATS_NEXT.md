# Provider Summary Agent – What’s Next (You Have DMO + Streams + Mock Data)

You have:
- **Flattened DMO** (Data Model Object) – the queryable table for provider data  
- **Data streams** – data flowing into the object  
- **Mock data** – test rows in the DMO  

Here’s what you need next to get the provider summary agent working.

---

## 1. Confirm the DMO schema (table + column names)

The Apex action must use the **exact** API names of your flattened DMO and its columns (case-sensitive in Data Cloud SQL).

**Do this:**

1. In your org: **Setup** → **Data Cloud** / **Data 360** → **Data Model** (or **Data Lake Objects**).
2. Open your **flattened DMO** (the one that has the mock provider data).
3. Note:
   - **Table / object API name** (e.g. `CanonicalData_PNM_Template_MT` or your actual name).
   - **NPI column** API name (e.g. `NPI__c`, `National_Provider_Identifier__c`).
   - Any other columns you want in the summary: provider name, specialty, city, state, zip, award, license, etc., and their **exact** API names.

**Deliverable:** A short list, e.g.  
`Table: MyProvider_Flat__dll`, `NPI: NPI__c`, `Name: Provider_Name__c`, `Specialty: Specialty__c`, …

---

## 2. Point the Apex action at your DMO

The existing **ProviderSummaryAction.cls** has two constants you must set to your schema:

| Constant       | Purpose              | Set to your…                    |
|----------------|----------------------|----------------------------------|
| `DLO_TABLE`    | Queryable table name | Flattened DMO API name          |
| `NPI_COLUMN`   | NPI field in SQL     | NPI column API name             |

Optional: the code also maps several fields (provider name, award, license, specialty, city, state, zip). If your DMO uses different API names, those mappings can be updated so the summary text and structured output match your data.

---

## 3. Deploy the action and run tests

- Deploy **ProviderSummaryAction** and **ProviderSummaryActionTest** to the org where the flattened DMO lives.
- Run the test class to ensure the action runs and coverage is sufficient.

---

## 4. Create the agent in Agentforce

- **Setup** → **Agents** → **New Agent** (e.g. “Provider Summary”).
- **Actions:** Add **Get Provider Summary** (from `ProviderSummaryAction`).
- **Instructions:** e.g.  
  “When the user asks for a provider summary or details by NPI, use the Get Provider Summary action with the NPI they provide. Read back the summary message. If the action returns an error (e.g. provider not found), say so.”
- **Slots (optional):** Add an **NPI** slot and map it to the action input.
- **Save and activate** the agent.

---

## 5. Test with your mock data

- Pick an **NPI that exists** in your flattened DMO (from your mock data).
- In the agent: “Give me a summary for NPI &lt;that NPI&gt;.”
- Confirm the agent calls the action and returns a summary. Try an invalid NPI and confirm you get a clear “not found” message.

---

## Summary checklist

| # | What you need next |
|---|--------------------|
| 1 | **Schema list** – Flattened DMO API name + NPI column + any other column names you want in the summary. |
| 2 | **Apex constants** – Set `DLO_TABLE` and `NPI_COLUMN` (and optional field mappings) in `ProviderSummaryAction.cls` to match that schema. |
| 3 | **Deploy + test** – Deploy the action and run `ProviderSummaryActionTest`. |
| 4 | **Agent** – Create the Agentforce agent, add the action, instructions, and optional NPI slot; activate. |
| 5 | **E2E test** – Use a known NPI from your mock data and confirm the agent returns the right summary. |

Once you have the **exact DMO name and NPI column name** (and optionally the other column names), the next step is to update `ProviderSummaryAction.cls` with those values and deploy.
