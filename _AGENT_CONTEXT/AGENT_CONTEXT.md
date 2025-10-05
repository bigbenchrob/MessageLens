# Agent Context - Master Documentation Index

This file serves as the master index for all critical documentation that AI agents MUST reference when working on this project. **EVERY AGENT MUST READ THIS FILE AND THE REFERENCED DOCUMENTATION BEFORE MAKING CODE CHANGES.**

## 🚨 CRITICAL READING ORDER 🚨

**READ THESE FILES IN THIS EXACT ORDER:**

### 1. Code Standards & Common Issues ⭐ MANDATORY

📁 **`00-code-standards.md`**

- **REQUIRED FIRST READ** - Contains all the repeated mistakes agents make
- Flutter/Dart linting rules and patterns
- Import requirements (hooks_riverpod vs flutter_riverpod)
- Control flow formatting rules, deprecated method warnings
- Performance optimizations (ColoredBox vs Container, withValues vs withOpacity)

### 2. AddressBook Database Resolution ⚠️ CRITICAL FOR IMPORTS

📁 **`01-addressbook-database-resolution.md`**

- **ESSENTIAL FOR ANY IMPORT WORK** - Prevents 90% of import failures
- Explains why agents pick wrong AddressBook database paths
- Details the MANDATORY use of `getFolderAggregateEitherProvider`
- Shows the correct vs incorrect database folder structure
- **IGNORE THIS AT YOUR PERIL** - Wrong path = import failure

### 3. Project Architecture & DDD Structure

📁 **`02-architecture-overview.md`**

- Domain Driven Development (DDD) structure explanation
- Feature organization and layer responsibilities
- Naming conventions and file organization patterns
- Infrastructure/Application/Domain layer separation

### 3.5. Participant-Handle Architecture ⚠️ CRITICAL FOR PARTICIPANTS/HANDLES/IMPORT

📁 **`09-participant-handle-architecture.md`**

- **ESSENTIAL FOR ALL PARTICIPANT/HANDLE WORK** - Core design specification
- The Manifesto: "A participant is a person, not a phone number"
- Participants (people) vs Handles (communication endpoints) vs Services (chat properties)
- HandleToParticipant join table architecture (confidence & source tracking)
- Import process: AddressBook Z_PK preservation, macos_import.db staging
- Phase 1-5 import pipeline: Core data → Contact matching → Projection → Spam filtering
- ChatToParticipant table DELETED (UI joins through handles directly)
- **IGNORE THIS = BROKEN IMPORTS** - Wrong architecture = duplicate participants

### 4. Database Schema Reference ⚠️ CRITICAL FOR DATABASE WORK

📁 **`10-database-schema-reference.md`**

- **REQUIRED BEFORE ANY DATABASE QUERIES** - Prevents field name mistakes
- Authoritative schema for all database tables
- Common join patterns and query examples
- Database file locations (NOT in Application Support!)
- Critical anti-patterns to avoid (message vs messages, text vs content, etc.)
- **IGNORE THIS = BROKEN QUERIES** - Wrong table/field names cause runtime errors

### 5. Riverpod Provider Patterns ⚠️ MANDATORY PATTERNS

📁 **`05-riverpod-provider-patterns.md`**

- **CRITICAL**: All providers MUST use riverpod_annotation code generation
- **NEVER** create manual StateNotifierProvider instances
- Required file naming: `feature_name_provider.dart`
- Required class pattern: `class FeatureName extends _$FeatureName {}`
- Usage patterns: `ref.watch(featureNameProvider)`, `ref.read(featureNameProvider.notifier)`
- **IMPORTANT**: Function providers use `Ref ref` parameter, NOT generated types

## Quick Reference Standards

- **Primary import**: Always use `hooks_riverpod`, never `flutter_riverpod`
- **Color opacity**: Use `withValues(alpha: 0.5)`, never `withOpacity(0.5)`
- **Control flow**: Always use braces, never single-line statements
- **Async functions**: Return `Future<void>`, never `void`
- **Containers**: Use `ColoredBox` when only setting color
- **Database tables**: `messages` (plural), never `message` (singular)
- **Database fields**: `content` not `text`, `message_id` not `message_guid`
- **Database location**: `/Users/rob/sqlite_rmc/remember_every_text/working.db`
- **AddressBook imports**: MUST use `getFolderAggregateEitherProvider` for path resolution
- **Riverpod providers**: MUST use `@riverpod` annotation, NEVER manual providers

## Project Overview

This is a macOS-native Flutter application that imports and manages Messages and AddressBook data using:

- Domain Driven Development (DDD) architecture
- Riverpod for state management (hooks_riverpod specifically)
- Drift for database operations
- macOS UI components for native feel

### Navigation System (Current State - September 2025)

**ViewSpec-Based Architecture**: The navigation system uses **sealed classes** and **reactive Riverpod providers** for type-safe navigation:

- **ViewSpec & MessagesSpec sealed classes**: Strongly-typed navigation specifications with compile-time guarantees
- **PanelsViewState**: Simple Map<WindowPanel, ViewSpec?> state management
- **Bottom-up provider chain**: ViewSpec → Feature Coordinators → Widget Builders → UI
- **Reactive panel providers**: Automatically rebuild UI when navigation state changes
- **Panel Layout**: Left sidebar, center content area, right sidebar

**Key Pattern**:

```dart
ref.read(panelsViewStateProvider.notifier).show(
  panel: WindowPanel.center,
  spec: const ViewSpec.messages(MessagesSpec.forChat(chatId: 42)),
);
```

**Adding New Features**:

1. Create feature spec sealed class (e.g., ChatsSpec)
2. Add ViewSpec variant (e.g., ViewSpec.chats)
3. Create feature coordinator with buildForSpec() method
4. Wire into panel coordinator
5. Create widget builders

**HOLY RULE**: Features coordinate through ViewSpec declarations only. No direct cross-feature commands or state mutations.

See `03-navigation-overview.md` for complete architecture, implementation layers, and usage patterns.

### 5. Flutter & Dart Extended Rules

📁 **`06-flutter-dart-agent-rules.md`**

- Extended Flutter/Dart implementation guidance
- Performance, theming, testing, accessibility, and anti-pattern checklist
- Supplements (does not override) earlier numbered docs

### 6. Rust Message Extractor ⚠️ CRITICAL FOR MESSAGE IMPORTS

📁 **`08-rust-message-extractor.md`**

- **ESSENTIAL FOR MESSAGE TEXT EXTRACTION** - 90% of message content is in attributedBody
- Binary location: `target/release/extract_messages_limited`
- Source code location: `rust/rust/attributed-string-decoder/`
- Build instructions and troubleshooting
- **WITHOUT EXTRACTOR**: Messages import with mostly empty text content

### 7. Native Link Preview Flow ✅

📁 **`09-rust-url-preview-parser.md`** _(Quick reference name retained for numbering; content now documents the LinkPresentation flow)_

- Summarises the production LinkPresentation + method channel architecture
- Lists key files (`native_link_preview_service.dart`, `url_preview_widget.dart`, `messages_for_chat_view.dart`)
- Outlines troubleshooting tips and test harness (`url_preview_test_runner.dart`)

📁 **`12-native-link-preview-implementation.md`**

- Full implementation guide for the LinkPresentation integration
- Explains service wiring, widget behaviour, and fallback UX
- Notes there is no longer any attachment parsing or Rust dependency for previews

### 8. Data Import & Migration Strategy ⚠️ CRITICAL FOR IMPORT/MIGRATION WORK

📁 **`11-data-import-migration-strategy.md`**

- **ESSENTIAL FOR ALL IMPORT AND MIGRATION WORK** - Complete strategy documentation
- Two-database architecture: import.db (immutable ledger) + working.db (application database)
- 12-stage import pipeline with progress tracking
- Data flow: macOS chat.db/AddressBook → import.db → working.db
- Batch tracking and provenance system
- Rust extractor integration for attributedBody
- Performance considerations and best practices
- **WITHOUT THIS**: Risk breaking import/migration workflows

## File Organization

```
_AGENT_CONTEXT/
├── AGENT_CONTEXT.md                        # This master index file
├── 00-code-standards.md                    # ⭐ MANDATORY - Code rules & patterns
├── 01-addressbook-database-resolution.md  # ⚠️ CRITICAL - Import path resolution
├── 02-architecture-overview.md            # DDD structure & naming conventions
├── 03-navigation-overview.md              # ⭐ ESSENTIAL - Navigation system with explicit event fields
├── 05-riverpod-provider-patterns.md       # ⚠️ MANDATORY - Provider code generation rules
├── 06-flutter-dart-agent-rules.md         # Extended Flutter/Dart agent rules
├── 08-rust-message-extractor.md           # ⚠️ CRITICAL - Rust binary for message text extraction
├── 09-participant-handle-architecture.md  # ⚠️ CRITICAL - Participant/Handle design & import architecture
├── 09-rust-url-preview-parser.md          # LinkPresentation quick reference (naming retained)
├── 10-database-schema-reference.md        # ⚠️ CRITICAL - Database schema & query patterns
├── 11-data-import-migration-strategy.md   # ⚠️ CRITICAL - Import/migration architecture
├── 12-native-link-preview-implementation.md # Native LinkPresentation for URL previews
└── [Additional numbered files as needed]
```

## Usage Instructions for Agents

1. **ALWAYS** read this file first when assigned to the project
2. **MANDATORY** - Read `00-code-standards.md` before any code changes
3. **IF WORKING WITH IMPORTS** - Read `01-addressbook-database-resolution.md`
4. **FOR ARCHITECTURE QUESTIONS** - Reference `02-architecture-overview.md`
5. **FOR UI/NAVIGATION WORK** - Read `03-navigation-overview.md` to understand explicit event fields
6. **FOR DATABASE WORK** - Read `10-database-schema-reference.md` before writing queries
7. **FOR PARTICIPANTS/HANDLES** - Read `09-participant-handle-architecture.md` for design principles
8. **FOR PROVIDERS** - Follow `05-riverpod-provider-patterns.md` for code generation patterns
9. **FOR MESSAGE IMPORTS** - Read `08-rust-message-extractor.md` for text extraction
10. **FOR URL PREVIEWS** - Read `09-rust-url-preview-parser.md` (quick reference) and `12-native-link-preview-implementation.md`
11. **FOR IMPORT/MIGRATION WORK** - Read `11-data-import-migration-strategy.md` for complete system architecture
12. When in doubt, ask for clarification rather than guessing

**Remember**: Following these guidelines prevents the most common agent mistakes and ensures code quality.
