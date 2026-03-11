// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_timeline_ordinal_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageTimelineOrdinalHash() =>
    r'15ad8387cd7be12cafc36eca6a9491df984b905f';

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

abstract class _$MessageTimelineOrdinal
    extends BuildlessAutoDisposeAsyncNotifier<MessageTimelineOrdinalState> {
  late final MessageTimelineScope scope;

  FutureOr<MessageTimelineOrdinalState> build({
    required MessageTimelineScope scope,
  });
}

/// Unified ordinal provider for message timelines.
///
/// Accepts a [MessageTimelineScope] to determine which message set to query.
/// Uses the strategy pattern to delegate to scope-specific data sources.
///
/// Copied from [MessageTimelineOrdinal].
@ProviderFor(MessageTimelineOrdinal)
const messageTimelineOrdinalProvider = MessageTimelineOrdinalFamily();

/// Unified ordinal provider for message timelines.
///
/// Accepts a [MessageTimelineScope] to determine which message set to query.
/// Uses the strategy pattern to delegate to scope-specific data sources.
///
/// Copied from [MessageTimelineOrdinal].
class MessageTimelineOrdinalFamily
    extends Family<AsyncValue<MessageTimelineOrdinalState>> {
  /// Unified ordinal provider for message timelines.
  ///
  /// Accepts a [MessageTimelineScope] to determine which message set to query.
  /// Uses the strategy pattern to delegate to scope-specific data sources.
  ///
  /// Copied from [MessageTimelineOrdinal].
  const MessageTimelineOrdinalFamily();

  /// Unified ordinal provider for message timelines.
  ///
  /// Accepts a [MessageTimelineScope] to determine which message set to query.
  /// Uses the strategy pattern to delegate to scope-specific data sources.
  ///
  /// Copied from [MessageTimelineOrdinal].
  MessageTimelineOrdinalProvider call({required MessageTimelineScope scope}) {
    return MessageTimelineOrdinalProvider(scope: scope);
  }

  @override
  MessageTimelineOrdinalProvider getProviderOverride(
    covariant MessageTimelineOrdinalProvider provider,
  ) {
    return call(scope: provider.scope);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageTimelineOrdinalProvider';
}

/// Unified ordinal provider for message timelines.
///
/// Accepts a [MessageTimelineScope] to determine which message set to query.
/// Uses the strategy pattern to delegate to scope-specific data sources.
///
/// Copied from [MessageTimelineOrdinal].
class MessageTimelineOrdinalProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          MessageTimelineOrdinal,
          MessageTimelineOrdinalState
        > {
  /// Unified ordinal provider for message timelines.
  ///
  /// Accepts a [MessageTimelineScope] to determine which message set to query.
  /// Uses the strategy pattern to delegate to scope-specific data sources.
  ///
  /// Copied from [MessageTimelineOrdinal].
  MessageTimelineOrdinalProvider({required MessageTimelineScope scope})
    : this._internal(
        () => MessageTimelineOrdinal()..scope = scope,
        from: messageTimelineOrdinalProvider,
        name: r'messageTimelineOrdinalProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messageTimelineOrdinalHash,
        dependencies: MessageTimelineOrdinalFamily._dependencies,
        allTransitiveDependencies:
            MessageTimelineOrdinalFamily._allTransitiveDependencies,
        scope: scope,
      );

  MessageTimelineOrdinalProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scope,
  }) : super.internal();

  final MessageTimelineScope scope;

  @override
  FutureOr<MessageTimelineOrdinalState> runNotifierBuild(
    covariant MessageTimelineOrdinal notifier,
  ) {
    return notifier.build(scope: scope);
  }

  @override
  Override overrideWith(MessageTimelineOrdinal Function() create) {
    return ProviderOverride(
      origin: this,
      override: MessageTimelineOrdinalProvider._internal(
        () => create()..scope = scope,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scope: scope,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    MessageTimelineOrdinal,
    MessageTimelineOrdinalState
  >
  createElement() {
    return _MessageTimelineOrdinalProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageTimelineOrdinalProvider && other.scope == scope;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scope.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageTimelineOrdinalRef
    on AutoDisposeAsyncNotifierProviderRef<MessageTimelineOrdinalState> {
  /// The parameter `scope` of this provider.
  MessageTimelineScope get scope;
}

class _MessageTimelineOrdinalProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          MessageTimelineOrdinal,
          MessageTimelineOrdinalState
        >
    with MessageTimelineOrdinalRef {
  _MessageTimelineOrdinalProviderElement(super.provider);

  @override
  MessageTimelineScope get scope =>
      (origin as MessageTimelineOrdinalProvider).scope;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
