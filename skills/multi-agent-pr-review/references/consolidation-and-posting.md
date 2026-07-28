# Consolidation and posting

## Consolidated report

```markdown
## verdict
APPROVE | COMMENT | REQUEST_CHANGES

## body
Complete GitHub review body.

## inline
- path: path/to/file
  side: RIGHT | LEFT
  line: 123
  start_line: optional
  body: Complete inline comment.

## verification
- Claim and evidence the parent must independently verify.

## dissent
- Material unresolved reviewer disagreement, or "none".
```

Verdict rules:

- `APPROVE`: no introduced blocking regression.
- `COMMENT`: material non-blocking concern or uncertain recommendation.
- `REQUEST_CHANGES`: demonstrated introduced bug, security gap, broken
  bootstrap, data risk, or contract break.

Before preview, verify inline paths are changed and line anchors occur in the
current patch. Limit inline comments to actionable findings. Summary must stand
on its own.

## GitHub API fallback

Write a JSON payload outside the repository:

```json
{
  "event": "COMMENT",
  "body": "Complete review body",
  "commit_id": "<signed-off-head-sha>",
  "comments": [
    {
      "path": "path/to/file",
      "side": "RIGHT",
      "line": 123,
      "body": "Complete inline body"
    }
  ]
}
```

Post only after sign-off:

```bash
gh api --method POST \
  repos/<owner>/<repo>/pulls/<number>/reviews \
  --input <payload.json>
```

Use `LEFT` for deleted lines. Add `start_line` and `start_side` only for
multi-line comments. Never reuse a payload after the head SHA changes.
