#!/bin/sh
# Refresh Noah's writing-style skills into ~/.claude/skills via the repo's
# canonical install-skills.sh, the single home of the fetch logic.
#
# The run_onchange_ prefix reruns this whenever the file contents change, so
# bump the version marker to force a refresh on the next apply. Fail soft so a
# machine without gh still applies cleanly.
#
# version: 2026-06-10.2

set -u

command -v gh >/dev/null 2>&1 || {
  echo "chezmoi: gh not found, skipping writing-style skill refresh" >&2
  exit 0
}

gh auth status >/dev/null 2>&1 || {
  echo "chezmoi: gh not authenticated, skipping writing-style skill refresh" >&2
  exit 0
}

# Pipe the canonical installer rather than reimplement its loop. || true keeps
# a refresh hiccup from failing the whole apply.
gh api "repos/noahbaculi/noah-writing-style/contents/scripts/install-skills.sh?ref=claude-skills" \
  -H "Accept: application/vnd.github.raw" | sh || true
