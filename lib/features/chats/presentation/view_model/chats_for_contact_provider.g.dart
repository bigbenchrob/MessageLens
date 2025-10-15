// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chats_for_contact_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatsForContactHash() => r'5496b4c1c886f93eaaadb7de7185640760c751f3';

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

/// Provider that finds all chats involving a specific participant.
///
/// This enables the "Show all chats with Danny" feature by:
/// 1. Finding all handles linked to the participant via handle_to_participant
/// 2. Finding all chats using those handles
/// 3. Grouping by chat with handle/service details
///
/// Copied from [chatsForContact].
@ProviderFor(chatsForContact)
const chatsForContactProvider = ChatsForContactFamily();

/// Provider that finds all chats involving a specific participant.
///
/// This enables the "Show all chats with Danny" feature by:
/// 1. Finding all handles linked to the participant via handle_to_participant
/// 2. Finding all chats using those handles
/// 3. Grouping by chat with handle/service details
///
/// Copied from [chatsForContact].
class ChatsForContactFamily
    extends Family<AsyncValue<List<ContactChatSummary>>> {
  /// Provider that finds all chats involving a specific participant.
  ///
  /// This enables the "Show all chats with Danny" feature by:
  /// 1. Finding all handles linked to the participant via handle_to_participant
  /// 2. Finding all chats using those handles
  /// 3. Grouping by chat with handle/service details
  ///
  /// Copied from [chatsForContact].
  const ChatsForContactFamily();

  /// Provider that finds all chats involving a specific participant.
  ///
  /// This enables the "Show all chats with Danny" feature by:
  /// 1. Finding all handles linked to the participant via handle_to_participant
  /// 2. Finding all chats using those handles
  /// 3. Grouping by chat with handle/service details
  ///
  /// Copied from [chatsForContact].
  ChatsForContactProvider call({required int participantId}) {
    return ChatsForContactProvider(participantId: participantId);
  }

  @override
  ChatsForContactProvider getProviderOverride(
    covariant ChatsForContactProvider provider,
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
  String? get name => r'chatsForContactProvider';
}

/// Provider that finds all chats involving a specific participant.
///
/// This enables the "Show all chats with Danny" feature by:
/// 1. Finding all handles linked to the participant via handle_to_participant
/// 2. Finding all chats using those handles
/// 3. Grouping by chat with handle/service details
///
/// Copied from [chatsForContact].
class ChatsForContactProvider
    extends AutoDisposeFutureProvider<List<ContactChatSummary>> {
  /// Provider that finds all chats involving a specific participant.
  ///
  /// This enables the "Show all chats with Danny" feature by:
  /// 1. Finding all handles linked to the participant via handle_to_participant
  /// 2. Finding all chats using those handles
  /// 3. Grouping by chat with handle/service details
  ///
  /// Copied from [chatsForContact].
  ChatsForContactProvider({required int participantId})
    : this._internal(
        (ref) => chatsForContact(
          ref as ChatsForContactRef,
          participantId: participantId,
        ),
        from: chatsForContactProvider,
        name: r'chatsForContactProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chatsForContactHash,
        dependencies: ChatsForContactFamily._dependencies,
        allTransitiveDependencies:
            ChatsForContactFamily._allTransitiveDependencies,
        participantId: participantId,
      );

  ChatsForContactProvider._internal(
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
    FutureOr<List<ContactChatSummary>> Function(ChatsForContactRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChatsForContactProvider._internal(
        (ref) => create(ref as ChatsForContactRef),
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
  AutoDisposeFutureProviderElement<List<ContactChatSummary>> createElement() {
    return _ChatsForContactProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatsForContactProvider &&
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
mixin ChatsForContactRef
    on AutoDisposeFutureProviderRef<List<ContactChatSummary>> {
  /// The parameter `participantId` of this provider.
  int get participantId;
}

class _ChatsForContactProviderElement
    extends AutoDisposeFutureProviderElement<List<ContactChatSummary>>
    with ChatsForContactRef {
  _ChatsForContactProviderElement(super.provider);

  @override
  int get participantId => (origin as ChatsForContactProvider).participantId;
}

String _$participantInfoHash() => r'a26c550773e5df2cfb1d7198b4fa5b843c7ca19a';

/// Provider that gets participant info for display purposes
///
/// Copied from [participantInfo].
@ProviderFor(participantInfo)
const participantInfoProvider = ParticipantInfoFamily();

/// Provider that gets participant info for display purposes
///
/// Copied from [participantInfo].
class ParticipantInfoFamily extends Family<AsyncValue<WorkingParticipant?>> {
  /// Provider that gets participant info for display purposes
  ///
  /// Copied from [participantInfo].
  const ParticipantInfoFamily();

  /// Provider that gets participant info for display purposes
  ///
  /// Copied from [participantInfo].
  ParticipantInfoProvider call({required int participantId}) {
    return ParticipantInfoProvider(participantId: participantId);
  }

  @override
  ParticipantInfoProvider getProviderOverride(
    covariant ParticipantInfoProvider provider,
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
  String? get name => r'participantInfoProvider';
}

/// Provider that gets participant info for display purposes
///
/// Copied from [participantInfo].
class ParticipantInfoProvider
    extends AutoDisposeFutureProvider<WorkingParticipant?> {
  /// Provider that gets participant info for display purposes
  ///
  /// Copied from [participantInfo].
  ParticipantInfoProvider({required int participantId})
    : this._internal(
        (ref) => participantInfo(
          ref as ParticipantInfoRef,
          participantId: participantId,
        ),
        from: participantInfoProvider,
        name: r'participantInfoProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$participantInfoHash,
        dependencies: ParticipantInfoFamily._dependencies,
        allTransitiveDependencies:
            ParticipantInfoFamily._allTransitiveDependencies,
        participantId: participantId,
      );

  ParticipantInfoProvider._internal(
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
    FutureOr<WorkingParticipant?> Function(ParticipantInfoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ParticipantInfoProvider._internal(
        (ref) => create(ref as ParticipantInfoRef),
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
  AutoDisposeFutureProviderElement<WorkingParticipant?> createElement() {
    return _ParticipantInfoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ParticipantInfoProvider &&
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
mixin ParticipantInfoRef on AutoDisposeFutureProviderRef<WorkingParticipant?> {
  /// The parameter `participantId` of this provider.
  int get participantId;
}

class _ParticipantInfoProviderElement
    extends AutoDisposeFutureProviderElement<WorkingParticipant?>
    with ParticipantInfoRef {
  _ParticipantInfoProviderElement(super.provider);

  @override
  int get participantId => (origin as ParticipantInfoProvider).participantId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
