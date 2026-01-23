---
tier: project
scope: design-notes
owner: agent-per-project
last_reviewed: 2025-11-06
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./rationalize-next-spec-system.txt
tests: []
---

# Design Notes - Spec Topology Modularization

## Objective

Modularize cassette spec child-resolution topology so it scales, while keeping
behavior and public APIs identical.

## Constraints (Non-negotiable)

- Do not move child-spec logic into feature folders.
- Do not add registries or top-down configuration.
- Do not make features aware of other features.
- Do not change public APIs or runtime behavior.

## Approach

1) Keep the `CassetteSpec` union unchanged in
   `lib/essentials/sidebar/domain/entities/cassette_spec.dart`.

2) Replace `CassetteSpec.childSpec()` implementation with a delegator in
   `cascade/cassette_child_resolver.dart`.

3) Move the existing `childSpec()` logic into per-feature topology files:

- `contacts_cassette_topology.dart`
- `messages_cassette_topology.dart`
- `handles_cassette_topology.dart`
- `sidebar_utility_topology.dart`
- `presentation_cassette_topology.dart` (if needed)
- `contacts_settings_topology.dart` (if needed)
- `contacts_info_topology.dart` (if needed)
- `sidebar_utility_settings_topology.dart` (if needed)

4) Move cross-feature transitions into explicit `links/` files (domain-only),
   e.g.:

- `links/contacts_to_messages.dart`
- `links/sidebar_utility_to_contacts.dart`

5) Add `cascade/README.md` explaining topology, ownership, and how to extend.

## Behavior Preservation Strategy

- Use mechanical moves only; no condition changes or new logic.
- Keep call shapes identical (same specs returned with same parameters).
- Ensure all `when`/`switch` statements remain exhaustive and unchanged.
