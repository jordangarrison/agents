# Workflow script template: implement, adversarial review, apply feedback

Adapt this for Claude Code's Workflow tool. It runs one loop iteration over a
pre-partitioned work list: each unit gets an implementer, then 2 diff-only
adversarial reviewers, then a fix pass if either reviewer finds real problems.
`pipeline()` keeps units independent, so unit A can be in review while unit B
is still implementing.

Build the work list BEFORE invoking Workflow (scout inline): for example, run
the compiler, group errors by file, write one assignment file per group.

```js
export const meta = {
  name: 'adversarial-port-loop',
  description: 'Implement each work unit, adversarially review with 2 diff-only skeptics, apply confirmed findings',
  phases: [
    { title: 'Implement', detail: 'one agent per work unit, isolated worktree' },
    { title: 'Review', detail: '2 adversarial diff-only reviewers per unit' },
    { title: 'Fix', detail: 'apply confirmed findings, re-review once' },
  ],
}

// args = { units: [{ id, assignment }], guide: 'path/to/PORTING.md', repo: 'path' }
const GUARDRAILS = `
HARD RULES:
- NEVER run git reset, git stash, git checkout -- <file>, or any force push.
- Commit your work with a conventional commit when done. Never amend others' commits.
- No placeholder stubs. If you cannot implement something correctly, return it in
  your "blocked" list instead of stubbing it.
- Do not modify, skip, or delete tests to make them pass.`

const FINDINGS = {
  type: 'object',
  required: ['findings'],
  properties: {
    findings: {
      type: 'array',
      items: {
        type: 'object',
        required: ['file', 'line', 'summary', 'failure_scenario'],
        properties: {
          file: { type: 'string' },
          line: { type: 'number' },
          summary: { type: 'string' },
          failure_scenario: { type: 'string', description: 'concrete input/state -> wrong behavior' },
        },
      },
    },
  },
}

const IMPL_RESULT = {
  type: 'object',
  required: ['diff', 'blocked'],
  properties: {
    diff: { type: 'string', description: 'full unified diff of the change' },
    blocked: { type: 'array', items: { type: 'string' } },
  },
}

const results = await pipeline(
  args.units,

  // Stage 1: implement
  (unit) => agent(
    `You are an IMPLEMENTER. Work in ${args.repo}. Read the guide at ${args.guide} and
follow it exactly. Your assignment:\n${unit.assignment}\n${GUARDRAILS}
Do NOT review or judge your own work. That is another agent's job.
Return the full unified diff of your change and any items you were blocked on.`,
    { label: `impl:${unit.id}`, phase: 'Implement', schema: IMPL_RESULT, isolation: 'worktree' }
  ),

  // Stage 2: two adversarial reviewers, diff only, no implementer rationale
  (impl, unit) => parallel([1, 2].map((n) => () => agent(
    `You are an ADVERSARIAL REVIEWER. Your ONLY job: find bugs and reasons this code
does not work. Assume the code is wrong until proven otherwise.
Context: ONLY this diff. Do not ask for or infer the author's intent.
Reject any workaround that needs a paragraph-long comment to justify it; if it
needs that comment, the code is wrong. Flag any stub, placeholder, or weakened test.
For each finding give file, line, and a concrete failure scenario (inputs/state ->
wrong output or crash). Do NOT implement fixes.\n\nDIFF:\n${impl.diff}`,
    { label: `review${n}:${unit.id}`, phase: 'Review', schema: FINDINGS }
  ))).then((reviews) => ({
    impl,
    findings: reviews.filter(Boolean).flatMap((r) => r.findings),
  })),

  // Stage 3: apply confirmed findings (skip if clean)
  (r, unit) => r.findings.length === 0 ? { unit: unit.id, status: 'clean' } : agent(
    `You are an IMPLEMENTER applying review feedback in ${args.repo} for unit ${unit.id}.
Fix each finding below properly. No stubs, no suppressed tests. If a finding is
wrong, explain why in your result instead of changing code.\n${GUARDRAILS}
FINDINGS:\n${JSON.stringify(r.findings, null, 2)}`,
    { label: `fix:${unit.id}`, phase: 'Fix' }
  ).then((out) => ({ unit: unit.id, status: 'fixed', findings: r.findings, out }))
)

const done = results.filter(Boolean)
log(`${done.filter((r) => r.status === 'clean').length} clean, ${done.filter((r) => r.status === 'fixed').length} fixed`)
return done
```

## After each iteration (the human part)

1. Read a sample of diffs and reviewer findings yourself.
2. Same mistake from 2+ units? Edit the guide and this script's prompts, then
   mechanically re-scan completed units for that one pattern (a cheap grep-lens
   agent per unit; do not re-review everything).
3. Re-run the deterministic check (compiler, test suite). Regroup remaining
   failures into new work units. That is the next iteration's `args.units`.
4. Phase gate: zero errors or suite green means next phase.

## Prompt fragments worth keeping verbatim

These come from the Bun Zig-to-Rust port writeup (https://bun.com/blog/bun-in-rust):

- Reviewer framing: "its context: only the diff. told to assume the code is wrong."
- Stub rejection: "If you need a paragraph-long comment to justify why the
  workaround is OK, the code is wrong. Fix the code."
- Role wall: "The implementer doesn't review. The reviewer doesn't implement."

No orchestration harness with `pipeline()`/`parallel()`? The same loop works
with plain background subagents: spawn implementers in worktrees, collect
diffs, spawn 2 reviewers per diff with only the diff in their prompt, route
findings back. The rules in SKILL.md are harness-independent.
