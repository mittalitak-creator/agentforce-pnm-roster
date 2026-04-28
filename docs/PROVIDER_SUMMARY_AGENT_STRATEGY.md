# Provider Summary Agent Strategy – CanonicalData_PNM_Template_MT (madan_org)

## 1. DLO analysis: CanonicalData_PNM_Template_MT

**Org:** madan_org  
**Object:** CanonicalData_PNM_Template_MT (flat Data Lake Object for provider data)

### 1.1 Purpose

- **Flat DLO** = one row per provider (or per provider-related entity) with denormalized attributes.
- Holds **provider identity and profile**: provider name, NPI, awards, licenses, specialty, and related details in a single table.

### 1.2 Likely / typical fields (confirm in Data 360)

| Concept        | Possible API names (Data 360 often uses `__c`) | Use in agent |
|----------------|-------------------------------------------------|--------------|
| Provider name  | `Provider_Name__c`, `Provider__c`, `Name__c`    | Summary title |
| NPI            | `NPI__c`, `Provider_NPI__c`, `National_Provider_Identifier__c` | Search key, display |
| Award          | `Award__c`, `Awards__c`                          | Summary line |
| License        | `License__c`, `License_Number__c`, `License_State__c` | Summary line |
| Specialty      | `Specialty__c`, `Primary_Specialty__c`, `Taxonomy__c` | Summary line |
| Address / location | `Address__c`, `City__c`, `State__c`, `Zip__c`  | Summary line |
| Other          | Any other `__c` fields in the DLO               | Optional in summary |

**Action:** In madan_org, open **Data Cloud Setup → Data Lake Objects → CanonicalData_PNM_Template_MT** and note the **exact field API names**. Update the Provider Summary action’s SQL and mapping to match.

### 1.3 Query access

- **Table name:** `CanonicalData_PNM_Template_MT` (use as-is or with Data 360 suffix if different in UI; use double quotes in SQL if case-sensitive).
- **Lookup key:** NPI (or primary key) to get a single row for “provider summary”.
- **API:** Same-org Data Cloud → Apex **ConnectApi.CdpQuery.queryAnsiSqlV2** with ANSI SQL.

---

## 2. Strategy: simple provider summary agent

### 2.1 Goal

- **Input:** One NPI (from conversation or slot).
- **Output:** One provider summary (text and/or structured) for the agent to read or display.
- **Data source:** Single row from `CanonicalData_PNM_Template_MT` in madan_org.

### 2.2 Architecture

```
User: "Give me a summary for NPI 1234567890"
    → Agent (Agentforce)
        → Invocable action: Get Provider Summary
            → Apex: ProviderSummaryAction
                → ConnectApi.CdpQuery.queryAnsiSqlV2(
                    SELECT * FROM "CanonicalData_PNM_Template_MT"
                    WHERE "NPI__c" = '<npi>' LIMIT 1
                  )
            ← Map row to ProviderSummaryOutput (message + optional fields)
    ← Agent speaks / shows summary to user
```

### 2.3 Components

| # | Component | Purpose |
|---|-----------|--------|
| 1 | **ProviderSummaryAction.cls** | Invocable method: input NPI → query DLO → return success + summary message + optional structured fields. |
| 2 | **ProviderSummaryActionTest.cls** | Test class for coverage and regression. |
| 3 | **Agent (Agentforce)** | One agent (e.g. “Provider Summary”) with this action, instructions, and optional NPI slot. |

### 2.4 Simplifications for “simple” agent

- **One action only:** “Get Provider Summary” by NPI (no search/list in this minimal version).
- **One DLO:** Only `CanonicalData_PNM_Template_MT`; no joins.
- **Summary as text:** Action returns a `summaryMessage` the agent can read out; optional structured fields for future use.
- **Error handling:** No row or invalid NPI → clear message (“Provider not found for NPI …”).

---

## 3. Next steps (in order)

### Step 1: Confirm DLO schema in madan_org

1. **Setup → Data Cloud / Data 360 → Data Lake Objects.**
2. Open **CanonicalData_PNM_Template_MT**.
3. List all fields (API names and types).
4. Identify:
   - **NPI field** (for WHERE clause).
   - **Provider name, award, license, specialty**, and any other fields to include in the summary.

### Step 2: Deploy Provider Summary action

1. **Align Apex with schema:** In `ProviderSummaryAction.cls`, set the correct table name and column names (especially the NPI column and any fields you map into `summaryMessage`).
2. Deploy to **madan_org:**
   ```bash
   sf project deploy start --source-dir force-app/main/default/classes/ProviderSummaryAction.cls force-app/main/default/classes/ProviderSummaryActionTest.cls --target-org madan_org
   ```
3. Run tests:
   ```bash
   sf apex run test --class-names ProviderSummaryActionTest --target-org madan_org --result-format human
   ```

### Step 3: Create the Provider Summary agent (Agentforce)

1. **Setup → Agents → New Agent** (e.g. name: “Provider Summary”).
2. **Actions:** Add **Get Provider Summary** (from `ProviderSummaryAction`).
3. **Instructions:** e.g.  
   “When the user asks for a provider summary or details about a provider by NPI, use the Get Provider Summary action with the NPI they provide. Read back the summary message clearly. If the action returns an error (e.g. provider not found), say so and ask for a different NPI if needed.”
4. **Slots (optional):** Add a slot **NPI** and map it to the action input.
5. **Save and activate.**

### Step 4: Test end-to-end

- “Give me a summary for NPI &lt;valid NPI in your DLO&gt;” → expect a clear summary.
- “Summary for NPI 0000000000” (invalid) → “Provider not found” (or similar).
- Confirm the agent calls the action and speaks/shows the summary.

### Step 5 (optional): Extend later

- **Provider Search action:** Same DLO, multiple rows (filter by name, specialty, city, etc.) for “find providers.”
- **Slots:** Specialty, City, State for a future search action.
- **RAG / search index:** If you add a Data Cloud search index on this DLO, you can add a retriever for semantic queries alongside the NPI-based summary.

---

## 4. Summary

| Item | Detail |
|------|--------|
| **DLO** | CanonicalData_PNM_Template_MT (madan_org), flat provider data. |
| **Key field** | NPI (exact name to confirm in Data 360). |
| **Simple agent** | One invocable (Get Provider Summary by NPI) → one row from DLO → one summary message. |
| **Next** | Confirm schema → deploy ProviderSummaryAction (+ test) → create agent → test with real NPI. |
