# Agent Says "I Can't Assist With That Request" for Provider Summary

When you type **"get provider summary for NPI 1000000000"** and the agent replies *"I can't assist with that request. Let me know if there's something else you'd like help with!"*, the agent is **not** calling your Get Provider Summary action. It’s declining the request before or instead of using the action.

---

## 1. Topic not matching (most common)

In Agentforce, **Topics** decide when an action runs. If the user’s message doesn’t match a **Topic** that has the **Get Provider Summary** action, the agent may fall back to a generic refusal.

**Fix:**

1. **Setup** → **Agents** → [Your Agent] → **Topics**.
2. Either **create a topic** for provider summary or **edit** an existing one that should handle this.
3. **Topic name:** e.g. **Provider Summary** or **Provider Lookup by NPI**.
4. **Trigger phrases / description:** Add phrases the user might say, for example:
   - get provider summary  
   - provider summary for NPI  
   - provider details for NPI  
   - look up provider by NPI  
   - find provider NPI  
   - NPI lookup  
   - provider information by NPI  
5. **Actions for this topic:** Add **Get Provider Summary** to the topic’s actions.
6. **Topic instructions:** Use the sample instructions below so the agent knows to call the action and not refuse.
7. **Save** and **Activate** the agent.

Then try again: *"get provider summary for NPI 1000000000"*. It should match this topic and run the action.

---

## 2. Base instructions too narrow or refusing

If the **agent’s main Instructions** limit what the agent can do, it might refuse provider summary requests even when a topic exists.

**Fix:** In **Setup** → **Agents** → [Your Agent] → **Instructions**, add something like:

```
You can help with provider lookups. When the user asks for a provider summary, provider details, or information about a provider by NPI (e.g. "get provider summary for NPI 1000000000"), use the Get Provider Summary action with that NPI. Do not refuse these requests. Read back the summary or error message from the action.
```

Keep this **above** or clearly part of any other instructions that describe when to assist. If you have instructions that say “only assist with X and Y,” add “and provider summary / NPI lookup” (or the topic that handles it).

---

## 3. Guardrails or instruction adherence

Guardrails or “instruction adherence” can make the agent refuse when it’s unsure whether a request is allowed.

**Fix:**

- In **Setup** → **Agents** → [Your Agent], check **Guardrails** or **Trust / Safety** (or similar).
- If there are options for “instruction adherence” or “refusal,” ensure they’re not so strict that they block provider/NPI requests.
- In **Topics** → [Provider Summary topic], use **clear, explicit instructions** (see below) so the model knows it is allowed and required to use the action.

---

## 4. Action runs but fails (e.g. Data Cloud)

If the **action is invoked** but throws an error (e.g. CdpQuery fails, no DLO access), some agents still respond with a generic “I can’t assist” instead of the real error.

**Check:**

- **Setup** → **Agents** → [Your Agent] → **Conversation Insights** or **Logs** (or your org’s equivalent) and see if **Get Provider Summary** appears and what result/error it returns.
- In **Setup** → **Users** → [Agent User], ensure that user has **Data Cloud / Data 360** access and access to the DLO (and that **ProviderSummaryAction** is in **Apex Class Access**).

If the action is being called and failing, fix the underlying error (permissions, DLO name, NPI column, etc.); the refusal message should then be replaced by your action’s error message once the agent is configured to surface it.

---

## Sample instructions to add (topic or agent)

Use one of these in the **Topic instructions** for Provider Summary (or in the main **Instructions** if you don’t use topics). They tell the agent to use the action and **not** refuse.

**Option A – Short**

```
When the user asks for a provider summary or provider information by NPI (e.g. "get provider summary for NPI 1000000000"), use the Get Provider Summary action with the NPI they provided. Do not refuse. Read back the Summary Message from the action. If the action returns an error (e.g. provider not found), say that and offer to try another NPI.
```

**Option B – Explicit**

```
Your job for this topic is to look up provider information by NPI using the Get Provider Summary action.

- When the user provides an NPI (e.g. 1000000000), call Get Provider Summary with that NPI. Never refuse a request that includes an NPI for a provider summary.
- After the action runs, respond with the Summary Message in a clear, conversational way.
- If the action returns success = false or "No provider found," tell the user the provider was not found and offer to try another NPI.
- If the user doesn't give an NPI, ask: "What's the NPI for the provider you want to look up?"
```

**Option C – With trigger wording**

```
If the user says anything like "get provider summary," "provider summary for NPI," "look up provider," or "provider details for NPI [number]," you must use the Get Provider Summary action. Do not say "I can't assist with that." Extract the NPI from their message (e.g. 1000000000) and pass it to the action. Then read back the Summary Message or the error message from the action.
```

---

## Quick checklist

| Step | Action |
|------|--------|
| 1 | Create or edit a **Topic** (e.g. Provider Summary) with trigger phrases like "get provider summary," "provider summary for NPI," "NPI lookup." |
| 2 | Attach the **Get Provider Summary** action to that topic. |
| 3 | Add **topic instructions** (or agent instructions) that explicitly say to use the action and **not** refuse provider summary / NPI requests (use Option A, B, or C above). |
| 4 | In **agent Instructions**, add a line that provider summary / NPI lookup is allowed and should use the action. |
| 5 | Save and activate, then test again with *"get provider summary for NPI 1000000000"*. |
| 6 | If it still refuses, check **Conversation Insights / Logs** to see if the action is being called and what error (if any) it returns. |
