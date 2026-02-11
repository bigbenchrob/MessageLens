// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_visible_month_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentVisibleMonthForScopeHash() =>
    r'd31296c3286f8b91897828491dbd8b5e96338700';

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

/// Provides the currently visible month key for a given timeline scope.
///
/// The month key is in 'yyyy-MM' format (e.g., '2023-06').
/// This is used by the heatmap widget to highlight the current scroll position.
///
/// Returns null if the ordinal state is not yet loaded.
///
/// Copied from [currentVisibleMonthForScope].
@ProviderFor(currentVisibleMonthForScope)
const currentVisibleMonthForScopeProvider = CurrentVisibleMonthForScopeFamily();

/// Provides the currently visible month key for a given timeline scope.
///
/// The month key is in 'yyyy-MM' format (e.g., '2023-06').
/// This is used by the heatmap widget to highlight the current scroll position.
///
/// Returns null if the ordinal state is not yet loaded.
///
/// Copied from [currentVisibleMonthForScope].
class CurrentVisibleMonthForScopeFamily extends Family<AsyncValue<String?>> {
  /// Provides the currently visible month key for a given timeline scope.
  ///
  /// The month key is in 'yyyy-MM' format (e.g., '2023-06').
  /// This is used by the heatmap widget to highlight the current scroll position.
  ///
  /// Returns null if the ordinal state is not yet loaded.
  ///
  /// Copied from [currentVisibleMonthForScope].
  const CurrentVisibleMonthForScopeFamily();

  /// Provides the currently visible month key for a given timeline scope.
  ///
  /// The month key is in 'yyyy-MM' format (e.g., '2023-06').
  /// This is used by the heatmap widget to highlight the current scroll position.
  ///
  /// Returns null if the ordinal state is not yet loaded.
  ///
  /// Copied from [currentVisibleMonthForScope].
  CurrentVisibleMonthForScopeProvider call({
    required MessageTimelineScope scope,
  }) {
    return CurrentVisibleMonthForScopeProvider(scope: scope);
  }

  @override
  CurrentVisibleMonthForScopeProvider getProviderOverride(
    covariant CurrentVisibleMonthForScopeProvider provider,
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
  String? get name => r'currentVisibleMonthForScopeProvider';
}

/// Provides the currently visible month key for a given timeline scope.
///
/// The month key is in 'yyyy-MM' format (e.g., '2023-06').
/// This is used by the heatmap widget to highlight the current scroll position.
///
/// Returns null if the ordinal state is not yet loaded.
///
/// Copied from [currentVisibleMonthForScope].
class CurrentVisibleMonthForScopeProvider
    extends AutoDisposeFutureProvider<String?> {
  /// Provides the currently visible month key for a given timeline scope.
  ///
  /// The month key is in 'yyyy-MM' format (e.g., '2023-06').
  /// This is used by the heatmap widget to highlight the current scroll position.
  ///
  /// Returns null if the ordinal state is not yet loaded.
  ///
  /// Copied from [currentVisibleMonthForScope].
  CurrentVisibleMonthForScopeProvider({required MessageTimelineScope scope})
    : this._internal(
        (ref) => currentVisibleMonthForScope(
          ref as CurrentVisibleMonthForScopeRef,
          scope: scope,
        ),
        from: currentVisibleMonthForScopeProvider,
        name: r'currentVisibleMonthForScopeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$currentVisibleMonthForScopeHash,
        dependencies: CurrentVisibleMonthForScopeFamily._dependencies,
        allTransitiveDependencies:
            CurrentVisibleMonthForScopeFamily._allTransitiveDependencies,
        scope: scope,
      );

  CurrentVisibleMonthForScopeProvider._internal(
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
  Override overrideWith(
    FutureOr<String?> Function(CurrentVisibleMonthForScopeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CurrentVisibleMonthForScopeProvider._internal(
        (ref) => create(ref as CurrentVisibleMonthForScopeRef),
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
  AutoDisposeFutureProviderElement<String?> createElement() {
    return _CurrentVisibleMonthForScopeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentVisibleMonthForScopeProvider && other.scope == scope;
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
mixin CurrentVisibleMonthForScopeRef on AutoDisposeFutureProviderRef<String?> {
  /// The parameter `scope` of this provider.
  MessageTimelineScope get scope;
}

class _CurrentVisibleMonthForScopeProviderElement
    extends AutoDisposeFutureProviderElement<String?>
    with CurrentVisibleMonthForScopeRef {
  _CurrentVisibleMonthForScopeProviderElement(super.provider);

  @override
  MessageTimelineScope get scope =>
      (origin as CurrentVisibleMonthForScopeProvider).scope;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
