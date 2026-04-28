# Provider Summary Returns "No Provider Found" – Troubleshooting

The agent **is** calling Get Provider Summary (you get the specific "I couldn't find a provider for NPI 1000000001" message). So the issue is that the **query returns no rows** – the DLO either has no matching row or the query doesn't match how the data is stored.

---

## 1. NPI not in the DLO (most common)

**Cause:** There is no row in `CanonicalData_PNM_Template_test__dll` where the NPI column equals `1000000001`. Your mock data may use different NPI values.

**What to do:**

1. **See which NPIs exist** – Run the script **scripts/ListNpisInDlo.apex** in Execute Anonymous (same org as the agent). It runs `SELECT ProviderNpi__c, KQ_ProviderNpi__c FROM ... LIMIT 10` and prints the values. Use one of those NPIs in the agent.
2. **Check in Data 360** – In Data Cloud / Data 360, open the table `CanonicalData_PNM_Template_test__dll`, preview data, and note the NPI values (and which column they’re in).
3. **Test with a known NPI** – Once you have a real NPI from the table (e.g. from the script or UI), ask the agent for a provider summary for that NPI.

---

## 2. Wrong NPI column (ProviderNpi__c vs KQ_ProviderNpi__c)

**Cause:** The action filters on `ProviderNpi__c`. In some setups the value that identifies a provider is in `KQ_ProviderNpi__c` (key qualifier), and `ProviderNpi__c` might be empty or different.

**What to do:**

- Run **ListNpisInDlo.apex** and check which column has the NPI values you expect.
- If only **KQ_ProviderNpi__c** is populated, we need to change the action to use `KQ_ProviderNpi__c` in the WHERE clause (or try both columns). I can update the Apex to use `KQ_ProviderNpi__c` or add a fallback.

---

## 3. Data type or format (string vs number, leading zeros)

**Cause:** NPI might be stored as a number (e.g. `1000000001`) and we compare with a string `'1000000001'`, or the opposite. Or values might have leading zeros (`01000000001`).

**What to do:**

- From **ListNpisInDlo.apex** (or Data 360 preview), note the **exact** format: string vs number, with or without leading zeros.
- Test in the agent using the **exact** value as shown (e.g. if the script shows `1000000001`, use that; if it shows `"1000000001"` with quotes, the value is string).
- If NPIs are numeric and the current string comparison fails, we can change the SQL to cast or use the correct type in the action.

---

## 4. Table or column name wrong in your org

**Cause:** The query uses `CanonicalData_PNM_Template_test__dll` and `ProviderNpi__c`. In your org the object might have a different API name (e.g. different suffix or case).

**What to do:**

- In **Setup** → **Data Cloud / Data 360** → Data Model (or Data Lake Objects), open the object that has your provider mock data and confirm:
  - **Exact API name** of the table (what you use in SQL).
  - **Exact API name** of the NPI field.
- If they differ, update `DLO_TABLE` and `NPI_COLUMN` in **ProviderSummaryAction.cls** and redeploy.

---

## 5. Data not yet in the flattened DMO

**Cause:** Streams or jobs that load into the flattened DMO might not have run yet, or the test data was loaded into a different object.

**What to do:**

- Confirm in Data 360 that **CanonicalData_PNM_Template_test__dll** has rows (e.g. preview or row count).
- If it’s empty, run the data load/stream that populates this table, then retry the agent with an NPI you know was loaded.

---

## Quick checklist

| Step | Action |
|------|--------|
| 1 | Run **scripts/ListNpisInDlo.apex** in Execute Anonymous and note which NPIs appear and in which column. |
| 2 | In the agent, ask for a provider summary using **one of those NPIs exactly** as shown. |
| 3 | If the script returns no rows, the table is empty or the table/column names are wrong – confirm in Data 360. |
| 4 | If only **KQ_ProviderNpi__c** has values, we should switch the action to use that column (or add a fallback). |
| 5 | If format differs (e.g. leading zeros), use that exact format when testing, and we can adjust the action if needed. |

---

## Optional: try KQ_ProviderNpi__c in the action

If you confirm that in your DLO the lookup column that has data is **KQ_ProviderNpi__c** (not **ProviderNpi__c**), we can change the action to use `KQ_ProviderNpi__c` in the WHERE clause, or query both (e.g. try `ProviderNpi__c` first, then `KQ_ProviderNpi__c` if no rows). Tell me which column has the values and I can suggest the exact code change.
