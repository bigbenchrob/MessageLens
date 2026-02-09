// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_is_favorite_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactIsFavoriteHash() => r'd6ad55593caf44725bf896d47044eb383ce06c1a';

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

/// Whether [participantId] is currently in the user's favorites.
///
/// Reactivity is driven by explicit invalidation: after add/remove mutations
/// the caller must `ref.invalidate(contactIsFavoriteProvider(participantId))`.
///
/// Copied from [contactIsFavorite].
@ProviderFor(contactIsFavorite)
const contactIsFavoriteProvider = ContactIsFavoriteFamily();

/// Whether [participantId] is currently in the user's favorites.
///
/// Reactivity is driven by explicit invalidation: after add/remove mutations
/// the caller must `ref.invalidate(contactIsFavoriteProvider(participantId))`.
///
/// Copied from [contactIsFavorite].
class ContactIsFavoriteFamily extends Family<AsyncValue<bool>> {
  /// Whether [participantId] is currently in the user's favorites.
  ///
  /// Reactivity is driven by explicit invalidation: after add/remove mutations
  /// the caller must `ref.invalidate(contactIsFavoriteProvider(participantId))`.
  ///
  /// Copied from [contactIsFavorite].
  const ContactIsFavoriteFamily();

  /// Whether [participantId] is currently in the user's favorites.
  ///
  /// Reactivity is driven by explicit invalidation: after add/remove mutations
  /// the caller must `ref.invalidate(contactIsFavoriteProvider(participantId))`.
  ///
  /// Copied from [contactIsFavorite].
  ContactIsFavoriteProvider call({required int participantId}) {
    return ContactIsFavoriteProvider(participantId: participantId);
  }

  @override
  ContactIsFavoriteProvider getProviderOverride(
    covariant ContactIsFavoriteProvider provider,
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
  String? get name => r'contactIsFavoriteProvider';
}

/// Whether [participantId] is currently in the user's favorites.
///
/// Reactivity is driven by explicit invalidation: after add/remove mutations
/// the caller must `ref.invalidate(contactIsFavoriteProvider(participantId))`.
///
/// Copied from [contactIsFavorite].
class ContactIsFavoriteProvider extends AutoDisposeFutureProvider<bool> {
  /// Whether [participantId] is currently in the user's favorites.
  ///
  /// Reactivity is driven by explicit invalidation: after add/remove mutations
  /// the caller must `ref.invalidate(contactIsFavoriteProvider(participantId))`.
  ///
  /// Copied from [contactIsFavorite].
  ContactIsFavoriteProvider({required int participantId})
    : this._internal(
        (ref) => contactIsFavorite(
          ref as ContactIsFavoriteRef,
          participantId: participantId,
        ),
        from: contactIsFavoriteProvider,
        name: r'contactIsFavoriteProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contactIsFavoriteHash,
        dependencies: ContactIsFavoriteFamily._dependencies,
        allTransitiveDependencies:
            ContactIsFavoriteFamily._allTransitiveDependencies,
        participantId: participantId,
      );

  ContactIsFavoriteProvider._internal(
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
    FutureOr<bool> Function(ContactIsFavoriteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContactIsFavoriteProvider._internal(
        (ref) => create(ref as ContactIsFavoriteRef),
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
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _ContactIsFavoriteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactIsFavoriteProvider &&
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
mixin ContactIsFavoriteRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `participantId` of this provider.
  int get participantId;
}

class _ContactIsFavoriteProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with ContactIsFavoriteRef {
  _ContactIsFavoriteProviderElement(super.provider);

  @override
  int get participantId => (origin as ContactIsFavoriteProvider).participantId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
