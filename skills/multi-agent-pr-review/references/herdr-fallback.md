# Herdr fallback

Use only after explicit Herdr request or confirmation. Require
`HERDR_ENV=1`. The installed `herdr --help`, `herdr agent`, and `herdr pane`
output is authoritative because command syntax varies by version.

1. Inspect live agents and panes. Resolve the current focused pane, workspace,
   harness kind, and working directory from JSON. Do not target a pane by list
   position.
2. Choose unique reviewer names. Start each reviewer with the same executable
   harness as the parent, an explicit working directory, `--no-focus`, and a
   sibling split or tab supported by the installed CLI.
3. Parse and record every returned pane ID. These are the only panes this run
   may close.
4. Send self-contained prompts. Run reviewers concurrently; do not wait for one
   before starting the next.
5. Wait for settled agent state. If blocked or unknown, inspect that agent's
   recent unwrapped output before deciding whether input is needed.
6. Capture the complete report. If terminal history truncates it, ask the
   reviewer to write Markdown under a new temporary directory and return only
   the path.
7. Start the consolidator only after all reports are captured.
8. Read and verify the consolidated output.
9. Close only pane IDs recorded in step 3, after report capture. Leave the
   parent pane, existing panes, workspaces, tabs, and server untouched.

Always preserve focus with `--no-focus`. Never stop the Herdr server. Never
close panes merely because their agents look idle.
