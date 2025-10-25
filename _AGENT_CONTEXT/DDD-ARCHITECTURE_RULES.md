DDD Architecture Rules & Initial Scaffold

This document is authoritative for the Messaging bounded context (macOS iMessage import → working DB → app). Keep it short and enforceable. Pair it with the lint + tests below.

⸻

ARCHITECTURE_RULES.md (drop this at repo root)

# Architecture Rules (Authoritative)

## Aggregates

- There are **exactly two aggregates** in the Messaging bounded context:
  - **Chat** (aggregate root)
  - **Message** (aggregate root)
- **Do NOT** create a Contact aggregate. Contacts are **external reference data / projections** only.
- A Message **belongs to exactly one** Chat.

## Layering (DDD)

- **Domain** layer MUST NOT import from **infrastructure** or **presentation**.
- **Application** layer (use-cases) depends on **domain** only; it may depend on repositories **as interfaces**.
- **Infrastructure** provides implementations (Drift/sqflite, Rust FFI, etc.)
- Repositories expose **domain models** only (no Drift row classes crossing the boundary).

## IDs & Invariants (essentials)

- `ChatId` is stable; participant set contains **unique handles**.
- `Message` content is immutable post-ingest; edits are revisions/events.
- Reactions/attachments are subordinate to Message (not aggregates).

## Data Flow

- Source (macOS chat.db/AddressBook) → **import.db (sqflite)** → ETL → **working.db (Drift)** → repositories → application → UI.
- ETL is **deterministic and idempotent**; re-running yields the same working state (modulo source changes).

## ADRs

- Any new aggregate, cross-boundary dependency, or schema-breaking change **requires an ADR** in `docs/adr/`.

⸻

Minimal folder scaffold (create empty files unless content is shown below)

.github/
pull_request_template.md
analysis_options.yaml
ARCHITECTURE_RULES.md # (paste the block above)
custom_lint_plugins/
ddd_lints/
lib/
ddd_lints.dart
pubspec.yaml # plugin pubspec (see below)
lib/
features/
chats/
domain/
entities/
chat.dart
value_objects/
ids.dart
participant.dart
repositories/
chat_repository.dart
application/
usecases/
get_chat_list.dart
infrastructure/
repositories/
chat_repository_drift.dart
messages/
domain/
entities/
message.dart
value_objects/
message_value_objects.dart
repositories/
message_repository.dart
application/
usecases/
get_messages_for_chat.dart
infrastructure/
repositories/
message_repository_drift.dart
identity/
projection/
contact_projection.dart
data/
working_db/
schema.dart # Drift tables for domain-driven schema
import_db/
schema.sql # Optional: mirror of macOS data + ETL bookkeeping
notes.md
test/
architecture/
no_contact_aggregate_test.dart
layering_imports_test.dart
smoke/
repo_smoke_test.dart

⸻

PR template (.github/pull_request_template.md)

- [ ] Follows **ARCHITECTURE_RULES.md**
- [ ] No new aggregates added without an ADR in `docs/adr/`

⸻

analysis_options.yaml (enable custom_lint)

analyzer:
plugins: - custom_lint
exclude: - build/** - .dart_tool/** - custom_lint_plugins/**/.dart_tool/**

In your app pubspec.yaml, add:

dev_dependencies:
custom_lint: ^0.6.0

Run locally/CI: dart run custom_lint && dart analyze

⸻

Custom lint plugin (blocks Contact aggregate & bad imports)

custom_lint_plugins/ddd_lints/lib/ddd_lints.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

PluginBase createPlugin() => \_DddPlugin();

class _DddPlugin extends PluginBase {
@override
List<LintRule> getLintRules(CustomLintConfigs _) => [
_NoContactAggregate(),
_NoInfraInDomain(),
];
}

class \_NoContactAggregate extends DartLintRule {
\_NoContactAggregate()
: super(code: const LintCode(
name: 'no_contact_aggregate',
problemMessage: 'Do not create a Contact aggregate.',
correctionMessage: 'Contacts must be projections only.',
));

@override
void run(ResolvedUnitResult unit, LintReporter reporter) {
for (final decl in unit.unit.declarations.whereType<ClassDeclaration>()) {
if (decl.name.lexeme == 'ContactAggregate') {
reporter.reportErrorForNode(code, decl.name);
}
}
}
}

class \_NoInfraInDomain extends DartLintRule {
\_NoInfraInDomain()
: super(code: const LintCode(
name: 'no_infra_in_domain',
problemMessage:
'Domain layer must not import infrastructure or presentation.',
));

@override
void run(ResolvedUnitResult unit, LintReporter reporter) {
final path = unit.path.replaceAll('\\', '/');
final isDomain = path.contains('/domain/');
if (!isDomain) return;
for (final imp in unit.unit.directives.whereType<ImportDirective>()) {
final uri = imp.uri.stringValue ?? '';
if (uri.contains('/infrastructure/') || uri.contains('/presentation/')) {
reporter.reportErrorForNode(code, imp.uri);
}
}
}
}

custom_lint_plugins/ddd_lints/pubspec.yaml (plugin package)

name: ddd_lints
publish_to: 'none'
environment:
sdk: '>=3.3.0 <4.0.0'
dependencies:
custom_lint_builder: ^0.6.0
dev_dependencies:
custom_lint: ^0.6.0

In your app pubspec.yaml, add under dev_dependencies:

ddd_lints:
path: custom_lint_plugins/ddd_lints

⸻

Architecture tests (tripwires)

test/architecture/no_contact_aggregate_test.dart

import 'dart:io';
import 'package:test/test.dart';

void main() {
test('No Contact aggregate class exists', () async {
final lib = Directory('lib');
final files = lib
.listSync(recursive: true)
.whereType<File>()
.where((f) => f.path.endsWith('.dart'));

    final violations = <String>[];
    for (final f in files) {
      final text = await f.readAsString();
      if (RegExp(r'\bclass\s+ContactAggregate\b').hasMatch(text)) {
        violations.add(f.path);
      }
    }
    expect(violations, isEmpty,
        reason:
            'ContactAggregate is forbidden by ARCHITECTURE_RULES.md. Found in:\n${violations.join('\n')}');

});
}

test/architecture/layering_imports_test.dart (simple import guard)

import 'dart:io';
import 'package:test/test.dart';

void main() {
test('Domain does not import infrastructure/presentation', () async {
final files = Directory('lib')
.listSync(recursive: true)
.whereType<File>()
.where((f) => f.path.contains('/domain/') && f.path.endsWith('.dart'));

    final bad = <String, List<String>>{};
    for (final f in files) {
      final lines = (await f.readAsLines());
      final hits = lines.where((l) =>
          l.contains("import '") &&
          (l.contains('/infrastructure/') || l.contains('/presentation/')));
      if (hits.isNotEmpty) bad[f.path] = hits.toList();
    }

    expect(bad, isEmpty,
        reason: 'Domain files must not import infrastructure/presentation.');

});
}

⸻

Domain stubs (so Copilot follows the pattern)

lib/features/chats/domain/value_objects/ids.dart

import 'package:meta/meta.dart';

@immutable
class ChatId {
final String value; // e.g., macOS chat.guid canonicalized
const ChatId(this.value);
@override
bool operator ==(Object other) => other is ChatId && other.value == value;
@override
int get hashCode => value.hashCode;
@override
String toString() => 'ChatId($value)';
}

lib/features/chats/domain/value_objects/participant.dart

import 'package:meta/meta.dart';

@immutable
class Participant {
final String handleId; // stable key from source (handle.ROWID or guid)
final String service; // iMessage/SMS
final String normalizedAddress; // E.164 or email
final String? displayName; // optional projection from Contacts
final String? contactId; // optional linkage
const Participant({
required this.handleId,
required this.service,
required this.normalizedAddress,
this.displayName,
this.contactId,
});
}

lib/features/chats/domain/entities/chat.dart

import '../value_objects/ids.dart';
import '../value_objects/participant.dart';

class Chat {
final ChatId id;
final List<Participant> participants; // unique by handleId
final String? title; // group title if any
final String? lastMessageId; // mirrors latest visible message
final DateTime? lastTimestamp;
final bool muted;
final bool pinned;

Chat({
required this.id,
required this.participants,
this.title,
this.lastMessageId,
this.lastTimestamp,
this.muted = false,
this.pinned = false,
});
}

lib/features/chats/domain/repositories/chat_repository.dart

import '../entities/chat.dart';
import '../value_objects/ids.dart';

abstract class ChatRepository {
Stream<List<Chat>> watchChatList();
Future<Chat?> getById(ChatId id);
Future<void> upsert(Chat chat);
}

lib/features/messages/domain/entities/message.dart

class Message {
final String id; // message.guid or ROWID as string
final String chatId; // foreign key to ChatId.value
final String senderHandleId;
final DateTime sentAt;
final String text; // decoded from attributedBody; immutable post-ingest
final bool isFromMe;

const Message({
required this.id,
required this.chatId,
required this.senderHandleId,
required this.sentAt,
required this.text,
required this.isFromMe,
});
}

lib/features/messages/domain/repositories/message_repository.dart

import '../entities/message.dart';

abstract class MessageRepository {
Stream<List<Message>> watchByChat(String chatId, {int pageSize = 50});
Future<void> upsertAll(List<Message> messages);
}

lib/features/identity/projection/contact_projection.dart

/// Contacts are external reference data. No aggregates here.
class ContactProjection {
final String contactId; // external id from AddressBook
final String displayName;
final String? avatarPath;
const ContactProjection({
required this.contactId,
required this.displayName,
this.avatarPath,
});
}

⸻

Drift & import placeholders (to be filled in later steps)

lib/data/working_db/schema.dart

// TODO: Define Drift tables driven by domain needs (Chat, Message, Participants join if needed)

lib/data/import_db/notes.md

Mirror macOS chat.db & AddressBook with minimal extras (plaintext, hashes, ETL bookkeeping).

⸻

Smoke test to keep repos in play

test/smoke/repo_smoke_test.dart

import 'package:test/test.dart';

void main() {
test('repositories compile and basic API is present', () async {
// This is just a placeholder to keep the test folder engaged until impls exist.
expect(true, isTrue);
});
}

⸻

Copilot Chat “prompt bumper” (paste at the top of new threads)

Use ARCHITECTURE_RULES.md as authoritative. If my request conflicts with those rules, STOP and ask. Never create a Contact aggregate; treat contacts as projections.

⸻

How to wire it up quickly 1. Copy the files/blocks above into your repo. 2. Add ddd_lints to your app dev_dependencies with a path: to custom_lint_plugins/ddd_lints. 3. Run: dart run custom_lint && dart analyze && dart test. 4. Keep ARCHITECTURE_RULES.md to 1–2 pages; update via ADRs, not ad-hoc edits.

From here, we can proceed to Step 1/2 of the plan: finalize domain contracts and draft the Drift working schema.
