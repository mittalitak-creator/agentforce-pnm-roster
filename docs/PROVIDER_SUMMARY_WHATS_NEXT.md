# Provider Summary Agent – What’s Next (DLO Metadata Done, Action Deployed)

Current state:

- **DLO metadata** – Field API names are known and wired in **ProviderSummaryAction.cls** (see **DLO_FIELD_MAPPING_CanonicalData_PNM_Template_test.md**).
- **Get Provider Summary** – Deployed to the org (ProviderSummaryAction + ProviderSummaryActionTest).
- **Tests** – ProviderSummaryActionTest passes (5/5).

---

## 1. Create or configure the Agentforce agent (next)

1. In the org: **Setup** → **Agents** → **New Agent** (e.g. “Provider Summary”) or open an existing agent.
2. **Actions** → **Add Action** → search for **Get Provider Summary** → add it.
3. **Instructions** – e.g.  
   *“When the user asks for a provider summary or details about a provider by NPI, use the Get Provider Summary action with the NPI they provide. Read back the summary message clearly. If the action returns an error (e.g. provider not found), say so and ask for a different NPI if needed.”*
4. **Slots** (optional) – Add a slot **NPI** and map it to the action input so the agent can collect NPI from the user.
5. **Save** and **Activate** the agent.

---

## 2. Test end-to-end

- In the agent chat: *“Give me a summary for NPI &lt;valid NPI from your DLO mock data&gt;”*  
  → You should get a summary built from the DLO (name, specialty, award, license, location, status).
- Try an invalid or unknown NPI → expect a clear “Provider not found” (or similar) message.

---

## 3. Optional later

| Item | Description |
|------|-------------|
| **Provider Search action** | Same DLO, multi-row query by name, specialty, city, state, zip (see **PROVIDER_SEARCH_AND_SUMMARY_ACTIONS_RECOMMENDED_STEPS.md**). |
| **More summary fields** | Add ProviderEmail__c, ProviderPhone__c, ProviderType__c, Facility names, etc. to the summary (see **DLO_FIELD_MAPPING_CanonicalData_PNM_Template_test.md**). |
| **RAG / search index** | If you add a Data Cloud search index on the DLO, you can add a retriever for semantic search alongside NPI lookup. |

---

## Summary

| Done | Next |
|------|------|
| DLO schema (CanonicalData_PNM_Template_test__dll, 485 fields) | Create/configure Agentforce agent with Get Provider Summary |
| ProviderSummaryAction deployed, field mappings set | Add action + instructions + optional NPI slot |
| Tests passing | Test E2E with a real NPI from your mock data |
