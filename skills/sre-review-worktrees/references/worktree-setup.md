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

Fetch the PR head explicitly. For a same-repository branch, create:

```bash
git -C <clone> worktree add <worktree-path> <head-branch>
```

For a fork, fetch the PR ref or remote head into a uniquely named local branch;
do not assume `origin/<head-branch>` exists.

If the worktree already exists, require it to be clean and confirm its branch
matches the PR head branch. Fast-forward it only when its HEAD is an ancestor of
the current PR head; stop on divergence or a path/branch conflict.

Copy only files that exist: `.env`, `.env.local`, and `.envrc`. Never print
their contents or overwrite a destination. If a destination exists, compare it
and stop on differences. After copying `.envrc`, preview
`direnv allow <worktree-path>` and require separate confirmation before running
it.
