# Documentation Roadmap & Best Practices

## Migration Goal

**Overarching principle**: Migrate all useful documentation from `_AGENT_CONTEXT/` into `_AGENT_INSTRUCTIONS/` (split between `agent-instructions-shared/` and `agent-per-project/`). Once complete, retire `_AGENT_CONTEXT/` and wire `.github/copilot-instructions.md` directly to `_AGENT_INSTRUCTIONS/`.

## Implementation Plan

### 1. Establish the Backbone

- **Inventory & Audit**: List every existing note in `_AGENT_INSTRUCTIONS/` and legacy `_AGENT_CONTEXT/`. Mark each as current/obsolete/needs merge.
- **Canonical TOC**: Maintain a living "map" (e.g., `_AGENT_INSTRUCTIONS/agent-per-project/README.md`) that mirrors the folder tree and links to every canonical doc. This becomes the mandatory starting point for new agents.
- **Shelve Legacy Notes**: Move superseded `_AGENT_CONTEXT/` material into an archive or import the relevant pieces into the new structure so there's only one source for each fact.

### 2. Standardize Formats

- **Frontmatter**: Adopt short YAML frontmatter on every file:
  ```yaml
  ---
  tier: project | shared
  scope: architecture | data | feature | integration
  owner: @username
  last_reviewed: YYYY-MM-DD
  source_of_truth: doc | code
  links: []
  tests: []
  ---
  ```
- **Document Types**: Define doc types (overview, playbook, reference, ADR, SOP) and keep reusable templates in `agent-instructions-shared/90-templates/`. Add a README showing when to use each template.
- **Explicit Scope**: Require "Explicit scope + last_reviewed" so automation can flag stale notes.

### 3. Create Core Knowledge Pods

For each major concern, nominate a single canonical document:

| Pod | Canonical Docs | Location |
| --- | --- | --- |
| **Environment & Tooling** | `env-and-secrets.md`, `services-and-keys.md` | `00-project/`, `40-integration/` |
| **Databases** | `data-locations.md`, `schema-reference.md`, migration playbooks | `00-project/`, `20-migrations/` |
| **Import Pipeline** | `import-orchestrator.md`, `rust-message-extractor.md` | `40-integration/` |
| **UI/Navigation** | Feature overviews, ViewSpec architecture | `10-features/chats/`, `10-features/messages/` |
| **ADRs** | Index linking each ADR to governed subsystem | `30-decisions/` |

Each pod should:
- Summarize the topic
- Link out to supporting notes
- Mark legacy alternatives as deprecated

### 4. Define Maintenance Process

- **Update Workflow**: New feature → add/update doc + link; schema change → update `schema-reference.md` + bump `last_reviewed`
- **PR Checklist**: For PRs touching core systems, verify code + docs updated and index entry touched
- **Staleness Detection**: Optional script or GitHub Action to warn when `last_reviewed` is older than threshold

### 5. Content Build-Out Roadmap

- **Documentation TODOs**: Maintain a living backlog listing missing or stale topics (Rust extractor, timeline logic, Riverpod patterns, etc.)
- **Sprint Integration**: For each sprint/feature, pick documentation items to:
  - Capture in canonical doc (using templates)
  - Link from TOC and relevant pods
  - Remove or update conflicting notes

### 6. Cross-Referencing & Discoverability

- **Internal Links**: Each doc's "Related" section points to other pods
- **Folder READMEs**: Update at each folder level to explain contents and usage
- **TOC Integration**: Ensure canonical TOC references folder READMEs

### 7. Automation (Optional)

- **Linters**: Ensure new docs have frontmatter, TOC inclusion, valid links
- **Review Reminders**: Scheduled alerts for docs with stale `last_reviewed` dates
- **Link Validation**: Verify all internal links resolve correctly

## Documentation Hygiene Best Practices

### When Creating New Documentation

1. **Choose the Right Location**
   - **Shared patterns** (DDD, Riverpod, linting) → `agent-instructions-shared/`
   - **Project-specific context** (schema, features, integrations) → `agent-per-project/`
   - Use the folder structure to guide placement (`00-project/`, `10-features/`, `20-migrations/`, etc.)

2. **Use Templates**
   - Start from templates in `agent-instructions-shared/90-templates/`
   - Include required frontmatter (tier, scope, owner, last_reviewed, source_of_truth)
   - Follow the document type conventions (overview, playbook, reference, ADR, SOP)

3. **Link Everything**
   - Add the new doc to the canonical TOC (`README.md` or `INDEX.md`)
   - Reference related documents in a "Related" or "See Also" section
   - Update folder-level READMEs to include the new entry

### When Updating Existing Documentation

1. **Single Source of Truth**
   - Never duplicate information—link to the canonical source instead
   - If merging notes, deprecate or delete the old version explicitly
   - Update all references to point to the new canonical location

2. **Maintain Metadata**
   - Bump `last_reviewed` date when making substantive changes
   - Update `links` if cross-references change
   - Adjust `source_of_truth` if code/doc ownership shifts

3. **Version Context**
   - Note when behavior changed (e.g., "As of October 2025, handles use compound_identifier...")
   - Capture migration history in appropriate playbooks
   - Link to relevant ADRs when architectural decisions drove changes

### Continuous Improvement

1. **Regular Audits**
   - Quarterly review of docs with stale `last_reviewed` dates
   - Verify links still resolve correctly
   - Check that recent code changes are reflected in docs

2. **Feedback Loop**
   - Track which docs agents struggle with or misinterpret
   - Revise unclear sections based on actual usage patterns
   - Add examples where agents repeatedly make the same mistakes

3. **Retirement Policy**
   - Archive superseded documentation rather than deleting outright
   - Keep a changelog of major documentation restructurings
   - Maintain redirect notes when moving canonical sources

---

**Executing this plan stepwise ensures each addition fits the larger map, inherits proper metadata, and stays current through clear ownership and review cycles.**
