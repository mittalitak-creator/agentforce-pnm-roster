# How the DLO Gets Provider Data for the Provider Summary

The **Provider Summary** action reads from the DLO **CanonicalData_PNM_Template_MT**. The DLO does not “reach out” to other systems at query time—it is a **table** that must be **populated** by ingestion or mapping. Below is how provider data gets **into** this DLO in three scenarios, and how the summary **accesses** it.

---

## 1. Data stored in Salesforce objects (CRM)

**Where data lives:** Account, custom Provider object, or other Salesforce objects.

**How it gets to the DLO:**

- You configure a **Salesforce CRM data stream** in Data 360 that:
  - **Source:** Salesforce objects (e.g. Account, `Provider__c`, or a view that joins them).
  - **Target:** The DLO **CanonicalData_PNM_Template_MT** (or a staging DLO that then feeds this one).
- The stream runs on a schedule or trigger; data is **copied** from Salesforce into the DLO. The DLO does not query Salesforce at read time.

**How the provider summary accesses data:**

- The summary action runs **CdpQuery** against the DLO only.
- So the path is: **Salesforce (source) → CRM data stream (ingestion) → DLO (storage) → Apex CdpQuery (read) → Provider Summary.**

**Summary:** The DLO is the target of a **CRM data stream**. Data is ingested from Salesforce into the DLO; the provider summary simply reads from the DLO. No real-time “access” to Salesforce from the DLO.

---

## 2. Data in Data Cloud DMOs

**Where data lives:** Unified Data Model Objects (e.g. Individual, Account, or a custom Provider DMO).

**How it relates to the DLO:**

- In Data 360, the usual direction is **DLO → DMO**, not the other way around:
  - **Ingestion** fills **DLOs** (from CRM, external systems, etc.).
  - **Mappings and recipes** fill **DMOs** from DLOs (and other sources).
- So “data in DMOs” for providers usually means:
  - Either the **same** provider data was first ingested into a DLO and then **mapped into** the DMO, or
  - Provider attributes exist only in a DMO (e.g. as part of a unified profile) and were never stored in this DLO.

**Two sub-cases:**

| Case | How the DLO has data | How the provider summary accesses it |
|------|----------------------|--------------------------------------|
| **A) DLO is the source for the DMO** | You ingest provider data **into** the DLO (via CRM stream, external stream, or another DLO). Then you **map this DLO → DMO**. The DLO is populated by ingestion; the DMO is populated by the mapping. | The summary keeps **reading from the DLO** (current design). No change. |
| **B) Provider data only in the DMO** | This DLO might be empty or not used for providers. The DMO was filled from other DLOs or sources. | The DLO does **not** have the provider data. You have two options: **(1)** Add ingestion (or mapping from the DMO back into a DLO, if supported) so this DLO is filled, then keep querying the DLO; **(2)** Change the Provider Summary action to **query the DMO** instead of the DLO (different table name and possibly different field names). |

**Summary:** The DLO does not “access” DMOs. Either the DLO is filled first and then feeds the DMO (summary keeps reading from DLO), or you choose to read from the DMO and change the action to query that object instead.

---

## 3. Data from an external system directly to DLOs

**Where data lives:** External system (data warehouse, S3, API, SFTP, etc.).

**How it gets to the DLO:**

- You configure an **external data stream** in Data 360 that:
  - **Source:** External system (e.g. S3 bucket, REST API, SFTP file).
  - **Target:** The DLO **CanonicalData_PNM_Template_MT** (or a DLO that feeds it).
- Files or API payloads are loaded into the DLO on a schedule or event. The DLO is the **direct** target of ingestion.

**How the provider summary accesses data:**

- Same as today: **Apex runs CdpQuery** on the DLO. No direct call to the external system at query time.
- Path: **External system → data stream (ingestion) → DLO → CdpQuery → Provider Summary.**

**Summary:** The DLO is the direct target of **external ingestion**. The provider summary only reads from the DLO; the external system is not accessed when showing the summary.

---

## At a glance

| Scenario | How provider data gets TO the DLO | How provider summary gets data |
|----------|-----------------------------------|--------------------------------|
| **Salesforce objects** | CRM data stream ingests from Salesforce objects into the DLO. | Apex queries the DLO (CdpQuery). |
| **Data in DMOs** | (A) DLO is filled by ingestion, then mapped to DMO. (B) Or data exists only in DMO (DLO not used for providers). | (A) Apex queries the DLO. (B) Either ingest into DLO first, or change the action to query the DMO. |
| **External system → DLO** | External data stream (S3, API, etc.) loads directly into the DLO. | Apex queries the DLO. |

---

## Important point

The DLO is **not** a live gateway to Salesforce, DMOs, or external systems. It is a **stored dataset**. For the provider summary to work:

1. **Data must already be in the DLO** (via one or more of the flows above).
2. The **Provider Summary action** only **reads** that DLO with CdpQuery.

So “how the DLO accesses provider data” is really: **how you populate the DLO** (ingestion + optional DLO→DMO mapping). After that, the summary always accesses provider data by **querying the DLO table** (or, if you choose, the DMO table) in the same org.
