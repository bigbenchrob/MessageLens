import '../../domain/base_table_importer.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';

/// Second importer in the pipeline. Depends only on [PrepareSourcesImporter].
///
/// Clears all existing ledger data when performing a fresh (non-incremental)
/// import. For incremental imports this is a no-op, but the importer still
/// runs to maintain a consistent execution sequence.
class ClearLedgerImporter extends BaseTableImporter {
  const ClearLedgerImporter();

  @override
  String get name => 'clear_ledger';

  @override
  String get displayName => 'Clear Ledger';

  @override
  List<String> get dependsOn => const <String>['prepare_sources'];

  @override
  Future<void> validatePrereqs(IImportContext ctx) async {
    // Nothing to validate.
  }

  @override
  Future<void> copy(IImportContext ctx) async {
    if (!ctx.hasExistingLedgerData) {
      ctx.info('Fresh import — clearing all existing ledger data.');
      await ctx.importDb.clearAllData();
    } else {
      ctx.info('Incremental import — preserving existing ledger data.');
    }
  }

  @override
  Future<void> postValidate(IImportContext ctx) async {
    // Nothing to post-validate.
  }
}
