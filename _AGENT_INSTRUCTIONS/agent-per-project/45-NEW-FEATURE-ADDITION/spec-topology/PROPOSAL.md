---
tier: project
scope: proposal
owner: agent-per-project
last_reviewed: 2025-11-06
source_of_truth: doc
links:
  - ./rationalize-next-spec-system.txt
tests: []
---

# Feature Brief - Spec Topology Modularization

**Goal**: Modularize cassette spec child-resolution topology so it scales with
more spec variants, without changing public APIs or runtime behavior.

**Scope**:
- In: Refactor `CassetteSpec.childSpec()` implementation into topology modules
  under `lib/essentials/sidebar/domain/entities/cascade/` with a thin delegator
  and explicit cross-feature links.
- Out: Any change to spec meaning, feature coordinators, or runtime behavior.

**Agents**:
- Follow `_AGENT_INSTRUCTIONS/agent-per-project/30-NEW-FEATURE-ADDITION/README.md`.
- Preserve the canonical spec flow and the non-negotiable constraints in
  `rationalize-next-spec-system.txt`.

**Success**:
- `CassetteSpec.childSpec()` behavior is identical before/after.
- Public APIs and feature imports remain unchanged.
- Topology logic is split into small, coherent files with clear ownership.
- New `cascade/README.md` explains the topology concept and extension points.
