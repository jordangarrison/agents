---
name: sre-review-worktrees
description: Read the Flocasts daily SRE review thread, filter pull requests that still need review, and create isolated local worktrees for them. Use when preparing a batch from #infra-private for multi-agent PR review.
---

# SRE review worktrees

Prepare worktrees only. Do not post GitHub reviews or Slack messages.

## Configuration

- Channel ID: `CF7SPS45P` (`#infra-private`)
- Cache root:
  `${XDG_CACHE_HOME:-$HOME/.cache}/jagents/sre-review`
- Workspace root: `${FLOCASTS_DEV_ROOT:-$HOME/dev/flocasts}`
- Worktrees:
  `<workspace-root>/.worktrees/<repo>/<head-branch-with-slashes-replaced>`

Use Slack connector capabilities for channel/thread reads and reactions. If
Slack access or thread-read capability is unavailable, stop clearly.

## Select PRs

Reuse `sre-review`'s same-day `thread.json`; rescan when absent or stale. Read
all replies and extract GitHub PR URLs.

By default drop:

- replies authored by the current Slack user;
- bot replies;
- replies with `mega-approved`;
- merged or closed PRs;
- drafts;
- PRs with a GitHub approval.

Resolve current identity through a Slack current-user/profile capability. If
unavailable, ask for an email and use user search. Cache only the opaque Slack
user ID and email in `identity.json`. Never embed personal identity in this
skill.

Keep PRs carrying `reverse` or `dumpsterfire`, and surface those reactions in
the plan. Prefer connected GitHub metadata; use `gh pr view` for missing fields.

Show kept and dropped PRs with reasons. Require explicit confirmation before
creating worktrees.

## Create worktrees

Read [references/worktree-setup.md](references/worktree-setup.md), then:

1. Group kept PRs by repository.
2. Verify each main clone exists and is clean.
3. Fetch and fast-forward its detected remote default branch.
4. Fetch each PR head and create or refresh its worktree.
5. Copy existing `.env`, `.env.local`, and `.envrc` files from the main clone.
   These remain local and untracked.
6. Run `direnv allow` when `.envrc` was copied and `direnv` is available.
7. Report PR, path, copied files, and current head SHA.

Different repositories may run in parallel. Sequence worktree mutations within
one repository.

Stop for dirty clones, unresolved fork refs, conflicting worktree paths, or
more than ten kept PRs without renewed confirmation. When setup completes,
offer `multi-agent-pr-review` for the selected PR URLs.
