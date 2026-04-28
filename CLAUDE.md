# Appeals & Grievances — Claude Code Config

## Salesforce Org

- **Default org alias:** `storm_org`
- **Username:** `storm.155501697ec74d@salesforce.com`
- **Instance URL:** `https://storm-155501697ec74d.my.salesforce.com`
- **Org ID:** `00DIf000000IoPZMA0`

Use `--target-org storm_org` on all `sf` commands unless the user specifies otherwise.

> **Why storm_org:** This org has Salesforce Health Cloud PNM installed — CaseRelatedFile object, RosterEntitiesCreationTrigger, DPE feature, and real provider data. Required for Roster Ingestion agent development.

## Other Connected Orgs

| Alias | Username | Status |
|---|---|---|
| `Kumar-org` | health-cloud-q3@na81.org | Connected (DevHub) |
| `gus` | mittali.tak@gus.com | Connected |
| `madan_org` | epic.out.de869f45a25d@orgfarm.salesforce.com | Connected |
| `sdb27_PNM` | epic.655de912eb5b@orgfarm.out | Same org as sdb27_test1 |
| `storm_org` | storm.155501697ec74d@salesforce.com | Connected |
| `AGOrg` | epic.79a07ecdfcbb@orgfarm.out | Expired |
| `voice_sdb15` | epic.out.a927059a93b6@orgfarm.salesforce.com | Expired |

## Project

- Salesforce DX project: `force-app/`
- API version: 65.0
