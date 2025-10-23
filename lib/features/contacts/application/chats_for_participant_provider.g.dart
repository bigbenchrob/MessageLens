// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chats_for_participant_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatsForParticipantHash() =>
    r'15b47952fb06f455702fe8a64689938fa2c31ed5';

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

/// See also [chatsForParticipant].
@ProviderFor(chatsForParticipant)
const chatsForParticipantProvider = ChatsForParticipantFamily();

/// See also [chatsForParticipant].
class ChatsForParticipantFamily
    extends Family<AsyncValue<List<RecentChatSummary>>> {
  /// See also [chatsForParticipant].
  const ChatsForParticipantFamily();

  /// See also [chatsForParticipant].
  ChatsForParticipantProvider call({required int participantId}) {
    return ChatsForParticipantProvider(participantId: participantId);
  }

  @override
  ChatsForParticipantProvider getProviderOverride(
    covariant ChatsForParticipantProvider provider,
  ) {
    return call(participantId: provider.participantId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatsForParticipantProvider';
}

/// See also [chatsForParticipant].
class ChatsForParticipantProvider
    extends AutoDisposeFutureProvider<List<RecentChatSummary>> {
  /// See also [chatsForParticipant].
  ChatsForParticipantProvider({required int participantId})
    : this._internal(
        (ref) => chatsForParticipant(
          ref as ChatsForParticipantRef,
          participantId: participantId,
        ),
        from: chatsForParticipantProvider,
        name: r'chatsForParticipantProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chatsForParticipantHash,
        dependencies: ChatsForParticipantFamily._dependencies,
        allTransitiveDependencies:
            ChatsForParticipantFamily._allTransitiveDependencies,
        participantId: participantId,
      );

  ChatsForParticipantProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.participantId,
  }) : super.internal();

  final int participantId;

  @override
  Override overrideWith(
    FutureOr<List<RecentChatSummary>> Function(ChatsForParticipantRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChatsForParticipantProvider._internal(
        (ref) => create(ref as ChatsForParticipantRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        participantId: participantId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<RecentChatSummary>> createElement() {
    return _ChatsForParticipantProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatsForParticipantProvider &&
        other.participantId == participantId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, participantId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatsForParticipantRef
    on AutoDisposeFutureProviderRef<List<RecentChatSummary>> {
  /// The parameter `participantId` of this provider.
  int get participantId;
}

class _ChatsForParticipantProviderElement
    extends AutoDisposeFutureProviderElement<List<RecentChatSummary>>
    with ChatsForParticipantRef {
  _ChatsForParticipantProviderElement(super.provider);

  @override
  int get participantId =>
      (origin as ChatsForParticipantProvider).participantId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
