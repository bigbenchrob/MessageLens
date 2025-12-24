// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_by_global_ordinal_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageByGlobalOrdinalHash() =>
    r'c76e5ab774e84c0a6f7e23a10ea77ee0a855617b';

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

/// Loads a message by its ordinal position within the global message timeline.
/// Returns null if ordinal is out of range.
///
/// Copied from [messageByGlobalOrdinal].
@ProviderFor(messageByGlobalOrdinal)
const messageByGlobalOrdinalProvider = MessageByGlobalOrdinalFamily();

/// Loads a message by its ordinal position within the global message timeline.
/// Returns null if ordinal is out of range.
///
/// Copied from [messageByGlobalOrdinal].
class MessageByGlobalOrdinalFamily
    extends Family<AsyncValue<ChatMessageListItem?>> {
  /// Loads a message by its ordinal position within the global message timeline.
  /// Returns null if ordinal is out of range.
  ///
  /// Copied from [messageByGlobalOrdinal].
  const MessageByGlobalOrdinalFamily();

  /// Loads a message by its ordinal position within the global message timeline.
  /// Returns null if ordinal is out of range.
  ///
  /// Copied from [messageByGlobalOrdinal].
  MessageByGlobalOrdinalProvider call({required int ordinal}) {
    return MessageByGlobalOrdinalProvider(ordinal: ordinal);
  }

  @override
  MessageByGlobalOrdinalProvider getProviderOverride(
    covariant MessageByGlobalOrdinalProvider provider,
  ) {
    return call(ordinal: provider.ordinal);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageByGlobalOrdinalProvider';
}

/// Loads a message by its ordinal position within the global message timeline.
/// Returns null if ordinal is out of range.
///
/// Copied from [messageByGlobalOrdinal].
class MessageByGlobalOrdinalProvider
    extends AutoDisposeFutureProvider<ChatMessageListItem?> {
  /// Loads a message by its ordinal position within the global message timeline.
  /// Returns null if ordinal is out of range.
  ///
  /// Copied from [messageByGlobalOrdinal].
  MessageByGlobalOrdinalProvider({required int ordinal})
    : this._internal(
        (ref) => messageByGlobalOrdinal(
          ref as MessageByGlobalOrdinalRef,
          ordinal: ordinal,
        ),
        from: messageByGlobalOrdinalProvider,
        name: r'messageByGlobalOrdinalProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messageByGlobalOrdinalHash,
        dependencies: MessageByGlobalOrdinalFamily._dependencies,
        allTransitiveDependencies:
            MessageByGlobalOrdinalFamily._allTransitiveDependencies,
        ordinal: ordinal,
      );

  MessageByGlobalOrdinalProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.ordinal,
  }) : super.internal();

  final int ordinal;

  @override
  Override overrideWith(
    FutureOr<ChatMessageListItem?> Function(MessageByGlobalOrdinalRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageByGlobalOrdinalProvider._internal(
        (ref) => create(ref as MessageByGlobalOrdinalRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        ordinal: ordinal,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ChatMessageListItem?> createElement() {
    return _MessageByGlobalOrdinalProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageByGlobalOrdinalProvider && other.ordinal == ordinal;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, ordinal.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageByGlobalOrdinalRef
    on AutoDisposeFutureProviderRef<ChatMessageListItem?> {
  /// The parameter `ordinal` of this provider.
  int get ordinal;
}

class _MessageByGlobalOrdinalProviderElement
    extends AutoDisposeFutureProviderElement<ChatMessageListItem?>
    with MessageByGlobalOrdinalRef {
  _MessageByGlobalOrdinalProviderElement(super.provider);

  @override
  int get ordinal => (origin as MessageByGlobalOrdinalProvider).ordinal;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
