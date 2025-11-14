// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_timeline_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$globalTimelineControllerHash() =>
    r'a64053c08311ae9f07c2c4c9f024e016e161175f';

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

abstract class _$GlobalTimelineController
    extends BuildlessAutoDisposeAsyncNotifier<GlobalTimelineState> {
  late final int? startAfterOrdinal;
  late final int? endBeforeOrdinal;
  late final int pageSize;

  FutureOr<GlobalTimelineState> build({
    int? startAfterOrdinal,
    int? endBeforeOrdinal,
    int pageSize = _globalTimelineDefaultPageSize,
  });
}

/// See also [GlobalTimelineController].
@ProviderFor(GlobalTimelineController)
const globalTimelineControllerProvider = GlobalTimelineControllerFamily();

/// See also [GlobalTimelineController].
class GlobalTimelineControllerFamily
    extends Family<AsyncValue<GlobalTimelineState>> {
  /// See also [GlobalTimelineController].
  const GlobalTimelineControllerFamily();

  /// See also [GlobalTimelineController].
  GlobalTimelineControllerProvider call({
    int? startAfterOrdinal,
    int? endBeforeOrdinal,
    int pageSize = _globalTimelineDefaultPageSize,
  }) {
    return GlobalTimelineControllerProvider(
      startAfterOrdinal: startAfterOrdinal,
      endBeforeOrdinal: endBeforeOrdinal,
      pageSize: pageSize,
    );
  }

  @override
  GlobalTimelineControllerProvider getProviderOverride(
    covariant GlobalTimelineControllerProvider provider,
  ) {
    return call(
      startAfterOrdinal: provider.startAfterOrdinal,
      endBeforeOrdinal: provider.endBeforeOrdinal,
      pageSize: provider.pageSize,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'globalTimelineControllerProvider';
}

/// See also [GlobalTimelineController].
class GlobalTimelineControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          GlobalTimelineController,
          GlobalTimelineState
        > {
  /// See also [GlobalTimelineController].
  GlobalTimelineControllerProvider({
    int? startAfterOrdinal,
    int? endBeforeOrdinal,
    int pageSize = _globalTimelineDefaultPageSize,
  }) : this._internal(
         () => GlobalTimelineController()
           ..startAfterOrdinal = startAfterOrdinal
           ..endBeforeOrdinal = endBeforeOrdinal
           ..pageSize = pageSize,
         from: globalTimelineControllerProvider,
         name: r'globalTimelineControllerProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$globalTimelineControllerHash,
         dependencies: GlobalTimelineControllerFamily._dependencies,
         allTransitiveDependencies:
             GlobalTimelineControllerFamily._allTransitiveDependencies,
         startAfterOrdinal: startAfterOrdinal,
         endBeforeOrdinal: endBeforeOrdinal,
         pageSize: pageSize,
       );

  GlobalTimelineControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.startAfterOrdinal,
    required this.endBeforeOrdinal,
    required this.pageSize,
  }) : super.internal();

  final int? startAfterOrdinal;
  final int? endBeforeOrdinal;
  final int pageSize;

  @override
  FutureOr<GlobalTimelineState> runNotifierBuild(
    covariant GlobalTimelineController notifier,
  ) {
    return notifier.build(
      startAfterOrdinal: startAfterOrdinal,
      endBeforeOrdinal: endBeforeOrdinal,
      pageSize: pageSize,
    );
  }

  @override
  Override overrideWith(GlobalTimelineController Function() create) {
    return ProviderOverride(
      origin: this,
      override: GlobalTimelineControllerProvider._internal(
        () => create()
          ..startAfterOrdinal = startAfterOrdinal
          ..endBeforeOrdinal = endBeforeOrdinal
          ..pageSize = pageSize,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        startAfterOrdinal: startAfterOrdinal,
        endBeforeOrdinal: endBeforeOrdinal,
        pageSize: pageSize,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    GlobalTimelineController,
    GlobalTimelineState
  >
  createElement() {
    return _GlobalTimelineControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GlobalTimelineControllerProvider &&
        other.startAfterOrdinal == startAfterOrdinal &&
        other.endBeforeOrdinal == endBeforeOrdinal &&
        other.pageSize == pageSize;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, startAfterOrdinal.hashCode);
    hash = _SystemHash.combine(hash, endBeforeOrdinal.hashCode);
    hash = _SystemHash.combine(hash, pageSize.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GlobalTimelineControllerRef
    on AutoDisposeAsyncNotifierProviderRef<GlobalTimelineState> {
  /// The parameter `startAfterOrdinal` of this provider.
  int? get startAfterOrdinal;

  /// The parameter `endBeforeOrdinal` of this provider.
  int? get endBeforeOrdinal;

  /// The parameter `pageSize` of this provider.
  int get pageSize;
}

class _GlobalTimelineControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          GlobalTimelineController,
          GlobalTimelineState
        >
    with GlobalTimelineControllerRef {
  _GlobalTimelineControllerProviderElement(super.provider);

  @override
  int? get startAfterOrdinal =>
      (origin as GlobalTimelineControllerProvider).startAfterOrdinal;
  @override
  int? get endBeforeOrdinal =>
      (origin as GlobalTimelineControllerProvider).endBeforeOrdinal;
  @override
  int get pageSize => (origin as GlobalTimelineControllerProvider).pageSize;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
