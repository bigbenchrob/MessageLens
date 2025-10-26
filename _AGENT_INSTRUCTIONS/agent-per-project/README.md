# Agent (Per-Project)

This directory lives inside your app repo and captures project-specific context.
Mount the shared repo at `agent/_shared` or similar.

Recommended layout:
- `00-project/` — overview, data locations, env setup, aggregate boundaries
- `10-features/` — per-feature briefs, prompts, decisions
- `20-migrations/` — schema history and playbooks
- `30-decisions/` — ADRs for this project
- `40-integration/` — services, pipelines, import/export
- `90-local/` — scratch notes
