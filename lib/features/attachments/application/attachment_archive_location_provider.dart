import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider;
import '../domain/entities/attachment_archive_location_configuration.dart';
import '../domain/entities/attachment_archive_location_state.dart';
import 'attachment_archive_location_controller.dart';
import 'attachment_archive_location_dependencies_provider.dart';
import 'attachment_archive_location_native_adapter.dart';
import 'attachment_archive_settings_store_provider.dart';

part 'attachment_archive_location_provider.g.dart';

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
}

/// Grants existing mutation paths access only to the admitted internal root.
///
/// Custom roots remain read/location-only until the later writable-root lease
/// phase, regardless of their physical writability.
@Riverpod(keepAlive: true)
Future<AttachmentArchiveMutationRoot> attachmentArchiveMutationRoot(Ref ref) {
  return _loadAttachmentArchiveMutationRoot(ref);
}

Future<AttachmentArchiveMutationRoot> _loadAttachmentArchiveMutationRoot(
  Ref ref,
) async {
  final location = await ref.watch(attachmentArchiveLocationProvider.future);
  return location.requireInternalMutationRoot();
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
