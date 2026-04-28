# Copy DLO CanonicalData_PNM_Template_MT from sdb27_PNM to madan_org

This guide explains how to **reference** the DLO **CanonicalData_PNM_Template_MT** in **sdb27_PNM** and **create the same DLO** in **madan_org**.

Data Lake Objects (DLOs) are not deployed via standard Salesforce metadata (e.g. `sf project retrieve --metadata`). You use **Data 360 DevOps data kits** to move DLO metadata between orgs.

---

## Prerequisites

| Requirement | sdb27_PNM | madan_org |
|-------------|-----------|-----------|
| Data 360 / Data Cloud | Must be enabled (you already have the DLO here) | Must be enabled |
| Data space | Has a data space that contains the DLO | Must have a **data space with the same prefix name** as in sdb27_PNM |
| Deployment connection | Source for retrieval | Target for deploy (or vice versa if you deploy from madan to sdb27) |

If **madan_org** does not have Data 360 enabled or does not have a matching data space, you must set those up first before the deploy will succeed.

---

## Option A: Deploy via Data 360 DevOps Data Kit (recommended)

This is the supported way to copy DLO metadata (schema and object definition) from one org to another.

### Step 1: In sdb27_PNM – Create/use a data space

1. Log in to **sdb27_PNM**.
2. Go to **Setup** → search **Data Cloud** or **Data 360**.
3. Open **Data Spaces** (or **Data Cloud Setup** → Data Spaces).
4. Note the **data space** that contains **CanonicalData_PNM_Template_MT** (or create one and add the DLO to it).
5. Note the **data space prefix/name** (e.g. `MyDataSpace`). **The same prefix must exist in madan_org.**

### Step 2: In sdb27_PNM – Create a DevOps data kit and add the DLO

1. In **sdb27_PNM**, go to **Data Cloud Setup** → **Data Kits** (or **Packages and Data Kits**).
2. Create a new data kit:
   - **Data Kit Type:** **DevOps** (for moving metadata between orgs).
   - Give it a name (e.g. `PNM_DLO_Export`).
3. Add components to the data kit:
   - Add **Data Lake Objects**.
   - Select **CanonicalData_PNM_Template_MT** (and any other DLOs or dependencies it relies on, e.g. data streams if the doc says to include them).
4. Review the **publishing sequence** for the components (Data 360 may show dependencies).
5. Save the data kit.

### Step 3: Download the manifest (package.xml)

1. In the same Data Kits page, open the **DevOps** data kit you created.
2. Click **Download Manifest** (or equivalent).
3. Save the **package.xml** file. It will list Data 360 metadata (e.g. data lake objects, data streams, data kit definitions) that you can retrieve and deploy.

### Step 4: Retrieve the data kit into your project (from sdb27_PNM)

1. Put the downloaded **package.xml** in your project (e.g. `manifest/package.xml` or project root).
2. From your project directory, run:

   ```bash
   sf project retrieve start --manifest manifest/package.xml --target-org sdb27_PNM
   ```

3. After retrieve completes, you should see new folders/files under your project (e.g. under `dataLakeObjects` or similar, depending on the manifest).
4. **Important (Unix/macOS):** Delete any **key qualifier** files as instructed in the [Salesforce Data 360 deploy guide](https://developer.salesforce.com/docs/data/data-cloud-dev/guide/dc-deploy_data_kit_using_cli.html). The guide says: *“execute the commands to delete any key qualifier files related to the project.”* (Windows: search for key qualifier files and remove them and their references.)

### Step 5: Ensure madan_org has a matching data space

1. Log in to **madan_org**.
2. Go to **Data Cloud Setup** → **Data Spaces**.
3. Create or confirm a **data space with the same prefix name** as in sdb27_PNM.  
   Deployment expects the same data space name in the target org.

### Step 6: Deploy the data kit to madan_org

1. From your project directory (with the retrieved metadata and the same manifest):

   ```bash
   sf project deploy start --manifest manifest/package.xml --target-org madan_org
   ```

2. Resolve any deployment errors (e.g. missing `FieldSrcTrgtRelationship`, inactive connectors) as described in the [deploy guide](https://developer.salesforce.com/docs/data/data-cloud-dev/guide/dc-deploy_data_kit_using_cli.html).
3. After a successful deploy, the DLO **CanonicalData_PNM_Template_MT** (and any other components in the kit) will exist in **madan_org** in the same data space.  
4. **Data:** The deploy copies **metadata/schema only**. Row data is not copied. You will need to load data into the DLO in madan_org via data streams or ingestion if needed.

---

## Option B: Recreate the DLO manually in madan_org (if Data Kit is not possible)

Use this if:

- madan_org does not have a matching data space or you cannot use DevOps data kits, or  
- You only need the same **schema** (field set) and can recreate the DLO by hand.

### Step 1: Document the schema in sdb27_PNM

1. In **sdb27_PNM**, go to **Data Cloud Setup** → **Data Lake Objects**.
2. Open **CanonicalData_PNM_Template_MT**.
3. Record every **field**: API name, label, data type, length, required, primary key, etc.
4. Optionally run a one-row query in Data 360 to confirm field names:  
   `SELECT * FROM "CanonicalData_PNM_Template_MT" LIMIT 1`  
   (use the exact object name shown in the UI.)

### Step 2: Create a new DLO in madan_org with the same structure

1. In **madan_org**, go to **Data Cloud Setup** → **Data Lake Objects**.
2. Create a **new** Data Lake Object (e.g. “From scratch” or “From template” if you have a similar one).
3. Use the **same API name** if allowed (`CanonicalData_PNM_Template_MT`) or a name that matches your naming standards.
4. Add each **field** from your list with the same API name, type, and settings as in sdb27_PNM.
5. Set primary key / key qualifiers to match the source DLO.
6. Save and activate.

This gives you the same structure in madan_org; you will still need to configure **data streams** or other ingestion to populate the DLO with data.

---

## Summary

| Goal | Approach |
|------|----------|
| **Copy DLO metadata (schema) from sdb27_PNM to madan_org** | **Option A:** Add **CanonicalData_PNM_Template_MT** to a **DevOps data kit** in sdb27_PNM → **Download manifest** → **Retrieve** with that manifest into your project → **Deploy** with that manifest to **madan_org**. Ensure **madan_org** has Data 360 and a **data space with the same prefix** as in sdb27_PNM. |
| **Same DLO when Data Kit cannot be used** | **Option B:** Document the DLO schema in sdb27_PNM, then **create a new DLO** in madan_org with the same fields and keys. |
| **Data in the new DLO** | Neither option copies data. Configure data streams or ingestion in madan_org to load data into the new DLO. |

---

## References

- [Use CLI to Deploy Changes from a Sandbox to Data 360](https://developer.salesforce.com/docs/data/data-cloud-dev/guide/dc-deploy_data_kit_using_cli.html)
- [Create a Data Kit](https://help.salesforce.com/s/articleView?id=data.c360_a_data_stream_bundle_package_kits.htm)
- [Data Cloud in a Sandbox](https://help.salesforce.com/s/articleView?id=data.c360_a_data_cloud_sandbox.htm)
- [Create Data Lake Objects (Data 360)](https://developer.salesforce.com/docs/data/data-cloud-code-ext/guide/create-dlos.html)
