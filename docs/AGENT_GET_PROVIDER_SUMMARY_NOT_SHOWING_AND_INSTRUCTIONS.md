# Get Provider Summary Action – Not Showing & Sample Instructions

## Why "Get Provider Summary" might not appear

### 1. Apex class not accessible to the agent user (most common)

Agentforce only shows invocable actions for **Apex classes the agent’s running user can access**.

**Fix:**

1. **Setup** → **Agents** → open your agent → note the **Agent User** (or the user the agent runs as).
2. **Setup** → **Users** → open that user → **Profile** (or **Permission Sets**).
3. In the **Profile** (or each **Permission Set**):
   - Find **Apex Class Access** (or **Enabled Apex Class Access**).
   - **Edit** → add **ProviderSummaryAction** to the allowed list → **Save**.

If the agent uses a permission set, add **ProviderSummaryAction** to **Apex Class Access** in that permission set instead (or in addition to the profile).

### 2. Where to look in the agent builder

- **Setup** → **Agents** → [Your Agent] → **Actions** → **Add Action**.
- Choose the type that includes **Apex** / **Invocable** or **Custom** actions.
- Search by:
  - **Get Provider Summary** (label), or  
  - **Provider Summary** (category), or  
  - **ProviderSummaryAction** (class name).
- If there’s a category filter, select **Provider Summary**.

### 3. Confirm the class is deployed

- **Setup** → **Quick Find** → **Apex Classes**.
- Open **ProviderSummaryAction** and confirm it’s there and **Invocable** is checked (or that the class is deployed in the same org as the agent).

### 4. Refresh and cache

- Save the agent, close the builder, reopen it, then try **Add Action** again.
- Try in an incognito/private window in case of cache.

---

## Sample instructions for the Provider Summary topic

Use these (or adapt them) as the **Instructions** or **Topic instructions** for your agent or for a “Provider Summary” topic.

**Short version:**

```
When the user asks for a provider summary, provider details, or information about a provider by NPI, use the Get Provider Summary action with the NPI they provide. Read back the Summary Message in a clear, conversational way. If the action returns an error (e.g. provider not found), say so and offer to try another NPI.
```

**Longer version (more guidance):**

```
You help users get information about healthcare providers by NPI (National Provider Identifier).

When the user asks for a provider summary, provider details, or information about a specific provider:
- Use the Get Provider Summary action.
- Pass the NPI they give you into the action's NPI input. If they haven't given an NPI, ask for it.
- After the action runs, read back the Summary Message in a clear, friendly way. You can paraphrase or highlight key points (name, specialty, location, award, license) if helpful.
- If the action returns success = false or an error message (e.g. "No provider found for NPI"), tell the user the provider was not found and offer to try another NPI or search.

Do not make up provider data. Only use what the Get Provider Summary action returns.
```

**Topic-specific (if you use a dedicated “Provider Summary” topic):**

```
Topic: Provider Summary

When the user wants a summary or details for a provider:
1. If they provide an NPI, call Get Provider Summary with that NPI.
2. If they do not provide an NPI, ask: "What's the NPI for the provider you want to look up?"
3. After the action returns, respond with the Summary Message. Mention provider name, NPI, specialty, and location when available.
4. If no provider is found, say: "I couldn't find a provider for that NPI. Please check the number or try another NPI."
```

---

## Quick checklist

| Step | Action |
|------|--------|
| 1 | Add **ProviderSummaryAction** to **Apex Class Access** for the agent user’s Profile (or Permission Set). |
| 2 | In the agent: **Actions** → **Add Action** → search **Get Provider Summary** or **Provider Summary**. |
| 3 | Paste or adapt the **Sample instructions** above into the agent’s Instructions (or topic instructions). |
| 4 | Save and activate the agent, then test with a valid NPI from your DLO. |
