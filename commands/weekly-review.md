---
description: Comprehensive weekly review following GTD/Redeeming Your Time methodology
---

# Weekly Review

Review all life areas, verify next actions, and maintain project health.

## Arguments

Parse "$ARGUMENTS" for:
- `--area <name>` (optional): Start with specific area (Personal, Work, Home, Ventures, Church, Lists)
- `--project <id>` (optional): Review single project by ID
- `--quick` (optional): Skip detailed summaries, focus on next action verification
- `--dry-run` (optional): Preview without making changes
- `--limit <n>` (optional): Limit projects per area (default: all)

## Examples

- `/jagents:weekly-review` - Full review of all areas
- `/jagents:weekly-review --area Work` - Review only Work area
- `/jagents:weekly-review --quick` - Fast next-action audit
- `/jagents:weekly-review --project 123456` - Review single project
- `/jagents:weekly-review --dry-run` - Preview mode

## Implementation

Use the Todoist MCP server to perform a comprehensive weekly review following GTD methodology.

### 1. Initialize Review Session

1. **Display welcome banner**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    WEEKLY REVIEW
           GTD / Redeeming Your Time Methodology
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Date: [Current date]
Mode: [Full/Quick/Single Project/Dry Run]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

2. **Fetch all projects** using `mcp__todoist__find-projects`
   - Build hierarchy map: Area -> Sub-projects
   - Count projects per area

3. **Life area configuration**:

| Area | Project ID | Someday Project ID |
|------|-----------|-------------------|
| Personal | 2264594942 | 6Xv8rJJWQPx5h6pf |
| Work | 2264594882 | 6Xv8rM2FHQ97p2cR |
| Home | 2264594895 | 6Xv8rMmFhcRGmG3H |
| Ventures | 2331219621 | 6XvjjjwrgwQ6cFgx |
| Church | 2264594944 | 6Xv8rPHWVpmfXgV7 |
| Lists | 2331245308 | N/A (reference only) |

4. **Area selection** (if `--area` not specified):

Use `AskUserQuestion`:
- Question: "Which life area would you like to start with?"
- Options:
  1. Personal (X active projects)
  2. Work (X active projects)
  3. Home (X active projects)
  4. More areas...

**If "More areas" selected**:
  1. Ventures (X active projects)
  2. Church (X active projects)
  3. Lists (reference review)
  4. Review all areas sequentially

### 2. Area Review Loop

For each life area (or selected area):

#### A. Display Area Header

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  AREA: WORK                                             ┃
┃  Active Projects: 12 | Someday: 5                       ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

#### B. Fetch Area Data

1. Get all sub-projects under area using `mcp__todoist__find-projects`
   - Identify projects where `parentId` matches the area's project ID

2. For each project, fetch:
   - Tasks using `mcp__todoist__find-tasks` with `projectId`
   - Recent activity using `mcp__todoist__find-activity` with `projectId`
   - Completed tasks (last 7 days) using `mcp__todoist__find-completed-tasks`

### 3. Project Review (for each project)

#### A. Generate Project Summary

Skip this section if `--quick` mode is active.

For each project, calculate and display:

```
┌──────────────────────────────────────────────────────────┐
│ PROJECT: Kubernetes Rightsizing                          │
├──────────────────────────────────────────────────────────┤
│ Status: ACTIVE          Last Activity: 2 days ago        │
│ Tasks: 8 total | 3 completed this week                   │
│ Staleness: ●●●○○ (worked on recently)                    │
├──────────────────────────────────────────────────────────┤
│ CURRENT STATE:                                           │
│   • 5 pending tasks, 2 in progress                       │
│   • Blocked: Waiting on Ted for resource limits          │
│   • Key milestone: Q1 optimization target                │
├──────────────────────────────────────────────────────────┤
│ NEXT ACTION CHECK:                                       │
│   ⚠ Issue: No task has 'next' label                      │
│   Top task: "Review K8s metrics dashboard"               │
│   Suggestion: Add 'next' label to top task               │
└──────────────────────────────────────────────────────────┘
```

**Staleness Indicator Logic** (based on last activity from `find-activity`):

| Last Activity | Indicator | Status |
|--------------|-----------|--------|
| < 3 days | ●●●●● | Hot |
| 3-7 days | ●●●●○ | Active |
| 7-14 days | ●●●○○ | Warm |
| 14-30 days | ●●○○○ | Cooling |
| 30-60 days | ●○○○○ | Stale |
| > 60 days | ○○○○○ | Dormant |

**Current State Analysis**:
- Count pending tasks vs completed
- Identify any tasks with `waiting`, `blocked`, or `followup` labels
- Check for overdue tasks
- Note any high-priority (`p1`, `p2`) or `urgent`/`important` labeled tasks

#### B. Next Action Verification

Get all tasks for project and check:

1. **Get tasks sorted by order** (first task = position 1)
2. **Find action labels**: `next`, `linchpin`, `waiting`, `followup`, `delegate`
3. **Verify conditions**:

**Valid states** (project is healthy):
- ✓ Exactly ONE task with `next` label AND it's the first task
- ✓ Exactly ONE task with `linchpin` label AND it's the first task
- ✓ First task has `waiting`/`followup`/`delegate` (project is blocked, acceptable)

**Warning states** (needs attention):
- ⚠ Multiple tasks with `next` label (violates one-next-action principle)
- ⚠ Task with `next` is NOT the first task (order mismatch)
- ⚠ `next` on one task, `linchpin` on another (conflicting priorities)

**Error states** (needs fixing):
- ✗ No action labels on any task (unclear next action)
- ✗ Project has tasks but none are actionable

Display current task order with labels:
```
Current task order:
  1. [waiting] Wait for Ted's email
  2. [ ] Review K8s metrics dashboard        ← Should this be 'next'?
  3. [next] Update documentation             ← Currently marked as next
  4. [ ] Schedule team sync
```

### 4. Per-Project Action Selection

Use `AskUserQuestion` with max 4 options:

**Question 1**: "What would you like to do with [Project Name]?"
1. **Project looks good** - Mark reviewed, continue to next
2. **Fix next action** - Update task labels/order
3. **Project maintenance** - Add/remove/complete tasks
4. **More options...** - Archive, move to Someday, etc.

---

**If "Fix next action" selected**:

Display current task order with labels (as shown above).

Use `AskUserQuestion`:
1. **Set task #N as next** - Suggest the most logical next task
2. **Keep current arrangement** - No changes needed
3. **Mark project blocked** - Add `waiting` label to top task
4. **Choose different task** - Show more options

**Execute fix**:
1. Use `mcp__todoist__update-tasks` to:
   - Remove `next` label from all tasks in project
   - Add `next` label to the selected task
2. If task is not first in order, note: "Task reordering requires manual adjustment in Todoist app"

---

**If "Project maintenance" selected**:

Use `AskUserQuestion`:
1. **Add new task** - Create task in this project
2. **Complete tasks** - Mark tasks as done
3. **Delete stale tasks** - Remove outdated items
4. **Back to project options**

**Add new task flow**:
1. Ask: "What's the new task?" (free text via subsequent prompt)
2. Use `AskUserQuestion` for quick setup:
   - Add as next action (with `next` label)
   - Add to backlog (no special labels)
   - Add with specific labels
3. Execute with `mcp__todoist__add-tasks`

**Complete tasks flow**:
1. Display incomplete tasks (up to 10)
2. Use `AskUserQuestion` to select tasks to complete (batch of 4 + "more" option)
3. Execute with `mcp__todoist__complete-tasks`

**Delete stale tasks flow**:
1. Identify stale candidates:
   - Tasks older than 90 days with no recent activity
   - Tasks with no due date and p4 priority
2. Display for review:
```
Stale task candidates:
  1. [Created 120 days ago] Old research notes
  2. [Created 95 days ago] Maybe look into X
  3. [Created 200 days ago] Idea from Q2
```
3. Use `AskUserQuestion`:
   - Delete all shown
   - Select specific tasks
   - Keep all
4. Execute with `mcp__todoist__delete-object` for each

---

**If "More options" selected**:

Use `AskUserQuestion`:
1. **Move to Someday** - Defer entire project
2. **Archive project** - Mark project as completed
3. **View in Todoist** - Show project URLs
4. **Back to main options**

**Move to Someday flow**:
1. Determine target Someday project based on current area:
   - Personal projects → Personal Someday (6Xv8rJJWQPx5h6pf)
   - Work projects → Work Someday (6Xv8rM2FHQ97p2cR)
   - Home projects → Home Someday (6Xv8rMmFhcRGmG3H)
   - Ventures projects → Ventures Someday (6XvjjjwrgwQ6cFgx)
   - Church projects → Church Someday (6Xv8rPHWVpmfXgV7)

2. Confirm: "Move [Project] to [Area] Someday?"

3. Execute with `mcp__todoist__update-projects`:
   - Update project's `parentId` to target Someday project ID

4. Optionally remove `next` labels from all tasks (they're no longer active)

**Archive project flow**:
1. Confirm action with `AskUserQuestion`:
   - "Archive will delete this project and all tasks. Proceed?"
   - Options: Yes (delete), No (cancel), Complete tasks first

2. If "Complete tasks first":
   - Mark all tasks complete with `mcp__todoist__complete-tasks`
   - Then delete empty project

3. Execute archive with `mcp__todoist__delete-object`:
   - `type: "project"`
   - `id: <project_id>`

**View in Todoist**:
Display URLs for user to click:
```
Project URLs:
  Web: https://todoist.com/app/project/<project_id>
  App: todoist://project?id=<project_id>
```
Return to action selection after displaying.

### 5. Continue Prompt

After each project action:
- Report what was done
- Show: "Continue to next project? (X remaining in [Area])"
- Options via `AskUserQuestion`:
  1. Continue to next project
  2. Skip to next area
  3. End review session

### 6. Area Summary

After completing all projects in an area:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Area Complete: WORK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Projects reviewed: 12
  • Healthy: 8
  • Fixed next action: 3
  • Moved to Someday: 1

Tasks: +2 added, 5 completed, 2 deleted
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `AskUserQuestion`:
- "Continue to next area?"
- Options:
  1. Continue to [Next Area] (X projects)
  2. Quick review remaining areas
  3. End review session

### 7. Final Summary

After all areas reviewed or user ends session:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    WEEKLY REVIEW COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Duration: [calculated from start]
Areas reviewed: X/6

PROJECT HEALTH SUMMARY
┌─────────────┬──────────┬────────┬─────────┬──────────┐
│ Area        │ Projects │ Healthy│ Fixed   │ Deferred │
├─────────────┼──────────┼────────┼─────────┼──────────┤
│ Personal    │    8     │   7    │    1    │    0     │
│ Work        │   12     │   8    │    3    │    1     │
│ Home        │    6     │   5    │    1    │    0     │
│ Ventures    │    4     │   2    │    1    │    1     │
│ Church      │    5     │   5    │    0    │    0     │
├─────────────┼──────────┼────────┼─────────┼──────────┤
│ TOTAL       │   35     │  27    │    6    │    2     │
└─────────────┴──────────┴────────┴─────────┴──────────┘

ACTIONS TAKEN
  • Next actions verified/fixed: X projects
  • Tasks added: X
  • Tasks completed: X
  • Tasks deleted: X
  • Projects moved to Someday: X
  • Projects archived: X

ATTENTION NEEDED
  ⚠ X projects have no recent activity (>30 days)
  ⚠ X projects have multiple 'next' labels

NEXT REVIEW: [Current date + 7 days]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Quick Mode (--quick flag)

When `--quick` is specified, streamline the review:

1. **Skip detailed summaries** - No task counts, staleness analysis, current state
2. **Focus only on next action verification**
3. **Auto-approve healthy projects** - Projects with valid next action are auto-marked reviewed
4. **Batch display format**:

```
Quick Review: Work Area

✓ Kubernetes Rightsizing - next: "Review metrics"
✓ CI/CD Pipeline - next: "Fix flaky test"
⚠ Database Migration - NO NEXT ACTION
✓ Documentation - linchpin: "API docs"
⚠ Tech Debt Cleanup - multiple 'next' labels

2 projects need attention. Fix now?
```

5. **Only pause on projects needing attention**
6. **Faster area transitions** - Auto-continue unless issues found

## Dry Run Mode

When `--dry-run` is specified:

1. All read operations execute normally
2. All write operations are simulated:
   - Show what WOULD happen
   - Prefix with "[DRY RUN]"
   - Do NOT call mutation APIs

Example:
```
[DRY RUN] Would update task "Review metrics":
  - Add label: next
  - Remove from tasks: "Update docs"

[DRY RUN] Would move project "Old Idea" to Ventures Someday
```

Final summary shows:
```
DRY RUN SUMMARY - No changes made
Would have:
  • Fixed 6 next actions
  • Added 4 tasks
  • Deleted 5 tasks
  • Moved 2 projects to Someday
```

## Edge Cases

### Empty Projects
If a project has no tasks:
```
Project: [Name]
Status: EMPTY - No tasks

Options:
1. Add first task
2. Archive project (no longer needed)
3. Move to Someday (will work on later)
4. Skip (keep as placeholder)
```

### Large Projects (>50 tasks)
- Show summary stats instead of full task list
- Focus on top 10 tasks for next action review
- Option to "dive deeper" for full task list

### Nested Projects
If a project has sub-projects:
- Review parent first, then offer to review children
- Or skip children if reviewing sequentially

### Lists Area (Reference)
The Lists area contains non-actionable reference lists.
- Skip next action verification
- Only offer: View, Add item, Delete items, Skip

## Permissions

This command requires Todoist MCP operations. The plugin's `hooks/hooks.json` auto-approves:

**Read operations**:
- `mcp__todoist__find-projects`
- `mcp__todoist__find-tasks`
- `mcp__todoist__find-activity`
- `mcp__todoist__find-completed-tasks`
- `mcp__todoist__get-overview`
- `mcp__todoist__fetch-object`

**Write operations**:
- `mcp__todoist__update-tasks`
- `mcp__todoist__update-projects`
- `mcp__todoist__complete-tasks`
- `mcp__todoist__delete-object`
- `mcp__todoist__add-tasks`

No manual configuration required when using the jagents plugin.
