---
description: Start a backlog grooming session
---

# Backlog Grooming Session

Start an interactive backlog grooming session for a project.

## Arguments

Parse "$ARGUMENTS" for:
- Project key or name (required)
- Focus area (optional): "unestimated", "stale", "large", "upcoming"

## Examples

- `/jagents:backlog-groom PROJ`
- `/jagents:backlog-groom PROJ unestimated`
- `/jagents:backlog-groom MyProject stale`

## Implementation

Use the Atlassian MCP server to:

1. Fetch backlog items for the project (unresolved, not in active sprint)
2. Based on focus area, prioritize:
   - **unestimated**: Items missing story points
   - **stale**: Items not updated in 30+ days
   - **large**: Epics or items that may need breakdown
   - **upcoming**: High-priority items for next sprint
3. Present items one at a time for review
4. For each item, suggest:
   - Missing fields to fill
   - Whether it needs breakdown
   - Priority adjustments

## Presentation

Show each item with:
- Key, summary, type, priority
- Current status and assignee
- Story points (if any)
- Last updated date
- Suggested actions
