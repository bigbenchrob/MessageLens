````instructions
You are an AI assistant helping with a Flutter macOS application called "remember_this_text".

🚨 **MANDATORY FIRST STEP**: Read `_AGENT_INSTRUCTIONS/agent-instructions-shared/00-global/agent-guardrails.md`. These guardrails govern how GitHub Copilot and Codex agents must plan work, request approval, and limit edit scope.

🚨 **MANDATORY SECOND STEP**: Read `_AGENT_INSTRUCTIONS/agent-per-project/README.md` before making ANY code changes. This file contains the canonical index to all project documentation including critical import, database, and architecture patterns.

## Project Context
This is a macOS-native Flutter application that imports and manages Messages and AddressBook data. The project uses:
- Domain Driven Development (DDD) architecture
- Riverpod for state management (hooks_riverpod specifically, NOT flutter_riverpod)
- Drift for database operations
- macOS UI components for native feel
- Rust FFI for high-performance data processing
- ViewSpec-based reactive navigation system

## Essential Reading Order
You MUST read these files in order before any code changes:
1. **`_AGENT_INSTRUCTIONS/agent-instructions-shared/00-global/agent-guardrails.md`** - Planning, approval, and diff-scope expectations for all agents
2. **`_AGENT_INSTRUCTIONS/agent-per-project/README.md`** - Canonical index of all project documentation
3. **`_AGENT_INSTRUCTIONS/agent-instructions-shared/10-language/dart-code-standards.md`** - Dart linting rules, type annotations, code patterns
4. **`_AGENT_INSTRUCTIONS/agent-instructions-shared/20-flutter/flutter-code-standards.md`** - Flutter-specific standards, deprecated methods
5. **`_AGENT_INSTRUCTIONS/agent-instructions-shared/20-riverpod/provider-patterns.md`** - MANDATORY provider code generation patterns
6. **`_AGENT_INSTRUCTIONS/agent-per-project/05-databases/README.md`** - Database access patterns and schema references
7. **`_AGENT_INSTRUCTIONS/agent-per-project/05-databases/addressbook-path-resolution.md`** - AddressBook path resolution (CRITICAL for imports)
8. **`_AGENT_INSTRUCTIONS/agent-per-project/00-project/aggregate-boundaries.md`** - DDD structure and aggregate boundaries
9. **`_AGENT_INSTRUCTIONS/agent-per-project/00-project/architecture-overview.md`** - Project architecture and DDD layer responsibilities
10. **`_AGENT_INSTRUCTIONS/agent-per-project/50-CROSS-SURFACE-SPEC-SYSTEMS-OVERVIEW/`** - 🔥 CRITICAL: How sealed spec classes coordinate UI across all surfaces
11. **`_AGENT_INSTRUCTIONS/agent-per-project/52-FEATURE-HANDLING-OF-X-SURFACE-SPECS/`** - Universal coordinator → resolver → widget_builder pattern
12. **`_AGENT_INSTRUCTIONS/agent-per-project/54-SIDEBAR-CASSETTE-SPEC-SYSTEM/`** - Sidebar cassette rack, cascade, card chrome
13. **`_AGENT_INSTRUCTIONS/agent-per-project/56-VIEW-SPEC-PANEL-CONTENT-SYSTEM/`** - ViewSpec panel navigation and feature dispatch

## Quick Reference Code Standards
- **Primary import**: Always use `hooks_riverpod`, never `flutter_riverpod`
- **Color opacity**: Use `withValues(alpha: 0.5)`, never `withOpacity(0.5)`
- **Control flow**: Always use braces, never single-line statements
- **Async functions**: Return `Future<void>`, never `void`
- **Containers**: Use `ColoredBox` when only setting color
- **String interpolation**: Use `$variable`, only `${expression}` for complex cases
 - **Redundant defaults**: Do not pass values equal to a parameter's default
 - **Collection literals**: Prefer `[...]`, `{...}` over constructors like `List<T>()`
 - **Control bodies**: Always put control bodies on new lines with braces
- **🔥 FREEZED CLASSES**: ALL Freezed classes MUST be declared as `abstract class`, never just `class`
 - **Freezed unnamed ctor order**: Place `const ClassName._();` AFTER the primary `const factory` constructor in the class body to satisfy `sort_unnamed_constructors_first`.
- **🔥 DATABASE ACCESS**: ALL database access MUST use providers in `essentials/databases/feature_level_providers.dart`
- **AddressBook imports**: MUST use `getFolderAggregateEitherProvider` for path resolution
- **🔥 RIVERPOD PATTERNS**: Follow ONLY the patterns documented in `05-riverpod-provider-patterns.md` - DO NOT scan codebase for examples
- **Provider naming**: Class names follow documented pattern: `MyFeature` → generates `myFeatureProvider`
- **Navigation**: Use ViewSpec sealed classes, never direct widget management
- **🔥 THEME ACCESS**: NEVER use `MacosTheme.of(context)` or `Theme.of(context)` - use `themeColorsProvider` and `themeTypographyProvider` exclusively
- **🔥 Feature Spec Handling**: Feature coordinators route only; application-layer resolvers own meaning; app-level coordinators choose UI chrome

## Development Workflow
- **Code generation**: `dart run build_runner build --delete-conflicting-outputs`
- **Testing**: `flutter test --plain-name "<pattern>"` (Flutter) / `dart test --plain-name "<pattern>"` (Dart)
- **Run app**: `flutter run -d macos`
- **Lint compliance**: Fix all violations immediately - strict analysis_options.yaml enforced

## Project Architecture
- **`lib/essentials/`** - Core systems (navigation, import, databases, window state)
- **`lib/features/`** - Business features following DDD (messages, chats, contacts, address_book_folders)
- **`lib/essentials/databases/`** - Drift database layer with working/import DB separation
- **`lib/essentials/import/`** - macOS data import system with Rust integration
- **`lib/essentials/navigation/`** - ViewSpec-based reactive navigation system
- **`rust/`** - High-performance Rust modules via flutter_rust_bridge
- **`_AGENT_INSTRUCTIONS/`** - Comprehensive agent documentation (READ FIRST!)

## Navigation System (Current)
Uses sealed classes and reactive providers for type-safe navigation:
```dart
// Navigate to messages for a specific chat
ref.read(panelsViewStateProvider.notifier).show(
  panel: WindowPanel.center,
  spec: const ViewSpec.messages(MessagesSpec.forChat(chatId: 42)),
);
````

**Key Pattern**: Features coordinate through ViewSpec declarations only. No direct cross-feature commands.

## 🔥 MANDATORY RIVERPOD PROVIDER PATTERNS

**🚨 CRITICAL**: All Riverpod patterns are documented in `_AGENT_INSTRUCTIONS/agent-instructions-shared/20-riverpod/provider-patterns.md`

**DO NOT** scan the codebase for provider examples - use ONLY the documented patterns:

### ✅ DOCUMENTED CLASS NAMING PATTERN:

```dart
@riverpod
class MyFeature extends _$MyFeature {
  @override
  StateType build() => initialState;
}
// Generates: myFeatureProvider
```

### ✅ DOCUMENTED FILE NAMING:

- File: `my_feature_provider.dart`
- Generated: `my_feature_provider.g.dart`
- Class: `MyFeature extends _$MyFeature`

### ✅ MANDATORY REQUIREMENTS:

- MUST use `@riverpod` annotation
- MUST include `part 'filename.g.dart';`
- MUST use `hooks_riverpod` import
- NEVER create manual providers

**⚠️ WARNING**: Do not search codebase for naming examples - follow only the documented pattern above.

## Critical Anti-Patterns to Avoid

- ❌ Manual StateNotifierProvider creation (use @riverpod)
- ❌ flutter_riverpod imports (use hooks_riverpod)
- ❌ withOpacity() calls (use withValues(alpha:))
- ❌ Single-line control flow (always use braces)
- ❌ **NON-ABSTRACT FREEZED CLASSES**: Never use `class MyClass with _$MyClass` - MUST be `abstract class`
- ❌ Freezed unnamed ctor at top: Do not place `const ClassName._();` before the primary `const factory` in the class — it must come after.
- ❌ Redundant default args: Don’t pass values that equal defaults (triggers `avoid_redundant_argument_values`).
- ❌ Unnecessary interpolation braces: Avoid `'${value}'` when `'${}'` isn’t needed; use `$value`.
- ❌ Prefer collection literals: Avoid `List<T>()`/typed literal invocation when `[]` or spreads suffice.
- ❌ Direct AddressBook path hardcoding (use getFolderAggregateEitherProvider)
- ❌ String-based navigation (use ViewSpec sealed classes)
- ❌ 🔥 **SCANNING CODEBASE FOR PROVIDER EXAMPLES** (use documented patterns only)
- ❌ 🔥 **CRITICAL**: Direct database instantiation (use `importDatabaseProvider` & `workingDatabaseProvider`)
- ❌ 🔥 **MacosTheme.of(context) / Theme.of(context)** (use `themeColorsProvider` & `themeTypographyProvider`)
- ❌ 🔥 **Feature coordinators doing logic** (coordinators route only; resolvers own meaning)
- ❌ 🔥 **Application-layer builders returning view models** (return widget content; coordinator wraps in chrome)
- ❌ 🔥 **INVIOLABLE: Dual-writing to overlay AND working DB** (user intent → overlay ONLY; migration → working ONLY; providers merge at read time with overlay winning on conflict. See `10-DATABASES/07-overlay-database-independence.md`)
- ❌ 🔥 **INVIOLABLE: Migration snapshot/restore of overlay data** (migration must NEVER read overlay, snapshot it, then restore into working. Providers merge at read time instead.)
- ❌ 🔥 **INVIOLABLE: User-intent columns on working-DB tables** (flags like `is_blacklisted`/`is_visible` must NOT live on working tables rebuilt by migration. Store in overlay; merge in providers.)

## 🔥 MANDATORY DATABASE ACCESS RULE

**ANY CLASS accessing working.db or import.db MUST use the centralized providers:**

- **Import DB**: `ref.watch(importDatabaseProvider)` from `essentials/databases/feature_level_providers.dart`
- **Working DB**: `ref.watch(workingDatabaseProvider)` from `essentials/databases/feature_level_providers.dart`
- **NEVER**: Direct `ImportDatabase()` or `DriftDb()` instantiation
- **REASON**: Prevents SQLite locking issues from multiple connections to same file

⚠️ **CRITICAL**: If you're working with AddressBook imports, read the AddressBook database resolution guide first. Many import failures are caused by using the wrong database path.

When in doubt, ask for clarification rather than guessing. Always prioritize code quality and following established patterns.

```

```
