# Agents

Personal micro agents for email, task management, backlog tracking, and more.

The repository contains portable
[Agent Skills](https://agentskills.io/) for compatible agents, a Claude Code
plugin adapter with additional commands, and SDK packages for automation. The
portable skills are the canonical source and are not tied to one agent harness.

## Philosophy

**Agentic tools are the new dotfiles.**

For decades, developers have curated their dotfiles - personal configurations that define how their tools behave. These configs are deeply personal, reflecting individual workflows, preferences, and productivity patterns.

Agents are the next evolution. Instead of configuring static tools, we're now defining *intelligent assistants* that understand our workflows. Just like dotfiles:

- **Personal**: Your agents reflect how *you* work
- **Portable**: Take them with you across machines and projects
- **Shareable**: Others can learn from and adapt your patterns
- **Composable**: Small, focused agents that work together

This repository is my personal collection of productivity agents - my "agent dotfiles." Fork it, adapt it, make it yours.

## Install portable skills

### Prerequisites

- Node.js for the `skills` installer
- A compatible local agent such as Claude Code, Codex, or Pi
- Nix when using the repository's pinned Himalaya runtime

Install the email skill globally for Claude Code, Codex, and Pi:

```bash
npx skills add jordangarrison/agents --skill email -g \
  -a claude-code -a codex -a pi
```

The skill may activate from a natural-language email request. Invoke it
explicitly as `$email` in Codex or `/skill:email` in Pi.

The email skill requires Himalaya v1.2.0 with keyring and OAuth2 support. Run
the tested package without installing it:

```bash
nix run github:jordangarrison/agents#himalaya -- --version
```

Or install it into the current Nix profile:

```bash
nix profile install github:jordangarrison/agents#himalaya
```

Account setup and provider-specific authentication are documented in the
skill's [provider reference](skills/email/references/providers.md).

## Install the Claude Code plugin

The plugin adds the repository's Claude-specific slash commands and exposes the
same root skills to Claude Code.

### Prerequisites

- [Claude Code](https://claude.ai/code) installed
- A Todoist account for task management
- An Atlassian Cloud account for backlog grooming

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
| `/jagents:backlog-kill <project>` | Interactively review and close unwanted backlog items |
| `/jagents:inbox-process` | Process inbox items using GTD methodology with AI suggestions |
| `/jagents:weekly-review` | Comprehensive weekly review following GTD/Redeeming Your Time methodology |

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

### Portable Skills

The `email` skill manages multiple Himalaya accounts:

```
"Check my email"
"Any new mail?"
"Search all inboxes for the quarterly report"
"Draft an email to Alex"
```

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

The `video-to-docs` skill activates when you provide a video file to document a
workflow or application:

```
"Document this video walkthrough"
"Create docs from this MP4"
```

The `adversarial-workflows` skill activates when orchestrating multi-agent
implementation work at scale.

## Available Agents

| Domain | Status | Backend |
|--------|--------|---------|
| Tasks (todo) | ✅ Available | Todoist |
| Backlog (backlog) | ✅ Available | Atlassian/Jira |
| Docs (video-to-docs) | ✅ Available | Video frames + transcription |
| Orchestration (adversarial-workflows) | ✅ Available | Multi-agent |
| Email (email) | ✅ Available | Himalaya IMAP/SMTP |
| Notes (notes) | 📋 Planned | Obsidian |
| Git (git) | 📋 Planned | GitHub |

## Architecture

This project uses three complementary surfaces:

- **Agent Skills**: Portable interactive workflows shared by Claude Code,
  Codex, Pi, and other compatible agents
- **Claude Code plugin**: Claude-specific distribution and slash commands
- **SDK packages**: Programmatic automation, uses API key (for CI/automation)

Portable skills live in `skills/`. Harness-specific metadata belongs in
adapter files such as `skills/<name>/agents/openai.yaml`, not in the shared
instructions. Commands use generic names (`todo-*`) with swappable backends.

## Development

```bash
# Enter the reproducible shell
nix develop

# Validate all flake outputs, including the Himalaya feature contract
nix flake check

# Validate the Claude plugin and run package tests
claude plugin validate --strict .
bun test

# Exercise harness-local discovery
claude --plugin-dir .
pi --skill ./skills/email
```

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
