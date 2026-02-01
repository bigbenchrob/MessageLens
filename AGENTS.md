# Agent Instructions

**⚠️ This file is maintained by OpenAI Codex CLI. For comprehensive agent instructions, see the `_AGENT_INSTRUCTIONS/` directory.**

## Quick Start for AI Agents

🚨 **MANDATORY FIRST STEP**: Read [`_AGENT_INSTRUCTIONS/agent-instructions-shared/00-global/agent-guardrails.md`](_AGENT_INSTRUCTIONS/agent-instructions-shared/00-global/agent-guardrails.md). These global guardrails control how agents plan work, request approval, and constrain edit scope.

🚨 **MANDATORY SECOND STEP**: Read [`_AGENT_INSTRUCTIONS/agent-per-project/README.md`](_AGENT_INSTRUCTIONS/agent-per-project/README.md) before making ANY code changes.

This README contains the canonical index to all project documentation including:
- Critical import patterns and database access rules
- DDD architecture and aggregate boundaries
- Riverpod provider code generation patterns
- Navigation system (ViewSpec-based)
- AddressBook path resolution (critical for imports)

## Essential Documentation

### Must-Read Before Coding
1. **[Agent Guardrails](_AGENT_INSTRUCTIONS/agent-instructions-shared/00-global/agent-guardrails.md)** - Global planning and change-control rules
2. **[Project README](_AGENT_INSTRUCTIONS/agent-per-project/README.md)** - Canonical index
3. **[Dart Guidelines](_AGENT_INSTRUCTIONS/agent-instructions-shared/10-language/dart.md)** - Language rules, async patterns, null-safety expectations
4. **[Flutter Widget Guidelines](_AGENT_INSTRUCTIONS/agent-instructions-shared/20-flutter/widgets.md)** - Composition, navigation, and state management rules
5. **[Riverpod Patterns](_AGENT_INSTRUCTIONS/agent-instructions-shared/20-riverpod/provider-patterns.md)** - MANDATORY code generation patterns
6. **[Database Access](_AGENT_INSTRUCTIONS/agent-per-project/05-databases/README.md)** - Critical: Use centralized providers only
7. **[Architecture Overview](_AGENT_INSTRUCTIONS/agent-per-project/00-project/architecture-overview.md)** - DDD layers and responsibilities
8. **[Cross-Surface Spec System](_AGENT_INSTRUCTIONS/agent-per-project/90-CROSS-SURFACE-SPEC-SYSTEMS/00-cross-surface-spec-system.md)** - 🔥 CRITICAL: How features interpret specs (coordinators route, resolvers own meaning, app-level chooses chrome)

### Quick Reference
- **Lint Antipatterns**: [`_AGENT_INSTRUCTIONS/agent-instructions-shared/10-language/linter-antipatterns.md`](_AGENT_INSTRUCTIONS/agent-instructions-shared/10-language/linter-antipatterns.md) - One-stop list of analyzer tripwires
- **Navigation System**: [`_AGENT_INSTRUCTIONS/agent-per-project/10-features/navigation-overview.md`](_AGENT_INSTRUCTIONS/agent-per-project/10-features/navigation-overview.md)
- **AddressBook Imports**: [`_AGENT_INSTRUCTIONS/agent-per-project/05-databases/addressbook-path-resolution.md`](_AGENT_INSTRUCTIONS/agent-per-project/05-databases/addressbook-path-resolution.md)
- **Cross-Surface Spec System**: [`_AGENT_INSTRUCTIONS/agent-per-project/90-CROSS-SURFACE-SPEC-SYSTEMS/00-cross-surface-spec-system.md`](_AGENT_INSTRUCTIONS/agent-per-project/90-CROSS-SURFACE-SPEC-SYSTEMS/00-cross-surface-spec-system.md) - Layer boundaries for spec interpretation

## Critical Rules (Quick Reference)

### Imports & Dependencies
- ✅ **Always use**: `hooks_riverpod` (never `flutter_riverpod`)
- ✅ **Database access**: Use `importDatabaseProvider` & `workingDatabaseProvider` from `essentials/databases/feature_level_providers.dart`
- ❌ **Never**: Create direct database instances (causes SQLite locking)

### Code Standards
- ✅ Color opacity: `withValues(alpha: 0.5)` (never `withOpacity`)
- ✅ Control flow: Always use braces (never single-line statements)
- ✅ Freezed classes: MUST be `abstract class`, never just `class`
- ✅ Async functions: Return `Future<void>`, never `void`
- ✅ Containers: Use `ColoredBox` when only setting color

### Riverpod Patterns
- ✅ **Use documented patterns only** - Do NOT scan codebase for examples
- ✅ All providers: Use `@riverpod` annotation with code generation
- ✅ Class naming: `MyFeature extends _$MyFeature` → generates `myFeatureProvider`
- ❌ **Never**: Create manual `StateNotifierProvider` instances

## Development Commands

```bash
# Run app
flutter run -d macos

# Code generation (Freezed, Riverpod, etc.)
dart run build_runner build --delete-conflicting-outputs

# Testing
flutter test --plain-name "pattern"

# Analysis & formatting
flutter analyze
dart format .
dart fix --apply
```

## Project Structure

```
lib/
├── essentials/          # Core systems (navigation, import, databases, window state)
├── features/            # Business features (DDD: messages, chats, contacts, address_book_folders)
└── domain_driven_development/  # Shared DDD utilities

_AGENT_INSTRUCTIONS/     # Comprehensive agent documentation (READ FIRST!)
├── agent-per-project/   # Project-specific patterns and architecture
└── agent-instructions-shared/  # Reusable patterns (Dart, Flutter, Riverpod, etc.)

rust/                    # High-performance Rust modules via flutter_rust_bridge
test/                    # Tests mirroring lib/ structure
```

## For More Details

See the comprehensive documentation in [`_AGENT_INSTRUCTIONS/`](_AGENT_INSTRUCTIONS/) for:
- Detailed architecture and DDD boundaries
- Complete code standards and linting rules
- Database schema and migration patterns
- Navigation system implementation
- Testing strategies
- Rust FFI integration
- And much more...

**When in doubt, consult the agent instructions rather than guessing!**

---

## Original Content (For Reference)

## Project Structure & Module Organization
The Flutter client lives in `lib/`, organized by domain-driven modules: shared utilities in `core/` and `essentials/`, feature flows inside `features/`, and Riverpod providers in `providers.dart` plus generated `providers.g.dart`. Platform scaffolds remain in `macos/`, `ios/`, and `web/`. Mac database and Supabase artifacts are tracked under `supabase/`. The Rust message extractor is in `rust/rust/attributed-string-decoder/` with its release binary expected at `target/release/extract_messages_limited`. Tests sit in `test/` with scenario-focused groupings, and developer tooling such as data reformatters lives under `tool/`.

## Build, Test, and Development Commands
- `flutter pub get` installs Flutter and plugin dependencies.
- `flutter run -d macos` launches the desktop app against the live macOS databases.
- `flutter build macos --release` generates a distributable bundle.
- `flutter analyze` enforces Dart lint rules from `analysis_options.yaml`.
- `flutter test` executes widget and integration tests in `test/`.
- `cargo build --release` and `cargo test` run within `rust/rust/attributed-string-decoder/` for the extractor.

## Coding Style & Naming Conventions
Use `dart format .` (2-space indentation) before submitting. Prefer PascalCase for classes, camelCase for methods and variables, and snake_case for file names such as `timeline_view.dart`. Hook-based Riverpod providers should follow the `<feature>Provider` pattern. Keep generated files (`*.g.dart`, `frb_generated*.dart`) untouched; update them via the relevant build step instead of manual edits.

## Testing Guidelines
Add `*_test.dart` files mirroring the `lib/` structure, grouping tests by feature name. Mock external I/O such as database imports; integration flows can use the extractor binary stubbed at `target/release/extract_messages_limited`. When modifying the Rust extractor, accompany changes with focused `#[test]` cases in `src/`. Aim to keep Flutter tests deterministic and runnable via `flutter test --coverage` before review.

## Commit & Pull Request Guidelines
Recent history favors concise, present-tense commit messages (`fix scroll jitter`). Scope commits narrowly and explain intent in the first line. Pull requests should include a summary of user-visible behavior, linked tracking issue or TODO reference, screenshots for UI updates, and notes on manual verification (e.g., `flutter run -d macos`). Request review from a teammate familiar with the touched module.

## Security & Configuration Tips
Never commit personal database exports or credential files; `.db` artifacts should stay in your local workspace. Confirm Full Disk Access permissions when testing imports, and verify the Rust binary’s execute bit (`chmod +x target/release/extract_messages_limited`) after rebuilding.
