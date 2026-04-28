# Appeals & Grievances AI Intake Agent - Setup Guide

## 🎯 Overview

This guide will walk you through creating an Agentforce AI Intake Agent for Appeals & Grievances case intake. The agent supports:
- Non-linear data collection
- Real-time checklist tracking
- Multi-modal interactions (chat, voice, assisted)
- Intelligent conversation flow

---

## ✅ Components Deployed

### Custom Objects
- **Intake_Checklist__c** - Tracks intake progress with 7 tasks

### Apex Classes (Invocable Actions)
1. **IntakeChecklistManager** - Creates and manages checklists
2. **MemberSearchService** - Searches for members
3. **ComplaintCaptureService** - Captures complaint details

### Existing Flow
- **AG_Case_Intake_Flow** - Can be wrapped as an action for case creation

---

## 📋 Step-by-Step Setup in Salesforce

### Phase 1: Enable Agentforce (If not already enabled)

1. Go to **Setup** → Search for "**Einstein Setup**"
2. Enable **Einstein for Service** and **Agentforce**
3. Navigate to **Setup** → **Agent Setup**
4. Click **Get Started** and follow the wizard

---

### Phase 2: Create the Agent

1. Go to **Setup** → Search for "**Agents**"
2. Click **New Agent**
3. Configure:
   - **Agent Name**: `Appeals & Grievances Intake Assistant`
   - **Description**: `Helps members file appeals and grievances by collecting all necessary information through natural conversation`
   - **Agent Type**: Service Agent
   - **Role**: Customer Support

---

### Phase 3: Create the Topic

1. In the Agent builder, click **+ New Topic**
2. Configure Topic Settings:
   ```
   Name: Appeals & Grievances Intake
   Description: I can help you file an appeal or grievance. I'll collect all necessary information, validate requirements, and create your case.
   ```

3. Add **Classification Utterances** (phrases that trigger this topic):
   ```
   - I want to file an appeal
   - I need to file a grievance
   - My claim was denied
   - I want to appeal a denial
   - File a complaint
   - Start an appeal
   - Submit a grievance
   - My prior authorization was denied
   - I disagree with a decision
   - Appeal denied service
   ```

---

### Phase 4: Configure Agent Instructions

In the Topic Instructions field, add:

```markdown
# Your Role
You are an expert Appeals & Grievances intake specialist. Your goal is to collect all necessary information to create a complete case while providing empathetic service.

# Key Behaviors
1. **Start by creating a checklist** - Always call Create Intake Checklist first
2. **Be flexible** - Accept information in any order, extract what you can
3. **Show empathy** - Members are often frustrated; acknowledge their concerns
4. **Track progress** - Update them on checklist completion
5. **Validate as you go** - Ensure data quality

# Data Collection Priority
1. Member identification (Member ID or Name + DOB)
2. Case type (Appeal vs Grievance)
3. Category and sub-category
4. Intake basics (date, urgency, channel)
5. Service type and associated case
6. AOR validation (if applicable)

# Conversation Style
- Professional but warm
- Use plain language
- Confirm understanding by reflecting back
- Don't ask for information already provided
- If member gives multiple details at once, extract all of them

# Special Handling
- **Late Filing**: Sensitively explain 60-day window, request good cause
- **Missing AOR**: Clearly explain requirement if someone else is filing
- **Urgent Cases**: Confirm reasoning for expedited request
```

---

### Phase 5: Add Actions to the Topic

#### Action 1: Create Intake Checklist

1. Click **+ Add Action**
2. Select **Apex Action**
3. Choose: `IntakeChecklistManager.createChecklist`
4. Configure:
   - **Action Name**: Create Intake Checklist
   - **When to use**: "At the start of every conversation to track progress"
   - **Input Mapping**:
     - `conversationId`: Map to `$ConversationId` (system variable)
     - `caseType`: Optional, can be blank initially
   - **Output**: Store `checklistId` in conversation variable `ctx_checklist_id`

5. Add Planner Prompt:
   ```
   Use this action immediately when a member wants to file an appeal or grievance. 
   This creates a checklist to track all required information. You must call this 
   before collecting any other information.
   ```

---

#### Action 2: Search Member

1. Click **+ Add Action**
2. Select **Apex Action**
3. Choose: `MemberSearchService.searchMember`
4. Configure:
   - **Action Name**: Search Member
   - **When to use**: "When you have Member ID or Name + DOB"
   - **Input Mapping**:
     - `memberId`: From conversation or user input
     - `firstName`: From conversation or user input
     - `lastName`: From conversation or user input
     - `dateOfBirth`: From conversation or user input
     - `checklistId`: Map to `ctx_checklist_id`
   - **Output**: Store `memberId` in `ctx_member_id`

5. Add Planner Prompt:
   ```
   Use this action when you have enough information to identify the member. 
   You need EITHER:
   - Member ID alone, OR
   - First Name + Last Name + Date of Birth together
   
   Don't call this if you're missing required fields. Ask for them first.
   ```

---

#### Action 3: Capture Complaint Details

1. Click **+ Add Action**
2. Select **Apex Action**
3. Choose: `ComplaintCaptureService.captureComplaint`
4. Configure:
   - **Action Name**: Capture Complaint Details
   - **When to use**: "When member describes their appeal or grievance"
   - **Input Mapping**:
     - `caseType`: From conversation (Appeal/Grievance)
     - `category`: From conversation
     - `subCategory`: From conversation (optional)
     - `narrative`: From conversation
     - `checklistId`: Map to `ctx_checklist_id`
   - **Outputs**: Store in conversation variables

5. Add Planner Prompt:
   ```
   Use this when the member indicates what they're filing about. Extract:
   - Type: Appeal or Grievance
   - Category: What it's regarding
   - Narrative: Their explanation
   
   The system will validate that the category matches the type. If invalid, 
   explain the correct categories to the member.
   ```

---

### Phase 6: Add Additional Actions (To be created)

**Note**: The following actions need to be created as you build out the full agent:

4. **Set Intake Basics** - Capture request date, urgency, channel
5. **Link Associated Case** - Connect to Prior Auth or Claim
6. **Validate Late Filing** - Check 60-day window
7. **Validate AOR** - Check authorized representative
8. **Create Case Records** - Final case creation (wrap existing flow)
9. **Generate Summary** - Provide case link and summary

---

### Phase 7: Add Knowledge Articles (Optional)

Create knowledge articles for the agent to reference:
1. **What is an Appeal** - Explain appeals process
2. **What is a Grievance** - Explain grievances process
3. **AOR Requirements** - Explain authorized representative
4. **Late Filing Process** - Explain good cause
5. **Appeal Categories** - List all appeal categories
6. **Grievance Categories** - List all grievance categories

To add:
1. Go to **Knowledge** → **New Article**
2. Create articles with clear titles and content
3. In Agent builder → **Knowledge** tab → **Add Knowledge Base**

---

### Phase 8: Test the Agent

1. Click **Preview** in the Agent builder
2. Test conversations:

**Test 1: Linear Flow**
```
You: I want to file an appeal
Agent: [Creates checklist] I can help with that! Do you have your Member ID?
You: Yes, it's MEM-001
Agent: [Searches] Great! I found your account. What is the appeal regarding?
You: My surgery claim was denied
Agent: [Captures details] I understand. Was this for Medical Necessity, Pharmacy, Benefit Denial, or Reimbursement?
...
```

**Test 2: Non-Linear Flow**
```
You: My doctor visit claim got denied last month. I'm John Smith, born 5/15/1980
Agent: [Extracts: Type=Appeal, Name, DOB, searches member]
Agent: Thanks John! I found your account. Let me capture the details about your denied doctor visit claim...
```

---

### Phase 9: Deploy to Channel

Once testing is complete:

1. **For Chat**:
   - Go to **Setup** → **Embedded Service Deployments**
   - Create or edit deployment
   - Add the Agent to the chat configuration

2. **For Voice**:
   - Go to **Setup** → **Voice**
   - Configure voice channel
   - Associate the Agent

3. **For Assisted Mode** (Agent helping human agent):
   - Human agents can launch the agent from Service Console
   - Agent runs in sidebar, suggests responses

---

## 🔧 Next Steps

### Immediate Next Steps:
1. ✅ Deploy the objects and Apex classes (DONE)
2. ⏭️ Create the Agent and Topic in UI
3. ⏭️ Add the 3 initial actions
4. ⏭️ Test with sample conversations

### Future Enhancements:
- Create remaining 6 actions (Intake Basics, Associated Case, Late Filing, AOR, Case Creation, Summary)
- Add entity extraction for dates, urgency levels
- Create knowledge articles
- Set up post-intake task automation
- Add analytics dashboard

---

## 📊 Monitoring & Analytics

After deployment, monitor:
1. **Agent Dashboard** - Conversation success rate
2. **Checklist Completion** - Track drop-off points
3. **Member Satisfaction** - CSAT scores
4. **Average Handle Time** - Compare to manual intake

---

## 🆘 Troubleshooting

**Issue**: Agent doesn't trigger
- Check classification utterances
- Verify agent is active and deployed

**Issue**: Action fails
- Check Apex debug logs
- Verify field permissions
- Ensure checklist ID is being passed

**Issue**: Agent gives generic responses
- Refine instructions
- Add more specific planner prompts
- Train with more sample conversations

---

## 📞 Support

For issues or questions:
1. Check Salesforce Agent logs
2. Review Apex debug logs
3. Test actions individually in Flow Builder
4. Consult Agentforce documentation

---

## ✨ You're Ready to Create Your AI Agent!

Follow the steps above to set up your Appeals & Grievances Intake Agent. The foundation is deployed and ready for configuration in the Salesforce UI.

Good luck! 🚀


