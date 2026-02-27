import '../../domain/base_table_importer.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';

/// First importer in the pipeline. Has no dependencies.
///
/// Validates that the source databases (Messages, AddressBook) are accessible
/// and logs the import batch configuration. The actual file resolution and
/// database opening happens before the orchestrator (since the context requires
/// open handles), but this importer makes the preparation step visible in the
/// execution sequence.
class PrepareSourcesImporter extends BaseTableImporter {
  const PrepareSourcesImporter();

  @override
  String get name => 'prepare_sources';

  @override
  String get displayName => 'Prepare Sources';

  @override
  List<String> get dependsOn => const <String>[];

  @override
  Future<void> validatePrereqs(IImportContext ctx) async {
    // Nothing to validate — path resolution already succeeded if we got here.
  }

  @override
  Future<void> copy(IImportContext ctx) async {
    final messageCount = await count(ctx.messagesDb, 'message');
    final handleCount = await count(ctx.messagesDb, 'handle');
    ctx.info(
      'Source databases open. '
      'Messages DB: $handleCount handles, $messageCount messages. '
      'Batch ID: ${ctx.batchId}.',
    );
  }

  @override
  Future<void> postValidate(IImportContext ctx) async {
    // Nothing to post-validate.
  }
}
