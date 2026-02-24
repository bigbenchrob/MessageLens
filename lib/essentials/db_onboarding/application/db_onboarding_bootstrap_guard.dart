import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../db/feature_level_providers.dart';

part 'db_onboarding_bootstrap_guard.g.dart';

/// Checks whether database onboarding is required.
///
/// Returns `true` if the working database has zero messages and
/// onboarding has not been completed, indicating a first-run scenario.
@riverpod
Future<bool> dbOnboardingRequired(DbOnboardingRequiredRef ref) async {
  try {
    final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);

    // Check if there are any messages in the working database
    final result = await workingDb
        .customSelect('SELECT COUNT(*) as count FROM messages')
        .getSingleOrNull();

    final messageCount = result?.read<int>('count') ?? 0;

    // If zero messages, onboarding is required
    return messageCount == 0;
  } catch (e) {
    // If database doesn't exist or error, onboarding is required
    return true;
  }
}
