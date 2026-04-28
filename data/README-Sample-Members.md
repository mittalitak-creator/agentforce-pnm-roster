# Creating Sample Member (Person Account) Records

## Prerequisites

**IMPORTANT:** Person Accounts must be enabled in your Salesforce org before creating records.

### Enable Person Accounts:
1. Go to **Setup** → Search for "Account Settings"
2. Click **Account Settings**
3. Check **Enable Person Accounts**
4. Click **Save**

---

## Option 1: Execute Apex Script (RECOMMENDED - Fastest)

### Steps:
1. Open **Developer Console** (Setup → Developer Console)
   - OR use VS Code with Salesforce Extensions
2. Go to **Debug** → **Open Execute Anonymous Window**
3. Copy the contents of `scripts/apex/create-sample-members.apex`
4. Paste into the Execute Anonymous window
5. Check **Open Log** checkbox
6. Click **Execute**
7. Check the debug log for confirmation

### Expected Output:
```
SUCCESS: Created 5 Person Account records
===== MEMBER SEARCH TEST DATA =====
1. John Smith - DOB: 03/15/1985
2. Jane Doe - DOB: 07/22/1990
3. Michael Johnson - DOB: 11/08/1978
4. Sarah Williams - DOB: 05/30/1995
5. Robert Brown - DOB: 09/12/1982
```

---

## Option 2: Data Import Wizard (UI-based)

### Steps:
1. Go to **Setup** → **Data Import Wizard**
2. Click **Launch Wizard**
3. Select **Accounts and Contacts** → **Accounts**
4. Select **Add new records**
5. Choose **CSV** file: `data/sample-member-accounts.csv`
6. Map the fields:
   - FirstName → First Name
   - LastName → Last Name
   - PersonBirthdate → Birthdate
   - PersonEmail → Email
   - Phone → Phone
   - PersonMailingStreet → Mailing Street
   - PersonMailingCity → Mailing City
   - PersonMailingState → Mailing State
   - PersonMailingPostalCode → Mailing Zip/Postal Code
   - PersonMailingCountry → Mailing Country
7. Click **Next** → **Start Import**

---

## Option 3: Data Loader (For Large Volumes)

### Steps:
1. Download and install **Salesforce Data Loader**
2. Launch Data Loader and log in to your org
3. Select **Insert**
4. Choose **Account** object
5. Browse to select `data/sample-member-accounts.csv`
6. Map fields and click **OK**
7. Click **Finish**

---

## Sample Members Created

| Name | DOB | Email | Phone |
|------|-----|-------|-------|
| John Smith | 03/15/1985 | john.smith@example.com | (555) 123-4567 |
| Jane Doe | 07/22/1990 | jane.doe@example.com | (555) 234-5678 |
| Michael Johnson | 11/08/1978 | michael.johnson@example.com | (555) 345-6789 |
| Sarah Williams | 05/30/1995 | sarah.williams@example.com | (555) 456-7890 |
| Robert Brown | 09/12/1982 | robert.brown@example.com | (555) 567-8901 |
| Maria Garcia | 02/14/1988 | maria.garcia@example.com | (555) 678-9012 |
| David Martinez | 12/25/1975 | david.martinez@example.com | (555) 789-0123 |
| Linda Rodriguez | 08/19/1992 | linda.rodriguez@example.com | (555) 890-1234 |
| James Wilson | 06/03/1980 | james.wilson@example.com | (555) 901-2345 |
| Patricia Anderson | 10/28/1987 | patricia.anderson@example.com | (555) 012-3456 |

---

## Test the A&G Intake Flow

After creating the members:

1. Open the **Appeals & Grievances** app
2. Click on the **A&G Intake** tab
3. Enter test data:
   - **Member ID**: Any value (e.g., "MEM-001")
   - **Last Name**: Smith
   - **Date of Birth**: 03/15/1985
4. Click **Next**
5. The flow should find John Smith and continue to Case Basic Info

---

## Troubleshooting

### Error: "Person Accounts not enabled"
- Go to Setup → Account Settings → Enable Person Accounts

### Error: "Field PersonBirthdate does not exist"
- Person Accounts are not enabled
- Enable them in Account Settings

### Member Not Found
- Verify Last Name matches exactly (case-sensitive)
- Verify Date of Birth format is correct
- Check that records were successfully created (go to Accounts tab)

---

## Adding More Members

To add more members, modify the Apex script or CSV file with additional records following the same format.


