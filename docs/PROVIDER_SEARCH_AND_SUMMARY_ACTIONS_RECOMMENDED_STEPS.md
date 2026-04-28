# Provider Search & Provider Summary Agentic Actions – Recommended Steps

**DLO:** `CanonicalData_PNM_Template_MT` (sdb27_PNM)  
**Goal:** Create agentic actions for **provider search** (list matching providers) and **provider summary** (single-provider details) for use in an Agentforce provider agent.

---

## Overview

| Action | Purpose | Typical use |
|--------|--------|-------------|
| **Provider Search** | Return a list of providers matching criteria (NPI, name, specialty, location). | "Find cardiologists in Austin TX", "Search by NPI 1234567890". |
| **Provider Summary** | Return a single provider’s full/summary record (by NPI or ID). | "Give me a summary for NPI 1234567890", "Tell me about this provider." |

Both actions query the same DLO in Data 360 via Apex using **ConnectApi.CdpQuery** and are exposed as **@InvocableMethod** for Agentforce.

---

## Step 1: Confirm DLO Schema in sdb27_PNM

You need the **exact API name** of the table and its **field names** (case-sensitive in Data 360 SQL).

**1.1 Get table and field names**

- In **sdb27_PNM**: **Setup** → **Data Model** / **Data 360** → **Data Lake Objects**.
- Open **CanonicalData_PNM_Template_MT**.
- Note:
  - **Table API name** (might be `CanonicalData_PNM_Template_MT` or with a suffix like `__dlm` / `__dll`; Data 360 UI shows it).
  - **Field API names** for at least: identifier (e.g. NPI), name, specialty, address, city, state, zip, phone, taxonomy, network, status, etc.

**1.2 Optional: validate with a one-row query**

In Apex (or Data 360 Query API), run:

```sql
SELECT * FROM "CanonicalData_PNM_Template_MT" LIMIT 1
```

Use the **exact** object name as shown in Data 360 (with quotes to preserve case). Replace the name above if your DLO has a different API name (e.g. `"CanonicalData_PNM_Template_MT__dlm"`).

**Deliverable:** A short schema list, e.g.  
`npi__c`, `provider_name__c`, `specialty__c`, `city__c`, `state__c`, `zip__c`, `address_line_1__c`, `phone__c`, …

---

## Step 2: Provider Search Agentic Action

**2.1 Create Apex class: `ProviderSearchAction.cls`**

- **@InvocableMethod**  
  - Label: e.g. **Search Provider**  
  - Description: Search providers in the PNM canonical DLO by NPI, name, specialty, or location.  
  - Category: e.g. **Provider Search** or **PNM**.

- **Input inner class** (all optional; at least one recommended):  
  - NPI (String)  
  - Provider Name (String)  
  - Specialty (String)  
  - City (String)  
  - State (String)  
  - Zip (String)  
  - Max Results (Integer, default e.g. 20, cap at 50)

- **Output inner class:**  
  - success (Boolean)  
  - providerCount (Integer)  
  - providerSummaries (List of a small “ProviderSummary” wrapper: NPI, name, specialty, city, state, zip, address, etc.)  
  - message / errorMessage (String)

**2.2 Build SQL safely**

- Use **parameterized/bind variables** where the Data Cloud Query API supports them to avoid SQL injection.
- If building a dynamic WHERE clause, **escape** all user inputs (e.g. `String.escapeSingleQuotes`) and **never** concatenate raw user input into SQL.
- Use **quoted identifiers** for table and column names if needed for case sensitivity, e.g. `"CanonicalData_PNM_Template_MT"`, `"npi__c"`.

Example WHERE pattern (field names are placeholders; replace with your schema):

```text
WHERE 1=1
  AND (npi__c = :npi OR :npi IS NULL)
  AND (LOWER(provider_name__c) LIKE LOWER(:name) OR :name IS NULL)
  AND (specialty__c = :specialty OR :specialty IS NULL)
  AND (city__c = :city OR :city IS NULL)
  AND (state__c = :state OR :state IS NULL)
  AND (zip__c = :zip OR :zip IS NULL)
LIMIT :maxResults
```

**2.3 Execute with CdpQuery**

- Use **ConnectApi.CdpQuery.queryAnsiSqlV2** (or the current documented method for your API version).
- Construct **ConnectApi.CdpQueryInput**, set the SQL, call the method.
- Map **ConnectApi.CdpQueryOutputV2** (e.g. `response.data`, `CdpQueryV2Row`, `rowData`) into your list of provider summaries.
- Handle no rows → success true, providerCount 0, message “No providers found”.
- Handle exception → success false, errorMessage set.

**2.4 Test class**

- Create **ProviderSearchActionTest.cls**.
- Use Test.startTest() / Test.stopTest() and either:
  - Call the invocable with minimal inputs and assert success and output shape, or  
  - Use a known test DLO or mock if available.
- Aim for coverage of: no criteria, valid criteria, no results, and error path.

---

## Step 3: Provider Summary Agentic Action

**3.1 Create Apex class: `ProviderSummaryAction.cls`**

- **@InvocableMethod**  
  - Label: e.g. **Get Provider Summary**  
  - Description: Get a single provider’s summary/details by NPI (or provider ID).  
  - Category: e.g. **Provider Search** or **PNM**.

- **Input:**  
  - NPI (String) – required, or  
  - Provider Id (String) – if your DLO has a unique ID and you want to support lookup by ID.

- **Output:**  
  - success (Boolean)  
  - providerSummary (single object: NPI, name, specialty, full address, phone, taxonomy, network, status, etc. – all fields you want the agent to “read out”)  
  - message / errorMessage (String)

**3.2 Build SQL**

- Single-row lookup, e.g.  
  `SELECT … FROM "CanonicalData_PNM_Template_MT" WHERE "npi__c" = :npi LIMIT 1`  
  (again, use your actual table and field names).

**3.3 Execute and map**

- Same **ConnectApi.CdpQuery** pattern as Step 2.
- Map the first row to one provider summary object.
- If no row → success false, message “Provider not found for NPI …”.

**3.4 Test class**

- **ProviderSummaryActionTest.cls**: call with a valid NPI and assert output; call with invalid/missing NPI and assert “not found”.

---

## Step 4: Agent Configuration in Agentforce (sdb27_PNM)

**4.1 Create or open the agent**

- **Setup** → **Agents** → New agent (e.g. “Provider Search”) or open existing.

**4.2 Add both actions**

- Add **Search Provider** (ProviderSearchAction).
- Add **Get Provider Summary** (ProviderSummaryAction).
- Map **conversation/slots** to action inputs:
  - Search: NPI, Provider Name, Specialty, City, State, Zip, Max Results.
  - Summary: NPI (or Provider Id).

**4.3 Instructions for the agent**

Example prompt text:

- “When the user wants to **find** or **search** providers (by location, specialty, name, or NPI), use the **Search Provider** action with the criteria they give. If they only give partial info (e.g. city and specialty), use those; ask for more only if the result set is too large or ambiguous.”
- “When the user asks for a **summary**, **details**, or **information about** a specific provider (usually by NPI), use the **Get Provider Summary** action with that NPI.”
- “Present results clearly: for search, list key details (name, NPI, specialty, location); for summary, give a short narrative summary of the provider.”

**4.4 Slots (optional)**

- Define slots for: NPI, Provider Name, Specialty, City, State, Zip.
- Use them in the flow so the agent collects values and passes them into the actions.

**4.5 Save and activate**

- Deploy Apex to **sdb27_PNM**, then save and activate the agent.

---

## Step 5: Testing

**5.1 Provider Search**

- “Find providers in Austin, TX.”
- “Search for cardiologists in 78701.”
- “Find provider by NPI 1234567890.”
- “Providers with specialty Internal Medicine in California.”
- No criteria / invalid input → expect clear error or “provide at least one criterion”.

**5.2 Provider Summary**

- “Give me a summary for NPI 1234567890.”
- “Tell me about this provider” (after NPI is in context).
- Invalid or unknown NPI → “Provider not found”.

**5.3 Agent behavior**

- Correct action is chosen (search vs summary).
- Results are formatted and read out in a user-friendly way.

---

## Summary Checklist

| Step | Task |
|------|------|
| 1 | In sdb27_PNM, confirm DLO **CanonicalData_PNM_Template_MT** table and field API names (and optional one-row query). |
| 2 | Implement **Provider Search** action: invocable, safe SQL, CdpQuery, map to provider list; add test class. |
| 3 | Implement **Provider Summary** action: invocable, single-row SQL by NPI (or ID), CdpQuery, map to one summary; add test class. |
| 4 | In Agentforce, add both actions, map slots/inputs, add instructions, save and activate. |
| 5 | Test search and summary flows and edge cases. |

---

## Technical Notes

- **Data 360 SQL:** Use quoted identifiers for object/field names if they are case-sensitive (e.g. `"CanonicalData_PNM_Template_MT"`).  
- **CdpQuery:** Same-org only; for cross-org use Named Credential + Data Cloud Query REST API.  
- **Limits:** Enforce a max row limit (e.g. 50) on search to avoid timeouts and large payloads.  
- **Security:** Use sharing and input validation; no raw concatenation of user input into SQL.

Once the DLO schema from Step 1 is confirmed, Steps 2–4 can be implemented in code and Setup in sdb27_PNM.
