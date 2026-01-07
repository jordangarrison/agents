---
name: todo
description: Manage tasks and projects - create, view, complete, and organize tasks. Use when the user wants to add tasks, view their task list, mark tasks complete, or manage their tasks.
---

# Task Management

Manage tasks and projects using the configured task management MCP server.

## Prerequisites

A task management MCP server must be configured. Currently supported:
- Todoist: `claude mcp add --transport http todoist https://ai.todoist.net/mcp`

Then run `/mcp` in Claude Code to authenticate.

## Capabilities

- **Find tasks** by date, project, or filter
- **Add tasks** with priorities, labels, due dates
- **Complete tasks** and track progress
- **Search tasks** across all projects

## Instructions

When working with tasks:

1. **Creating tasks**
   - Ask for project/area if not specified
   - Confirm priority and due date
   - Use actionable language (start with verbs)

2. **Viewing tasks**
   - Group by project or due date
   - Highlight overdue/urgent items
   - Show relevant labels and contexts

3. **Completing tasks**
   - Confirm the correct task before marking done
   - Show what remains after completion

4. **Best practices**
   - Tasks should be specific and actionable
   - Clarify ambiguous requests before acting
   - Summarize changes after operations

## Methodology

<!-- TODO: Customize for GTD + Redeeming Your Time workflow -->

This skill follows productivity best practices:
- Capture tasks quickly, process later
- Keep tasks actionable (start with verbs)
- Use labels/projects for organization
- Regular reviews to stay current

## Examples

**Add a task:**
```
User: "Add review Q1 budget to work"
→ Creates task in Work project, asks about priority/due date
```

**View tasks:**
```
User: "What's due today?"
→ Lists tasks due today, grouped by project
```

**Complete a task:**
```
User: "Mark the budget review as done"
→ Completes the task, shows remaining items
```
