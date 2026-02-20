// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_metadata_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$timelineMetadataHash() => r'0d6cb92125229488a8794ce65778bbba6664b01b';

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

/// Provides lightweight metadata about a timeline scope.
///
/// Fetches only the count and date bounds without computing full heatmap data.
///
/// Copied from [timelineMetadata].
@ProviderFor(timelineMetadata)
const timelineMetadataProvider = TimelineMetadataFamily();

/// Provides lightweight metadata about a timeline scope.
///
/// Fetches only the count and date bounds without computing full heatmap data.
///
/// Copied from [timelineMetadata].
class TimelineMetadataFamily extends Family<AsyncValue<TimelineMetadata>> {
  /// Provides lightweight metadata about a timeline scope.
  ///
  /// Fetches only the count and date bounds without computing full heatmap data.
  ///
  /// Copied from [timelineMetadata].
  const TimelineMetadataFamily();

  /// Provides lightweight metadata about a timeline scope.
  ///
  /// Fetches only the count and date bounds without computing full heatmap data.
  ///
  /// Copied from [timelineMetadata].
  TimelineMetadataProvider call({required MessageTimelineScope scope}) {
    return TimelineMetadataProvider(scope: scope);
  }

  @override
  TimelineMetadataProvider getProviderOverride(
    covariant TimelineMetadataProvider provider,
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
  String? get name => r'timelineMetadataProvider';
}

/// Provides lightweight metadata about a timeline scope.
///
/// Fetches only the count and date bounds without computing full heatmap data.
///
/// Copied from [timelineMetadata].
class TimelineMetadataProvider
    extends AutoDisposeFutureProvider<TimelineMetadata> {
  /// Provides lightweight metadata about a timeline scope.
  ///
  /// Fetches only the count and date bounds without computing full heatmap data.
  ///
  /// Copied from [timelineMetadata].
  TimelineMetadataProvider({required MessageTimelineScope scope})
    : this._internal(
        (ref) => timelineMetadata(ref as TimelineMetadataRef, scope: scope),
        from: timelineMetadataProvider,
        name: r'timelineMetadataProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$timelineMetadataHash,
        dependencies: TimelineMetadataFamily._dependencies,
        allTransitiveDependencies:
            TimelineMetadataFamily._allTransitiveDependencies,
        scope: scope,
      );

  TimelineMetadataProvider._internal(
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
    FutureOr<TimelineMetadata> Function(TimelineMetadataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TimelineMetadataProvider._internal(
        (ref) => create(ref as TimelineMetadataRef),
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
  AutoDisposeFutureProviderElement<TimelineMetadata> createElement() {
    return _TimelineMetadataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TimelineMetadataProvider && other.scope == scope;
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
mixin TimelineMetadataRef on AutoDisposeFutureProviderRef<TimelineMetadata> {
  /// The parameter `scope` of this provider.
  MessageTimelineScope get scope;
}

class _TimelineMetadataProviderElement
    extends AutoDisposeFutureProviderElement<TimelineMetadata>
    with TimelineMetadataRef {
  _TimelineMetadataProviderElement(super.provider);

  @override
  MessageTimelineScope get scope => (origin as TimelineMetadataProvider).scope;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
