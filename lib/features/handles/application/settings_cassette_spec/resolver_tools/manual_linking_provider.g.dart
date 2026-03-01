// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_linking_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unlinkedHandlesHash() => r'0eafcb0cd9fa71b771b08a10c5174d72d6d767cc';

/// Provider that finds handles not linked to any participant.
///
/// A handle is considered linked if it has a working-DB addressbook link OR an
/// overlay manual link (participant or virtual participant). Overlay visibility
/// overrides (blacklisted) are also merged here.
///
/// Copied from [unlinkedHandles].
@ProviderFor(unlinkedHandles)
final unlinkedHandlesProvider =
    AutoDisposeFutureProvider<List<UnlinkedHandle>>.internal(
      unlinkedHandles,
      name: r'unlinkedHandlesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unlinkedHandlesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnlinkedHandlesRef = AutoDisposeFutureProviderRef<List<UnlinkedHandle>>;
String _$availableParticipantsHash() =>
    r'a6567b296a2f81a6c7462a8692ec562156b908d7';

/// Provider that gets all available participants for linking.
///
/// Handle counts merge working-DB addressbook links with overlay manual links.
///
/// Copied from [availableParticipants].
@ProviderFor(availableParticipants)
final availableParticipantsProvider =
    AutoDisposeFutureProvider<List<AvailableParticipant>>.internal(
      availableParticipants,
      name: r'availableParticipantsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$availableParticipantsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AvailableParticipantsRef =
    AutoDisposeFutureProviderRef<List<AvailableParticipant>>;
String _$manualLinkingHash() => r'7add33d6eb97507c3c4189b96702c08a1a52fc46';

/// Provider for manual linking operations
///
/// Copied from [ManualLinking].
@ProviderFor(ManualLinking)
final manualLinkingProvider =
    AutoDisposeAsyncNotifierProvider<ManualLinking, void>.internal(
      ManualLinking.new,
      name: r'manualLinkingProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$manualLinkingHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ManualLinking = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
