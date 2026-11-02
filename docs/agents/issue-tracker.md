# Issue tracker: GitHub

Issues for this repo live as GitHub issues in `d1ll3x/homeops-talos`. Use the `gh` CLI for all operations.

## Conventions

- **Create an issue**: `gh issue create --title "..." --body "..." --milestone <M> --label needs-triage`. Use a heredoc for multi-line bodies.
- **Read an issue**: `gh issue view <number> --json number,title,body,labels,milestone,comments`.
- **List issues**: `gh issue list --state open --json number,title,body,labels,milestone,comments --jq '[.[] | {number, title, milestone: .milestone.title, labels: [.labels[].name]}]'` with appropriate `--label`, `--milestone` and `--state` filters.
- **Make an issue a sub-issue of a parent**: `gh issue create --parent <parent> ...`, or `gh issue edit <parent> --add-sub-issue <child>` afterwards.
- **Comment on an issue**: `gh issue comment <number> --body "..."`
- **Apply / remove labels**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **Claim**: `gh issue edit <number> --add-assignee @me`. An assigned open issue is in progress.
- **Close**: `gh issue close <number> --comment "<result>, <commit SHA>"`. A PR that finishes an issue says `Closes #<number>` in its body instead.

Infer the repo from `git remote -v`; `gh` does this automatically when run inside a clone.

## Issue shape

- **Milestone**: one of `M1`…`M9` (the build milestones in [design.md](../design.md#milestones)) or `misc`.
- **Body**, in this order:
  - one-line goal
  - `Blocked by #N` lines, one per blocker, when blocked (an issue is unblocked when every blocker is closed)
  - **Files**: every file the issue creates, modifies or deletes, with its repo path, or "outside the repo: …" / "workstation only: …"
  - **Done when**: a checkable condition
  - the guided-build sections: **Learn / Write / Validate / Verify / Commit**
- **Progress** goes in comments: one dated line per result, with the commit SHA where there is one.

**Frontier** (next issue): open, unassigned, no open blocker, lowest milestone and number first.

## Pull requests as a triage surface

**PRs as a request surface: no.**

## When a skill says "publish to the issue tracker"

Create a GitHub issue.

## When a skill says "fetch the relevant ticket"

Read it as in **Read an issue** above.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a single issue with **child** issues as tickets.

- **Map**: a single issue labelled `wayfinder:map`, holding the Notes / Decisions-so-far / Fog body. `gh issue create --label wayfinder:map`.
- **Child ticket**: an issue linked to the map as a GitHub sub-issue. Labels: `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`). Once claimed, the ticket is assigned to the driving dev.
- **Blocking**: the `Blocked by #N` lines above.
- **Frontier query**: list the map's open sub-issues, drop any with an open blocker or an assignee; first in map order wins.
- **Claim**: `gh issue edit <n> --add-assignee @me`, the session's first write.
- **Resolve**: `gh issue comment <n> --body "<answer>"`, then `gh issue close <n>`, then append a context pointer (gist + link) to the map's Decisions-so-far.
