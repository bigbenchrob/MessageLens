import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/application/supabase_api_url_provider.dart';
import '../../../config/application/supabase_service_role_key_provider.dart';
import '../../../db/feature_level_providers.dart';
import '../../../db_importers/application/debug_settings_provider.dart';
import '../supabase/supabase_mirror_sync_service.dart';

part 'supabase_mirror_sync_service_provider.g.dart';

/// Provides the application-layer service responsible for mirroring batches
/// into Supabase once the working database is populated.
@riverpod
Future<SupabaseMirrorSyncService> supabaseMirrorSyncService(Ref ref) async {
  final database = await ref.watch(driftWorkingDatabaseProvider.future);
  final supabaseUrl = ref.watch(supabaseApiUrlProvider);
  final serviceRoleKey = ref.watch(supabaseServiceRoleKeyProvider);
  final debugSettings = ref.watch(importDebugSettingsProvider);

  final service = SupabaseMirrorSyncService(
    database: database,
    supabaseApiUrl: supabaseUrl,
    serviceRoleKey: serviceRoleKey,
    debugSettings: debugSettings,
  );

  ref.onDispose(() async {
    await service.dispose();
  });

  return service;
}
