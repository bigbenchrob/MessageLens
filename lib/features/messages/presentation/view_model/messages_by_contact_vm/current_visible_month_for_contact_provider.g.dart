// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_visible_month_for_contact_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentVisibleMonthForContactHash() =>
    r'9dac36d7901b7482616c97f824dedfd415f72312';

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

/// Tracks the currently visible month for a specific contact based on scroll position
/// Returns monthKey in format "YYYY-MM" (e.g., "2025-12")
///
/// Copied from [currentVisibleMonthForContact].
@ProviderFor(currentVisibleMonthForContact)
const currentVisibleMonthForContactProvider =
    CurrentVisibleMonthForContactFamily();

/// Tracks the currently visible month for a specific contact based on scroll position
/// Returns monthKey in format "YYYY-MM" (e.g., "2025-12")
///
/// Copied from [currentVisibleMonthForContact].
class CurrentVisibleMonthForContactFamily extends Family<AsyncValue<String?>> {
  /// Tracks the currently visible month for a specific contact based on scroll position
  /// Returns monthKey in format "YYYY-MM" (e.g., "2025-12")
  ///
  /// Copied from [currentVisibleMonthForContact].
  const CurrentVisibleMonthForContactFamily();

  /// Tracks the currently visible month for a specific contact based on scroll position
  /// Returns monthKey in format "YYYY-MM" (e.g., "2025-12")
  ///
  /// Copied from [currentVisibleMonthForContact].
  CurrentVisibleMonthForContactProvider call({required int contactId}) {
    return CurrentVisibleMonthForContactProvider(contactId: contactId);
  }

  @override
  CurrentVisibleMonthForContactProvider getProviderOverride(
    covariant CurrentVisibleMonthForContactProvider provider,
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
  String? get name => r'currentVisibleMonthForContactProvider';
}

/// Tracks the currently visible month for a specific contact based on scroll position
/// Returns monthKey in format "YYYY-MM" (e.g., "2025-12")
///
/// Copied from [currentVisibleMonthForContact].
class CurrentVisibleMonthForContactProvider
    extends AutoDisposeStreamProvider<String?> {
  /// Tracks the currently visible month for a specific contact based on scroll position
  /// Returns monthKey in format "YYYY-MM" (e.g., "2025-12")
  ///
  /// Copied from [currentVisibleMonthForContact].
  CurrentVisibleMonthForContactProvider({required int contactId})
    : this._internal(
        (ref) => currentVisibleMonthForContact(
          ref as CurrentVisibleMonthForContactRef,
          contactId: contactId,
        ),
        from: currentVisibleMonthForContactProvider,
        name: r'currentVisibleMonthForContactProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$currentVisibleMonthForContactHash,
        dependencies: CurrentVisibleMonthForContactFamily._dependencies,
        allTransitiveDependencies:
            CurrentVisibleMonthForContactFamily._allTransitiveDependencies,
        contactId: contactId,
      );

  CurrentVisibleMonthForContactProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contactId,
  }) : super.internal();

  final int contactId;

  @override
  Override overrideWith(
    Stream<String?> Function(CurrentVisibleMonthForContactRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CurrentVisibleMonthForContactProvider._internal(
        (ref) => create(ref as CurrentVisibleMonthForContactRef),
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
  AutoDisposeStreamProviderElement<String?> createElement() {
    return _CurrentVisibleMonthForContactProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentVisibleMonthForContactProvider &&
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
mixin CurrentVisibleMonthForContactRef
    on AutoDisposeStreamProviderRef<String?> {
  /// The parameter `contactId` of this provider.
  int get contactId;
}

class _CurrentVisibleMonthForContactProviderElement
    extends AutoDisposeStreamProviderElement<String?>
    with CurrentVisibleMonthForContactRef {
  _CurrentVisibleMonthForContactProviderElement(super.provider);

  @override
  int get contactId =>
      (origin as CurrentVisibleMonthForContactProvider).contactId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
