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
- **Process inbox** using GTD methodology with AI suggestions (see `/jagents:inbox-process`)

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

This skill follows GTD (Getting Things Done) methodology:

### Capture
- Quick capture to inbox - don't organize while capturing
- Use `/jagents:todo-add` for quick capture

### Clarify & Organize
- Process inbox regularly with `/jagents:inbox-process`
- For each item, decide: Delete, Reference, Defer, Delegate, or Do
- Clarify next action (start with action verb)
- Move to appropriate project

### Project Structure
- **Active projects** under areas: Personal, Work, Home, Ventures, Church
- **Someday projects** for deferred items: Personal Someday, Work Someday, etc.
- **Lists** for reference material: Books, Articles, Tools, etc.

### Labels
- **Time estimates**: `time:5m`, `time:15m`, `time:30m`, `time:60m`, `time:+90m`
- **Context**: `at:computer`, `at:ipad`, `house`
- **Actions**: `next`, `followup`, `clarify`, `delegate`, `urgent`, `important`
- **People**: Tag people involved for easy filtering

### Review
- Daily: Check today's tasks
- Weekly: Process inbox, review projects, plan week ahead

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
