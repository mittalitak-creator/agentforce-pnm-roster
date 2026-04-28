# Quick Start: Creating Your AI Agent in 10 Minutes

## 🚀 Ultra-Fast Setup Guide

Follow these steps to get your AI agent running quickly!

---

## Step 1: Access Agent Builder (2 min)

1. Open Salesforce
2. Go to **Setup** → Search for "**Agents**"
3. Click **New Agent**
4. Fill in:
   - Name: `Appeals & Grievances Intake Assistant`
   - Type: Service Agent
5. Click **Save**

---

## Step 2: Create the Topic (2 min)

1. Click **+ New Topic**
2. Fill in:
   - Name: `Appeals & Grievances Intake`
   - Description: `I can help you file an appeal or grievance`
3. Add these trigger phrases:
   - `I want to file an appeal`
   - `File a grievance`
   - `My claim was denied`
   - `Appeal a decision`
4. Click **Save**

---

## Step 3: Add Agent Instructions (1 min)

Copy-paste this into the Instructions field:

```
You are an Appeals & Grievances intake specialist. 

1. Start every conversation by creating a checklist
2. Accept information in any order
3. Show empathy - members are frustrated
4. Track and show progress
5. Validate data as you collect it

Priority order:
1. Member ID or Name + DOB
2. Case type (Appeal/Grievance)  
3. Category
4. Other details

Be warm, use plain language, confirm understanding.
```

---

## Step 4: Add Action 1 - Create Checklist (2 min)

1. Click **+ Add Action**
2. Select **Apex Action**
3. Choose: `IntakeChecklistManager → createChecklist`
4. Configure:
   - **Input**: `conversationId` = `$ConversationId`
   - **Output**: Save `checklistId` to `ctx_checklist_id`
5. Planner Prompt: `Use this first to create intake checklist`
6. Save

---

## Step 5: Add Action 2 - Search Member (2 min)

1. Click **+ Add Action**
2. Select **Apex Action**
3. Choose: `MemberSearchService → searchMember`
4. Configure:
   - **Inputs**:
     - `memberId` = from conversation
     - `firstName` = from conversation  
     - `lastName` = from conversation
     - `dateOfBirth` = from conversation
     - `checklistId` = `ctx_checklist_id`
   - **Output**: Save `memberId` to `ctx_member_id`
5. Planner Prompt: `Use when you have Member ID OR name + DOB`
6. Save

---

## Step 6: Add Action 3 - Capture Complaint (1 min)

1. Click **+ Add Action**
2. Select **Apex Action**
3. Choose: `ComplaintCaptureService → captureComplaint`
4. Configure:
   - **Inputs**:
     - `caseType` = from conversation
     - `category` = from conversation
     - `checklistId` = `ctx_checklist_id`
   - **Outputs**: Auto-save
5. Planner Prompt: `Use when member describes their issue`
6. Save

---

## Step 7: Test! (Take your time)

1. Click **Preview** button
2. Try this conversation:

```
You: I want to file an appeal
[Agent should create checklist]

You: My Member ID is MEM-001
[Agent should find member]

You: My surgery claim was denied
[Agent should capture details]
```

3. Check that:
   - Checklist is created
   - Member is found
   - Details are captured
   - Agent shows progress

---

## ✅ Done! Your AI Agent is Live

**What works now:**
- Creates intake checklist
- Searches for members
- Captures complaint details
- Tracks progress

**What's next:**
- Add remaining 6 actions (intake basics, associated case, etc.)
- Deploy to chat/voice channels
- Add knowledge articles
- Train with real conversations

---

## 🆘 Quick Troubleshooting

**Agent doesn't respond?**
- Make sure Agent Status = Active
- Check trigger phrases match your input

**Action fails?**
- Check Apex debug logs (Setup → Debug Logs)
- Verify you're passing `checklistId`

**Can't find Apex classes?**
- Make sure they're deployed (they should be!)
- Refresh the page

---

## 📞 Need Help?

1. Check `AI_AGENT_SETUP_GUIDE.md` for detailed steps
2. Review `AI_AGENT_IMPLEMENTATION_SUMMARY.md` for technical details
3. Test actions individually in Flow Builder

---

You're all set! Go create your agent! 🎉


