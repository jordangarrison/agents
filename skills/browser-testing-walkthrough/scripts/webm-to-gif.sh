#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  printf 'Usage: %s <input.webm> <output.gif>\n' "$0" >&2
  exit 64
fi

input=$1
output=$2

if [[ ! -f "$input" ]]; then
  printf 'Input file does not exist: %s\n' "$input" >&2
  exit 66
fi

if command -v ffmpeg >/dev/null 2>&1; then
  ffmpeg_command=(ffmpeg)
elif command -v nix >/dev/null 2>&1; then
  ffmpeg_command=(nix run nixpkgs#ffmpeg --)
else
  printf 'ffmpeg is unavailable and nix is not installed.\n' >&2
  exit 69
fi

temporary_directory=$(mktemp -d)
trap 'rm -rf "$temporary_directory"' EXIT
palette="$temporary_directory/palette.png"

"${ffmpeg_command[@]}" -y -i "$input" \
  -vf "fps=12,scale=1280:-1:flags=lanczos,palettegen=stats_mode=diff" \
  -frames:v 1 -update 1 \
  "$palette"

"${ffmpeg_command[@]}" -y -i "$input" -i "$palette" \
  -lavfi "fps=12,scale=1280:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=sierra2_4a" \
  "$output"

printf 'Created %s\n' "$output"
