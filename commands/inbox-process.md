---
description: Process inbox items using GTD methodology with AI suggestions
---

# Process Inbox

Clarify and organize inbox items one at a time with AI-powered suggestions.

## Arguments

Parse "$ARGUMENTS" for:
- `--limit <n>` (optional): Process only first N items
- `--dry-run` (optional): Preview without making changes

## Examples

- `/jagents:inbox-process` - Process entire inbox
- `/jagents:inbox-process --limit 5` - Process only 5 items
- `/jagents:inbox-process --dry-run` - Preview mode

## Implementation

Use the Todoist MCP server to process inbox items following GTD methodology.

### 1. Fetch Inbox Items

Get all items from inbox, ordered by creation date (oldest first):
- Use `mcp__todoist__find-tasks` with `projectId: "inbox"`
- Fetch project list with `mcp__todoist__find-projects` for AI suggestions

### 2. Process Loop (One Item at a Time)

For each inbox item:

#### A. Display Item Context

Show the item with full context:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Content of inbox item]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Created: 3 days ago | Priority: p4 | No due date
Description: [if any]
Labels: [if any]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### B. AI Analysis

Analyze content and suggest:

1. **Item Type**: Task, Project, Reference, or Trash
2. **Recommended Project** (if task): Best-fit from user's project hierarchy
3. **Suggested Labels**:
   - Time estimate: `time:5m`, `time:15m`, `time:30m`, `time:60m`, `time:+90m`
   - Context: `at:computer`, `at:ipad`, `house`
   - People: Detect names (e.g., `MikeRyan`, `Madhu`, `TedKnudsen`)
   - Action type: `followup`, `clarify`, `delegate`, `next`, `urgent`, `important`
4. **Next Action Wording**: If item is vague, suggest clearer phrasing starting with action verb

Present AI suggestion with ALL label categories:
```
AI Suggestion:
  Type: Task
  Project: Work → Kubernetes Rightsizing

  Labels (suggested):
    Time:     time:30m
    Context:  at:computer
    Energy:   energy:medium
    Work:     shallow_work
    Priority: important
    Action:   followup
    Person:   TedKnudsen

  Next action: "Review K8s resource limits with Ted"
```

#### C. Action Selection

Use `AskUserQuestion` with options (max 4 per question, split if needed):

**Question 1**: "What would you like to do with this item?"
1. **Move to project** - Move with AI-suggested project/labels
2. **Defer (Someday)** - Move to appropriate someday project
3. **Open task** - View task URLs (web + app) to inspect further
4. **More options...** - Show additional actions

**If "More options" selected**:
1. **Reference** - Move to Lists (non-actionable)
2. **Delete** - Remove from Todoist
3. **Create new project** - Turn this into a project
4. **Complete/Skip** - Mark done or leave in inbox

#### D. Execute Action

Based on selection:

**Open task**:
Display task URLs for user to click:
```
Task URLs:
  Web: https://todoist.com/showTask?id=<task_id>
  App: todoist://task?id=<task_id>

Click to open, then return here to continue processing.
```
After displaying URLs, return to action selection for the same item (don't advance to next item).

**Move to project**:
1. Show AI-suggested project and labels
2. Use `AskUserQuestion`: "Accept suggestions or customize?"
   - Accept as-is
   - Edit content first (clarify next action)
   - Change project
   - Modify labels
3. Optionally prompt for due date only if user wants
4. Execute with `mcp__todoist__update-tasks`:
   - Set `projectId` to target project
   - Set `labels` to suggested/modified labels
   - Update `content` if edited

**Defer (Someday)**:
Suggest appropriate Someday project based on content:

| Content Type | Target Project | Project ID |
|-------------|----------------|------------|
| Work-related | Work Someday | 6Xv8rM2FHQ97p2cR |
| Home/family | Home Someday | 6Xv8rMmFhcRGmG3H |
| Personal/self | Personal Someday | 6Xv8rJJWQPx5h6pf |
| Side projects | Ventures Someday | 6XvjjjwrgwQ6cFgx |
| Church-related | Church Someday | 6Xv8rPHWVpmfXgV7 |

Options:
- Accept suggested Someday project
- Choose different Someday project
- Create as new sub-project under Someday area

Execute with `mcp__todoist__update-tasks` to move to Someday project.

**Reference**:
Suggest appropriate Lists sub-project:

| Content Type | Target Project |
|-------------|----------------|
| Movies, shows to watch | Movies |
| Podcasts to listen | Podcasts |
| Articles to read | Articles |
| Videos to watch | Videos |
| Books to read | Books |
| Software/hardware | Tools |
| Prayer requests | Prayers |
| Special dates | Birthdays & Anniversaries |
| Work docs | Work Documents and Presentations |

Execute with `mcp__todoist__update-tasks`:
- Move to selected Lists project
- Remove actionable labels (`next`, `urgent`, `important`, etc.)

**Delete**:
Execute with `mcp__todoist__delete-object`:
- `type: "task"`
- `id: <task_id>`

**Create new project**:
1. Ask which area: Personal, Work, Home, Ventures, Church
2. Ask for project name (default to inbox item content)
3. Create with `mcp__todoist__add-projects`:
   - Set `parentId` to chosen area's ID
4. Ask if inbox item should become first task in new project
5. If yes, move task to new project; if no, delete original item

**Complete**:
Execute with `mcp__todoist__complete-tasks`:
- `ids: [<task_id>]`

**Skip**:
Continue to next item without changes.

#### E. Continue Prompt

After each action (unless `--dry-run`):
- Report what was done
- Ask: "Continue processing? (X items remaining)"
- Options: Continue, Quit

### 3. Final Summary

After all items processed or user quits:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Inbox processing complete:
- Processed: 15 items
- Moved to projects: 8
- Deferred (Someday): 2
- Reference: 1
- Deleted: 2
- Completed: 1
- Skipped: 1
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## AI Suggestion Logic

### Project Matching

Analyze item content and match to user's project hierarchy:

**Work indicators**: Slack links (flosports.slack.com), Jira (flocasts.atlassian.net), work emails, coworker names, technical terms like K8s, CI/CD, AWS, Datadog
→ Match to Work area projects

**Home indicators**: Family names, house tasks, kids, pets, financial terms
→ Match to Home area projects

**Personal indicators**: Health, fitness, hobbies, personal development
→ Match to Personal area projects

**Ventures indicators**: Side projects, portfolio, business ideas
→ Match to Ventures area projects

**Church indicators**: Faith, ministry, church activities
→ Match to Church area projects

### Label Detection (MUST suggest from ALL categories)

For each task, AI MUST suggest labels from these categories:

#### 1. Time Estimate (required)

| Task Complexity | Label |
|----------------|-------|
| Quick reply, single click | `time:5m` |
| Simple task, one step | `time:15m` |
| Review, meeting prep | `time:30m` |
| Substantial work | `time:60m` |
| Research, planning, deep work | `time:+90m` |

#### 2. Context (required)

- Computer/online tasks → `at:computer`
- iPad/tablet specific → `at:ipad`
- Physical house tasks → `house`

#### 3. Energy Level (required)

| Task Type | Label |
|-----------|-------|
| Complex decisions, creative work, deep thinking | `energy:high` |
| Standard tasks, meetings, reviews | `energy:medium` |
| Routine, administrative, low-stakes | `energy:low` |

#### 4. Work Type (required)

| Task Nature | Label |
|-------------|-------|
| Focused, uninterrupted, creative, strategic | `deep_work` |
| Email, admin, quick responses, routine | `shallow_work` |

#### 5. Priority (if applicable)

- Time-sensitive, deadline-driven → `urgent`
- High-impact, significant outcome → `important`
- Can combine: `urgent` + `important` = do first

#### 6. Action Type (if applicable)

- Waiting on someone → `followup`
- Need more info → `clarify`
- Should assign to someone else → `delegate`
- Clear next step ready → `next`
- Needs evaluation → `review`

#### 7. People (if detected)

- Detect names in content: `@mentions`, capitalized names, email senders
- Known labels: `MikeRyan`, `Madhu`, `SolomonDuncan`, `CharlesCooper`, `TonyRocca`, `TedKnudsen`, `DavidCisarik`, `LolaBeste`
- Create new person label if name detected but no existing label

#### 8. Filing (if applicable)

- Should be saved to Obsidian → `to-file:obsidian`
- Should become Jira ticket → `to-file:jira`

#### 9. Life Goals (if applicable)

- Leadership/management → `+LG: Lead others well`
- Health/fitness/discipline → `+LG: Be a Tough MF`
- Purpose/meaning → `+LG: Live with a purpose and no regrets`

### Next Action Wording

If item content is vague (no action verb, unclear outcome):
- Suggest rewording to start with action verb
- Make outcome specific and concrete
- Example: "K8s stuff" → "Review K8s resource allocation report"

## Dry Run Mode

When `--dry-run` is specified:
- Show all analysis and suggestions
- Show what actions WOULD be taken
- Do NOT execute any Todoist API calls
- Prefix actions with "[DRY RUN]"

## Permissions

This command requires Todoist MCP operations. The plugin's `hooks/hooks.json` auto-approves:
- Read operations: `mcp__todoist__find-*`, `mcp__todoist__get-*`
- Write operations: `mcp__todoist__update-tasks`, `mcp__todoist__delete-object`, `mcp__todoist__complete-tasks`, `mcp__todoist__add-projects`, `mcp__todoist__add-tasks`

No manual configuration required when using the jagents plugin.
