// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_timeline_view_model_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageTimelineViewModelHash() =>
    r'a3ffb1c39996ccec8b59244607b79c69cfe86fef';

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

abstract class _$MessageTimelineViewModel
    extends BuildlessAutoDisposeNotifier<MessageTimelineViewModelState> {
  late final MessageTimelineScope scope;

  MessageTimelineViewModelState build({required MessageTimelineScope scope});
}

/// Unified view model provider for message timelines.
///
/// Manages search, debounce, and coordinates with the ordinal provider.
/// Works for all scopes (global, contact, chat).
///
/// Copied from [MessageTimelineViewModel].
@ProviderFor(MessageTimelineViewModel)
const messageTimelineViewModelProvider = MessageTimelineViewModelFamily();

/// Unified view model provider for message timelines.
///
/// Manages search, debounce, and coordinates with the ordinal provider.
/// Works for all scopes (global, contact, chat).
///
/// Copied from [MessageTimelineViewModel].
class MessageTimelineViewModelFamily
    extends Family<MessageTimelineViewModelState> {
  /// Unified view model provider for message timelines.
  ///
  /// Manages search, debounce, and coordinates with the ordinal provider.
  /// Works for all scopes (global, contact, chat).
  ///
  /// Copied from [MessageTimelineViewModel].
  const MessageTimelineViewModelFamily();

  /// Unified view model provider for message timelines.
  ///
  /// Manages search, debounce, and coordinates with the ordinal provider.
  /// Works for all scopes (global, contact, chat).
  ///
  /// Copied from [MessageTimelineViewModel].
  MessageTimelineViewModelProvider call({required MessageTimelineScope scope}) {
    return MessageTimelineViewModelProvider(scope: scope);
  }

  @override
  MessageTimelineViewModelProvider getProviderOverride(
    covariant MessageTimelineViewModelProvider provider,
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
  String? get name => r'messageTimelineViewModelProvider';
}

/// Unified view model provider for message timelines.
///
/// Manages search, debounce, and coordinates with the ordinal provider.
/// Works for all scopes (global, contact, chat).
///
/// Copied from [MessageTimelineViewModel].
class MessageTimelineViewModelProvider
    extends
        AutoDisposeNotifierProviderImpl<
          MessageTimelineViewModel,
          MessageTimelineViewModelState
        > {
  /// Unified view model provider for message timelines.
  ///
  /// Manages search, debounce, and coordinates with the ordinal provider.
  /// Works for all scopes (global, contact, chat).
  ///
  /// Copied from [MessageTimelineViewModel].
  MessageTimelineViewModelProvider({required MessageTimelineScope scope})
    : this._internal(
        () => MessageTimelineViewModel()..scope = scope,
        from: messageTimelineViewModelProvider,
        name: r'messageTimelineViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messageTimelineViewModelHash,
        dependencies: MessageTimelineViewModelFamily._dependencies,
        allTransitiveDependencies:
            MessageTimelineViewModelFamily._allTransitiveDependencies,
        scope: scope,
      );

  MessageTimelineViewModelProvider._internal(
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
  MessageTimelineViewModelState runNotifierBuild(
    covariant MessageTimelineViewModel notifier,
  ) {
    return notifier.build(scope: scope);
  }

  @override
  Override overrideWith(MessageTimelineViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: MessageTimelineViewModelProvider._internal(
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
  AutoDisposeNotifierProviderElement<
    MessageTimelineViewModel,
    MessageTimelineViewModelState
  >
  createElement() {
    return _MessageTimelineViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageTimelineViewModelProvider && other.scope == scope;
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
mixin MessageTimelineViewModelRef
    on AutoDisposeNotifierProviderRef<MessageTimelineViewModelState> {
  /// The parameter `scope` of this provider.
  MessageTimelineScope get scope;
}

class _MessageTimelineViewModelProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          MessageTimelineViewModel,
          MessageTimelineViewModelState
        >
    with MessageTimelineViewModelRef {
  _MessageTimelineViewModelProviderElement(super.provider);

  @override
  MessageTimelineScope get scope =>
      (origin as MessageTimelineViewModelProvider).scope;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
