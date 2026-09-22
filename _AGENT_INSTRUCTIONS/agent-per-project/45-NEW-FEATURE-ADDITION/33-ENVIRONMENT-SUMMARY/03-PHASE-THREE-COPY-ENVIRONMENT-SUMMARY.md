# Environment Summary — Phase Three Copy Environment Summary

Date: 2026-09-22

Phase Two checkpoint: `fd046353639b48d1c40ad12850b9e05b03492156`
(`feat(environment): add settings environment summary`)

## Architecture plan

Phase Three adds one explicit support action without changing how Environment
facts are observed. The dependency direction is:

`EnvironmentSummaryPanel`
→ `EnvironmentSummaryActions`
→ `EnvironmentSummaryFormatter`
→ `EnvironmentSummaryClipboardWriter`
→ `SystemEnvironmentSummaryClipboardWriter`
→ Flutter `Clipboard`

The panel continues to watch only `environmentSummaryProvider` for environment
facts. It passes the already-rendered aggregate to the action only after the
user activates **Copy Environment Summary**. The action owns orchestration and
pure formatting. An application port keeps Flutter Clipboard APIs confined to
one infrastructure adapter.

No provider is initialized merely to discover new environment facts. The copy
path performs no filesystem, database, archive, attachment-resolution,
bookmark, Finder, or mutation work.

## Implementation

The Environment header now contains one semantic primary action labeled
**Copy Environment Summary**. The control is enabled whenever no copy is
already in flight. It remains available for partially settled summaries
because the aggregate and formatter have explicit representations for those
states. While a write is pending, the control is disabled and says
**Copying…**.

Activation passes the already-observed `EnvironmentSummary` to the action
provider. The action formats it once, writes that exact text through the
clipboard port, and returns a typed `copied` or `failed` result. Failures are
logged through the application logging seam. The panel uses the established
transient `SnackBar` feedback pattern:

- success: `Environment summary copied.`;
- failure: `MessageLens could not copy the environment summary.`

Opening or rendering the page performs no clipboard write. There are no
per-field or per-path controls and no Reveal in Finder control.

## Formatter semantics

The formatter remains a pure domain service with one import: the Environment
read model. Phase Three tightens its fallbacks so copied support text preserves
the model's typed truth:

- `Loading`, `Unknown`, `Unavailable`, `Not retained`, and `Failed` remain
  distinct;
- a ready numeric zero remains `0`;
- unsettled Message source evidence reports its section state instead of a
  fabricated zero-source breakdown;
- data-root and attachment states respect both section settlement and typed
  availability;
- missing package and technical evidence uses the owning section state.

The formatter continues to exclude Message and Contacts content, historical
source labels and paths, bookmark bytes, WAL/SHM details, retired databases,
device nodes, logs, retained previous archive paths, invented Contacts source
paths, and lower-level authority internals.

## Ownership and boundaries

`EnvironmentSummaryClipboardWriter` is the application port. Its sole
implementation, `SystemEnvironmentSummaryClipboardWriter`, is the only
Feature 33 source file that imports `package:flutter/services.dart` or invokes
`Clipboard.setData`. `EnvironmentSummaryActions` owns the imperative
format/write operation and typed result. Presentation owns only explicit user
activation, in-flight control state, and transient feedback.

The panel still watches only `environmentSummaryProvider` for environment
facts. Copying performs no provider-based rediscovery, Feature 31 attachment
resolution, filesystem probing, SQL, database opening, startup work, archive
access, or state mutation.

## Tests and architecture tripwires

Focused coverage proves:

- exact formatter output is written once and only after activation;
- rendering alone makes no clipboard call;
- the infrastructure adapter sends the expected Flutter platform-channel
  clipboard call;
- success and failure feedback are bounded;
- the action has a textual accessibility label;
- partial summaries and authoritative zero retain their typed meaning;
- privacy-excluded historical source paths are absent;
- no per-path copy or Finder action is present;
- Settings navigation and the passive Feature 31 observation seam remain
  unchanged.

Architecture coverage confines Flutter clipboard APIs to the infrastructure
adapter, keeps the formatter and application port Flutter-free, keeps
presentation formatter-free, preserves the aggregate-only read boundary, and
continues to reject startup/onboarding reverse dependencies and attachment,
filesystem, database, or mutation authority.

Validation completed:

- Riverpod generation completed successfully;
- focused Feature 33, Settings/navigation, passive-observation, and
  architecture matrix: 531 passed;
- `flutter analyze --no-pub`: no issues;
- full repository suite: 2,620 passed and 1 pre-existing skip;
- `git diff --check`: clean;
- documentation/reference checks: canonical Feature 33/Phase Three references
  are intact, with Flutter clipboard APIs present only in the named adapter.

No native code changed, so native tests are not applicable.

## Release metadata

Repository convention requires a version/build bump and changelog entry for
this user-facing action. Phase Three advances `0.2.125+143` to
`0.2.126+144` and adds the smallest truthful Added, Changed, and Safety notes.

## Handoff

Phase Three is intentionally left unstaged for review. It adds no Finder
integration, per-path copy behavior, general export system, or future-phase
work. Nothing was pushed, and no real production or development database,
archive, WD/Toshiba source, or user content was accessed or modified.
