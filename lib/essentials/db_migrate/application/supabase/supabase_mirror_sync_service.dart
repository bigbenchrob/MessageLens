import '../../../config/domain/value_objects/supabase_api_url.dart';
import '../../../config/domain/value_objects/supabase_service_role_key.dart';
import '../../../db/infrastructure/data_sources/local/working/working_database.dart';
import '../../../db_importers/application/debug_settings_provider.dart';

/// Coordinates mirroring the working database into Supabase.
///
/// This service is intentionally lightweight for now; concrete sync logic and
/// drift queries will be added once the infrastructure DTOs and payload
/// builders land. For the moment we expose structured entry points so the
/// migration pipeline and UI can trigger sync runs without needing to know the
/// eventual implementation details.
class SupabaseMirrorSyncService {
  SupabaseMirrorSyncService({
    required WorkingDatabase database,
    required SupabaseApiUrl supabaseApiUrl,
    required SupabaseServiceRoleKey serviceRoleKey,
    required ImportDebugSettingsState debugSettings,
  }) : _database = database,
       _supabaseApiUrl = supabaseApiUrl,
       _serviceRoleKey = serviceRoleKey,
       _debugSettings = debugSettings;

  final WorkingDatabase _database;
  final SupabaseApiUrl _supabaseApiUrl;
  final SupabaseServiceRoleKey _serviceRoleKey;
  final ImportDebugSettingsState _debugSettings;

  /// Ensures any pending migration batches are mirrored to Supabase.
  Future<void> syncAllPendingBatches() async {
    _debugSettings.logProgress(
      'Stub Supabase sync invoked for endpoint ${_supabaseApiUrl.getOrCrash()}',
    );

    _debugSettings.logProgress(
      'Using service role key ${_serviceRoleKey.masked()} for authentication.',
    );

    // Touch the database so lint rules know the dependency is wired.
    await _database.customSelect('SELECT 1;').getSingleOrNull();
  }

  /// Mirrors the specified batch. Consumers can supply a batch identifier to
  /// re-run individual slices when debugging.
  Future<void> mirrorBatch({required int batchId}) async {
    _debugSettings.logProgress(
      'Stub Supabase batch sync requested for batch $batchId '
      'to ${_supabaseApiUrl.getOrCrash()}',
    );
  }

  /// Allows explicit disposal hooks when the provider owning this service is
  /// torn down. This keeps the API symmetrical before we introduce stream
  /// subscriptions or cached HTTP clients.
  Future<void> dispose() async {
    _debugSettings.logProgress('Disposing Supabase mirror sync service stub.');
  }
}
