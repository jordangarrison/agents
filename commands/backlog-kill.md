---
description: Interactively review and close unwanted backlog items
---

# Kill Backlog Items

Quickly close tickets you don't want to work on through interactive review.

## Arguments

Parse "$ARGUMENTS" for:
- Project key (required)
- Filter (optional): "stale", "old", "low-priority", or JQL fragment
- `--board <id>` (optional): Filter to a specific board's backlog
- `--since <date>` (optional): Only items created after date (default: -1y)
- `--jql "<query>"` (optional): Custom base JQL (overrides default)
- `--dry-run` flag (optional): Preview without making changes

## Examples

- `/jagents:backlog-kill PROJ` - Review backlog items (last year, excludes done)
- `/jagents:backlog-kill PROJ stale` - Focus on items not updated in 30+ days
- `/jagents:backlog-kill PROJ --board 123` - Only items on board 123
- `/jagents:backlog-kill PROJ --since -6m` - Only items from last 6 months
- `/jagents:backlog-kill PROJ --jql "labels = tech-debt"` - Custom filter
- `/jagents:backlog-kill PROJ stale --dry-run` - Preview what would be closed

## Implementation

Use the Atlassian MCP server to:

### 1. Fetch Candidates

Build JQL query:

**If `--jql` provided**: Use custom JQL as base, still apply project filter

**Otherwise, build default** (single query only):
```
project = KEY
AND statusCategory != Done
AND sprint is EMPTY
AND created > -1y
ORDER BY updated ASC
```

Note: Use `statusCategory != Done` instead of specific status names - this works across all Jira configurations regardless of custom status names.

**Apply optional filters**:
- `--board <id>`: Use board's filter - fetch board config first, or add `AND "Board" = <id>` if supported
- `--since <date>`: Replace default `-1y` with provided date (e.g., `-6m`, `-2y`, `2024-01-01`)
- **stale**: `AND updated < -30d`
- **old**: `AND created < -90d` (overrides --since)
- **low-priority**: `AND priority in (Low, Lowest)`
- **custom JQL fragment**: Append with AND

**Important**: Run only ONE search query. Do not run a separate count query first.

### 2. Select Closure Transition and Resolution

Before processing batches, gather options and prompt user:

1. **Get available transitions** using `getTransitionsForJiraIssue` on first ticket
   - Look for closure transitions (to statuses like "Done", "Closed", "Cancelled")
   - Note which transitions have required fields (like resolution)

2. **Get available resolutions** from the transition metadata or project config
   - Use `getJiraIssueTypeMetaWithFields` to find allowed resolution values
   - Or extract from transition's `fields.resolution.allowedValues`

3. **Prompt user for transition** using `AskUserQuestion`:
   - Question: "Which transition should be used to close tickets?"
   - Options: List available transitions from step 1

4. **Prompt user for resolution** using `AskUserQuestion`:
   - Question: "What resolution should be set for closed tickets?"
   - Options: List available resolutions from step 2 (e.g., "Won't Do", "Duplicate", "Done")
   - Default suggestion: "Won't Do" if available

5. **Remember selections** for all batches in the session

When executing transitions, set both the status AND resolution:
```
transitionJiraIssue(issueKey, {
  transition: { id: selectedTransitionId },
  fields: { resolution: { name: selectedResolution } }
})
```

### 3. Batch Review + Transition Loop

Process tickets in batches of 5, transitioning each batch before moving to the next:

**For each batch:**

1. **Fetch full details** for each ticket using `getJiraIssue`:
   - Summary and description (first 200 chars)
   - Type, priority, status
   - Reporter and assignee
   - Created date and last updated
   - Comment count
   - Linked issues count
   - Labels

2. **Present ticket details** one at a time or as a group with rich context:

```
## PROJ-123 (Bug, Low Priority)
**Fix alignment issue on mobile nav**

> The hamburger menu is offset by 2px on iOS devices when...

| Created | Updated | Reporter | Comments | Links |
|---------|---------|----------|----------|-------|
| 8 months ago | 3 months ago | jsmith | 2 | 1 |

Labels: `mobile`, `css`
```

3. **Use AskUserQuestion with multi-select** to pick tickets to close:
   - Each option shows: `PROJ-123: Fix alignment issue... (Bug, 8mo old)`
   - User checks boxes for tickets to close
   - Options: individual tickets + "Skip all"

4. **Execute transitions immediately** for selected tickets in this batch
   - Report success/failure for each
   - If `--dry-run`, show what would happen but don't execute

5. **Ask to continue** to next batch or quit

### 4. Final Summary

After all batches (or user quits):
```
Session complete:
- Reviewed: 25 tickets
- Closed: 12 tickets (Won't Do)
- Skipped: 13 tickets
- Failed: 0
```

## Presentation

### Ticket Detail View
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PROJ-123 | Bug | Low Priority | Unassigned
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Fix alignment issue on mobile nav

The hamburger menu is offset by 2px on iOS devices when
the viewport is less than 375px wide. This causes...

Created: Mar 2024 (8 months ago) by jsmith
Updated: Jun 2024 (3 months ago)
Comments: 2 | Links: 1 | Labels: mobile, css
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Batch Selector
Use `AskUserQuestion` with `multiSelect: true`:
- Question: "Which tickets should be closed?"
- Options show key + summary + age for quick scanning
- User selects multiple, then transitions happen immediately

## Safety Features

- Always show tickets before closing
- Require explicit confirmation before batch closure
- Support `--dry-run` for preview mode
- Report any failures during transition

## Permissions

This command requires Atlassian MCP read operations. The plugin's `hooks/hooks.json` auto-approves these via `PermissionRequest` hooks:
- `mcp__atlassian__get*` (getJiraIssue, getTransitionsForJiraIssue, etc.)
- `mcp__atlassian__search*` (searchJiraIssuesUsingJql)
- `mcp__atlassian__lookup*` (lookupJiraAccountId)

No manual configuration required when using the jagents plugin.
