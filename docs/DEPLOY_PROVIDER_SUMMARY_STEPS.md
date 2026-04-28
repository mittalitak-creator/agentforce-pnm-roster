# Deploy Provider Summary Action – Steps

Deploy the **Get Provider Summary** invocable action (and its test) to your org, then optionally configure the agent.

---

## Prerequisites

- **Salesforce CLI** (`sf`) installed and authenticated.
- **Target org** set up (e.g. `madan_org`) with Data Cloud and the DLO **CanonicalData_PNM_Template_test__dll**.
- From the project root: `Appeals&Grievances` (or your workspace root).

---

## Step 1: Deploy the Apex classes

From the project root, run one of the following.

**Option A – Deploy the provider summary components only (recommended if other classes fail)**

Use this when deploying the whole `classes` folder fails (e.g. other Apex classes reference custom objects not in the org, like `Intake_Checklist__c`):

```bash
sf project deploy start \
  --source-dir force-app/main/default/classes/ProviderSummaryAction.cls \
  --source-dir force-app/main/default/classes/ProviderSummaryAction.cls-meta.xml \
  --source-dir force-app/main/default/classes/ProviderSummaryActionTest.cls \
  --source-dir force-app/main/default/classes/ProviderSummaryActionTest.cls-meta.xml \
  --target-org madan_org
```

**Option B – Deploy the whole `classes` folder**

May fail if other classes depend on metadata not in the org (e.g. `Intake_Checklist__c`). Use Option A to deploy only Provider Summary.

```bash
sf project deploy start --source-dir force-app/main/default/classes --target-org madan_org
```

**Option C – Deploy the entire project**

```bash
sf project deploy start --target-org madan_org
```

Use the org alias that has your DLO (e.g. replace `madan_org` with your org alias).

---

## Step 2: Run the tests

```bash
sf apex run test \
  --class-names ProviderSummaryActionTest \
  --target-org madan_org \
  --result-format human
```

To wait for results in the same run (recommended):

```bash
sf apex run test \
  --class-names ProviderSummaryActionTest \
  --target-org madan_org \
  --result-format human \
  --synchronous \
  --wait 10
```

- Expect **passing** tests. The test may not hit real DLO rows (depending on test data); focus on no compile/runtime errors and sufficient coverage.
- For JSON output: use `--result-format json` and inspect the summary.

---

## Step 3: Confirm deployment in the org

1. Log in to the target org.
2. **Setup** → **Apex Classes**.
3. Confirm **ProviderSummaryAction** and **ProviderSummaryActionTest** are listed and the action’s **Invocable** checkbox is checked (or use **Quick Find** → “Apex Class” and open `ProviderSummaryAction`).

---

## Step 4: Add the action to an Agentforce agent (optional)

1. **Setup** → **Agents** → open an existing agent or **New Agent** (e.g. “Provider Summary”).
2. **Actions** → **Add Action** → search for **Get Provider Summary** → add it.
3. **Instructions**: e.g.  
   *“When the user asks for a provider summary or details by NPI, use the Get Provider Summary action with the NPI they provide. Read back the summary message. If the action returns an error (e.g. provider not found), say so.”*
4. **Slots** (optional): add **NPI** and map it to the action input.
5. **Save** and **Activate**.

---

## Step 5: Test end-to-end

- In the agent chat: *“Give me a summary for NPI &lt;valid NPI from your DLO&gt;”*  
  → You should get a summary built from the DLO fields.
- Try an invalid or unknown NPI → expect a clear “Provider not found” (or similar) message.

---

## Troubleshooting

| Issue | What to do |
|-------|------------|
| Deploy fails: “Invalid type” or CdpQuery not found | Ensure the org has **Data Cloud** / **Data 360** and the **ConnectApi.CdpQuery** API is available (API v51.0+). |
| Tests fail with “no rows” or DLO errors | Tests may mock or skip the live query. If the test class uses `Test.startTest()` and a try/catch, ensure the action is invoked with a valid input; adjust test data or mocks if needed. |
| Agent doesn’t show “Get Provider Summary” | Confirm the class is deployed, then in the agent **Actions** list use **Refresh** or re-add the action. |
| Summary is empty or wrong | Confirm the DLO has rows for the NPI you use and that field API names in **ProviderSummaryAction.cls** match your DLO (see **docs/DLO_FIELD_MAPPING_CanonicalData_PNM_Template_test.md**). |

---

## Quick reference

```bash
# Deploy (provider summary only – use when full classes deploy fails)
sf project deploy start \
  --source-dir force-app/main/default/classes/ProviderSummaryAction.cls \
  --source-dir force-app/main/default/classes/ProviderSummaryAction.cls-meta.xml \
  --source-dir force-app/main/default/classes/ProviderSummaryActionTest.cls \
  --source-dir force-app/main/default/classes/ProviderSummaryActionTest.cls-meta.xml \
  --target-org madan_org

# Test (synchronous, wait for results)
sf apex run test --class-names ProviderSummaryActionTest --target-org madan_org --result-format human --synchronous --wait 10
```

Replace `madan_org` with your target org alias.
