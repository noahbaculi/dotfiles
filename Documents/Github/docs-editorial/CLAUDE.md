# docs-editorial container (personal notes)

This folder is not a checkout. `.bare` holds the repo, and each worktree is a subfolder named after its branch. Run git commands inside a worktree. Branch from and target `develop`, the repo's default branch.

Agent drafts (review notes, PR replies, plans) go in this folder's `tmp/`, outside every worktree, so they never land in a commit.

Docs claims about aidb get checked against aidb's source at the matching release tag (`v7.9.0` and so on). The aidb repo lives at `~/Documents/Github/aidb/.bare`, with tags fetched there.
