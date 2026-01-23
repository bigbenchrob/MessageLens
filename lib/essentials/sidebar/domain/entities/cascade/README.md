# Cassette Topology (Child Spec Resolution)

This folder defines the cassette topology: the global parent -> child
relationships between cassette specs.

## What "topology" means here

Topology describes how one cassette spec leads to the next. It is global because
cross-feature transitions must be defined in one place, but it is modular so no
single file becomes a "god router."

## What belongs here

- Pure, domain-level child resolution logic.
- One topology file per feature's cassette spec family.
- Explicit cross-feature edges in `links/`.

## What does NOT belong here

- Feature interpretation or UI rendering.
- Repository access or provider reads.
- Any application or presentation logic.

## How to add a new childSpec path

1) Add the logic to the matching topology file.
2) If the edge crosses features, add a helper in `links/`.
3) Keep `CassetteSpec.childSpec()` delegating through
   `cassette_child_resolver.dart`.
