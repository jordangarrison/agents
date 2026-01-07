---
description: Add a task
---

# Add Task

Add a new task to the task management system.

## Arguments

Parse "$ARGUMENTS" for:
- Task content (required) - should be actionable, start with a verb
- Project name (optional, after "to" or "in")
- Due date (optional, after "by" or "due")
- Priority (optional, p1-p4)

## Examples

- `/jagents:todo-add Buy groceries`
- `/jagents:todo-add Review PR to Work by tomorrow`
- `/jagents:todo-add Call dentist p1`

## Implementation

Use the Todoist MCP server to create the task.
Confirm the created task with its details.
