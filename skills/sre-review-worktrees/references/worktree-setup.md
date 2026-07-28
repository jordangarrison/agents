# Worktree setup

Use the configured workspace root, never an absolute personal path.

Detect the remote default branch, then separate its remote and local names:

```bash
default_ref="$(git -C <clone> symbolic-ref refs/remotes/origin/HEAD --short)"
default_remote="${default_ref%%/*}"
default_branch="${default_ref#*/}"
```

Require a clean clone before:

```bash
git -C <clone> fetch --all --prune
git -C <clone> switch "$default_branch"
git -C <clone> pull --ff-only "$default_remote" "$default_branch"
```

Stop if the local default branch is absent, diverged, or checked out in another
worktree; do not create, reset, or overwrite it implicitly.

Resolve the immutable expected PR head SHA through GitHub metadata. Fetch that
exact PR head, then create a detached review worktree so a stale local branch
cannot select an older commit:

```bash
git -C <clone> fetch <remote> <pr-ref-or-head-ref>
git -C <clone> worktree add --detach <worktree-path> <expected-pr-head-sha>
test "$(git -C <worktree-path> rev-parse HEAD)" = "<expected-pr-head-sha>"
```

For a fork, fetch the upstream repository's PR ref or the fork remote's exact
head. Do not assume `origin/<head-branch>` exists.

If the worktree already exists, require it to be clean and confirm it was
created for the same PR. Update it to the expected detached SHA only after
confirmation, then verify exact equality. Stop on a path/PR conflict.

Never copy `.env`, `.env.local`, or `.envrc` for a fork or otherwise untrusted
PR. For a trusted same-repository PR, list filenames without contents, confirm
each destination is ignored with `git check-ignore`, and require separate
opt-in. Copy only absent files with mode `0600`; compare existing destinations
and stop on differences. After copying `.envrc`, separately preview and confirm
`direnv allow <worktree-path>`.
