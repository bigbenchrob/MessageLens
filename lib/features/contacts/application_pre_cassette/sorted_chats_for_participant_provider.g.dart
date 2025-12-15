// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sorted_chats_for_participant_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sortedChatsForParticipantHash() =>
    r'f3090720ae41dfd54a100e719761502335d30c5a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provides sorted chats for a participant based on the selected view mode
///
/// Copied from [sortedChatsForParticipant].
@ProviderFor(sortedChatsForParticipant)
const sortedChatsForParticipantProvider = SortedChatsForParticipantFamily();

/// Provides sorted chats for a participant based on the selected view mode
///
/// Copied from [sortedChatsForParticipant].
class SortedChatsForParticipantFamily
    extends Family<AsyncValue<List<RecentChatSummary>>> {
  /// Provides sorted chats for a participant based on the selected view mode
  ///
  /// Copied from [sortedChatsForParticipant].
  const SortedChatsForParticipantFamily();

  /// Provides sorted chats for a participant based on the selected view mode
  ///
  /// Copied from [sortedChatsForParticipant].
  SortedChatsForParticipantProvider call({
    required int participantId,
    required ChatViewMode viewMode,
  }) {
    return SortedChatsForParticipantProvider(
      participantId: participantId,
      viewMode: viewMode,
    );
  }

  @override
  SortedChatsForParticipantProvider getProviderOverride(
    covariant SortedChatsForParticipantProvider provider,
  ) {
    return call(
      participantId: provider.participantId,
      viewMode: provider.viewMode,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sortedChatsForParticipantProvider';
}

/// Provides sorted chats for a participant based on the selected view mode
///
/// Copied from [sortedChatsForParticipant].
class SortedChatsForParticipantProvider
    extends AutoDisposeFutureProvider<List<RecentChatSummary>> {
  /// Provides sorted chats for a participant based on the selected view mode
  ///
  /// Copied from [sortedChatsForParticipant].
  SortedChatsForParticipantProvider({
    required int participantId,
    required ChatViewMode viewMode,
  }) : this._internal(
         (ref) => sortedChatsForParticipant(
           ref as SortedChatsForParticipantRef,
           participantId: participantId,
           viewMode: viewMode,
         ),
         from: sortedChatsForParticipantProvider,
         name: r'sortedChatsForParticipantProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$sortedChatsForParticipantHash,
         dependencies: SortedChatsForParticipantFamily._dependencies,
         allTransitiveDependencies:
             SortedChatsForParticipantFamily._allTransitiveDependencies,
         participantId: participantId,
         viewMode: viewMode,
       );

  SortedChatsForParticipantProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.participantId,
    required this.viewMode,
  }) : super.internal();

  final int participantId;
  final ChatViewMode viewMode;

  @override
  Override overrideWith(
    FutureOr<List<RecentChatSummary>> Function(
      SortedChatsForParticipantRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SortedChatsForParticipantProvider._internal(
        (ref) => create(ref as SortedChatsForParticipantRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        participantId: participantId,
        viewMode: viewMode,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<RecentChatSummary>> createElement() {
    return _SortedChatsForParticipantProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SortedChatsForParticipantProvider &&
        other.participantId == participantId &&
        other.viewMode == viewMode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, participantId.hashCode);
    hash = _SystemHash.combine(hash, viewMode.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SortedChatsForParticipantRef
    on AutoDisposeFutureProviderRef<List<RecentChatSummary>> {
  /// The parameter `participantId` of this provider.
  int get participantId;

  /// The parameter `viewMode` of this provider.
  ChatViewMode get viewMode;
}

class _SortedChatsForParticipantProviderElement
    extends AutoDisposeFutureProviderElement<List<RecentChatSummary>>
    with SortedChatsForParticipantRef {
  _SortedChatsForParticipantProviderElement(super.provider);

  @override
  int get participantId =>
      (origin as SortedChatsForParticipantProvider).participantId;
  @override
  ChatViewMode get viewMode =>
      (origin as SortedChatsForParticipantProvider).viewMode;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
