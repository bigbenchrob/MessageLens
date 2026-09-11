That report is exactly what we needed. I would **not** branch from `Ftr.archive-recovery`.

The search work is unrelated enough that inheriting 84 archive-recovery commits would create needless coupling. The clean path is to get back to `main`, update it to the intended baseline, and create `feature/message-text-search` from there.

The only loose end is `.vscode/settings.json`. Since it is untracked, simply changing branches will leave it in the working tree. That is not inherently dangerous, but we should understand whether it is meant to be local-only or belongs in the repo before starting feature work.

I’d give Codex this next prompt:



Please establish the new message-search feature branch from `main`, not from `Ftr.archive-recovery`.

Do not implement any search functionality yet.

## Current known state

- Current branch: `Ftr.archive-recovery`
- Current HEAD: `e2a950563b8bd02ce9cce3291e3c530c016de676`
- `Ftr.archive-recovery` is 84 commits ahead of `main`
- Tracked worktree is clean
- Untracked:
  - `.vscode/settings.json`
  - `30-SEARCH-ENHANCEMENT/`
- `agent-instructions-shared` is clean
- The search-enhancement directory is related to the new feature
- `.vscode/settings.json` appears unrelated

## Goal

Create and switch to:

`feature/message-text-search`

from the appropriate current `main` baseline.

## Instructions

1. First inspect `.vscode/settings.json`.

   Determine whether:
   - `.vscode/` or `.vscode/settings.json` is already intentionally ignored;
   - similar VS Code workspace settings are tracked elsewhere;
   - the file appears to be machine/user-specific configuration rather than project configuration.

   Do not edit, delete, move, commit, or ignore it yet.

2. Inspect the relationship between:
   - local `main`
   - its configured upstream
   - `Ftr.archive-recovery`

   If possible without altering repository state, determine whether `main` is synchronized with its local upstream tracking ref.

3. Do not merge `Ftr.archive-recovery` into `main`.

   The message-search feature should not depend on archive-recovery history merely because that happens to be the currently checked-out branch.

4. If local `main` is a suitable baseline:
   - switch to `main`;
   - create `feature/message-text-search` from `main`;
   - switch to the new branch.

5. Preserve both untracked items:
   - `.vscode/settings.json`
   - `30-SEARCH-ENHANCEMENT/`

   Do not stash or remove them simply to change branches unless Git itself prevents the checkout.

6. If switching to `main` would overwrite or otherwise endanger either untracked item, stop without altering them and report the conflict.

7. Do not:
   - merge;
   - rebase;
   - reset;
   - discard files;
   - create cleanup commits;
   - fetch or pull from the network unless explicitly necessary and permitted;
   - begin implementing search.

## Deliverable

Report:

1. `.vscode/settings.json` assessment
2. `main` and upstream relationship
3. branch point used
4. whether the untracked files were preserved
5. final branch and HEAD

If successful, finish with:

`Now on branch feature/message-text-search`

One important nuance: I would **not merge archive recovery into `main` just to enable this branch**. If archive recovery is eventually meant for `main`, that should happen on its own merits and timetable. Search should begin from the clean mainline unless Codex later identifies an actual dependency.