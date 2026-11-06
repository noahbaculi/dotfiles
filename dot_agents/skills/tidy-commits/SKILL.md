---
name: tidy-commits
description: Squash, fold, fixup, replay, or regroup a branch's unpushed commits by concern, with a backup ref and an identical-tree check. Use when asked to squash, replay, fold in fixups, or clean up commits before pushing.
---

# Tidy commits

Rewrite only the branch's unpushed commits into one commit per concern, and prove the result changed history but not content. The _backup ref_ is the safety net: every step after step 3 can be undone from it, and the final tree must match it exactly.

Shell variables do not survive between tool calls, so write the resolved values of `BASE` and `BACKUP` into the conversation as you get them and paste them as literals in later steps.

## Steps

1. Pin the range. Require a clean worktree (`git status --porcelain` prints nothing; otherwise ask the user to commit or stash). If `git rev-parse --abbrev-ref @{u}` succeeds, `BASE=$(git merge-base @{u} HEAD)`, since the upstream may have moved past the branch's fork point. Otherwise `DEFAULT=$(git symbolic-ref --short refs/remotes/origin/HEAD)` (if that ref is missing, run `git remote set-head origin --auto` first) and `BASE=$(git merge-base "$DEFAULT" HEAD)`. Then confirm nothing in `$BASE..HEAD` is pushed anywhere: `git rev-list "$BASE..HEAD" --not --remotes | wc -l` equals `git rev-list --count "$BASE..HEAD"`. If it is smaller, set `BASE` to the parent of the oldest unpushed commit, `$(git rev-list --reverse "$BASE..HEAD" --not --remotes | head -1)^`. Done when `BASE` resolves, the range is non-empty, every commit in it is unpushed, and `git rev-list --merges "$BASE..HEAD"` prints nothing (stop and tell the user if the range has merges).
2. Propose. Show `git log --reverse --format='%h %s' --stat "$BASE..HEAD"` and a regrouping by concern: each `fixup!`/`squash!` commit folds into the commit it names, commits that touch one concern merge, and a commit mixing unrelated concerns splits by path. Give each resulting commit its subject. Done when the user approves the grouping, since this rewrites history.
3. Back up. `BACKUP=refs/backup/tidy-$(git branch --show-current)-$(date +%Y%m%d-%H%M%S)`, then `git update-ref "$BACKUP" HEAD`. Done when `git rev-parse "$BACKUP"` equals `git rev-parse HEAD`.
4. Rewrite, without opening an editor. Pick the mode the grouping needs:
   - **Fold, reorder, reword**: write the full todo list, fixups already placed under their targets and hashes copied from step 2, to an absolute path with no spaces (`pick`, `fixup`, and `exec git commit --amend -m '<subject>'` after the last line of a group whose subject changes), then run `GIT_SEQUENCE_EDITOR="cp <todo-file>" GIT_EDITOR=true git rebase -i --autosquash "$BASE"`. The sequence editor replaces the todo list, so nothing waits on a terminal. On a conflict, `git rebase --abort` and report.
   - **Split by path**: `git reset --hard "$BASE"`, then for each group in order, `git restore --source="$BACKUP" -- <paths>`, `git add -- <paths>`, `git commit -m '<subject>'`. A path that belongs to two groups goes whole into the earlier one; tell the user, since splitting hunks needs interactive staging.
     Done when the rewrite finishes with no rebase in progress (`git status` shows none).
5. Verify. `git diff --quiet "$BACKUP" HEAD` exits 0. If it does not, stop: leave HEAD where it is, show `git diff --stat "$BACKUP" HEAD`, and tell the user the backup ref name so they can `git reset --hard "$BACKUP"` themselves. Done when the diff is empty and `git log --format='%h %s' "$BASE..HEAD"` matches the approved grouping.
6. Report the new log and the backup ref name. Leave pushing to the user; the branch was unpushed, so a plain push works.

Commit subjects follow the global commit rules in `~/.config/AGENTS.md` (conventional prefix, no ticket ID, no attribution trailer).
