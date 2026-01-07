# Contributing to Agents

Thanks for your interest in contributing! This document outlines how to get started.

## Development Setup

### Prerequisites

- [Nix](https://nixos.org/download.html) (for reproducible dev environment)
- [direnv](https://direnv.net/) (optional, for automatic environment loading)

### Getting Started

```bash
# Clone the repository
git clone https://github.com/jordangarrison/agents.git
cd agents

# Enter the dev environment
nix develop

# Install dependencies
bun install

# Run tests
bun test
```

### Testing the Plugin Locally

```bash
# Start Claude Code with the plugin loaded
claude --plugin-dir .

# Verify commands are available
/help
```

## Project Structure

```
agents/
├── .claude-plugin/          # Plugin manifest
│   └── plugin.json
├── skills/                   # Skills (auto-invoked by Claude)
│   └── <domain>/
│       └── SKILL.md
├── commands/                 # Slash commands (user-invoked)
│   └── <domain>-<action>.md
├── packages/                 # SDK agents (programmatic use)
│   ├── core/                # Shared utilities
│   └── <implementation>/    # Specific implementations
└── CLAUDE.md                # Claude Code guidance
```

## Adding a New Agent

### 1. Plugin (Interactive Use)

Create a skill and commands for interactive use:

**Skill** (`skills/<domain>/SKILL.md`):
```yaml
---
name: <domain>
description: What this skill does. When to use it.
---

# Domain Name

Instructions for Claude on how to use this skill.
```

**Commands** (`commands/<domain>-<action>.md`):
```yaml
---
description: Short description for /help
---

# Action Name

Instructions for what this command does.

## Arguments
What $ARGUMENTS contains.

## Implementation
How to accomplish the task (which MCP to use, etc.)
```

### 2. SDK Package (Automation)

Create a package for programmatic use:

```bash
mkdir -p packages/<name>/src
```

Required files:
- `packages/<name>/package.json` - with `@agents/core` dependency
- `packages/<name>/src/agent.ts` - agent definition
- `packages/<name>/src/index.ts` - exports and CLI entry
- `packages/<name>/src/agent.test.ts` - tests

## Design Principles

1. **One agent, one responsibility** - Each agent handles a single domain
2. **Official MCPs first** - Use official MCP servers when available
3. **Interface over implementation** - Generic command names, swappable backends
4. **Test everything** - All packages should have tests

## Code Style

- TypeScript for all packages
- Use Bun's built-in test runner
- Tests colocated with source (`*.test.ts` next to `*.ts`)

## Commit Convention

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add new jira-create command
fix: handle empty task list in todo-today
docs: update README with new examples
test: add tests for config loading
refactor: extract MCP config to shared module
```

## Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/my-feature`)
3. Make your changes
4. Run tests (`bun test`)
5. Commit with conventional commit message
6. Push and open a PR

## Testing

```bash
# Run all tests
bun test

# Run specific package tests
bun test packages/core

# Watch mode
bun test --watch
```

### What to Test

- Core utilities and config loading
- Agent configurations are valid
- Command parsing logic
- Composition/pipeline behavior

### What NOT to Test

- MCP server internals (tested by providers)
- External API responses (mock at boundaries)

## Questions?

Open an issue for questions or discussion.
