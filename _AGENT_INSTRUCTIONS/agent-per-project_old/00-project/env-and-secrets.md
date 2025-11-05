---
tier: project
scope: security
owner: @rob
last_reviewed: 2025-10-25
source_of_truth: code
links: []
tests: []
---

# Env & Secrets

**Never commit secrets.** Document *how to set* them:
- `.env` sample: `cp .env.example .env`
- macOS Keychain / pass / 1Password CLI instructions
- CI secret names & rotation policy
