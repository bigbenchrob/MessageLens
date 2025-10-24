// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_linking_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unlinkedHandlesHash() => r'8f46160845f93188f6c35b5ac4b038bc0d659265';

/// Provider that finds handles not linked to any participant
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
    r'2b74851c12a79f94ac56012c30e18ed6fd1834d6';

/// Provider that gets all available participants for linking
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
String _$manualLinkingHash() => r'e79fd52ae764dae5d9331bac1a1f8cd60430052b';

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
