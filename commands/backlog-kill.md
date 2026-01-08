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

**Otherwise, build default**:
```
project = KEY
AND resolution = Unresolved
AND status NOT IN (Done, Closed, Resolved)
AND sprint is EMPTY
AND created > -1y
```

**Apply optional filters**:
- `--board <id>`: Use board's filter - fetch board config first, or add `AND "Board" = <id>` if supported
- `--since <date>`: Replace default `-1y` with provided date (e.g., `-6m`, `-2y`, `2024-01-01`)
- **stale**: `AND updated < -30d`
- **old**: `AND created < -90d` (overrides --since)
- **low-priority**: `AND priority in (Low, Lowest)`
- **custom JQL fragment**: Append with AND

Order by: `ORDER BY updated ASC` (oldest activity first)

### 2. Discover Closure Transitions

Use `getTransitionsForJiraIssue` on the first ticket to find available closure transitions:
- Look for transitions to statuses like "Won't Do", "Closed", "Done", "Cancelled"
- Present available options to user: "Which closure status? (1) Won't Do (2) Done..."
- Remember selection for batch

### 3. Interactive Review Loop

Present tickets in batches of 10:

| # | Key | Type | Priority | Summary (truncated) | Updated |
|---|-----|------|----------|---------------------|---------|

Prompt: `Enter numbers to close (e.g., 1,3,5), 'all', 'none', or 'q' to quit:`

Track decisions across batches.

### 4. Execute Closures

After review is complete (user quits or no more tickets):

1. Show summary: "Ready to close X tickets with status 'Won't Do'"
2. List the tickets to be closed
3. Ask for final confirmation: "Proceed? (y/n)"
4. If `--dry-run`, skip execution and just show what would happen
5. Execute transitions using `transitionJiraIssue`
6. Report results: "Closed X tickets, Y failed"

## Presentation

### During Review
```
Reviewing 47 backlog items for PROJECT (stale: not updated in 30+ days)

Batch 1 of 5:
| # | Key      | Type | Pri  | Summary                    | Updated    |
|---|----------|------|------|----------------------------|------------|
| 1 | PROJ-123 | Bug  | Low  | Fix alignment issue...     | 2024-03-15 |
| 2 | PROJ-456 | Task | Med  | Update documentation...    | 2024-02-28 |
...

Enter numbers to close (1,3,5), 'all', 'none', or 'q' to quit:
```

### Final Summary
```
Ready to close 12 tickets with status "Won't Do":
- PROJ-123: Fix alignment issue...
- PROJ-456: Update documentation...
...

Proceed? (y/n):
```

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
