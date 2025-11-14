// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_message_timeline_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$globalMessageTimelineHash() =>
    r'9a04026c1999b829a0a952623f730ffed863f155';

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

abstract class _$GlobalMessageTimeline
    extends BuildlessAutoDisposeAsyncNotifier<GlobalMessageTimelinePage> {
  late final int? startAfterOrdinal;
  late final int? endBeforeOrdinal;
  late final int? pageSize;

  FutureOr<GlobalMessageTimelinePage> build({
    int? startAfterOrdinal,
    int? endBeforeOrdinal,
    int? pageSize,
  });
}

/// See also [GlobalMessageTimeline].
@ProviderFor(GlobalMessageTimeline)
const globalMessageTimelineProvider = GlobalMessageTimelineFamily();

/// See also [GlobalMessageTimeline].
class GlobalMessageTimelineFamily
    extends Family<AsyncValue<GlobalMessageTimelinePage>> {
  /// See also [GlobalMessageTimeline].
  const GlobalMessageTimelineFamily();

  /// See also [GlobalMessageTimeline].
  GlobalMessageTimelineProvider call({
    int? startAfterOrdinal,
    int? endBeforeOrdinal,
    int? pageSize,
  }) {
    return GlobalMessageTimelineProvider(
      startAfterOrdinal: startAfterOrdinal,
      endBeforeOrdinal: endBeforeOrdinal,
      pageSize: pageSize,
    );
  }

  @override
  GlobalMessageTimelineProvider getProviderOverride(
    covariant GlobalMessageTimelineProvider provider,
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
  String? get name => r'globalMessageTimelineProvider';
}

/// See also [GlobalMessageTimeline].
class GlobalMessageTimelineProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          GlobalMessageTimeline,
          GlobalMessageTimelinePage
        > {
  /// See also [GlobalMessageTimeline].
  GlobalMessageTimelineProvider({
    int? startAfterOrdinal,
    int? endBeforeOrdinal,
    int? pageSize,
  }) : this._internal(
         () => GlobalMessageTimeline()
           ..startAfterOrdinal = startAfterOrdinal
           ..endBeforeOrdinal = endBeforeOrdinal
           ..pageSize = pageSize,
         from: globalMessageTimelineProvider,
         name: r'globalMessageTimelineProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$globalMessageTimelineHash,
         dependencies: GlobalMessageTimelineFamily._dependencies,
         allTransitiveDependencies:
             GlobalMessageTimelineFamily._allTransitiveDependencies,
         startAfterOrdinal: startAfterOrdinal,
         endBeforeOrdinal: endBeforeOrdinal,
         pageSize: pageSize,
       );

  GlobalMessageTimelineProvider._internal(
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
  final int? pageSize;

  @override
  FutureOr<GlobalMessageTimelinePage> runNotifierBuild(
    covariant GlobalMessageTimeline notifier,
  ) {
    return notifier.build(
      startAfterOrdinal: startAfterOrdinal,
      endBeforeOrdinal: endBeforeOrdinal,
      pageSize: pageSize,
    );
  }

  @override
  Override overrideWith(GlobalMessageTimeline Function() create) {
    return ProviderOverride(
      origin: this,
      override: GlobalMessageTimelineProvider._internal(
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
    GlobalMessageTimeline,
    GlobalMessageTimelinePage
  >
  createElement() {
    return _GlobalMessageTimelineProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GlobalMessageTimelineProvider &&
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
mixin GlobalMessageTimelineRef
    on AutoDisposeAsyncNotifierProviderRef<GlobalMessageTimelinePage> {
  /// The parameter `startAfterOrdinal` of this provider.
  int? get startAfterOrdinal;

  /// The parameter `endBeforeOrdinal` of this provider.
  int? get endBeforeOrdinal;

  /// The parameter `pageSize` of this provider.
  int? get pageSize;
}

class _GlobalMessageTimelineProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          GlobalMessageTimeline,
          GlobalMessageTimelinePage
        >
    with GlobalMessageTimelineRef {
  _GlobalMessageTimelineProviderElement(super.provider);

  @override
  int? get startAfterOrdinal =>
      (origin as GlobalMessageTimelineProvider).startAfterOrdinal;
  @override
  int? get endBeforeOrdinal =>
      (origin as GlobalMessageTimelineProvider).endBeforeOrdinal;
  @override
  int? get pageSize => (origin as GlobalMessageTimelineProvider).pageSize;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
