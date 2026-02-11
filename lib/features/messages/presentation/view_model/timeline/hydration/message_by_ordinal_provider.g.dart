// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_by_ordinal_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageByTimelineOrdinalHash() =>
    r'0aa6a6eb478f6a091e6f70794975475a959008e3';

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

/// Unified provider to load a message by its ordinal position within a scope.
///
/// Works for all scopes (global, contact, chat) using the strategy pattern.
/// Returns null if ordinal is out of range.
/// Uses auto-dispose for memory efficiency.
///
/// Copied from [messageByTimelineOrdinal].
@ProviderFor(messageByTimelineOrdinal)
const messageByTimelineOrdinalProvider = MessageByTimelineOrdinalFamily();

/// Unified provider to load a message by its ordinal position within a scope.
///
/// Works for all scopes (global, contact, chat) using the strategy pattern.
/// Returns null if ordinal is out of range.
/// Uses auto-dispose for memory efficiency.
///
/// Copied from [messageByTimelineOrdinal].
class MessageByTimelineOrdinalFamily
    extends Family<AsyncValue<MessageListItem?>> {
  /// Unified provider to load a message by its ordinal position within a scope.
  ///
  /// Works for all scopes (global, contact, chat) using the strategy pattern.
  /// Returns null if ordinal is out of range.
  /// Uses auto-dispose for memory efficiency.
  ///
  /// Copied from [messageByTimelineOrdinal].
  const MessageByTimelineOrdinalFamily();

  /// Unified provider to load a message by its ordinal position within a scope.
  ///
  /// Works for all scopes (global, contact, chat) using the strategy pattern.
  /// Returns null if ordinal is out of range.
  /// Uses auto-dispose for memory efficiency.
  ///
  /// Copied from [messageByTimelineOrdinal].
  MessageByTimelineOrdinalProvider call({
    required MessageTimelineScope scope,
    required int ordinal,
  }) {
    return MessageByTimelineOrdinalProvider(scope: scope, ordinal: ordinal);
  }

  @override
  MessageByTimelineOrdinalProvider getProviderOverride(
    covariant MessageByTimelineOrdinalProvider provider,
  ) {
    return call(scope: provider.scope, ordinal: provider.ordinal);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageByTimelineOrdinalProvider';
}

/// Unified provider to load a message by its ordinal position within a scope.
///
/// Works for all scopes (global, contact, chat) using the strategy pattern.
/// Returns null if ordinal is out of range.
/// Uses auto-dispose for memory efficiency.
///
/// Copied from [messageByTimelineOrdinal].
class MessageByTimelineOrdinalProvider
    extends AutoDisposeFutureProvider<MessageListItem?> {
  /// Unified provider to load a message by its ordinal position within a scope.
  ///
  /// Works for all scopes (global, contact, chat) using the strategy pattern.
  /// Returns null if ordinal is out of range.
  /// Uses auto-dispose for memory efficiency.
  ///
  /// Copied from [messageByTimelineOrdinal].
  MessageByTimelineOrdinalProvider({
    required MessageTimelineScope scope,
    required int ordinal,
  }) : this._internal(
         (ref) => messageByTimelineOrdinal(
           ref as MessageByTimelineOrdinalRef,
           scope: scope,
           ordinal: ordinal,
         ),
         from: messageByTimelineOrdinalProvider,
         name: r'messageByTimelineOrdinalProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$messageByTimelineOrdinalHash,
         dependencies: MessageByTimelineOrdinalFamily._dependencies,
         allTransitiveDependencies:
             MessageByTimelineOrdinalFamily._allTransitiveDependencies,
         scope: scope,
         ordinal: ordinal,
       );

  MessageByTimelineOrdinalProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scope,
    required this.ordinal,
  }) : super.internal();

  final MessageTimelineScope scope;
  final int ordinal;

  @override
  Override overrideWith(
    FutureOr<MessageListItem?> Function(MessageByTimelineOrdinalRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageByTimelineOrdinalProvider._internal(
        (ref) => create(ref as MessageByTimelineOrdinalRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scope: scope,
        ordinal: ordinal,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MessageListItem?> createElement() {
    return _MessageByTimelineOrdinalProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageByTimelineOrdinalProvider &&
        other.scope == scope &&
        other.ordinal == ordinal;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scope.hashCode);
    hash = _SystemHash.combine(hash, ordinal.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageByTimelineOrdinalRef
    on AutoDisposeFutureProviderRef<MessageListItem?> {
  /// The parameter `scope` of this provider.
  MessageTimelineScope get scope;

  /// The parameter `ordinal` of this provider.
  int get ordinal;
}

class _MessageByTimelineOrdinalProviderElement
    extends AutoDisposeFutureProviderElement<MessageListItem?>
    with MessageByTimelineOrdinalRef {
  _MessageByTimelineOrdinalProviderElement(super.provider);

  @override
  MessageTimelineScope get scope =>
      (origin as MessageByTimelineOrdinalProvider).scope;
  @override
  int get ordinal => (origin as MessageByTimelineOrdinalProvider).ordinal;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
