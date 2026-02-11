---
tier: project
scope: tests
owner: agent-per-project
last_reviewed: 2025-11-06
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./CHECKLIST.md
  - ./DESIGN_NOTES.md
  - ./rationalize-next-spec-system.txt
tests: []
---

# Tests and Verification - Spec Topology Modularization

## Automated

- None required (behavior-preserving refactor).

## Manual Verification

- Compare `CassetteSpec.childSpec()` behavior before/after for all existing
  variants.
- Confirm cassette stack order and child transitions remain identical.
- Verify no public API changes in `cassette_spec.dart`.
- Confirm no feature imports changed.

## Notes

- Verified by mechanical move of the existing switch/when logic into
  `cascade/` modules with no conditional changes.
- If any differences appear, treat as a regression and revert the change.
