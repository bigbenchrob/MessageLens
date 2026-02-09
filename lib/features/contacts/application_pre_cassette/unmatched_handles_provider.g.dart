// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unmatched_handles_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unmatchedPhonesHash() => r'cf174ed2615e7e7bb5bd91eca8dead1632972002';

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

/// See also [unmatchedPhones].
@ProviderFor(unmatchedPhones)
const unmatchedPhonesProvider = UnmatchedPhonesFamily();

/// See also [unmatchedPhones].
class UnmatchedPhonesFamily
    extends Family<AsyncValue<List<UnmatchedHandleSummary>>> {
  /// See also [unmatchedPhones].
  const UnmatchedPhonesFamily();

  /// See also [unmatchedPhones].
  UnmatchedPhonesProvider call({required PhoneFilterMode filterMode}) {
    return UnmatchedPhonesProvider(filterMode: filterMode);
  }

  @override
  UnmatchedPhonesProvider getProviderOverride(
    covariant UnmatchedPhonesProvider provider,
  ) {
    return call(filterMode: provider.filterMode);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'unmatchedPhonesProvider';
}

/// See also [unmatchedPhones].
class UnmatchedPhonesProvider
    extends AutoDisposeFutureProvider<List<UnmatchedHandleSummary>> {
  /// See also [unmatchedPhones].
  UnmatchedPhonesProvider({required PhoneFilterMode filterMode})
    : this._internal(
        (ref) =>
            unmatchedPhones(ref as UnmatchedPhonesRef, filterMode: filterMode),
        from: unmatchedPhonesProvider,
        name: r'unmatchedPhonesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$unmatchedPhonesHash,
        dependencies: UnmatchedPhonesFamily._dependencies,
        allTransitiveDependencies:
            UnmatchedPhonesFamily._allTransitiveDependencies,
        filterMode: filterMode,
      );

  UnmatchedPhonesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filterMode,
  }) : super.internal();

  final PhoneFilterMode filterMode;

  @override
  Override overrideWith(
    FutureOr<List<UnmatchedHandleSummary>> Function(UnmatchedPhonesRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UnmatchedPhonesProvider._internal(
        (ref) => create(ref as UnmatchedPhonesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filterMode: filterMode,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<UnmatchedHandleSummary>>
  createElement() {
    return _UnmatchedPhonesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnmatchedPhonesProvider && other.filterMode == filterMode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filterMode.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UnmatchedPhonesRef
    on AutoDisposeFutureProviderRef<List<UnmatchedHandleSummary>> {
  /// The parameter `filterMode` of this provider.
  PhoneFilterMode get filterMode;
}

class _UnmatchedPhonesProviderElement
    extends AutoDisposeFutureProviderElement<List<UnmatchedHandleSummary>>
    with UnmatchedPhonesRef {
  _UnmatchedPhonesProviderElement(super.provider);

  @override
  PhoneFilterMode get filterMode =>
      (origin as UnmatchedPhonesProvider).filterMode;
}

String _$unmatchedEmailsHash() => r'068be66aa5f15eb29f26d792f6013d6e4babc547';

/// See also [unmatchedEmails].
@ProviderFor(unmatchedEmails)
final unmatchedEmailsProvider =
    AutoDisposeFutureProvider<List<UnmatchedHandleSummary>>.internal(
      unmatchedEmails,
      name: r'unmatchedEmailsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unmatchedEmailsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnmatchedEmailsRef =
    AutoDisposeFutureProviderRef<List<UnmatchedHandleSummary>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
