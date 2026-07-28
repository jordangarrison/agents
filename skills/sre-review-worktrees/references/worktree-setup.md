# Worktree setup

Use the configured workspace root, never an absolute personal path.

Detect the default branch:

```bash
git -C <clone> symbolic-ref refs/remotes/origin/HEAD --short
```

Require a clean clone before:

```bash
git -C <clone> fetch --all --prune
git -C <clone> switch <default-branch>
git -C <clone> pull --ff-only
```

Fetch the PR head explicitly. For a same-repository branch, create:

```bash
git -C <clone> worktree add <worktree-path> <head-branch>
```

For a fork, fetch the PR ref or remote head into a uniquely named local branch;
do not assume `origin/<head-branch>` exists.

If the worktree already exists, compare its branch and HEAD with the PR. Refresh
only when they match. Stop on a path/branch conflict.

Copy only files that exist: `.env`, `.env.local`, and `.envrc`. Never print
their contents. Run `direnv allow <worktree-path>` after copying `.envrc`.
