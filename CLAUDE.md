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
│   ├── todo/
│   │   └── SKILL.md
│   ├── backlog/
│   │   └── SKILL.md
│   ├── video-to-docs/
│   │   └── SKILL.md
│   └── adversarial-workflows/
│       └── SKILL.md
├── commands/                 # Slash commands (user-invoked)
│   ├── todo-today.md        # /jagents:todo-today
│   ├── todo-add.md          # /jagents:todo-add
│   ├── todo-complete.md     # /jagents:todo-complete
│   ├── backlog-add.md       # /jagents:backlog-add
│   ├── backlog-groom.md     # /jagents:backlog-groom
│   ├── backlog-review.md    # /jagents:backlog-review
│   ├── backlog-kill.md      # /jagents:backlog-kill
│   ├── inbox-process.md     # /jagents:inbox-process
│   └── weekly-review.md     # /jagents:weekly-review
├── packages/                 # SDK agents (programmatic)
│   ├── core/
│   ├── jira/
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

# Run SDK agents
bun run todoist
bun run jira
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

- `/jagents:todo-today` - Show tasks due today
- `/jagents:todo-add <task>` - Add a task
- `/jagents:todo-complete <task>` - Mark a task as complete
- `/jagents:backlog-add <item>` - Add an item to the backlog
- `/jagents:backlog-groom <project>` - Start a backlog grooming session
- `/jagents:backlog-review <project>` - Review backlog items for a project
- `/jagents:backlog-kill <project>` - Interactively review and close unwanted backlog items
- `/jagents:inbox-process` - Process inbox items using GTD methodology with AI suggestions
- `/jagents:weekly-review` - Comprehensive weekly review following GTD/Redeeming Your Time methodology

### Skills (Auto-Invoked)

- `todo` - activates when you mention tasks or task management.
- `backlog` - activates when you mention backlog grooming, prioritization, or sprint prep.
- `video-to-docs` - activates when you provide a video file to document a workflow or app.
- `adversarial-workflows` - activates when orchestrating multi-agent implementation work at scale.

## Plugin Development

### Versioning and Cache Management

**CRITICAL**: Bump the plugin version in `.claude-plugin/plugin.json` on EVERY commit that touches plugin files. This is required for changes to take effect.

Claude Code caches plugins by version number. Without a version bump, it will continue using the cached version even after changes are committed and pushed.

CI enforces this: `.github/workflows/plugin-version-check.yml` fails any push/PR that changes `commands/`, `skills/`, `hooks/`, or `.claude-plugin/` without also changing the `version` in `plugin.json`.

**Version Bump Required For** (bump on EVERY push):
- Adding/modifying commands (`commands/*.md`)
- Adding/modifying skills (`skills/**/*.md`)
- Modifying hooks (`hooks/hooks.json`)
- Changes to `plugin.json` manifest
- Any file that affects plugin behavior

**Semantic Versioning**:
- `patch` (0.1.x): Bug fixes, hook permission additions, small tweaks
- `minor` (0.x.0): New commands or skills
- `major` (x.0.0): Breaking changes, renamed commands, removed features

**Process**:
1. Make your changes to plugin files
2. **ALWAYS** bump `version` in `.claude-plugin/plugin.json` before committing
3. Commit and push changes
4. Plugin will reload with new version automatically

**Example**:
```json
{
  "name": "jagents",
  "version": "0.4.0",  // Minor bump: added new skills and commands
  ...
}
```

### Plugin Manifest Rules

The `.claude-plugin/plugin.json` manifest has specific validation rules:

- **Do NOT include** `permissions` field (not supported in manifest)
- **Do NOT include** explicit `hooks` reference if using standard `hooks/hooks.json` (auto-loaded)
- **Only reference** additional hook files in manifest if needed beyond the standard location

**Valid Manifest Structure**:
```json
{
  "name": "jagents",
  "version": "0.4.0",
  "description": "...",
  "author": { "name": "..." },
  "repository": "...",
  "license": "MIT",
  "keywords": [...],
  "commands": "./commands/",
  "skills": "./skills/"
}
```

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
