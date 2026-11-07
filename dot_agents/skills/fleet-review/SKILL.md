---
name: fleet-review
description: Three parallel reviewers on a branch (requesting-code-review, code-review, ponytail-review), merged into one ranked list, walked through with you, then fed to brainstorming for your own work or drafted as feedback for someone else's.
disable-model-invocation: true
---

# Fleet review

Three reviewers read the same branch from different angles, in parallel and with fresh context, and you merge their findings into one ranked list. The fleet:

| Seat     | How it runs                                                                              | Angle                                                                       |
| -------- | ---------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| Senior   | `general-purpose` filled from `~/.claude/skills/requesting-code-review/code-reviewer.md` | Keep, simplify or drop for each commit, judged through the user's _concern_ |
| Two-axis | `general-purpose` whose first action is the Skill tool with `code-review`                | Standards (CLAUDE.md, `agent_docs/`) side by side with Spec                 |
| Ponytail | `general-purpose` whose first action is the Skill tool with `ponytail-review`            | Is each line needed, what is the smaller version, lines to delete           |

The _concern_ is the specific worry the user wants the review to test, for example "is this over-engineered", backed by evidence such as a past pushback quoted word for word. Every seat gets it. Without one, the seats return generic reviews that agree with each other.

## Steps

1. Pin the range. `git fetch origin main`, then `BASE=$(git merge-base origin/main HEAD)` and `HEAD_SHA=$(git rev-parse HEAD)`. Record `git diff --stat $BASE...HEAD` and `git log --oneline $BASE..HEAD`. Done when both SHAs resolve and the diff is non-empty.
2. Gather the spec and the concern. Fetch the ticket the branch name points at (Jira via the Atlassian tools) for the spec. Fetch any ticket or thread the user cites as the concern's evidence, and quote the reviewer's words exactly. Note which commits came from bot reviews (Copilot) according to their commit messages. Done when you can state the spec in two sentences and the concern in one.
3. Dispatch all three seats in one message, `model: opus`, running in the background. Each prompt is the shared brief below plus its seat line from the table. Then tell the user what is running and which files or commits the diff stat says to watch, and end the turn.
4. Relay each report as it lands: its verdict, plus only what it adds beyond the reports already relayed. A pending seat is "still running".
5. Spot-check before merging. For every finding you will recommend acting on, verify it with a cheap read (`grep`, `sed -n`, `git show`). Run the checks in "Reviewer blind spots" below on each cut. Done when every recommended finding has been confirmed or corrected.
6. Merge into the report shape below.
7. Walk the findings with the user, one prompt per decision, following the "Asking questions" rules in `~/.config/AGENTS.md`. Go in the merged report's rank order:
   - Each ranked cut gets its own prompt. Write its context as text first: what the commit does, the reviewers who flagged it, your spot-check result, and the current and proposed shape. Then offer the real choices (for example cut, keep, or move to its own PR), with your recommendation first.
   - The small fixes share one multi-select prompt, since they need no real thought. Mark each fix you recommend with "(Recommended)" and give the reason in its description, and say in the description why you would skip the others.
   - When an answer changes a later finding, say how before you ask about it. For example, keeping a commit can make a fix for it moot.
   - Done when every ranked cut and small fix has an answer.
8. Hand off the decisions. List them in one block: each finding, the choice made, and the reason. Include the spec, the concern and the spot-check corrections. Where the block goes depends on whose work it is (the PR author or branch committer compared with `gh api user --jq .login`, or what the user said):
   - The user's own work: invoke the Skill tool with `brainstorming` and pass the block as its args, so the design starts from what the walkthrough settled. The brainstorming skill owns the design and any implementation that follows. Commit or push only when the user asks.
   - Someone else's work: skip brainstorming, since nothing gets built. Draft the feedback the decisions call for, in the format the user wants (a pending PR review with inline comments, or a Slack message). Write it with `writing-style-github-collaboration` under the draft rule at the top of `~/.config/AGENTS.md`, and post nothing until the user approves the final text.

## Shared brief

```
Repo: <absolute worktree path>. Read CLAUDE.md and the agent_docs/ file for the area.
Range: <BASE>..<HEAD_SHA> (merge-base with origin/main). Ignore content that arrived
through merges from main; inspect the branch's own commits with `git show <sha>`.
Spec (<ticket>): <two sentences>.
Concern: <one sentence>. Evidence: "<exact quote>". Judge each commit against the concern
and name the simpler alternative with a rough line count.
Bot-review commits: <sha list>.
Read-only: do not edit files, move HEAD, build, or run tests.
Cite file:line for every finding, with a severity, and list what you did not check.
```

## Reviewer blind spots

Reviewers judge from the diff. Before you recommend a cut, check each of these:

- Origin. A change called "new" or "intrusive" may extend a mechanism already on main. Run `git grep <symbol> $BASE` and `git log --format='%h %ad %s' -- <file>` to find where it came from. Report what is new and what already existed, since that can flip a recommendation from "split it out" to "keep it and disclose it".
- Load-bearing behaviour. A simplification can break a test that depends on the current behaviour, for example a timing gap between two timeouts. Grep the smoke and regression tests for the constant or message before you cut.
- Precedent. A pattern flagged as speculative may already exist elsewhere in the repo (`grep -rn` for the same construct). The cut can still be right, but tell the user so they can answer "we do this in X".

## Merged report

1. Consensus. One or two lines covering what every seat agreed on, including "no correctness bugs" when that holds.
2. Ranked cuts. A table with these columns: #, commit(s), flagged by, recommendation with its reason, lines. Rank by how likely the user's concern is to object. A finding flagged by all three seats goes first, and the table says so.
3. Keep. Commits the seats agreed are needed, one line each.
4. Small fixes. These hold whichever cuts the user picks, with file:line for each.
5. Spec gaps for the PR description.
6. Not checked by any seat
7. Corrections. Anything a seat claimed that your spot-check disproved, with the evidence.
