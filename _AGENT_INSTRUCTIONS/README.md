# _AGENT_INSTRUCTIONS

This directory holds all AI and agent-related documentation.

## Structure

_AGENT_INSTRUCTIONS/
├─ agent-instructions-shared/ # Submodule: reusable global rules (DDD, Riverpod, linting)
├─ agent-per-project/ # Local notes specific to this project

## Updating the shared rules

cd _AGENT_INSTRUCTIONS/agent-instructions-shared
git pull origin main
cd ../../
git add _AGENT_INSTRUCTIONS/agent-instructions-shared
git commit -m "Update shared agent instructions"


## Local-only notes
Everything in `agent-per-project/` stays project-specific and should never be pushed to the shared repo.
