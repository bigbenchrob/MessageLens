import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/logging/application/app_logger.dart';
import '../../../handles/infrastructure/repositories/stray_handles_provider.dart';
import '../../infrastructure/repositories/virtual_participants_provider.dart';

part 'manual_handle_link_service.g.dart';

/// Simple failure wrapper for service-level errors
class Failure {
  const Failure(this.message, {this.stackTrace});

  final String message;
  final StackTrace? stackTrace;

  @override
  String toString() => 'Failure: $message';
}

/// Service for managing manual handle-to-contact links.
///
/// All writes target the overlay database exclusively. The working database
/// is never modified here — providers merge both databases at read time
/// with overlay winning on conflict (inviolable architectural rule).
@riverpod
class ManualHandleLinkService extends _$ManualHandleLinkService {
  @override
  void build() {
    // Stateless service, no initialization needed
  }

  /// Creates a virtual participant stored solely in the overlay database.
  ///
  /// Returns the new overlay-scoped participant ID on success, or
  /// `Failure` when validation fails or persistence encounters an error.
  Future<Either<Failure, int>> createVirtualParticipant({
    required String displayName,
    String? notes,
  }) async {
    final normalizedName = displayName.trim();
    if (normalizedName.isEmpty) {
      return const Left(
        Failure('Display name cannot be empty when creating a contact.'),
      );
    }

    try {
      final overlayDb = await ref.read(overlayDatabaseProvider.future);
      final existing = await overlayDb.getVirtualParticipants();
      final normalizedLower = normalizedName.toLowerCase();

      final hasDuplicate = existing.any(
        (participant) =>
            participant.displayName.toLowerCase() == normalizedLower,
      );

      if (hasDuplicate) {
        ref
            .read(appLoggerProvider.notifier)
            .warn(
              'Duplicate virtual contact name requested: $normalizedName',
              source: 'ManualHandleLinkService',
              context: {'displayName': normalizedName},
            );
      }

      final created = await overlayDb.createVirtualParticipant(
        displayName: normalizedName,
        notes: notes,
      );

      ref.invalidate(virtualParticipantsProvider);

      return Right(created.id);
    } catch (e, stackTrace) {
      return Left(
        Failure('Failed to create virtual contact: $e', stackTrace: stackTrace),
      );
    }
  }

  /// Links a handle to a real (working-DB) participant.
  ///
  /// Writes only to the overlay database. Providers merge at read time.
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

      // Check if manual link already exists to a different participant
      final existingOverride = await overlayDb.getHandleOverride(handleId);

      if (existingOverride != null &&
          existingOverride.participantId != null &&
          existingOverride.participantId != participantId) {
        return const Left(
          Failure(
            'Handle is already manually linked to a different contact. '
            'Delete the existing link first.',
          ),
        );
      }

      // Write overlay-only link
      await overlayDb.setHandleOverride(handleId, participantId);

      // Invalidate cached providers
      ref.invalidate(strayHandlesProvider);

      return const Right(unit);
    } catch (e, stackTrace) {
      return Left(
        Failure('Failed to link handle to contact: $e', stackTrace: stackTrace),
      );
    }
  }

  /// Links a handle to a virtual participant (overlay-DB).
  ///
  /// Typically called after creating a virtual participant, to associate
  /// the stray handle with the newly-named contact.
  Future<Either<Failure, Unit>> linkHandleToVirtualParticipant({
    required int handleId,
    required int virtualParticipantId,
  }) async {
    try {
      final overlayDb = await ref.read(overlayDatabaseProvider.future);

      await overlayDb.setHandleVirtualParticipantOverride(
        handleId,
        virtualParticipantId,
      );

      // Invalidate cached providers
      ref.invalidate(strayHandlesProvider);
      ref.invalidate(virtualParticipantsProvider);

      return const Right(unit);
    } catch (e, stackTrace) {
      return Left(
        Failure(
          'Failed to link handle to virtual contact: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Removes a manual link between handle and participant.
  ///
  /// Deletes the overlay override only. The working database is not touched.
  /// The handle reverts to its automatic link (if any) or unlinked status.
  Future<Either<Failure, Unit>> unlinkHandle({required int handleId}) async {
    try {
      final overlayDb = await ref.read(overlayDatabaseProvider.future);

      // Check if manual link exists
      final existingOverride = await overlayDb.getHandleOverride(handleId);

      if (existingOverride == null) {
        return const Left(Failure('No manual link found for this handle.'));
      }

      // Remove overlay link only
      await overlayDb.deleteHandleOverride(handleId);

      // Invalidate cached providers
      ref.invalidate(strayHandlesProvider);

      return const Right(unit);
    } catch (e, stackTrace) {
      return Left(
        Failure('Failed to unlink handle: $e', stackTrace: stackTrace),
      );
    }
  }
}
