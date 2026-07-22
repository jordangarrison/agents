---
name: adversarial-workflows
description: This skill should be used when orchestrating multi-agent implementation work at scale
  (large ports, migrations, mass refactors, compiler-error or test-failure
  burn-down), or when a batch of agent-written changes needs independent
  verification before merge.
---

# Adversarial workflows

Structure large agent-driven work as a loop: implement, adversarial review, apply feedback. Hard role separation plus context starvation for reviewers is what makes it work. Based on Bun's Zig-to-Rust port (6,502 commits, 64 parallel Claudes: https://bun.com/blog/bun-in-rust). Run it with Claude Code's Workflow tool or plain parallel subagents; [workflow-script-template.md](workflow-script-template.md) has a ready-to-adapt script.

## The rules

1. **Split roles absolutely.** 1 implementer, 2+ adversarial reviewers. The implementer never reviews. The reviewer never implements. A single agent checking its own work rubber-stamps itself.
2. **Starve the reviewer's context.** A reviewer gets only the diff and one job: find bugs and reasons this code does not work, assuming it is wrong. Never pass along the implementer's reasoning, summary, or commit message; it transmits their confirmation bias. For ports, a separate equivalence reviewer gets the diff plus the original source, nothing else.
3. **Adversarially review the plan before any code.** Porting guides, mapping tables, and migration plans get 2 rounds of diff-only review too. A wrong plan compounds across every fan-out agent.
4. **Trial before scale.** Hand-run 2 or 3 units through the full loop, fix the prompts, and only then fan out. Never discover a prompt bug 40 agents deep.
5. **Deterministic output is the work queue.** After a bulk pass, run the compiler or test suite, group failures by file or module, and write each group to a file; each file is one agent's assignment. This partitions work without collisions and creates a natural sync point. Zero failures is the phase gate.
6. **Guardrail the git surface.** Every agent prompt forbids `git reset`, `git stash`, `git checkout -- <file>`, force pushes, and slow commands. Parallel agents sharing a worktree WILL destroy each other's work otherwise. Isolate parallel implementers in worktrees.
7. **Reject justified workarounds.** Reviewer rule: if the code needs a paragraph-long comment explaining why the workaround is OK, the code is wrong; reject it. This is how stubs sneak through review.
8. **Tests are the spec.** Never skip, delete, or weaken a test to go green. Done means the original suite passes on every platform.
9. **Fix the loop, not the output.** The same mistake from 2+ agents is a prompt bug. Pause fan-out, add the rule (with a before/after example) to the shared guide and prompts, then mechanically re-scan completed work for that one pattern. First occurrence: code bug. Second: doc gap. Third: prompt bug.
10. **Human reads the outputs.** Spot-read diffs and reviewer verdicts; edit the workflow when a failure mode appears. The loop is the product you are iterating on.

## Common mistakes

| Mistake | Fix |
|---|---|
| One reviewer, or reviewer sees implementer's rationale | 2+ reviewers, diff only |
| Reviewing code but not the plan doc | 2 adversarial rounds on the plan before code |
| Fanning out immediately | Trial phase of 2 or 3 units |
| Agents self-assigning files | Pre-partition failures into per-agent assignment files |
| Patching each bad output by hand | Edit the workflow prompt, re-scan mechanically |
