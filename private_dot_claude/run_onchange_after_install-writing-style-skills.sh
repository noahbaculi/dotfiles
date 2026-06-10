#!/bin/sh
# Install or refresh Noah's writing-style skills into ~/.claude/skills.
#
# The run_onchange_ prefix makes chezmoi rerun this whenever the file contents
# change, so bump the version marker below to force a refresh on the next apply.
# A first apply on a new machine runs it automatically. Fail soft so a machine
# without gh still applies cleanly.
#
# version: 2026-06-10.1

set -u

REPO="noahbaculi/noah-writing-style"
BRANCH="claude-skills"
DEST="$HOME/.claude/skills"

if ! command -v gh >/dev/null 2>&1; then
  echo "chezmoi: gh not found, skipping writing-style skill refresh" >&2
  exit 0
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "chezmoi: gh not authenticated, skipping writing-style skill refresh" >&2
  exit 0
fi

skills=$(gh api "repos/$REPO/contents/skills?ref=$BRANCH" -q '.[].name' 2>/dev/null || true)

if [ -z "$skills" ]; then
  echo "chezmoi: could not list writing-style skills, skipping refresh" >&2
  exit 0
fi

mkdir -p "$DEST"

for skill in $skills; do
  echo "chezmoi: installing $skill"
  mkdir -p "$DEST/$skill"
  gh api "repos/$REPO/contents/skills/$skill/SKILL.md?ref=$BRANCH" \
    -H "Accept: application/vnd.github.raw" >"$DEST/$skill/SKILL.md"
done

echo "chezmoi: writing-style skills installed to $DEST"
