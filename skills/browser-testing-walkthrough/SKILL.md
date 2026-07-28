---
name: browser-testing-walkthrough
description: Manually test a web feature with agent-browser, recording a WebM walkthrough, screenshots, and an optional GIF. Use when the user asks for browser testing, exploratory QA, a visual walkthrough, screenshots, a recorded demo, or a reproducible browser bug report.
---

# Browser testing walkthrough

Use `agent-browser` to test the requested flow as a user would. Record evidence
and report bugs. Do not modify application code unless the user explicitly asks
for fixes.

## Prepare

1. Require `agent-browser`. If unavailable, use `npx agent-browser` when
   permitted or explain the missing runtime.
2. Read the installed CLI guide with `agent-browser skills get core`; it is the
   authority for the installed version.
3. Derive an isolated session:

   ```bash
   SESSION="$(agent-browser session id --scope worktree --prefix browser-walkthrough)"
   ```

4. Choose output paths inside the project or a temporary directory. Never put
   credentials, tokens, or private data in screenshots or recordings.

## Record and test

Open the starting page, then begin recording before the tested interactions:

```bash
agent-browser --session "$SESSION" open <url>
agent-browser --session "$SESSION" record start <walkthrough.webm>
agent-browser --session "$SESSION" snapshot -i
```

Use the snapshot-and-ref loop:

1. Snapshot interactive elements.
2. Interact through the current `@eN` reference or semantic locator.
3. Wait for the expected URL, text, element, or network-idle state.
4. Re-snapshot after every page change because references become stale.
5. Capture screenshots at meaningful before/after states:

   ```bash
   agent-browser --session "$SESSION" screenshot <step.png>
   ```

Prefer condition-based waits over fixed sleeps. Use the authentication vault or
an existing restored session for secrets; never place passwords on a command
line or in the report.

Test the requested happy path and named edge cases. Restore mutated test data
when safe and within scope.

Always stop recording, including after a failed flow:

```bash
agent-browser --session "$SESSION" record stop
agent-browser --session "$SESSION" close
```

## GIF conversion

Keep the WebM as the primary recording. When a GIF is requested:

```bash
scripts/webm-to-gif.sh <input.webm> <output.gif>
```

The script uses `ffmpeg` from `PATH`, or
`nix run nixpkgs#ffmpeg --` when `ffmpeg` is unavailable.

## Report

Provide:

- flows attempted and pass/fail result;
- expected versus actual behavior for each bug;
- exact reproduction steps;
- screenshots and WebM/GIF paths;
- relevant console or network evidence when captured;
- any data restored or left changed.

Do not silently fix a discovered bug. If fixes were not requested, stop after
diagnosis and evidence.
