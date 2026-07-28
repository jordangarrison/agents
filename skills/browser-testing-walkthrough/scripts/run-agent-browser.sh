#!/usr/bin/env bash
set -euo pipefail

if command -v agent-browser >/dev/null 2>&1; then
  exec agent-browser "$@"
fi

if command -v npx >/dev/null 2>&1; then
  exec npx --yes agent-browser "$@"
fi

printf 'agent-browser and npx are unavailable.\n' >&2
exit 69
