// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_czar_operating_currentness_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appCzarOperatingCurrentnessCadenceHash() =>
    r'f46ca66bc783631ef7f27eb6da5068a8e365b3e5';

/// See also [appCzarOperatingCurrentnessCadence].
@ProviderFor(appCzarOperatingCurrentnessCadence)
final appCzarOperatingCurrentnessCadenceProvider =
    AutoDisposeProvider<Duration>.internal(
      appCzarOperatingCurrentnessCadence,
      name: r'appCzarOperatingCurrentnessCadenceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$appCzarOperatingCurrentnessCadenceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppCzarOperatingCurrentnessCadenceRef =
    AutoDisposeProviderRef<Duration>;
String _$appCzarOperatingCurrentnessControllerHash() =>
    r'6f7edb0e6d06e14a8150c81b922dce433f986e25';

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

abstract class _$AppCzarOperatingCurrentnessController
    extends BuildlessAutoDisposeNotifier<AppCzarOperatingCurrentnessState> {
  late final AppCzarOperatingSessionOccurrence occurrence;

  AppCzarOperatingCurrentnessState build(
    AppCzarOperatingSessionOccurrence occurrence,
  );
}

/// See also [AppCzarOperatingCurrentnessController].
@ProviderFor(AppCzarOperatingCurrentnessController)
const appCzarOperatingCurrentnessControllerProvider =
    AppCzarOperatingCurrentnessControllerFamily();

/// See also [AppCzarOperatingCurrentnessController].
class AppCzarOperatingCurrentnessControllerFamily
    extends Family<AppCzarOperatingCurrentnessState> {
  /// See also [AppCzarOperatingCurrentnessController].
  const AppCzarOperatingCurrentnessControllerFamily();

  /// See also [AppCzarOperatingCurrentnessController].
  AppCzarOperatingCurrentnessControllerProvider call(
    AppCzarOperatingSessionOccurrence occurrence,
  ) {
    return AppCzarOperatingCurrentnessControllerProvider(occurrence);
  }

  @override
  AppCzarOperatingCurrentnessControllerProvider getProviderOverride(
    covariant AppCzarOperatingCurrentnessControllerProvider provider,
  ) {
    return call(provider.occurrence);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'appCzarOperatingCurrentnessControllerProvider';
}

/// See also [AppCzarOperatingCurrentnessController].
class AppCzarOperatingCurrentnessControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          AppCzarOperatingCurrentnessController,
          AppCzarOperatingCurrentnessState
        > {
  /// See also [AppCzarOperatingCurrentnessController].
  AppCzarOperatingCurrentnessControllerProvider(
    AppCzarOperatingSessionOccurrence occurrence,
  ) : this._internal(
        () => AppCzarOperatingCurrentnessController()..occurrence = occurrence,
        from: appCzarOperatingCurrentnessControllerProvider,
        name: r'appCzarOperatingCurrentnessControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$appCzarOperatingCurrentnessControllerHash,
        dependencies: AppCzarOperatingCurrentnessControllerFamily._dependencies,
        allTransitiveDependencies: AppCzarOperatingCurrentnessControllerFamily
            ._allTransitiveDependencies,
        occurrence: occurrence,
      );

  AppCzarOperatingCurrentnessControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.occurrence,
  }) : super.internal();

  final AppCzarOperatingSessionOccurrence occurrence;

  @override
  AppCzarOperatingCurrentnessState runNotifierBuild(
    covariant AppCzarOperatingCurrentnessController notifier,
  ) {
    return notifier.build(occurrence);
  }

  @override
  Override overrideWith(
    AppCzarOperatingCurrentnessController Function() create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AppCzarOperatingCurrentnessControllerProvider._internal(
        () => create()..occurrence = occurrence,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        occurrence: occurrence,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    AppCzarOperatingCurrentnessController,
    AppCzarOperatingCurrentnessState
  >
  createElement() {
    return _AppCzarOperatingCurrentnessControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AppCzarOperatingCurrentnessControllerProvider &&
        other.occurrence == occurrence;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, occurrence.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AppCzarOperatingCurrentnessControllerRef
    on AutoDisposeNotifierProviderRef<AppCzarOperatingCurrentnessState> {
  /// The parameter `occurrence` of this provider.
  AppCzarOperatingSessionOccurrence get occurrence;
}

class _AppCzarOperatingCurrentnessControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          AppCzarOperatingCurrentnessController,
          AppCzarOperatingCurrentnessState
        >
    with AppCzarOperatingCurrentnessControllerRef {
  _AppCzarOperatingCurrentnessControllerProviderElement(super.provider);

  @override
  AppCzarOperatingSessionOccurrence get occurrence =>
      (origin as AppCzarOperatingCurrentnessControllerProvider).occurrence;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
