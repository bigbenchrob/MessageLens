### Here is the next Codex prompt. I’d keep this one deliberately narrow: establish a clean branch boundary before any implementation begins.
### Please prepare the repository safely for the message-search work described in the previous audit.
### Donot begin implementing the search changes yet.
The intended branch name is:
### feature/message-text-search
Before creating it, please inspect the repository state carefully.
# Tasks
1. Report the current:
   * branch;
   * git status;
   * staged changes;
   * unstaged changes;
   * untracked files;
   * submodule state, including any modified or detached submodules;
   * commits on the current branch that have not yet been merged/pushed to the expected upstream, if that can be established safely.
2. Determine whether the current HEAD is a suitable branch point for: ### feature/message-text-search 
3. Identify any unrelated in-progress work that would accidentally be carried into the new branch.
4. Do not discard, reset, stash, commit, or otherwise alter unrelated user work merely to obtain a clean tree.
5. If the repository is already in a safe state for branching, create: ### feature/message-text-search from the current appropriate HEAD and switch to it. 
6. If creating the branch would entangle unrelated uncommitted work or otherwise produce an unsafe branch point, do not modify anything. Instead report:
   * exactly what prevents safe branching;
   * which files/submodules are involved;
   * the smallest safe action needed before the branch can be created.

⠀Important constraints
* Do not implement any search functionality.
* Do not edit source files.
* Do not create an opportunistic “cleanup” commit.
* Do not stash changes unless explicitly instructed later.
* Do not reset or discard anything.
* Preserve all unrelated worktree changes.
* Pay particular attention to shared/agent-instruction submodules or other repositories that may have independent Git state.
* If a submodule is dirty, distinguish between:
  * the superproject merely pointing at a changed submodule commit;
  * actual uncommitted work inside the submodule.

⠀Deliverable
### Return a concise report containing:
1. Current branch and HEAD
2. Worktree status
3. Submodule status
4. Whether current HEAD is a safe branch point
5. Any unrelated work that would be inherited
6. Action taken

⠀If safe, the final line should confirm:
### Now on branch feature/message-text-search
If not safe, leave the repository unchanged and explain the minimum next step.
This should prevent the search work from inheriting accidental baggage while also avoiding the more dangerous Codex instinct of “helpfully” cleaning the repository for us.
