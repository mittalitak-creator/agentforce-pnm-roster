# PRD: Agentforce Roster File Ingestion — Provider Network Management

**Status:** READY FOR IMPLEMENTATION — All Questions Resolved
**Version:** 0.8
**Date:** April 28, 2026
**Org:** storm_org · storm-155501697ec74d.my.salesforce.com

---

## Table of Contents

1. [Problem Statement](#1-problem-statement)
2. [Solution Overview](#2-solution-overview)
3. [Agentforce Conversational Experience](#3-agentforce-conversational-experience)
4. [UI Designs](#4-ui-designs)
5. [Artifact Inventory](#5-artifact-inventory)
6. [End-to-End Workflow Map](#6-end-to-end-workflow-map)
7. [Open Questions — Decisions Needed](#7-open-questions--decisions-needed)
8. [Validation Rule Set — Confirmed](#8-validation-rule-set--confirmed)

---

## 1. Problem Statement

### Current State

Provider Network Management admins receive periodic roster files (CSV) from health plans, IPAs, and provider groups. These files contain hundreds of provider records with 40–100+ fields each (NPI, name, specialty, address, license, network tier, effective dates, etc.).

Today the end-to-end flow exists — Health Cloud PNM ships a staging + DPE ingestion pipeline — but it requires admins to navigate the CRF record manually, interpret raw staging errors without guidance, and trigger each step independently with no conversational assistance, no plain-English error reporting, and no guided confirmation step.

### Why This Is a Problem

- **Error-prone:** No front-door validation before staging — invalid NPIs, missing required fields, and duplicate entries surface only after staging fails.
- **No transparency:** Admins cannot see a plain-English summary of what changed and why.
- **No safety net:** No pre-ingestion diff showing exactly what records will be written before the admin clicks "Run Ingestion."
- **Not conversational:** No guided experience. Admins must understand the CRF object, DPE, and DLO concepts to operate this today.
- **Slow:** Errors are discovered one at a time during staging. A guided pre-validation step would surface all issues before the admin even triggers staging.

### Success Criteria

- An admin can upload a roster file and have it fully ingested — with validation, staging, DPE mapping review, and a final confirmation — through a guided conversational interface.
- All errors are explained in plain English with specific row-level fix instructions **before staging begins**, so the admin fixes the file once and proceeds.
- No records are written to Health Cloud until the admin explicitly confirms after reviewing the staged change preview.
- Every run produces an immutable audit record.
- End-to-end time for a 500-row file: under 10 minutes (excluding admin review time).

---

## 2. Solution Overview

### Approach

We will build an **Agentforce agent** ("Roster Manager") that orchestrates the existing Health Cloud PNM ingestion pipeline conversationally. The agent drives; the admin only acts at two points:

1. **Post-staging confirmation** — review validation results and staged change preview (UI-1)
2. **Post-ingestion review** — review the audit summary (UI-2)

Everything else is fully automated and conversationally narrated. The agent does **not** replace the existing CRF/DPE pipeline — it wraps and orchestrates it.

> **Design principle:** The agent drives. The admin confirms. We show UI only where a human decision is required — a staged change preview and a final summary. Everything else is conversational narration.

### How Files Arrive — Two Channels

Files arrive in Salesforce through two channels. In both cases, the downstream platform behaviour is identical:

| Channel | Mechanism | What happens automatically |
|---|---|---|
| **Email-to-Case** | Admin or provider group emails the file as an attachment | Salesforce creates a Case; the `RosterEntitiesCreationTrigger` fires on `ContentDocumentLink` insert and calls `healthcloudext.RosterFileRelatedObjectsCreationService.createCaseRelatedFiles()`, which creates the **Case Related File (CRF)** record |
| **Provider Portal** | OmniScript `HealthCloudPNM/RosterFileUpload` | Same trigger fires; same CRF creation (known intermittent bug as of March 2026 — verify in target org) |

The uploaded file is stored as a **`ContentDocumentLink`** on the Case. One Case can have multiple CRF records (one per file upload).

### What We Are NOT Building

| We will not build | Instead we will reuse |
|---|---|
| A custom field-mapping UI | DPE Gen AI mapping (native Health Cloud feature — auto-suggests column → DLO field mappings; admin reviews and confirms within DPE) |
| A file upload LWC | File arrives via Email-to-Case or Provider Portal — `RosterEntitiesCreationTrigger` handles the rest |
| A new checklist/progress-tracking pattern | `IntakeChecklistManager.cls` (already in project) |
| A new test infrastructure pattern | Follow `AGIntakeActionsTest.cls` conventions |
| A custom async ingestion job | DPE handles async ingestion natively — no custom Queueable needed |
| A field mapping metadata table | Mapping config is stored inside the DPE definition itself (Gen AI mapping) — no custom metadata type needed |

### Five-Stage Process

| # | Stage | Who acts | Mode | UI needed? |
|---|---|---|---|---|
| 1 | **Upload** | Admin selects existing Roster Case OR uploads a new CSV (agent creates Case + CRF). File arrives via Email-to-Case / Provider Portal / agent-assisted upload. | Interactive — agent asks admin to choose path | No new UI — agent chat + inline file upload widget |
| 2 | **Stage** | Agent runs pre-validation checks on the file, then triggers CRF "Stage File" to create Target DLO from Canonical DLO | Automated + conversational narration | **YES — UI-1: Post-Staging Confirmation** |
| 3 | **Map** | Agent triggers CRF "Create/Select Mapping"; DPE Gen AI auto-suggests column→DLO field mappings; admin reviews and confirms | Automated + **1 admin confirm in DPE** | DPE native (no new UI) |
| 4 | **Ingest** | Agent triggers CRF "Run Ingestion"; DPE 3-level chain writes to Health Cloud objects asynchronously | DPE async | No — agent notifies when done |
| 5 | **Summary** | Agent narrates outcome, presents audit report | Conversational + **1 UI screen** | **YES — UI-2: Post-Ingestion Summary** |

> **Staging details:** The Stage step does exactly two things: (1) run format and validation checks on the roster file, and (2) create a Target DLO from the Canonical DLO template configured during PNM setup. No DPE is involved in staging — DPE is only used for mapping and ingestion.

---

## 3. Agentforce Conversational Experience

The agent runs under an **Agent Topic: "Provider Roster Management"**. It invokes 5 new Invocable Actions (Apex) as tools and decides when to call each one.

### Entry Point: Background Page Context

The agent is invoked from the **Case Related File record page**. When the admin opens a CRF record and launches the Roster Management agent, the agent reads the CRF record ID from the page context automatically — no search needed.

If the agent is invoked from any other page context (not a CRF record), it falls back to asking the admin for a CRF record ID or to upload a new file.

### CRF State Machine — How the Agent Reads Context

Before responding to the admin, the agent reads `ProcessStage` + `ProcessStatus` from the CRF record to determine exactly where the file is in the workflow:

| `ProcessStage` | `ProcessStatus` | Agent behaviour on entry |
|---|---|---|
| *(null)* | *(null)* | Fresh CRF — start from pre-validation |
| `Staging` | `InProgress` | Staging already running — narrate, poll for completion |
| `Staging` | `Failed` | Staging failed — show error, offer to re-stage |
| `Staging` | `Complete` | Staged — `TargetDatasetName` is set (`CanonicalData_<CRF_ID>`). Resume from Mapping step |
| `Mapping` | `InReview` | Mapping reviewed by admin, not yet marked Complete — prompt admin to mark Complete |
| `Mapping` | `Complete` | Mapping done — offer to trigger ingestion |
| `Processing` | `InProgress` | Ingestion already running — notify admin, poll for completion |
| `Processing` | `Failed` | Ingestion failed — show errors |
| `Processing` | `Complete` | Already fully ingested — show summary / audit record |

**Key field reference:**
- `SourceDatasetName` — name of the uploaded file/sheet (set at CRF creation)
- `TargetDatasetName` — always `CanonicalData_<CRF_ID>` (set when staging succeeds; null if staging not yet run or failed)
- `ContentDocumentId` — ID of the attached file
- `ProcessDefinitionReferenceId` — lookup to the DPE Batch Calculation Job Definition (set when DPE mapping/ingestion is linked)

### Conversation Script (Reference)

Below is the expected conversation flow. **Bold agent text** = what the agent says. Items marked 🔑 = admin confirmation required.

---

**Scenario A — Admin invokes agent from a CRF record page (primary path)**

**Admin:** `I want to ingest this roster file.`

**Agent:** I can see you're on the Case Related File record **CRF-000000020** (Case: **00001234 — Blue Shield PPO Q2 2026 Roster**).

Here's what I found:

| Field | Value |
|---|---|
| File | `provider_roster_Q2_2026.csv` |
| Source Dataset | `Aug5_Demo_4Fields - Sheet1` |
| Stage | Staging |
| Status | Complete |
| Target DLO | `CanonicalData_1FxLT00000001k50AA` |

Staging is already complete for this file. The Target DLO has been created. Is this the right file and are you ready to proceed to the **Mapping** step?

---

🔑 **Admin confirms:** Yes, proceed.

---

**Scenario B — Admin invokes agent from a non-CRF page (fallback)**

**Admin:** `I want to ingest this roster file.`

**Agent:** I don't see a Case Related File record in the current page context. To proceed, please either:
1. Open the specific **Case Related File record** for your roster file and re-invoke me from there
2. Provide a **CRF record ID** directly (e.g. `1FxLT00000001k50AA`)
3. **Upload a new CSV file** — I'll create a Case and Case Related File for you

Which would you prefer?

**Path B3 — Admin selects upload:**

**Agent:** Please upload your CSV roster file.

*[ file upload widget rendered inline in chat ]*

**Admin:** *[uploads `provider_roster_Q2_2026.csv`]*

**Agent:** Got it — `provider_roster_Q2_2026.csv` (864 rows, 2.1 MB). Creating Case and Case Related File now...

Case **00001235** and Case Related File **CRF-000000021** created. Running pre-validation...

---

*(All scenarios converge at pre-validation)*

---

**Agent:** Pre-validation complete for **provider_roster_Q2_2026.csv** (864 rows). Here's what I checked:

| # | Rule | Result | Detail |
|---|---|---|---|
| F1 | File format (CSV only) | ✅ Pass | CSV confirmed |
| F2 | File not empty | ✅ Pass | 864 data rows found |
| F3 | File size ≤ 5 MB | ✅ Pass | 2.1 MB |
| F5 | Header row present | ✅ Pass | Row 1 detected as header |
| C1 | Column names ≤ 40 chars, no spaces | ✅ Pass | All 12 column names valid |
| C2 | Required columns present | ✅ Pass | ProviderNpi, ProviderNpiIsActive, ProviderFirstName, ProviderLastName all present |
| C3 | Picklist values valid | ⚠️ 2 warnings | ProviderClass: "Resident" not in picklist (rows 34, 67) |
| R1 | NPI format (10 digits, numeric) | ❌ 3 errors | Rows 14, 27, 45 — invalid NPI |
| R2 | NPI Luhn checksum | ✅ Pass | All valid NPIs pass check digit |
| R3 | Date format (yyyy-mm-dd) | ✅ Pass | |
| R5 | Boolean fields (TRUE/FALSE only) | ✅ Pass | |
| X1 | No duplicate NPIs within file | ✅ Pass | |
| S2 | Network name matches org record | ✅ Pass | "Blue Shield PPO" found |

**3 rows have errors (rows 14, 27, 45). 2 rows have picklist warnings — those rows will be skipped during ingest.** I've prepared a downloadable error report. Would you like to fix and re-upload, or proceed with the 861 valid rows?

---

🔑 **Admin decision point:** Fix and re-upload vs. proceed with valid rows.

**Admin:** `Proceed with the 861 valid rows.`

**Agent:** Understood. Staging the file now — creating the Target DLO from the Canonical DLO template and comparing your 861 valid providers against the current Blue Shield PPO network...

Staging complete. Here's what will change:

- 🟢 **23 new providers** will be added to the network
- 🔵 **41 existing providers** will have records updated
- ⚪ **7 providers** currently in the network are not in this file — their records will not be changed *(no action taken on missing providers)*
- ⚪ **790 providers** — no changes

I've prepared a full change preview for your review.
*[ 🔑 Post-Staging Confirmation UI-1 rendered inline ]*

---

🔑 **Admin decision point:** Review UI-1, click Confirm & Proceed to Mapping.

**Admin:** *[clicks "Confirm & Proceed to Mapping" in UI-1]*

**Agent:** Triggering the DPE Gen AI field mapping now. Salesforce will open the mapping review screen — please review the suggested column → DLO field mappings and confirm them there to proceed.

*→ Link: Open DPE Mapping Review for Case 00001234*

*[ Admin navigates to DPE native UI, reviews AI-suggested column → DLO field mappings, confirms ]*

---

**Agent:** *(polling CRF status)* I can see the mapping has been reviewed. However, the CRF mapping stage is currently set to **"In Review"** — you need to manually mark it as **"Completed"** before I can trigger ingestion.

Please open the **Case Related File record** for this roster and change the Mapping stage status from **In Review → Completed**.

*→ Link: Open CRF Record for Case 00001234*

Once you've done that, come back here and let me know — or I'll detect it automatically if you prefer.

---

🔑 **Admin action required:** On the CRF record, set Mapping stage status to **Completed**.

---

**Admin:** `Done, I've marked it as completed.`

**Agent:** *(confirms CRF mapping status = Completed)* Confirmed — mapping stage is now Completed. Running ingestion now (DPE 3-level job). You can close this chat — I'll notify you when the job completes. You will also receive a Salesforce notification. You can check progress at any time by asking me *"What's the status of the roster ingestion?"*

---

*[ ~4 minutes later — agent resumes proactively via Platform Event ]*

**Agent:** ✅ **Done!** Your Q2 2026 Blue Shield PPO roster has been fully ingested.

23 providers added · 41 updated · 6 state-code warnings logged but skipped.

Audit record saved: **ROSTER-2026-0427-001**. Here's the full change summary:
*[ Post-Ingestion Summary UI-2 rendered inline ]*

---

### Agent Decision Points — Full Map

| Decision | Who decides | How |
|---|---|---|
| File format acceptable? | Agent auto-decides | Narrated in pre-validation summary |
| Rows with errors — skip or abort? | **Admin confirms** | Agent asks explicitly in chat |
| Providers missing from file — end membership or ignore? | **Agent ignores** | Option C: only file rows are processed; providers absent from file are unchanged |
| Staged changes look correct? | **Admin confirms via UI-1** | Post-Staging Confirmation |
| Field mapping — file column → DLO field? | Admin reviews DPE Gen AI suggestions | DPE native mapping UI (admin leaves chat via deep link) |
| Mapping stage marked Completed? | **Admin manually sets CRF status** | Agent prompts with CRF deep link; polls CRF status to detect completion |
| Partial failure during ingest — continue or rollback? | **DPE native behavior** | No custom handling — DPE governs; agent surfaces whatever DPE reports in UI-2 |
| Background job timed out? | Agent auto-retries once, then notifies admin | In-chat notification |

---

## 4. UI Designs

Only two UI screens are needed. Both render **inline within the Agentforce chat panel** — no separate page navigation required.

### UI-1: Post-Staging Confirmation

**When:** After staging is complete (validation passed + Target DLO created), before triggering DPE mapping.
**Purpose:** Admin sees the validation summary and the full change preview (what staging found vs. the current network state) and must explicitly approve before field mapping begins.

**Key design decisions:**
- The "Updated" section shows **only the specific fields that are changing**, not all 100+ fields. With large provider records, showing only diffs keeps this scannable.
- Changes are in **expandable/collapsible groups** (New, Updated, Removed, No Change) — admin can expand only what they want to review.
- A **Download Change Report** button exports the full diff as CSV for offline audit or sign-off.
- The **Confirm & Proceed to Mapping** button is the only way to proceed — there is no implicit confirmation.

**Fields shown:**

| Section | What's displayed |
|---|---|
| Validation summary | Count of Passed / Warnings / Errors / Skipped rows |
| New providers | NPI, Name, Specialty, Network Tier |
| Updated providers | NPI, Name, Field Name, Current Value → New Value |
| Network ended | NPI, Name, Current Status, Action (end date) |
| Warnings | Skipped rows count with reason and download link |

---

### UI-2: Post-Ingestion Summary (Audit View)

**When:** After the DPE ingestion job completes (agent resumes via Platform Event).
**Purpose:** Plain-English summary of what changed. This view is also the face of the `Roster_Audit_Log__c` record.

**Key design decisions:**
- Leads with a **plain-English paragraph** (not a table) — e.g., *"Your Q2 2026 Blue Shield PPO roster was processed on April 27, 2026. 23 new providers are now active..."* — because this is the text an admin would copy into a status email or send to a manager.
- Outcome metrics (Added / Updated / Ended / Skipped / Unchanged) shown as summary numbers.
- Skipped rows are **expandable** with row-level fix instructions for the admin's next run.
- Audit record reference (name + ID + retention note) is always visible.

---

## 5. Artifact Inventory

**Legend:** `REUSE` = existing artifact, no change needed. `NEW` = to be built. Every NEW artifact is justified below.

### Existing Platform Objects & Triggers (REUSE)

| Artifact | Type | Status | Notes |
|---|---|---|---|
| `ContentDocumentLink` | Standard SF Object | **REUSE** | File attached to Case via Email-to-Case or Provider Portal. Agent reads file from here. |
| `Case Related File (CRF)` | Health Cloud Custom Object (`healthcloudext` ns) | **REUSE** | Created by trigger on every roster file upload. Tracks staging status. Has Stage File / Create or Select Mapping / Run Ingestion action buttons. One Case can have many CRFs. |
| `RosterEntitiesCreationTrigger` | Apex Trigger (after insert on `ContentDocumentLink`) | **REUSE** | Calls `healthcloudext.RosterFileRelatedObjectsCreationService.createCaseRelatedFiles()`. Creates Case + CRF automatically. No changes needed. |
| DPE Gen AI Field Mapping | Health Cloud native feature | **REUSE** | Triggered via CRF "Create/Select Mapping" button. Auto-suggests column → DLO field mappings. Admin reviews and confirms. No custom mapping UI or metadata table needed. |
| DPE 3-Level Ingestion Chain | Health Cloud native feature | **REUSE** | Triggered via CRF "Run Ingestion" button. Writes to 17 Health Cloud objects across 3 levels. No custom Queueable needed. |

### Apex Classes

| Artifact | Type | Status | Purpose & Justification |
|---|---|---|---|
| `IntakeChecklistManager.cls` | Service | **REUSE** | Reuse for tracking roster job progress through stages. Supports discrete task markers and % tracking — no changes needed. |
| `ProviderSummaryAction.cls` | Invocable | **REUSE** | Reuse during staging to look up existing provider records by NPI before computing diffs. |
| `RosterContextAction.cls` | Invocable | **NEW** | Reads the CRF record from page context (record ID passed in by the Agentforce framework). Returns `ProcessStage`, `ProcessStatus`, `SourceDatasetName`, `TargetDatasetName`, `ContentDocumentId`, and `CaseId` so the agent can determine where the file is in the workflow and what to say next. Also handles the fallback path: when no CRF record ID is in context, creates a new Case + CRF by invoking `healthcloudext.RosterFileRelatedObjectsCreationService` after file upload. |
| `RosterValidationAction.cls` | Invocable | **NEW** | Reads the file body from the `ContentDocumentLink` attached to the Case, runs all validation rules (Categories 1–6) row-by-row, returns structured JSON of pass/fail per rule per row. No existing class handles front-door file parsing + NPI validation before staging. |
| `RosterStagingAction.cls` | Invocable | **NEW** | Calls the CRF "Stage File" action programmatically (after pre-validation passes). Diffs validated file rows against current `HealthcareProvider` + network records using NPI as key. Returns change set (new/update/remove/no-change) for display in UI-1. |
| `RosterMappingAction.cls` | Invocable | **NEW** | Two responsibilities: (1) **Trigger mapping** — calls CRF "Create/Select Mapping" and returns a deep link to the DPE mapping review screen for the admin to open. (2) **Poll CRF status** — called by the agent to check whether the CRF mapping stage status has been manually set to "Completed" by the admin. Platform behavior: after the admin reviews and confirms the DPE Gen AI mapping, the CRF mapping stage is set to "In Review" — it does NOT auto-advance to Completed. The admin must manually change the status from "In Review" to "Completed" on the CRF record before ingestion can be triggered. This action polls that status field and returns the current value so the agent can prompt the admin if it is still "In Review". |
| `RosterIngestAction.cls` | Invocable | **NEW** | Calls the CRF "Run Ingestion" action programmatically after admin confirms mapping. Thin wrapper so the agent can call DPE ingestion as a tool. Returns DPE Job ID. |
| `RosterAuditService.cls` | Service | **NEW** | Creates `Roster_Audit_Log__c` after ingestion. Separated from ingest action to keep audit concerns isolated and independently testable. Triggered by Platform Event on DPE job completion. |

### Lightning Web Components

| Artifact | Status | Purpose & Justification |
|---|---|---|
| `rosterConfirmationUI` (LWC) | **NEW** | Post-Staging Confirmation screen (UI-1). Receives staged diff data from `RosterStagingAction`, renders expandable change groups with diff view per field. No existing component handles this. |
| `rosterSummaryUI` (LWC) | **NEW** | Post-Ingestion Summary (UI-2). Renders plain-English summary, outcome metrics, skipped rows, and audit record link. Also reused on the `Roster_Audit_Log__c` record page. |

### Data Model

| Artifact | Type | Status | Fields | Justification |
|---|---|---|---|---|
| `Case Related File (CRF)` | Health Cloud Object (`healthcloudext` ns) | **REUSE** | Existing | Already tracks ingestion stage/status. Agent reads and updates status via `RosterStagingAction` and `RosterIngestAction`. |
| `Intake_Checklist__c` | Custom Object | **REUSE** | Existing | Reuse for tracking roster job progress — each stage maps to a checklist task. |
| `Roster_Audit_Log__c` | Custom Object | **NEW** | File_Name, Uploaded_By, Network, Total_Rows, Added, Updated, Ended, Skipped, Status, Error_Details, Ingest_Start, Ingest_End, Job_Id, CRF_Id | Necessary for compliance — immutable record of every roster run. Cannot be derived from provider record history alone (captures file-level metadata and agent decisions). |

### Agent Configuration

| Artifact | Status | Justification |
|---|---|---|
| Agent Topic: *Provider Roster Management* | **NEW** | Distinct admin workflow from existing A&G intake topics. Scopes which actions the agent can call. |
| Agent Instructions (system prompt) | **NEW** | Tells the agent to: always call `RosterContextAction` first to read the CRF record from page context; confirm CRF + Case details with admin before taking any action; resume from the correct workflow step based on `ProcessStage` + `ProcessStatus`; if no CRF context, ask for a CRF ID or offer file upload; run pre-validation before triggering staging; always narrate rule-by-rule validation results; always render UI-1 before triggering mapping; prompt admin to mark mapping status Complete before triggering ingestion; notify admin via chat + Salesforce notification when ingestion completes. |
| Platform Event: `Roster_Ingest_Complete__e` | **NEW** | Fired by DPE (or a trigger on DPE job completion) when the background ingestion job finishes. Triggers an Agent Action to resume the conversation and render UI-2. This is the mechanism by which the agent "wakes up" after the async DPE job. |

---

## 6. End-to-End Workflow Map

```
ADMIN          │ (File arrives    │ Agent narrates   │ Reviews UI-1,    │ Reviews + confirms │ (can close     │ Reviews UI-2
               │ via Email/Portal)│ pre-validation   │ clicks Confirm & │ DPE Gen AI mapping │  chat window)  │ summary
               │ → CRF created    │ results          │ Proceed to Map   │ DPE mapping UI  │ ⚠ manually sets  │  chat window)  │ summary
               │  automatically   │                  │                  │                 │ CRF status:      │                │
               │                  │                  │                  │                 │ In Review →      │                │
               │                  │                  │                  │                 │ Completed        │                │
               ▼                  ▼                  ▼                  ▼                 ▼                  ▼                ▼
AGENT          │ Detects new CRF, │ Calls            │ Calls            │ Calls           │ Polls CRF        │ Receives       │ Calls Audit
               │ reads file from  │ RosterValidation │ RosterStaging    │ RosterMapping   │ status via       │ Platform       │ Service,
               │ ContentDocument  │ Action,          │ Action,          │ Action →        │ RosterMapping    │ Event          │ renders UI-2
               │ Link             │ narrates results │ renders UI-1     │ provides deep   │ Action; prompts  │                │
               │                  │                  │                  │ link to DPE UI  │ admin if still   │                │
               │                  │                  │                  │                 │ "In Review"      │                │
               │                  │                  │                  │                 │                  │                │
               ▼                  ▼                  ▼                  ▼                 ▼                  ▼                ▼
SALESFORCE     │ ContentDocument  │ File parsed,     │ CRF "Stage File" │ DPE Gen AI      │ CRF mapping      │ DPE 3-level    │ Platform Event
               │ Link created by  │ validation rules │ triggered:       │ mapping runs;   │ status =         │ chain writes   │ fires →
               │ trigger →        │ evaluated        │ Target DLO       │ CRF status →    │ "Completed" →    │ to 17 HC       │ Audit_Log__c
               │ Case + CRF       │                  │ created from     │ "In Review"     │ agent triggers   │ objects async  │ created
               │ created          │                  │ Canonical DLO    │ (not auto-      │ ingestion        │                │
               │                  │                  │                  │  completed)     │                  │                │
               │                  │                  │                  │                 │                  │                │
─ ─ ─ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ─ ─ ─
STAGE          │   1 · UPLOAD     │  2 · STAGE       │  2 · STAGE       │  3 · MAP        │  3 · MAP         │  4 · INGEST    │  5 · SUMMARY
               │                  │  (pre-validation)│  (Target DLO)    │  (DPE Gen AI)   │  (CRF complete)  │  (DPE 3-level) │
```

> **Note on Stage 2:** The staging step has two distinct sub-steps that both happen before mapping:
> - **(2a) Pre-validation** — agent runs format/row checks via `RosterValidationAction`; narrates results to admin
> - **(2b) Target DLO creation** — agent calls `RosterStagingAction` which triggers CRF "Stage File"; creates Target DLO from Canonical DLO template

### How the artifacts connect

```
[File arrives via Email-to-Case or Provider Portal]
         │
         │ ContentDocumentLink insert
         ▼
[RosterEntitiesCreationTrigger] ──calls──> [healthcloudext.RosterFileRelatedObjectsCreationService]
         │                                         │ creates
         │                                         ▼
         │                                [Case + CRF record]
         │
[Agent detects CRF] ──reads file from──> [ContentDocumentLink]
         │
         ▼
[RosterValidationAction] ── runs all validation rules ──> returns pass/fail per rule per row
         │
         ▼ (validation passes)
[RosterStagingAction] ──triggers CRF "Stage File"──> Target DLO created from Canonical DLO
         │ also diffs file vs org records
         │ returns: new / updated / ended / no-change
         ▼
[rosterConfirmationUI] (UI-1) ──admin confirms──>
         │
         ▼
[DPE Gen AI Mapping] ──admin reviews and confirms in DPE native UI──>
         │
         │ CRF mapping stage auto-set to "In Review" (NOT Completed)
         ▼
⚠ [Admin manually sets CRF mapping status: In Review → Completed]
         │  Agent provides deep link to CRF record + prompts admin
         │  RosterMappingAction polls CRF status until = "Completed"
         ▼
[RosterIngestAction] ──triggers CRF "Run Ingestion"──> [DPE 3-Level Chain]
                                                              │
                                        Level 1 ─────────────┤──> Account
                                                              │
                                        Level 2 ─────────────┤──> CareSpecialty, CareTaxonomy,
                                                              │    ContactProfile, HealthcareProvider,
                                                              │    HealthcareProviderSpecialty,
                                                              │    HealthcareProviderTaxonomy, PersonLanguage
                                                              │
                                        Level 3 ─────────────┤──> HealthcareProviderNpi, Award,
                                                              │    BoardCertification, CareService,
                                                              │    HealthcareFacility, HealthcareProviderService,
                                                              │    HealthcarePractitionerFacility, PersonEducation
                                                              │
                                                              │ fires on completion
                                                              └──> [Roster_Ingest_Complete__e]
                                                                           │
                                                                           ▼
                                                           [RosterAuditService] ──creates──> [Roster_Audit_Log__c]
                                                                           │
                                                                           ▼
                                                           [rosterSummaryUI] (UI-2) rendered in chat
```

---

## 7. Open Questions — Decisions Needed

Please fill in your answers below before implementation begins.

---

**Q1 · Validation Rules**
What are the complete validation rules for a roster file?

> **Status:** ✅ Confirmed — see §8 in full.

---

**Q2 · Providers Missing From File**
If a provider is currently Active in the network but NOT in the uploaded roster file, what should happen?

Options:
- **(A)** End their network membership with today as the end date ← *assumed in script above*
- **(B)** Flag as a warning and ask admin to confirm each one
- **(C)** Do nothing — only the file's explicit rows are processed

> **Answer:** ✅ **(C) Do nothing.** Only the file's explicit rows are processed. Providers absent from the file retain their current status unchanged. The agent will not flag, warn, or end memberships for providers missing from the file.

---

**Q3 · Field Mapping**
> **Status:** ✅ Confirmed. Use DPE Gen AI mapping (native Health Cloud feature). No custom mapping UI or `Roster_Field_Mapping__mdt` needed. Mapping config lives inside the DPE definition.

---

**Q4 · Partial Failure Behavior**
If records fail to write during DPE ingestion (e.g. a Salesforce validation rule fires), should the job:

- **(A)** Continue with remaining records and report failures in UI-2
- **(B)** Roll back all changes

> **Answer:** ✅ **Follows DPE native behavior.** No custom partial-failure handling will be built. DPE's own error handling and reporting governs how partial failures are surfaced and whether the job continues or aborts. UI-2 will surface whatever DPE reports.

---

**Q5 · Target Objects**
> **Status:** ✅ Confirmed. DPE 3-level chain writes to 17 Health Cloud objects: Account (L1) + 7 objects (L2) + 9 objects (L3). See workflow map above. Access control governed by standard SF profiles/permission sets — user with right permissions; refer to Salesforce PNM docs for specifics.

---

**Q6 · Access Control**
Who can run the Roster Management agent — specific profile/permission set (e.g. "PNM Admin"), or any user with Agentforce console access?

> **Answer:** ✅ **Users who have both Roster File feature access (PNM feature permission set) and Agentforce console access.** The agent should be surfaced only to users already authorized for the PNM Roster File feature — Agentforce access alone is not sufficient.

---

**Q7 · Audit Retention**
How long should `Roster_Audit_Log__c` records be retained? (Assumed 7 years for healthcare compliance — is that correct?)

> **Status:** ✅ Keep `Roster_Audit_Log__c`. No rollback needed (see Q8). Retention period TBD by customer.

---

**Q8 · Rollback Capability**
> **Status:** ✅ Confirmed — no rollback. Re-upload the previous roster file to revert if needed. `Roster_Audit_Log__c` provides the audit trail.

---

*PRD v0.8 · Updated April 28, 2026*

---

## 8. Validation Rule Set — Confirmed

**Legend:** ✅ Confirmed · ⚠️ Warning (row skipped, ingest continues) · ❌ Error (row skipped or file aborted) · 📋 Implementation note · 🔖 Customer consideration (not built now)

> **When these run:** All Categories 1–6 run during **Stage 2a (Pre-Validation)**, before staging is triggered and before any DLO is created. The admin sees the full results in the conversational narration and in UI-1.

---

### Category 1 — File Structure

| # | Rule | Severity | Logic |
|---|---|---|---|
| F1 | File format must be **CSV only** | ❌ Abort file | Reject all non-CSV formats (XLSX, XLS, TSV, etc.) |
| F2 | File must not be empty | ❌ Abort file | Zero data rows after header |
| F3 | File size must be ≤ 5 MB | ❌ Abort file | Check ContentDocumentLink / ContentVersion body size in bytes |
| F4 | File must be UTF-8 encoded | ⚠️ Warn, attempt recovery | Flag non-UTF-8 characters; log affected rows |
| F5 | First row must be a header row | ❌ Abort file | Header absence detected if first cell is numeric |

---

### Category 2 — Column Rules

| # | Rule | Severity | Logic |
|---|---|---|---|
| C1 | Column names must be ≤ 40 characters | ❌ Abort file | Any header > 40 chars rejects the whole file |
| C2 | Column names must have no spaces | ❌ Abort file | Use underscore or camelCase — spaces not permitted |
| C3 | Required columns must be present | ❌ Abort file | **Must exist:** `ProviderNpi`, `ProviderNpiIsActive`, `ProviderFirstName`, `ProviderLastName` |
| C4 | Picklist field values must match org picklist | ❌ Skip row | At runtime: query org field metadata for all Picklist/MultiSelectPicklist fields mapped in the DPE definition. Skip row and report exact invalid value + list of valid options. **Never hardcode picklist values.** |
| C5 | Unknown columns not in DPE mapping config | ⚠️ Warn, ignore column | Column is skipped during ingest; logged in audit for admin awareness |

**Picklist fields validated at runtime** *(pulled from org — not hardcoded):*
- `ProviderClass`, `ProviderType`, `Status`, and any field whose Salesforce metadata type is `Picklist` or `MultiSelectPicklist` per the DPE mapping configuration

---

### Category 3 — Row-Level Format Rules

| # | Rule | Severity | Logic |
|---|---|---|---|
| R1 | NPI must be exactly 10 digits, numeric | ❌ Skip row | Regex: `^\d{10}$` |
| R2 | NPI Luhn check digit must be valid | ❌ Skip row | Standard NPI check digit algorithm (mod-10) |
| R3 | Date fields: format must be `yyyy-mm-dd` | ❌ Skip row | e.g. `2025-06-15`. Reject `06/15/2025`, `15-06-2025`, etc. |
| R4 | DateTime fields: format must be `yyyy-mm-ddThh:mm:ssZ` | ❌ Skip row | e.g. `2025-06-15T12:00:55Z`. Z = UTC. Reject any other timezone offset. |
| R5 | Boolean fields must be `TRUE` or `FALSE` (exact uppercase) | ❌ Skip row | Reject `true`, `True`, `1`, `yes`, `Y`, `false`, `False`, `0`, `no` |
| R6 | `ProviderNpiIsActive` must be `TRUE` or `FALSE` — cannot be blank | ❌ Skip row | Required Boolean — blank is not allowed |
| R7 | Required fields on a row must not be blank | ❌ Skip row | Based on C3 required column list |

---

### Category 4 — Within-File Cross-Row Rules

| # | Rule | Severity | Logic |
|---|---|---|---|
| X1 | NPI must be unique within the file | ❌ Skip duplicates | First occurrence kept; all subsequent duplicates flagged with row numbers |
| X2 | NPI + Network combination must be unique within the file | ❌ Skip duplicates | A provider may appear in multiple networks, but not listed twice for the same network |

---

### Category 5 — Cross-System Rules

| # | Rule | Severity | Logic |
|---|---|---|---|
| S1 | **NPPES validation** | 🔖 Not in scope | Do not call external NPPES API. Trust NPI values in the file as-is. *See Customer Considerations below.* |
| S2 | **Network Name must match a `HealthcarePayerNetwork` record in org** | ❌ Skip row | Query `HealthcarePayerNetwork` by name at staging time. If no match found, skip the row and report: *"Network 'Blue Shield PPO' not found in org. Ensure the network record exists before uploading."* |
| S3 | **NPI already in org = same provider** | ✅ Treat as update | If `ProviderNpi` matches an existing `HealthcareProvider` record, treat as an update regardless of name differences. No name-mismatch error or warning. |
| S4 | **Effective Date rules** | 🔖 No validation now | No backdating or future-dating restrictions enforced. Dates are passed through as-is. *See Customer Considerations.* |
| S5 | **Termination Date rules** | 🔖 No validation now | No restrictions. *See Customer Considerations.* |
| S6 | **License validation** | 🔖 Not in scope | No license number validation against any registry. License data in the file is accepted as-is. *See Customer Considerations.* |
| S7 | **Previously terminated provider re-added** | ✅ Auto-reactivate | If provider exists in org with an end date, and appears in the new file, reactivate silently. The staging diff will show this as an "Updated" record so admin sees it at UI-1. |

---

### Category 6 — Lookup / Parent Record Existence Rules

> These rules are **critical**. Junction and child objects require parent records to exist in the org before the DPE ingest can write to them. The roster file must supply the correct names/IDs for all lookup fields, and the referenced records must already exist.

| # | Object | Lookup Field | Parent Object | Rule | Severity |
|---|---|---|---|---|---|
| L1 | `HealthcareProviderSpecialty` | `CareSpecialty` lookup | `CareSpecialty` | File value must match an existing `CareSpecialty.Name` in org | ❌ Skip row |
| L2 | `HealthcareProviderService` | `CareService` lookup | `CareService` | File value must match an existing `CareService.Name` in org | ❌ Skip row |
| L3 | `HealthcareProviderTaxonomy` | `CareTaxonomy` lookup | `CareTaxonomy` | File value must match an existing `CareTaxonomy.Name` in org | ❌ Skip row |
| L4 | `HealthcarePractitionerFacility` | `HealthcareFacility` lookup | `HealthcareFacility` | File value must match an existing `HealthcareFacility.Name` in org | ❌ Skip row |
| L5 | `HealthcarePractitionerFacility` | `OperatingHours` lookup | `OperatingHours` | File value must match an existing `OperatingHours` record in org | ❌ Skip row |
| L6 | `HealthcarePractitionerFacility` | `BusinessAccountId` | `Account` | **Required by OOTB DPE logic.** File must include `BusinessAccountId` to link `HealthcarePractitionerFacility` to the correct `HealthcareFacility` record. If blank, the DPE will fail for that row. | ❌ Skip row |

**📋 Implementation note for L1–L6:**
`RosterValidationAction` will:
1. Inspect the DPE mapping configuration to identify which file columns map to Lookup fields.
2. For each Lookup field, query the parent object to fetch all existing `Name` values.
3. Compare each file row's value against the fetched set. If no match, skip the row and report:
   > *"Row 45 — CareSpecialty not found: 'Orthopedic Surgery' does not exist in this org. Ensure the CareSpecialty record is created before uploading, or correct the spelling in your file."*

**📋 Important: Parent records must be pre-created.**
The agent will warn at the start of any upload session:
> *"Before I can ingest HealthcareProviderSpecialty, HealthcareProviderService, HealthcareProviderTaxonomy, or HealthcarePractitionerFacility records, the following must already exist in the org: CareSpecialty records, CareService records, CareTaxonomy records, HealthcareFacility records, OperatingHours records, and Business Account records. If any are missing, those rows will be skipped."*

---

### Category 7 — Warning-Only Rules (never block ingestion)

| # | Rule | When triggered |
|---|---|---|
| W1 | Row has unknown columns | Column not in DPE mapping config — logged in audit, column ignored |
| W2 | Specialty changed significantly (e.g. Pediatrics → Oncology) | Flagged as possible data entry error |
| W3 | Network Tier changed from Tier 1 → Tier 2 | May affect member cost-sharing — flagged for awareness |
| W4 | > 20% of current network being removed in a single file | Unusual volume — flagged before staging proceeds |

---

### Error Message Format (agent narration)

All errors follow this structure: **what failed · which row · which column · exact value · how to fix**.

> **Row 14 — NPI invalid:** The value `123456789` in column `ProviderNpi` has only 9 digits. NPIs must be exactly 10 digits, numeric. **How to fix:** Go to row 14, column `ProviderNpi` and enter a valid 10-digit NPI.

> **Row 34 — Picklist value not allowed:** The value `Resident` in column `ProviderClass` is not configured in this org. **Valid values are:** Physician, Nurse Practitioner, Physician Assistant, Specialist, Hospital, Group Practice. **How to fix:** Update row 34, column `ProviderClass` to one of the values above.

> **Row 67 — Date format incorrect:** The value `06/15/2025` in column `EffectiveDate` must use format `yyyy-mm-dd`. **How to fix:** Change to `2025-06-15`.

> **Row 45 — Related record not found:** The value `Orthopedic Surgery` in column `CareSpecialty` does not match any CareSpecialty record in this org. **How to fix:** Either create the CareSpecialty record in the org first, or correct the spelling in your file. To see existing CareSpecialty values, ask me: *"What CareSpecialty records exist in the org?"*

> **Row 88 — BusinessAccountId missing:** Column `BusinessAccountId` is required for HealthcarePractitionerFacility records but is blank on row 88. **How to fix:** Add the Salesforce Account ID (18-character) for the facility's business account in column `BusinessAccountId`.

> **Row 92 — Network not found:** The value `Blue Shield PPO` in column `NetworkName` does not match any HealthcarePayerNetwork record in this org. **How to fix:** Verify the network name spelling, or create the HealthcarePayerNetwork record before uploading.

---

### Customer Considerations (not implemented — document for implementers)

When deploying this solution, customers should evaluate the following additional controls based on their compliance and operational requirements:

| Topic | Recommendation |
|---|---|
| **NPPES NPI Validation (S1)** | Consider calling the NPPES public API to verify NPI existence and type (individual vs. organization). Particularly important for new providers being added. Adds ~1–2s per row; batch at validation time. |
| **Effective Date backdating (S4)** | Consider enforcing a maximum lookback window (e.g. 90 days) to prevent accidental retroactive changes that could affect member eligibility reporting. |
| **Future Effective Date (S5)** | Consider staging future-dated records with a status of "Pending Active" and a scheduled job to activate them on the effective date. |
| **License Validation (S6)** | Consider integrating with state license board APIs (CAQH, NPDB, or state-specific) to validate license numbers and expiry dates, particularly for credentialing use cases. |
| **Terminated Provider Re-activation (S7)** | Consider requiring admin confirmation when a previously terminated provider (end date in past) is re-added, rather than auto-reactivating. Prevents accidental reinstatement. |
| **Audit Retention** | Align `Roster_Audit_Log__c` retention with HIPAA/NCQA requirements for your organization. Typical range: 6–10 years. |
| **Provider Portal staging bug** | The OmniScript `HealthCloudPNM/RosterFileUpload` has a known intermittent issue (as of March 2026) where the CRF record is not reliably created. Verify this is resolved in the target org before enabling the Provider Portal channel. Email-to-Case is the reliable channel. |

---

*PRD v0.8 · Updated April 28, 2026*
