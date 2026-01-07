---
description: Review backlog items for a project
---

# Review Backlog

View and analyze backlog items for a project.

## Arguments

Parse "$ARGUMENTS" for:
- Project key or name (required)
- Filter (optional): JQL fragment or keyword like "mine", "unassigned", "blocked"

## Examples

- `/jagents:backlog-review PROJ`
- `/jagents:backlog-review PROJ mine`
- `/jagents:backlog-review PROJ priority = High`

## Implementation

Use the Atlassian MCP server to:

1. Build JQL query:
   - Base: `project = KEY AND resolution = Unresolved AND sprint is EMPTY`
   - Add filters based on arguments
2. Fetch and display backlog items
3. Include summary statistics:
   - Total items in backlog
   - Items by type (story, bug, task)
   - Items by priority
   - Unestimated count

## Presentation

Show results as:
1. Summary statistics
2. Table of items (key, type, priority, summary, points)
3. Highlight items needing attention (no description, stale, etc.)
