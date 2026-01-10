# CLAUDE.md

This file provides guidance to Claude Code when working with this agents codebase.

## Project Overview

A personal micro agents codebase with a **hybrid architecture**:
- **Claude Code Plugin** (skills/commands) - Interactive use via CLI, uses subscription
- **SDK Packages** - Programmatic automation, uses API key

Each agent follows the Unix philosophy: do one thing well, compose small tools together.

## Architecture

### Hybrid Structure

```
agents/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest (name: jagents)
├── skills/                   # Skills (auto-invoked by Claude)
│   └── todo/
│       └── SKILL.md
├── commands/                 # Slash commands (user-invoked)
│   ├── todo-today.md        # /jagents:todo-today
│   ├── todo-add.md          # /jagents:todo-add
│   └── todo-complete.md     # /jagents:todo-complete
├── packages/                 # SDK agents (programmatic)
│   ├── core/
│   └── todoist/
├── flake.nix
└── package.json
```

### Interface vs Implementation

Commands use generic names (`todo-*`) but implement with specific backends:
- `todo-*` commands → Todoist MCP (current implementation)
- Future: could swap to different task management system

### When to Use What

| Use Case | Approach | Cost |
|----------|----------|------|
| Interactive daily use | Skills/Commands | Subscription |
| Automation/CI | SDK packages | API key |
| Quick task operations | `/jagents:todo-*` | Subscription |
| Headless batch jobs | `bun run todoist` | API key |

### Design Principles

1. **One agent, one responsibility**: Each agent handles a single domain
2. **Official MCPs first**: Use official MCP servers when available
3. **Hybrid by default**: Support both interactive and programmatic use
4. **Interface over implementation**: Generic commands, swappable backends

### MCP Strategy

| Domain | MCP Server | URL |
|--------|-----------|-----|
| Tasks (todo) | Doist/todoist-ai | https://ai.todoist.net/mcp |
| Backlog (jira) | Atlassian Remote MCP | https://mcp.atlassian.com/v1/sse |

## Development

### Prerequisites

- Nix (for reproducible dev environment)
- direnv (optional, for automatic environment loading)

### Getting Started

```bash
# Enter dev environment
nix develop

# Install dependencies
bun install

# Test the plugin locally
claude --plugin-dir .

# Run SDK agent
bun run todoist
```

### Setting Up Todoist MCP

```bash
# Add the MCP server
claude mcp add --transport http todoist https://ai.todoist.net/mcp

# Authenticate (run inside Claude Code)
/mcp
```

### Setting Up Atlassian MCP

```bash
# Add the MCP server
claude mcp add --transport sse atlassian https://mcp.atlassian.com/v1/sse

# Authenticate (run inside Claude Code)
# This will trigger an OAuth 2.1 browser flow
/mcp
```

Note: The Atlassian MCP server uses OAuth 2.1 authentication and requires you to log in with your Atlassian account. Access is scoped to your Jira, Confluence, and Compass permissions.

### Environment Variables

Copy `.env.example` to `.env`:
- `TODOIST_API_TOKEN`: For SDK automation (get from todoist.com/prefs/integrations)
- `ANTHROPIC_API_KEY`: For SDK automation (if not using CLI)

## Plugin Usage

### Available Commands

After loading the plugin (`claude --plugin-dir .`):

- `/jagents:todo-today` - Show today's tasks
- `/jagents:todo-add <task>` - Add a task
- `/jagents:todo-complete <task>` - Complete a task

### Skills (Auto-Invoked)

The `todo` skill activates automatically when you mention tasks or task management.

## Adding New Agents

### For Interactive Use (Plugin)

1. Create skill: `skills/<domain>/SKILL.md`
2. Create commands: `commands/<domain>-*.md`
3. Update `plugin.json` if needed

### For Automation (SDK)

1. Create package: `packages/<implementation>/`
2. Add `package.json` with `@agents/core` dependency
3. Create `src/agent.ts` with agent definition
4. Add run script to root `package.json`

## Testing

### Running Tests

```bash
bun test                    # All tests
bun test packages/core      # Specific package
bun test --watch           # Watch mode
```

### Test Structure

Tests colocated with source:
```
packages/core/src/
├── config.ts
└── config.test.ts
```

## Git Conventions

- Use conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`
- Push with `pu` alias
- Include ticket numbers when relevant
