import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/archive_environment/domain.dart'
    show ArchiveMutationOperation;
import '../../../essentials/archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider;
import '../domain/entities/attachment_archive_location_configuration.dart';
import '../domain/entities/attachment_archive_location_state.dart';
import 'attachment_archive_location_controller.dart';
import 'attachment_archive_location_dependencies_provider.dart';
import 'attachment_archive_location_native_adapter.dart';
import 'attachment_archive_settings_store_provider.dart';

part 'attachment_archive_location_provider.g.dart';

/// Stable mutation checkpoints at which a writable-root lease is revalidated.
enum AttachmentArchiveMutationBoundary {
  operationStart,
  beforeRootCreation,
  beforeSourceRead,
  afterSourceHash,
  beforeTemporaryCopy,
  beforePayloadVerification,
  beforeFinalInstall,
  afterFinalInstall,
  beforeMetadataCommit,
  beforeDestructiveReset,
}

/// Typed reasons why attachment archive mutation must wait or remain denied.
enum AttachmentArchiveMutationDeferredReason {
  customArchiveNotActivated,
  customArchiveReadOnly,
  customArchiveUnavailable,
  permissionDenied,
  configuredDirectoryMissing,
  configurationInvalid,
  locationStateUnavailable,
  staleGeneration,
  staleConfigurationIdentity,
  resolvedRootChanged,
  destructiveResetNotPermitted,
}

@immutable
final class AttachmentArchiveWritableRootValidation {
  const AttachmentArchiveWritableRootValidation.valid()
    : deferredReason = null,
      issue = null;

  const AttachmentArchiveWritableRootValidation.deferred({
    required this.deferredReason,
    this.issue,
  });

  final AttachmentArchiveMutationDeferredReason? deferredReason;
  final String? issue;

  bool get isValid => deferredReason == null;
}

typedef _WritableRootLeaseValidator =
    Future<AttachmentArchiveWritableRootValidation> Function(
      AttachmentArchiveWritableRootLease lease,
      ArchiveMutationOperation operation,
      AttachmentArchiveMutationBoundary boundary,
    );

/// Opaque, generation-bound authority for one currently writable archive root.
///
/// Only this location module can construct a lease. A root path, remembered
/// display path, or arbitrary location state is therefore insufficient write
/// authority. Callers must revalidate the lease at mutation boundaries.
@immutable
final class AttachmentArchiveWritableRootLease {
  const AttachmentArchiveWritableRootLease._({
    required this.archiveRootPath,
    required this.locationGeneration,
    required this.locationMode,
    required this.permitsDestructiveReset,
    required AttachmentArchiveLocationConfiguration configurationIdentity,
    required _WritableRootLeaseValidator validator,
  }) : _configurationIdentity = configurationIdentity,
       _validator = validator;

  final String archiveRootPath;
  final int locationGeneration;
  final AttachmentArchiveLocationMode locationMode;
  final bool permitsDestructiveReset;
  final AttachmentArchiveLocationConfiguration _configurationIdentity;
  final _WritableRootLeaseValidator _validator;

  Future<AttachmentArchiveWritableRootValidation> validate({
    required ArchiveMutationOperation operation,
    required AttachmentArchiveMutationBoundary boundary,
  }) {
    return _validator(this, operation, boundary);
  }

  Future<void> requireValid({
    required ArchiveMutationOperation operation,
    required AttachmentArchiveMutationBoundary boundary,
  }) async {
    final validation = await validate(operation: operation, boundary: boundary);
    if (!validation.isValid) {
      throw AttachmentArchiveMutationDeferredException(
        reason: validation.deferredReason!,
        boundary: boundary,
        issue: validation.issue,
      );
    }
  }
}

@immutable
final class AttachmentArchiveWritableRootAdmission {
  const AttachmentArchiveWritableRootAdmission.admitted(this.lease)
    : deferredReason = null,
      issue = null;

  const AttachmentArchiveWritableRootAdmission.deferred({
    required this.deferredReason,
    this.issue,
  }) : lease = null;

  final AttachmentArchiveWritableRootLease? lease;
  final AttachmentArchiveMutationDeferredReason? deferredReason;
  final String? issue;

  bool get isAdmitted => lease != null;
}

final class AttachmentArchiveMutationDeferredException implements Exception {
  const AttachmentArchiveMutationDeferredException({
    required this.reason,
    required this.boundary,
    this.issue,
  });

  final AttachmentArchiveMutationDeferredReason reason;
  final AttachmentArchiveMutationBoundary boundary;
  final String? issue;

  @override
  String toString() {
    return 'AttachmentArchiveMutationDeferredException('
        '${reason.name}, ${boundary.name})'
        '${issue == null ? '' : ': $issue'}';
  }
}

/// Publishes the active attachment-owned archive location.
///
/// Loading performs one overlay setting read and, for custom configuration, a
/// bounded bookmark resolution. It never creates, inventories, or recursively
/// traverses the payload directory.
@Riverpod(keepAlive: true)
class AttachmentArchiveLocation extends _$AttachmentArchiveLocation {
  AttachmentArchiveLocationController? _controller;
  AttachmentArchiveLocationNativeAdapter? _nativeAdapter;
  _AttachmentArchiveLocationEventListener? _eventListener;
  AttachmentArchiveLocationState? _lastPublishedLocation;
  var _resolutionSerial = 0;
  var _forceNextGenerationAdvance = false;
  var _disposeRegistered = false;

  @override
  Future<AttachmentArchiveLocationState> build() async {
    final archiveAccessAuthority = ref.watch(archiveAccessAuthorityProvider);
    final nativeAdapter = ref.watch(
      attachmentArchiveLocationNativeAdapterProvider,
    );
    final settingsStore = await ref.watch(
      attachmentArchiveSettingsStoreProvider.future,
    );
    _nativeAdapter = nativeAdapter;
    _controller = AttachmentArchiveLocationController(
      archiveAccessAuthority: archiveAccessAuthority,
      settingsStore: settingsStore,
      nativeAdapter: nativeAdapter,
    );
    if (!_disposeRegistered) {
      _disposeRegistered = true;
      ref.onDispose(() {
        unawaited(_disposeEventListener());
      });
    }

    final candidate = await _controllerOrThrow().load();
    final next = _withCurrentGeneration(candidate);
    await _synchronizeEventSubscription(next);
    return next;
  }

  Future<bool> chooseCustomLocation() async {
    await _ensureInitialized();
    final chooser = ref.read(attachmentArchiveLocationFolderChooserProvider);
    final selectedPath = await chooser.chooseArchiveDirectory();
    if (selectedPath == null) {
      return false;
    }
    await configureCustomLocation(directoryPath: selectedPath);
    return true;
  }

  Future<void> configureCustomLocation({required String directoryPath}) async {
    await _ensureInitialized();
    final creation = await _nativeAdapterOrThrow().createBookmark(
      directoryPath: directoryPath,
    );
    final configuration = AttachmentArchiveLocationConfiguration.customExternal(
      bookmarkDataBase64: creation.bookmarkDataBase64,
      lastKnownPath: creation.resolvedPath,
      volumeName: creation.volumeName,
    );
    await _controllerOrThrow().persistConfiguration(configuration);
    await _refresh(forceGenerationAdvance: true);
  }

  Future<void> useDefaultInternalLocation() async {
    await _ensureInitialized();
    await _controllerOrThrow().persistConfiguration(
      const AttachmentArchiveLocationConfiguration.defaultInternal(),
    );
    await _refresh(forceGenerationAdvance: true);
  }

  Future<void> refresh() async {
    await _ensureInitialized();
    await _refresh();
  }

  Future<void> _ensureInitialized() async {
    if (_controller == null || _nativeAdapter == null) {
      await future;
    }
  }

  Future<void> _refresh({bool forceGenerationAdvance = false}) async {
    if (forceGenerationAdvance) {
      _forceNextGenerationAdvance = true;
    }
    final requestSerial = ++_resolutionSerial;
    try {
      final candidate = await _controllerOrThrow().load();
      if (requestSerial != _resolutionSerial) {
        return;
      }
      final next = _withCurrentGeneration(
        candidate,
        forceGenerationAdvance: _forceNextGenerationAdvance,
      );
      _forceNextGenerationAdvance = false;
      await _synchronizeEventSubscription(next);
      if (state.valueOrNull != next) {
        state = AsyncData(next);
      }
    } on Object catch (error, stackTrace) {
      if (requestSerial == _resolutionSerial) {
        state = AsyncError(error, stackTrace);
      }
    }
  }

  AttachmentArchiveLocationState _withCurrentGeneration(
    AttachmentArchiveLocationState candidate, {
    bool forceGenerationAdvance = false,
  }) {
    final previous = _lastPublishedLocation;
    final generation = previous == null
        ? AttachmentArchiveLocationState.initialGeneration
        : forceGenerationAdvance ||
              !candidate.hasSameEffectiveLocationAs(previous)
        ? previous.generation + 1
        : previous.generation;
    final next = candidate.withGeneration(generation);
    _lastPublishedLocation = next;
    return next;
  }

  Future<void> _synchronizeEventSubscription(
    AttachmentArchiveLocationState location,
  ) async {
    final isCustom =
        location.configuration?.mode ==
        AttachmentArchiveLocationMode.customExternal;
    if (!isCustom) {
      await _disposeEventListener();
      return;
    }
    if (_eventListener != null) {
      return;
    }
    _eventListener = _AttachmentArchiveLocationEventListener(
      events: _nativeAdapterOrThrow().locationEvents,
      onEvent: (_) {
        unawaited(_refresh());
      },
      onError: (Object error, StackTrace stackTrace) {
        state = AsyncError(error, stackTrace);
      },
    );
  }

  Future<void> _disposeEventListener() async {
    final listener = _eventListener;
    _eventListener = null;
    if (listener != null) {
      await listener.dispose();
    }
  }

  AttachmentArchiveLocationController _controllerOrThrow() {
    final controller = _controller;
    if (controller == null) {
      throw StateError('Attachment archive location is not initialized.');
    }
    return controller;
  }

  AttachmentArchiveLocationNativeAdapter _nativeAdapterOrThrow() {
    final nativeAdapter = _nativeAdapter;
    if (nativeAdapter == null) {
      throw StateError(
        'Attachment archive native location adapter is not initialized.',
      );
    }
    return nativeAdapter;
  }

  Future<AttachmentArchiveLocationState> _currentLocationForLeaseValidation() {
    final current = state.valueOrNull;
    if (current != null) {
      return Future.value(current);
    }
    return future;
  }

  _AttachmentArchiveLeaseRevocationToken _createLeaseRevocationToken() {
    final token = _AttachmentArchiveLeaseRevocationToken();
    ref.onDispose(token.revoke);
    return token;
  }
}

/// Issues the only writable-root authority accepted by archive mutation paths.
///
/// Custom selections remain mutation-ineligible until their configuration is
/// explicitly marked active by a later verified relocation workflow.
@Riverpod(keepAlive: true)
Future<AttachmentArchiveWritableRootAdmission>
attachmentArchiveWritableRootAdmission(Ref ref) async {
  final location = await ref.watch(attachmentArchiveLocationProvider.future);
  return _admitWritableRoot(ref, location);
}

AttachmentArchiveWritableRootAdmission _admitWritableRoot(
  Ref ref,
  AttachmentArchiveLocationState location,
) {
  final configuration = location.configuration;
  final rootPath = location.archiveRootPath;
  final deferredReason = _deferredReasonForLocation(location);
  if (deferredReason != null || configuration == null || rootPath == null) {
    return AttachmentArchiveWritableRootAdmission.deferred(
      deferredReason:
          deferredReason ??
          AttachmentArchiveMutationDeferredReason.locationStateUnavailable,
      issue: location.issue,
    );
  }

  final locationAuthority = ref.read(
    attachmentArchiveLocationProvider.notifier,
  );
  final revocationToken = locationAuthority._createLeaseRevocationToken();

  return AttachmentArchiveWritableRootAdmission.admitted(
    AttachmentArchiveWritableRootLease._(
      archiveRootPath: rootPath,
      locationGeneration: location.generation,
      locationMode: configuration.mode,
      permitsDestructiveReset:
          configuration.mode == AttachmentArchiveLocationMode.defaultInternal,
      configurationIdentity: configuration,
      validator: (lease, operation, boundary) async {
        if (revocationToken.isRevoked) {
          return const AttachmentArchiveWritableRootValidation.deferred(
            deferredReason:
                AttachmentArchiveMutationDeferredReason.staleGeneration,
            issue: 'The location authority that issued this lease was reset.',
          );
        }
        final current = await locationAuthority
            ._currentLocationForLeaseValidation();
        if (revocationToken.isRevoked) {
          return const AttachmentArchiveWritableRootValidation.deferred(
            deferredReason:
                AttachmentArchiveMutationDeferredReason.staleGeneration,
            issue: 'The location authority that issued this lease was reset.',
          );
        }
        return _validateWritableRootLease(
          lease: lease,
          operation: operation,
          boundary: boundary,
          current: current,
        );
      },
    ),
  );
}

AttachmentArchiveWritableRootValidation _validateWritableRootLease({
  required AttachmentArchiveWritableRootLease lease,
  required ArchiveMutationOperation operation,
  required AttachmentArchiveMutationBoundary boundary,
  required AttachmentArchiveLocationState current,
}) {
  if (current.generation != lease.locationGeneration) {
    return const AttachmentArchiveWritableRootValidation.deferred(
      deferredReason: AttachmentArchiveMutationDeferredReason.staleGeneration,
    );
  }
  if (current.configuration != lease._configurationIdentity) {
    return const AttachmentArchiveWritableRootValidation.deferred(
      deferredReason:
          AttachmentArchiveMutationDeferredReason.staleConfigurationIdentity,
    );
  }
  if (current.archiveRootPath != lease.archiveRootPath) {
    return const AttachmentArchiveWritableRootValidation.deferred(
      deferredReason:
          AttachmentArchiveMutationDeferredReason.resolvedRootChanged,
    );
  }
  final deferredReason = _deferredReasonForLocation(current);
  if (deferredReason != null) {
    return AttachmentArchiveWritableRootValidation.deferred(
      deferredReason: deferredReason,
      issue: current.issue,
    );
  }
  if (operation == ArchiveMutationOperation.attachmentClearing &&
      !lease.permitsDestructiveReset) {
    return const AttachmentArchiveWritableRootValidation.deferred(
      deferredReason:
          AttachmentArchiveMutationDeferredReason.destructiveResetNotPermitted,
    );
  }
  return const AttachmentArchiveWritableRootValidation.valid();
}

AttachmentArchiveMutationDeferredReason? _deferredReasonForLocation(
  AttachmentArchiveLocationState location,
) {
  final configuration = location.configuration;
  return switch (location.availability) {
    AttachmentArchiveLocationAvailability.defaultAvailable =>
      configuration?.mode == AttachmentArchiveLocationMode.defaultInternal
          ? null
          : AttachmentArchiveMutationDeferredReason.configurationInvalid,
    AttachmentArchiveLocationAvailability.customAvailable =>
      configuration?.mode == AttachmentArchiveLocationMode.customExternal &&
              configuration?.customWritePolicy ==
                  AttachmentArchiveCustomWritePolicy.activeArchive
          ? null
          : AttachmentArchiveMutationDeferredReason.customArchiveNotActivated,
    AttachmentArchiveLocationAvailability.customReadOnly =>
      AttachmentArchiveMutationDeferredReason.customArchiveReadOnly,
    AttachmentArchiveLocationAvailability.customUnavailable =>
      AttachmentArchiveMutationDeferredReason.customArchiveUnavailable,
    AttachmentArchiveLocationAvailability.permissionDenied =>
      AttachmentArchiveMutationDeferredReason.permissionDenied,
    AttachmentArchiveLocationAvailability.configuredDirectoryMissing =>
      AttachmentArchiveMutationDeferredReason.configuredDirectoryMissing,
    AttachmentArchiveLocationAvailability.configurationInvalid =>
      AttachmentArchiveMutationDeferredReason.configurationInvalid,
  };
}

final class _AttachmentArchiveLeaseRevocationToken {
  bool _isRevoked = false;

  bool get isRevoked => _isRevoked;

  void revoke() {
    _isRevoked = true;
  }
}

final class _AttachmentArchiveLocationEventListener {
  _AttachmentArchiveLocationEventListener({
    required Stream<AttachmentArchiveLocationEvent> events,
    required void Function(AttachmentArchiveLocationEvent event) onEvent,
    required void Function(Object error, StackTrace stackTrace) onError,
  }) : _subscription = events.listen(onEvent, onError: onError);

  final StreamSubscription<AttachmentArchiveLocationEvent> _subscription;

  Future<void> dispose() => _subscription.cancel();
}
