---
name: multi-agent-pr-review
description: Review one or more GitHub pull requests with parallel specialist agents, an independent simplicity reviewer, and a consolidator. Use when the user asks for a multi-agent, expert, thorough, or domain-focused PR review and supplies PR URLs or domain hints.
---

# Multi-agent PR review

Produce evidence-backed GitHub review drafts from genuinely independent,
parallel reviewers. Never simulate multiple reviewers by doing serial passes in
one agent.

## Inputs

Accept one or more `https://github.com/<owner>/<repo>/pull/<number>` URLs.
Accept optional per-PR domain hints, omitted reviewers, or added specialist
roles.

Accept `--skip-validation` as an explicit fast-review flag. It skips optional
test commands, focused runtime checks, and external documentation lookup. It
does not skip diff inspection, introduced-versus-pre-existing attribution,
blocking-claim evidence, inline-anchor validation, PR state/head rechecks,
preview, or per-PR posting sign-off.

Skip merged PRs. Skip drafts unless explicitly requested. Do not approve the
current user's own PR.

## Gather context

Prefer a connected GitHub provider for PR metadata, changed files, patch,
comments, checks, and head SHA. Use `gh` for unavailable operations, especially
creating a GitHub review with inline comments.

For each PR:

1. Record URL, author, state, draft status, base, head, head SHA, title, body,
   changed files, and diff.
2. Establish whether findings are introduced by the PR. Pre-existing problems
   are not blocking regressions.
3. Choose one to four domain specialists based on the diff. Always add an
   independent simplicity reviewer.
4. Give each reviewer the same PR context and one focused prompt from
   [references/reviewer-prompts.md](references/reviewer-prompts.md).

Set `{VALIDATION_POLICY}` in every prompt:

- default: run focused read-only checks and consult primary documentation when
  needed to validate material claims;
- with `--skip-validation`: use static diff and surrounding-code evidence only,
  run no validation commands or documentation lookup, and label findings as
  statically reviewed but not independently validated.

## Delegation boundary

Use this order:

1. Native subagents or task delegation supported by the active harness. Launch
   all phase-one reviewers in parallel.
2. Herdr only when the user explicitly requested Herdr or confirms the fallback
   after being told native delegation is unavailable.
3. Otherwise stop and explain that real multi-agent execution is unavailable.

Never run reviewer prompts serially in the parent and call that multi-agent
work.

For Herdr, read
[references/herdr-fallback.md](references/herdr-fallback.md) before acting.
Launch the same harness as the parent in unfocused sibling panes. Track every
pane created for this run. Close only those panes, and only after their reports
have been captured and consolidated.

## Review phases

### Phase one: independent reports

Launch specialists and the simplicity reviewer together. Require each report to
include:

- only correctness, security, regression, operability, or material design risks;
- file and line evidence;
- whether the issue is introduced by this PR;
- a concrete fix;
- confidence and validation performed.

Drop style preferences and cosmetic nits.

### Phase two: consolidation

After all phase-one reports complete, launch one separate consolidator. Give it
every report plus PR context. It must deduplicate, reject unsupported claims,
separate blocking regressions from non-blocking notes, and produce the schema in
[references/consolidation-and-posting.md](references/consolidation-and-posting.md).

The parent independently verifies every proposed blocking claim and every
inline anchor. An inline line must be part of the current diff hunk. Move
unanchorable findings into the summary.

With `--skip-validation`, limit this verification to the current diff and
surrounding source. Do not run commands or consult external documentation.

## Preview and sign-off

Re-fetch PR state and head SHA immediately before preview. If the head moved,
refresh the diff and revalidate affected findings.

For each PR separately, show:

- full verdict: `APPROVE`, `COMMENT`, or `REQUEST_CHANGES`;
- full review body;
- every inline comment with path, side, line, and full body;
- current head SHA.

When `--skip-validation` was used, state that prominently in the review body
and preview.

Require explicit per-PR sign-off before posting. Apply requested edits and show
the complete preview again. Never batch-sign-off or post without preview.

## Post

Prefer a connected GitHub provider if it supports full reviews with inline
comments. Otherwise use the `gh api` payload described in
[references/consolidation-and-posting.md](references/consolidation-and-posting.md).

Re-check state and head SHA once more before posting. Stop if merged, closed, or
changed since sign-off. Report the posted review URL or API result.

This skill has no Slack behavior. SRE companion skills own thread lookup and
reactions.
