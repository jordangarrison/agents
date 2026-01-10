# Agents

Personal micro agents for productivity - task management, backlog tracking, and more.

A Claude Code plugin that provides commands and skills for managing your productivity workflows.

## Philosophy

**Agentic tools are the new dotfiles.**

For decades, developers have curated their dotfiles - personal configurations that define how their tools behave. These configs are deeply personal, reflecting individual workflows, preferences, and productivity patterns.

Agents are the next evolution. Instead of configuring static tools, we're now defining *intelligent assistants* that understand our workflows. Just like dotfiles:

- **Personal**: Your agents reflect how *you* work
- **Portable**: Take them with you across machines and projects
- **Shareable**: Others can learn from and adapt your patterns
- **Composable**: Small, focused agents that work together

This repository is my personal collection of productivity agents - my "agent dotfiles." Fork it, adapt it, make it yours.

## Installation

### Prerequisites

- [Claude Code](https://claude.ai/code) installed
- A Todoist account (for task management)
- Atlassian Cloud account (for backlog grooming)

### Install the Plugin

```bash
# Add the marketplace
/plugin marketplace add jordangarrison/agents

# Install the plugin
/plugin install jagents
```

Or install from a local clone:

```bash
git clone https://github.com/jordangarrison/agents.git ~/agents
claude plugin install ~/agents
```

### Set Up Todoist

```bash
# Add the Todoist MCP server
claude mcp add --transport http todoist https://ai.todoist.net/mcp

# Inside Claude Code, authenticate with Todoist
/mcp
```

### Set Up Atlassian (Jira)

```bash
# Add the Atlassian MCP server
claude mcp add --transport sse atlassian https://mcp.atlassian.com/v1/sse

# Inside Claude Code, authenticate with Atlassian
# This will trigger an OAuth 2.1 browser flow
/mcp
```

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `/jagents:todo-today` | Show tasks due today |
| `/jagents:todo-add <task>` | Add a new task |
| `/jagents:todo-complete <task>` | Mark a task as complete |
| `/jagents:backlog-groom <project>` | Start a backlog grooming session |
| `/jagents:backlog-review <project>` | Review backlog items |
| `/jagents:backlog-add <item>` | Add an item to the backlog |

### Examples

```
# See what's due today
/jagents:todo-today

# Add a task
/jagents:todo-add Buy groceries

# Add with project and due date
/jagents:todo-add Review PR to Work by tomorrow

# Add with priority
/jagents:todo-add Call dentist p1

# Complete a task
/jagents:todo-complete Buy groceries

# Groom a project backlog
/jagents:backlog-groom PROJ

# Focus on unestimated items
/jagents:backlog-groom PROJ unestimated

# Review backlog
/jagents:backlog-review PROJ

# Add a story to backlog
/jagents:backlog-add Implement user search to PROJ
```

### Skills (Auto-Invoked)

The `todo` skill activates automatically when you mention tasks or task management:

```
"What tasks do I have today?"
"Add a reminder to call Mom"
"Show me my overdue tasks"
```

The `backlog` skill activates when you mention backlog grooming or Jira work:

```
"Let's groom the backlog"
"Show me unestimated items in PROJ"
"What needs refinement before the sprint?"
```

## Available Agents

| Domain | Status | Backend |
|--------|--------|---------|
| Tasks (todo) | ✅ Available | Todoist |
| Backlog (backlog) | ✅ Available | Atlassian/Jira |
| Notes (notes) | 📋 Planned | Obsidian |
| Git (git) | 📋 Planned | GitHub |

## Architecture

This project uses a hybrid approach:

- **Plugin** (skills/commands): Interactive use via Claude Code CLI, uses your Claude subscription
- **SDK packages**: Programmatic automation, uses API key (for CI/automation)

Commands use generic names (`todo-*`) with swappable backends. Currently Todoist, but designed to support other task management systems in the future.

## Configuration

### Environment Variables

For SDK/automation usage, create a `.env` file:

```bash
TODOIST_API_TOKEN=your_token_here
ANTHROPIC_API_KEY=your_api_key  # Only for SDK automation
```

Get your Todoist API token from [todoist.com/prefs/integrations](https://todoist.com/prefs/integrations).

## Contributing

See [CONTRIBUTORS.md](CONTRIBUTORS.md) for guidelines on contributing to this project.

## License

MIT
