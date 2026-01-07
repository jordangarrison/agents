---
description: Add an item to the backlog
---

# Add Backlog Item

Create a new issue in the project backlog.

## Arguments

Parse "$ARGUMENTS" for:
- Summary (required) - brief description of the work
- Project key (optional, after "to" or "in")
- Issue type (optional): story, bug, task, epic (default: story)
- Priority (optional): p1-p4 or high/medium/low

## Examples

- `/jagents:backlog-add Implement user search to PROJ`
- `/jagents:backlog-add Fix login timeout bug to PROJ`
- `/jagents:backlog-add Setup CI pipeline to PROJ task`
- `/jagents:backlog-add Redesign dashboard epic to PROJ`

## Implementation

Use the Atlassian MCP server to:

1. Determine project (from args or ask user)
2. Create issue with:
   - Summary from arguments
   - Type (default to Story)
   - Priority (default to Medium/P3)
3. Confirm created issue with link

## Presentation

Show the created issue:
- Key and link
- Summary and type
- Priority
- Suggest next steps (add description, estimate, etc.)
