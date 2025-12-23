// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_for_handle_view_builder_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messagesForHandleViewBuilderHash() =>
    r'a11d137e396296a661d22609538f0ee855a2a2df';

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

/// See also [messagesForHandleViewBuilder].
@ProviderFor(messagesForHandleViewBuilder)
const messagesForHandleViewBuilderProvider =
    MessagesForHandleViewBuilderFamily();

/// See also [messagesForHandleViewBuilder].
class MessagesForHandleViewBuilderFamily extends Family<Widget> {
  /// See also [messagesForHandleViewBuilder].
  const MessagesForHandleViewBuilderFamily();

  /// See also [messagesForHandleViewBuilder].
  MessagesForHandleViewBuilderProvider call(int handleId) {
    return MessagesForHandleViewBuilderProvider(handleId);
  }

  @override
  MessagesForHandleViewBuilderProvider getProviderOverride(
    covariant MessagesForHandleViewBuilderProvider provider,
  ) {
    return call(provider.handleId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messagesForHandleViewBuilderProvider';
}

/// See also [messagesForHandleViewBuilder].
class MessagesForHandleViewBuilderProvider extends AutoDisposeProvider<Widget> {
  /// See also [messagesForHandleViewBuilder].
  MessagesForHandleViewBuilderProvider(int handleId)
    : this._internal(
        (ref) => messagesForHandleViewBuilder(
          ref as MessagesForHandleViewBuilderRef,
          handleId,
        ),
        from: messagesForHandleViewBuilderProvider,
        name: r'messagesForHandleViewBuilderProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messagesForHandleViewBuilderHash,
        dependencies: MessagesForHandleViewBuilderFamily._dependencies,
        allTransitiveDependencies:
            MessagesForHandleViewBuilderFamily._allTransitiveDependencies,
        handleId: handleId,
      );

  MessagesForHandleViewBuilderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.handleId,
  }) : super.internal();

  final int handleId;

  @override
  Override overrideWith(
    Widget Function(MessagesForHandleViewBuilderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessagesForHandleViewBuilderProvider._internal(
        (ref) => create(ref as MessagesForHandleViewBuilderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        handleId: handleId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<Widget> createElement() {
    return _MessagesForHandleViewBuilderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesForHandleViewBuilderProvider &&
        other.handleId == handleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, handleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessagesForHandleViewBuilderRef on AutoDisposeProviderRef<Widget> {
  /// The parameter `handleId` of this provider.
  int get handleId;
}

class _MessagesForHandleViewBuilderProviderElement
    extends AutoDisposeProviderElement<Widget>
    with MessagesForHandleViewBuilderRef {
  _MessagesForHandleViewBuilderProviderElement(super.provider);

  @override
  int get handleId => (origin as MessagesForHandleViewBuilderProvider).handleId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
