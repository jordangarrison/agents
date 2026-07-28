# Thread lookup

Compute dates in `America/Chicago`. A valid `thread.json` entry must match
today's `YYYY-MM-DD` and contain a plausible Slack timestamp.

On cache miss:

1. Read roughly one workday of channel history.
2. Keep same-day bot-authored messages whose text contains `review thread`.
3. Require literal `:thread:` in the text.
4. Pick the latest timestamp.
5. Store only date, parent timestamp, and permalink.

If none match, stop with:

```text
No SRE review thread found for today in #infra-private; the bot may not have
posted yet.
```

If a send returns thread-not-found or message-not-found, remove only
`thread.json`, rescan, and retry once. Never delete the whole cache directory.
