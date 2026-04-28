# Build a Provider Search Agent Using DLO `CanonicalData_PNM_Template_MT`

This guide lists steps to build a **provider search agent** in the **sdb27_PNM** org using the flattened Data Lake Object (DLO) **CanonicalData_PNM_Template_MT**.

---

## Prerequisites

- **Org**: sdb27_PNM (where the DLO exists)
- **DLO**: `CanonicalData_PNM_Template_MT` (flattened provider/canonical data)
- **Data Cloud / Data 360** enabled in that org (required to query DLOs)
- **Agentforce** license and access in the same org (or a connected org with Named Credential to Data Cloud)

---

## Step 1: Discover the DLO Schema

You need the exact **field names and types** of `CanonicalData_PNM_Template_MT` to write correct SQL and map results to your agent.

**Option A – Data 360 / Data Model Manager (UI)**  
1. In **sdb27_PNM**, go to **Setup** → search for **Data Model** or **Data 360**.  
2. Open **Data Lake Objects** (or **Data Model Manager**).  
3. Find **CanonicalData_PNM_Template_MT** and open it.  
4. Note all fields that are relevant for provider search (e.g. NPI, provider name, specialty, address, city, state, zip, network, taxonomy, etc.).

**Option B – API / Developer**  
- Use the Data Cloud Object Catalog API or Data 360 object metadata to list fields for `CanonicalData_PNM_Template_MT`.  
- Or run a simple `SELECT * FROM CanonicalData_PNM_Template_MT LIMIT 1` (via Data Cloud Query API or Apex) and inspect the returned columns.

**Deliverable**: A list of field API names you will use in queries (e.g. `npi`, `provider_name`, `specialty`, `city`, `state`, `zip` — names depend on your DLO).

---

## Step 2: Decide How the Agent Will Query the DLO

Two common patterns:

| Scenario | Approach |
|--------|----------|
| **Agent and Data Cloud in the same org (sdb27_PNM)** | Use **Apex + ConnectApi.CdpQuery** to run SQL on the DLO and expose an invocable action to the agent. |
| **Agent in a different org** | Use **Named Credential** (OAuth, scope `cdp_query_api`) to call the Data Cloud Query API from that org; implement an Apex invocable action that does an HTTP callout to run SQL and return provider results. |

For most cases, **same-org + Apex invocable action** is the simplest.

---

## Step 3: Implement a Provider Search Invocable Action (Apex)

Create an Apex action that runs a parameterized SQL query on `CanonicalData_PNM_Template_MT` and returns a structured result for the agent.

1. **Create an Apex class** (e.g. `ProviderSearchAction.cls`) with:
   - **@InvocableMethod** (e.g. label “Search Provider”, category “Provider Search” or “PNM”).
   - **Input inner class** with `@InvocableVariable`:
     - e.g. NPI, Provider Name, Specialty, City, State, Zip (all optional; at least one recommended).
   - **Output inner class** with:
     - `success` (Boolean), `providers` (list of provider summary), `count`, `message` / `errorMessage`.

2. **Inside the method**:
   - Build a **parameterized ANSI SQL** string against `CanonicalData_PNM_Template_MT` using the DLO field names from Step 1 (e.g. `WHERE (npi = :npi OR provider_name ILIKE :name) AND city = :city ...`).
   - Use **ConnectApi.CdpQuery** (same-org Data Cloud) to execute the query and map rows into your output list.
   - Enforce a **reasonable row limit** (e.g. 20–50) and handle no rows / errors (set `success = false`, `message` for the agent).

3. **Security**: Run with sharing as appropriate; validate/sanitize inputs to avoid injection (use bind variables / parameters, not string concatenation).

4. **Test class**: Add an Apex test that mocks or runs against a test DLO (or use a test that verifies the action runs without throwing; Data Cloud test context may require a test DLO or stub).

**Reference**: Your existing `MemberSearchAction.cls` and `ClaimSearchAction.cls` are good patterns for input/output and error handling.

---

## Step 4: Deploy the Action to the Org Where the Agent Runs

- If the agent is in **sdb27_PNM**: deploy the Apex class (and test) to sdb27_PNM.  
- If the agent is in **another org**: deploy the Apex there and ensure the Named Credential and callout to Data Cloud Query API are configured (see Step 2).

---

## Step 5: Create or Edit the Provider Search Agent (Agentforce)

1. In the org where the agent will run: **Setup** → **Agents** → create a new agent or open an existing one (e.g. “Provider Search”).
2. **Add your action**:
   - In the agent configuration, add an **Action** and select the invocable **“Search Provider”** (or whatever you named it).
   - Map agent inputs (e.g. from conversation/slots) to the action inputs (NPI, name, specialty, city, state, zip).
3. **Instructions / prompt**:
   - Tell the agent when to search providers (e.g. “When the user asks to find a provider, search by network, location, or specialty”).
   - Tell it to use the Provider Search action with the criteria the user provided (name, NPI, city, state, zip, specialty).
   - Optionally: “If the user gives only partial info (e.g. city and specialty), use those; ask for more only if needed to narrow results.”
4. **Slots (optional)**:
   - Define slots for NPI, Provider Name, Specialty, City, State, Zip so the agent collects them in conversation and passes them into the action.
5. **Save and activate** the agent.

---

## Step 6: Optional – Add a Search Index (RAG) for Semantic Search

If you want **semantic / natural-language** provider search (e.g. “providers who do physical therapy near 90210”):

1. In **Data 360**, create a **search index** that includes the relevant DLO (or a DMO built from it) and the fields you want searchable (name, specialty, address, etc.).
2. In **Agentforce**, add a **retriever** that uses this search index.
3. The agent can then use the retriever for RAG and still use your **Provider Search action** for structured, filter-based search (NPI, exact location, etc.).

You can use both: **retriever for discovery**, **action for precise lookup**.

---

## Step 7: Test End-to-End

1. Open the agent in the desired channel (e.g. Agent Console, embedded chat).
2. Run conversations such as:
   - “Find providers in Austin, TX.”
   - “Search for NPI 1234567890.”
   - “I need a cardiologist in zip 78701.”
3. Confirm the agent calls the Provider Search action with the right parameters and that results match the DLO data.
4. Test error cases: no criteria, invalid NPI, no results — and that the agent responds with a clear message.

---

## Summary Checklist

| Step | Task |
|------|------|
| 1 | Discover schema of `CanonicalData_PNM_Template_MT` in sdb27_PNM (fields for NPI, name, specialty, location, etc.). |
| 2 | Decide same-org (CdpQuery) vs cross-org (Named Credential + Data Cloud Query API). |
| 3 | Implement Apex invocable Provider Search action that runs SQL on the DLO and returns provider list. |
| 4 | Deploy the action to the org that runs the agent. |
| 5 | Create/configure the Provider Search agent in Agentforce; add action, instructions, and slots. |
| 6 | (Optional) Add a Data Cloud search index + retriever for RAG-style provider search. |
| 7 | Test with real and edge-case queries. |

---

## References

- [Create Data Lake Objects | Data 360 Code Extension](https://developer.salesforce.com/docs/data/data-cloud-code-ext/guide/create-dlos.html)
- [Query Data in Data 360](https://developer.salesforce.com/docs/data/data-cloud-query-guide)
- [Boost Data Cloud Integrations with the New Query Connect API](https://developer.salesforce.com/blogs/2025/08/boost-data-cloud-integrations-with-the-new-query-connect-api) — Query Connect API
- [Create Custom Actions Using Apex InvocableMethod | Agentforce](https://developer.salesforce.com/docs/einstein/genai/guide/agent-invocablemethod.html)
- [Implement Data 360 for Agentforce (Trailhead)](https://trailhead.salesforce.com/content/learn/modules/data-cloud-powered-agentforce/implement-data-cloud-for-agentforce)

---

**Note**: The MCP Salesforce tools in this workspace are currently pointed at a different org (madan_org). To deploy or query **sdb27_PNM**, add that org to your Salesforce project and run CLI commands (e.g. `sf project deploy`, `sf org list`) targeting the sdb27_PNM alias, or perform Setup steps directly in the sdb27_PNM org.
