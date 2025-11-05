import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart';
import 'unmatched_handles_provider.dart';

part 'manual_handle_link_service.g.dart';

/// Simple failure wrapper for service-level errors
class Failure {
  const Failure(this.message, {this.stackTrace});

  final String message;
  final StackTrace? stackTrace;

  @override
  String toString() => 'Failure: $message';
}

/// Service for managing manual handle-to-contact links
///
/// This service coordinates between overlay and working databases to:
/// 1. Create user-defined handle-participant associations
/// 2. Update the working database projection
/// 3. Rebuild affected message indexes
/// 4. Invalidate cached providers
@riverpod
class ManualHandleLinkService extends _$ManualHandleLinkService {
  @override
  void build() {
    // Stateless service, no initialization needed
  }

  /// Links a handle to a participant manually
  ///
  /// Returns:
  /// - Right(unit) on success
  /// - Left(Failure) if handle already manually linked to a different participant
  Future<Either<Failure, Unit>> linkHandleToParticipant({
    required int handleId,
    required int participantId,
  }) async {
    try {
      final overlayDb = await ref.read(overlayDatabaseProvider.future);
      final workingDb = await ref.read(driftWorkingDatabaseProvider.future);

      // Check if manual link already exists
      final existingOverride = await overlayDb.getHandleOverride(handleId);

      if (existingOverride != null &&
          existingOverride.participantId != participantId) {
        return const Left(
          Failure(
            'Handle is already manually linked to a different contact. '
            'Delete the existing link first.',
          ),
        );
      }

      // Step 1: Create or update overlay link
      await overlayDb.setHandleOverride(handleId, participantId);

      // Step 2: Update working.handle_to_participant
      // Delete existing links for this handle, then insert the new manual link
      await workingDb.transaction(() async {
        await workingDb.customStatement(
          '''
          DELETE FROM handle_to_participant
          WHERE handle_id = ?
          ''',
          [handleId],
        );

        await workingDb.customStatement(
          '''
          INSERT INTO handle_to_participant (handle_id, participant_id, confidence, source)
          VALUES (?, ?, 1.0, 'user_manual')
          ''',
          [handleId, participantId],
        );
      });

      // Step 3: Rebuild contact message index for this participant
      await workingDb.rebuildContactMessageIndexForParticipant(participantId);

      // Step 4: Invalidate cached providers
      // Note: Provider names may need adjustment based on actual implementation
      ref.invalidate(unmatchedPhonesProvider);
      ref.invalidate(unmatchedEmailsProvider);

      return const Right(unit);
    } catch (e, stackTrace) {
      return Left(
        Failure('Failed to link handle to contact: $e', stackTrace: stackTrace),
      );
    }
  }

  /// Removes a manual link between handle and participant
  ///
  /// This reverts the handle to its automatic link (if any) or unlinked status.
  Future<Either<Failure, Unit>> unlinkHandle({required int handleId}) async {
    try {
      final overlayDb = await ref.read(overlayDatabaseProvider.future);
      final workingDb = await ref.read(driftWorkingDatabaseProvider.future);

      // Check if manual link exists
      final existingOverride = await overlayDb.getHandleOverride(handleId);

      if (existingOverride == null) {
        return const Left(Failure('No manual link found for this handle.'));
      }

      final participantId = existingOverride.participantId;

      // Step 1: Remove overlay link
      await overlayDb.deleteHandleOverride(handleId);

      // Step 2: Remove from working.handle_to_participant
      // This will be re-added by next migration if there's an automatic match
      await workingDb.customStatement(
        '''
        DELETE FROM handle_to_participant
        WHERE handle_id = ?
        ''',
        [handleId],
      );

      // Step 3: Rebuild contact message index for affected participant
      await workingDb.rebuildContactMessageIndexForParticipant(participantId);

      // Step 4: Invalidate cached providers
      ref.invalidate(unmatchedPhonesProvider);
      ref.invalidate(unmatchedEmailsProvider);

      return const Right(unit);
    } catch (e, stackTrace) {
      return Left(
        Failure('Failed to unlink handle: $e', stackTrace: stackTrace),
      );
    }
  }
}
