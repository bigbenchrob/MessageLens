// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_for_handle_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messagesForHandleHash() => r'3582d2a5d5d6e077e7e1ba77ef9bd14e07d0cfa3';

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

/// See also [messagesForHandle].
@ProviderFor(messagesForHandle)
const messagesForHandleProvider = MessagesForHandleFamily();

/// See also [messagesForHandle].
class MessagesForHandleFamily
    extends Family<AsyncValue<List<MessageWithChatContext>>> {
  /// See also [messagesForHandle].
  const MessagesForHandleFamily();

  /// See also [messagesForHandle].
  MessagesForHandleProvider call({required int handleId}) {
    return MessagesForHandleProvider(handleId: handleId);
  }

  @override
  MessagesForHandleProvider getProviderOverride(
    covariant MessagesForHandleProvider provider,
  ) {
    return call(handleId: provider.handleId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messagesForHandleProvider';
}

/// See also [messagesForHandle].
class MessagesForHandleProvider
    extends AutoDisposeFutureProvider<List<MessageWithChatContext>> {
  /// See also [messagesForHandle].
  MessagesForHandleProvider({required int handleId})
    : this._internal(
        (ref) =>
            messagesForHandle(ref as MessagesForHandleRef, handleId: handleId),
        from: messagesForHandleProvider,
        name: r'messagesForHandleProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messagesForHandleHash,
        dependencies: MessagesForHandleFamily._dependencies,
        allTransitiveDependencies:
            MessagesForHandleFamily._allTransitiveDependencies,
        handleId: handleId,
      );

  MessagesForHandleProvider._internal(
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
    FutureOr<List<MessageWithChatContext>> Function(
      MessagesForHandleRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessagesForHandleProvider._internal(
        (ref) => create(ref as MessagesForHandleRef),
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
  AutoDisposeFutureProviderElement<List<MessageWithChatContext>>
  createElement() {
    return _MessagesForHandleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesForHandleProvider && other.handleId == handleId;
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
mixin MessagesForHandleRef
    on AutoDisposeFutureProviderRef<List<MessageWithChatContext>> {
  /// The parameter `handleId` of this provider.
  int get handleId;
}

class _MessagesForHandleProviderElement
    extends AutoDisposeFutureProviderElement<List<MessageWithChatContext>>
    with MessagesForHandleRef {
  _MessagesForHandleProviderElement(super.provider);

  @override
  int get handleId => (origin as MessagesForHandleProvider).handleId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
