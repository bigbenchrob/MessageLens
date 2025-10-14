// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_by_id_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageByIdHash() => r'b78cc3f3ec9f88a33aa929c580c28a77907898eb';

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

/// See also [messageById].
@ProviderFor(messageById)
const messageByIdProvider = MessageByIdFamily();

/// See also [messageById].
class MessageByIdFamily extends Family<AsyncValue<ChatMessageListItem>> {
  /// See also [messageById].
  const MessageByIdFamily();

  /// See also [messageById].
  MessageByIdProvider call({required int messageId}) {
    return MessageByIdProvider(messageId: messageId);
  }

  @override
  MessageByIdProvider getProviderOverride(
    covariant MessageByIdProvider provider,
  ) {
    return call(messageId: provider.messageId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageByIdProvider';
}

/// See also [messageById].
class MessageByIdProvider
    extends AutoDisposeFutureProvider<ChatMessageListItem> {
  /// See also [messageById].
  MessageByIdProvider({required int messageId})
    : this._internal(
        (ref) => messageById(ref as MessageByIdRef, messageId: messageId),
        from: messageByIdProvider,
        name: r'messageByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messageByIdHash,
        dependencies: MessageByIdFamily._dependencies,
        allTransitiveDependencies: MessageByIdFamily._allTransitiveDependencies,
        messageId: messageId,
      );

  MessageByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.messageId,
  }) : super.internal();

  final int messageId;

  @override
  Override overrideWith(
    FutureOr<ChatMessageListItem> Function(MessageByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageByIdProvider._internal(
        (ref) => create(ref as MessageByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        messageId: messageId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ChatMessageListItem> createElement() {
    return _MessageByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageByIdProvider && other.messageId == messageId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, messageId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageByIdRef on AutoDisposeFutureProviderRef<ChatMessageListItem> {
  /// The parameter `messageId` of this provider.
  int get messageId;
}

class _MessageByIdProviderElement
    extends AutoDisposeFutureProviderElement<ChatMessageListItem>
    with MessageByIdRef {
  _MessageByIdProviderElement(super.provider);

  @override
  int get messageId => (origin as MessageByIdProvider).messageId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
