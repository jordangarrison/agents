---
name: sre-review-rollover
description: Repost the current user's still-unreviewed pull requests from yesterday's Flocasts SRE review thread into today's thread, or add a stale-request bump reaction. Use for SRE review rollover, yesterday's unreviewed PRs, or a travolta bump.
---

# SRE review rollover

Roll over only the current user's eligible PR replies. Never create a top-level
Slack message.

## Conventions and state

- Workspace: Flocasts
- Channel: `#infra-private`
- Channel ID: `CF7SPS45P`
- Time zone: `America/Chicago`
- Thread marker: a same-day bot-authored message containing both
  `review thread` and `:thread:` (case-insensitive)
- Cache root:
  `${XDG_CACHE_HOME:-$HOME/.cache}/jagents/sre-review`
- Thread cache: `thread.json` containing `{date, thread_ts, permalink}`; valid
  only when `date` is today's Central-time `YYYY-MM-DD` and `thread_ts` is a
  plausible Slack timestamp
- Rollover reply:
  `[rollover from <ORIGINAL_PERMALINK|yesterday>] <description>: <PR URL>`

Use Slack connector capabilities for channel history, thread read, current
profile or user search, threaded send, and reaction add. Stop and state the
missing capability when Slack access is unavailable.

Resolve current identity dynamically and store only opaque Slack user ID plus
email in `identity.json`. Do not embed personal identifiers.

## Flow

1. Find yesterday's latest bot review thread using Central-time dates and the
   marker above.
2. Read replies and keep only current-user GitHub PR posts.
3. Prefer connected GitHub metadata, falling back to `gh pr view`. Eligible PRs
   are open, non-draft, and not approved. Skip merged and closed PRs.
4. Find today's review thread, using same-day `thread.json` when valid.
5. Read today's replies and drop PR URLs already present.
6. Show yesterday/today thread links, every eligible and skipped PR, reason,
   and exact final message.
7. Require explicit confirmation.
8. Post eligible replies sequentially. On stale thread cache, invalidate only
   `thread.json`, rescan once, and retry the failed reply once.

If no yesterday thread, no current-user posts, no eligible PRs, or no today
thread exists, stop without writing Slack.

## Lighter bump

When the user requests a bump instead of rollover, apply `travolta` to the
original reply only after confirming it remains eligible and has no
`eye-twitch`, `mega-approved`, `reverse`, or `dumpsterfire` reaction. Preview
the exact target and require confirmation.

Rollover and `travolta` are alternatives for each PR; never do both.
