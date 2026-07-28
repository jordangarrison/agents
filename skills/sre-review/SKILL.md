---
name: sre-review
description: "Post or bump a pull request in the Flocasts daily SRE review thread in #infra-private. Use when the user asks to submit a PR for SRE review, post it in the daily thread, or add the approved review-status reactions."
---

# SRE review thread

Post one PR link as a reply to the daily bot-created review thread. Preview and
require explicit confirmation before any visible Slack write.

## Workspace conventions

- Workspace: Flocasts
- Channel: `#infra-private`
- Channel ID: `CF7SPS45P`
- Thread marker: a same-day bot message containing `review thread` and
  `:thread:` (case-insensitive)
- Reply: `<short description>: <GitHub PR URL>`
- Time zone: `America/Chicago`
- Review reactions: `eye-twitch` for in progress, `mega-approved` for approved,
  `reverse` for comment, `dumpsterfire` for requested changes, and `travolta`
  for a genuinely stale review request

Runtime state belongs in:

```bash
CACHE_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}/jagents/sre-review"
```

Use `thread.json` for `{date, thread_ts, permalink}` and `identity.json` for
opaque Slack identity metadata. Never store tokens or message bodies.

## Required capabilities

Use available Slack connector operations by capability: channel history, thread
read, threaded send, and reaction add. Do not assume harness-specific tool
names. If a needed capability or Slack access is unavailable, stop and name the
missing capability.

## Post flow

1. Resolve the PR from an explicit URL or the current branch. Prefer connected
   GitHub metadata; fall back to `gh pr view`.
2. Format one line only. Do not add mentions or rich formatting.
3. Read a same-day cache entry or scan the channel for the latest matching bot
   thread. Write cache only after a valid match. Never fall back to a top-level
   post.
4. Show channel, thread permalink, and exact message. Require explicit yes.
5. Send as a thread reply. If a cached thread is missing, invalidate the cache,
   rescan once, and retry once.

## Reactions

Reaction writes also require exact target resolution and preview.

- Add `travolta` only when the post has no review-status reaction, GitHub shows
  no review activity, and enough time has passed to make the request stale.
- For SRE-thread reviews run through `multi-agent-pr-review`, add `eye-twitch`
  to the PR reply when review begins. After the authorized GitHub review posts,
  add exactly one matching verdict reaction.
- Never add a verdict reaction before its GitHub review exists.
- Never use thread reactions for ad-hoc PR URLs not found in this thread.

See [references/thread-lookup.md](references/thread-lookup.md) for cache and
failure details.
