import '../../domain/base_table_importer.dart';
import '../../domain/row_progress_reporter.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';
import 'identifier_utils.dart';

class ContactToChatHandleImporter extends BaseTableImporter
    with RowProgressReporter {
  ContactToChatHandleImporter();

  @override
  String get name => 'contact_to_chat_handle';

  @override
  List<String> get dependsOn => const <String>[
    'handles',
    'contacts',
    'contact_phone_email',
  ];

  @override
  Future<void> validatePrereqs(IImportContext ctx) async {
    if (ctx.hasExistingLedgerData) {
      return;
    }
    final existingCount = await count(ctx.importDb, name);
    await expectZeroOrThrow(
      existingCount,
      'contact-to-chat-handle-not-empty',
      'Contact-to-handle link table must be empty before first ledger import.',
    );
  }

  @override
  Future<void> copy(IImportContext ctx) async {
    await ctx.importDb.clearContactHandleLinksForBatch(batchId: ctx.batchId);

    final handles = await ctx.importDb.handlesForBatch(ctx.batchId);
    final channels = await ctx.importDb.contactChannelsForBatch(ctx.batchId);

    if (handles.isEmpty || channels.isEmpty) {
      ctx.info(
        'ContactToChatHandleImporter: insufficient data to establish links '
        '(handles: ${handles.length}, channels: ${channels.length}).',
      );
      ctx.writeScratch('contactHandleLinks.inserted', 0);
      await ctx.importDb.updateContactIgnoreFlags(batchId: ctx.batchId);
      return;
    }

    final handleIndex = <String, List<int>>{};
    for (final handle in handles) {
      final handleId = handle['id'] as int?;
      if (handleId == null) {
        continue;
      }

      final rawIdentifier = _trim(handle['raw_identifier']);
      final normalizedIdentifier = _trim(handle['normalized_identifier']);

      final normalizedKey =
          normalizedIdentifier?.toLowerCase() ??
          normalizeIdentifier(rawIdentifier)?.toLowerCase();
      if (normalizedKey != null && normalizedKey.isNotEmpty) {
        handleIndex.putIfAbsent(normalizedKey, () => []).add(handleId);
      }

      if (rawIdentifier != null && rawIdentifier.isNotEmpty) {
        final rawKey = rawIdentifier.toLowerCase();
        handleIndex.putIfAbsent(rawKey, () => []).add(handleId);
      }
    }

    final links = <Map<String, int>>[];
    var processed = 0;

    for (final channel in channels) {
      final contactZpk = channel['contact_Z_PK'] as int?;
      final kind = channel['kind'] as String?;
      final value = _trim(channel['value']);
      if (contactZpk == null || value == null || value.isEmpty) {
        processed += 1;
        continue;
      }

      final baseKey = value.toLowerCase();
      final normalizedKey = kind == 'phone'
          ? normalizeIdentifier(value)?.toLowerCase()
          : baseKey;

      final handleIds =
          handleIndex[normalizedKey ?? baseKey] ?? handleIndex[baseKey];
      if (handleIds == null || handleIds.isEmpty) {
        processed += 1;
        continue;
      }

      // Link this contact to ALL matching handles (e.g., both iMessage and SMS)
      for (final handleId in handleIds) {
        links.add(<String, int>{
          'contact_Z_PK': contactZpk,
          'chat_handle_id': handleId,
        });
      }

      processed += 1;

      if (processed % 200 == 0 || processed == channels.length) {
        ctx.info(
          'ContactToChatHandleImporter: processed '
          '$processed/${channels.length} channels (linked ${links.length})',
        );
        reportRowProgress(processed: processed, total: channels.length);
      }
    }

    // Batch insert all links at once
    await ctx.importDb.insertContactHandleLinksBatch(
      links: links,
      batchId: ctx.batchId,
    );

    await ctx.importDb.updateContactIgnoreFlags(batchId: ctx.batchId);
    ctx.writeScratch('contactHandleLinks.inserted', links.length);
  }

  @override
  Future<void> postValidate(IImportContext ctx) async {
    final total = await count(ctx.importDb, name);
    ctx.info(
      'ContactToChatHandleImporter: ledger now tracks $total handle/contact links.',
    );
  }
}

String? _trim(Object? value) {
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
  return null;
}
