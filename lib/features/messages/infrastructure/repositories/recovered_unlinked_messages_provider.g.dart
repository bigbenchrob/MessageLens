// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovered_unlinked_messages_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recoveredUnlinkedMessagesHash() =>
    r'dc2d575987f5260634712db6ccdd56d3ba4c2838';

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

/// See also [recoveredUnlinkedMessages].
@ProviderFor(recoveredUnlinkedMessages)
const recoveredUnlinkedMessagesProvider = RecoveredUnlinkedMessagesFamily();

/// See also [recoveredUnlinkedMessages].
class RecoveredUnlinkedMessagesFamily
    extends Family<AsyncValue<List<RecoveredUnlinkedMessageItem>>> {
  /// See also [recoveredUnlinkedMessages].
  const RecoveredUnlinkedMessagesFamily();

  /// See also [recoveredUnlinkedMessages].
  RecoveredUnlinkedMessagesProvider call({int? contactId}) {
    return RecoveredUnlinkedMessagesProvider(contactId: contactId);
  }

  @override
  RecoveredUnlinkedMessagesProvider getProviderOverride(
    covariant RecoveredUnlinkedMessagesProvider provider,
  ) {
    return call(contactId: provider.contactId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recoveredUnlinkedMessagesProvider';
}

/// See also [recoveredUnlinkedMessages].
class RecoveredUnlinkedMessagesProvider
    extends AutoDisposeStreamProvider<List<RecoveredUnlinkedMessageItem>> {
  /// See also [recoveredUnlinkedMessages].
  RecoveredUnlinkedMessagesProvider({int? contactId})
    : this._internal(
        (ref) => recoveredUnlinkedMessages(
          ref as RecoveredUnlinkedMessagesRef,
          contactId: contactId,
        ),
        from: recoveredUnlinkedMessagesProvider,
        name: r'recoveredUnlinkedMessagesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recoveredUnlinkedMessagesHash,
        dependencies: RecoveredUnlinkedMessagesFamily._dependencies,
        allTransitiveDependencies:
            RecoveredUnlinkedMessagesFamily._allTransitiveDependencies,
        contactId: contactId,
      );

  RecoveredUnlinkedMessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contactId,
  }) : super.internal();

  final int? contactId;

  @override
  Override overrideWith(
    Stream<List<RecoveredUnlinkedMessageItem>> Function(
      RecoveredUnlinkedMessagesRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecoveredUnlinkedMessagesProvider._internal(
        (ref) => create(ref as RecoveredUnlinkedMessagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contactId: contactId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<RecoveredUnlinkedMessageItem>>
  createElement() {
    return _RecoveredUnlinkedMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecoveredUnlinkedMessagesProvider &&
        other.contactId == contactId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contactId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecoveredUnlinkedMessagesRef
    on AutoDisposeStreamProviderRef<List<RecoveredUnlinkedMessageItem>> {
  /// The parameter `contactId` of this provider.
  int? get contactId;
}

class _RecoveredUnlinkedMessagesProviderElement
    extends AutoDisposeStreamProviderElement<List<RecoveredUnlinkedMessageItem>>
    with RecoveredUnlinkedMessagesRef {
  _RecoveredUnlinkedMessagesProviderElement(super.provider);

  @override
  int? get contactId => (origin as RecoveredUnlinkedMessagesProvider).contactId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
