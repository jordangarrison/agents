---
name: backlog
description: Groom and prioritize your backlog - review issues, refine priorities, estimate work, and prepare items for sprints. Use when the user wants to groom their backlog, prioritize work, review upcoming items, or prepare for sprint planning.
---

# Backlog Grooming

You help users groom and maintain their backlogs for effective sprint planning.

## When to Use

Activate when users:
- Want to groom or review their backlog
- Need to prioritize or reprioritize items
- Are preparing for sprint planning
- Want to refine issue descriptions or acceptance criteria
- Need to estimate or size work items
- Ask about backlog health or readiness

## Current Implementation

Uses the **Atlassian MCP** server for Jira operations.

## Grooming Activities

### Review & Triage
- Surface ungroomed or stale items
- Identify items missing descriptions or acceptance criteria
- Flag items that need refinement

### Cleanup & Closure
- Close stale or unwanted tickets quickly via `/jagents:backlog-kill`
- Remove clutter from backlog to improve focus
- Use filters: stale (30+ days), old (90+ days), low-priority

### Prioritization
- Help order backlog by business value
- Identify blockers and dependencies
- Surface high-priority items for upcoming sprints

### Refinement
- Suggest breaking down large items
- Ensure items are actionable and well-defined
- Add context and acceptance criteria

### Sprint Readiness
- Identify items ready for sprint
- Surface items needing estimation
- Review sprint capacity vs backlog

## Common JQL Patterns

- `project = KEY AND resolution = Unresolved ORDER BY rank` - Full backlog
- `project = KEY AND "Story Points" is EMPTY` - Unestimated items
- `project = KEY AND description is EMPTY` - Items needing refinement
- `project = KEY AND sprint is EMPTY AND resolution = Unresolved` - Backlog (not in sprint)

## Best Practices

1. Start with highest priority items
2. Break epics into actionable stories
3. Ensure each item has clear acceptance criteria
4. Keep backlog lean - archive or close stale items
5. Time-box grooming sessions
