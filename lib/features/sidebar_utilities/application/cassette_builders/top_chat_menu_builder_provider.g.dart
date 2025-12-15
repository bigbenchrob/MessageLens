// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_chat_menu_builder_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$topChatMenuBuilderHash() =>
    r'84009f2d68d802c9f8dc7b4f4e1137c9024ec2f5';

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

abstract class _$TopChatMenuBuilder
    extends BuildlessAutoDisposeNotifier<Widget> {
  late final SidebarUtilityCassetteSpec sidebarUtilityCassetteSpec;

  Widget build(SidebarUtilityCassetteSpec sidebarUtilityCassetteSpec);
}

/// [SidebarWidgetCassetteSpec.topChatMenu] into the corresponding
/// [TopChatMenu] widget.
/// Additional sidebar widget cassettes should have their own builders
///  placed in this folder.
///
/// Copied from [TopChatMenuBuilder].
@ProviderFor(TopChatMenuBuilder)
const topChatMenuBuilderProvider = TopChatMenuBuilderFamily();

/// [SidebarWidgetCassetteSpec.topChatMenu] into the corresponding
/// [TopChatMenu] widget.
/// Additional sidebar widget cassettes should have their own builders
///  placed in this folder.
///
/// Copied from [TopChatMenuBuilder].
class TopChatMenuBuilderFamily extends Family<Widget> {
  /// [SidebarWidgetCassetteSpec.topChatMenu] into the corresponding
  /// [TopChatMenu] widget.
  /// Additional sidebar widget cassettes should have their own builders
  ///  placed in this folder.
  ///
  /// Copied from [TopChatMenuBuilder].
  const TopChatMenuBuilderFamily();

  /// [SidebarWidgetCassetteSpec.topChatMenu] into the corresponding
  /// [TopChatMenu] widget.
  /// Additional sidebar widget cassettes should have their own builders
  ///  placed in this folder.
  ///
  /// Copied from [TopChatMenuBuilder].
  TopChatMenuBuilderProvider call(
    SidebarUtilityCassetteSpec sidebarUtilityCassetteSpec,
  ) {
    return TopChatMenuBuilderProvider(sidebarUtilityCassetteSpec);
  }

  @override
  TopChatMenuBuilderProvider getProviderOverride(
    covariant TopChatMenuBuilderProvider provider,
  ) {
    return call(provider.sidebarUtilityCassetteSpec);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'topChatMenuBuilderProvider';
}

/// [SidebarWidgetCassetteSpec.topChatMenu] into the corresponding
/// [TopChatMenu] widget.
/// Additional sidebar widget cassettes should have their own builders
///  placed in this folder.
///
/// Copied from [TopChatMenuBuilder].
class TopChatMenuBuilderProvider
    extends AutoDisposeNotifierProviderImpl<TopChatMenuBuilder, Widget> {
  /// [SidebarWidgetCassetteSpec.topChatMenu] into the corresponding
  /// [TopChatMenu] widget.
  /// Additional sidebar widget cassettes should have their own builders
  ///  placed in this folder.
  ///
  /// Copied from [TopChatMenuBuilder].
  TopChatMenuBuilderProvider(
    SidebarUtilityCassetteSpec sidebarUtilityCassetteSpec,
  ) : this._internal(
        () =>
            TopChatMenuBuilder()
              ..sidebarUtilityCassetteSpec = sidebarUtilityCassetteSpec,
        from: topChatMenuBuilderProvider,
        name: r'topChatMenuBuilderProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$topChatMenuBuilderHash,
        dependencies: TopChatMenuBuilderFamily._dependencies,
        allTransitiveDependencies:
            TopChatMenuBuilderFamily._allTransitiveDependencies,
        sidebarUtilityCassetteSpec: sidebarUtilityCassetteSpec,
      );

  TopChatMenuBuilderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sidebarUtilityCassetteSpec,
  }) : super.internal();

  final SidebarUtilityCassetteSpec sidebarUtilityCassetteSpec;

  @override
  Widget runNotifierBuild(covariant TopChatMenuBuilder notifier) {
    return notifier.build(sidebarUtilityCassetteSpec);
  }

  @override
  Override overrideWith(TopChatMenuBuilder Function() create) {
    return ProviderOverride(
      origin: this,
      override: TopChatMenuBuilderProvider._internal(
        () => create()..sidebarUtilityCassetteSpec = sidebarUtilityCassetteSpec,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sidebarUtilityCassetteSpec: sidebarUtilityCassetteSpec,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<TopChatMenuBuilder, Widget>
  createElement() {
    return _TopChatMenuBuilderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TopChatMenuBuilderProvider &&
        other.sidebarUtilityCassetteSpec == sidebarUtilityCassetteSpec;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sidebarUtilityCassetteSpec.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TopChatMenuBuilderRef on AutoDisposeNotifierProviderRef<Widget> {
  /// The parameter `sidebarUtilityCassetteSpec` of this provider.
  SidebarUtilityCassetteSpec get sidebarUtilityCassetteSpec;
}

class _TopChatMenuBuilderProviderElement
    extends AutoDisposeNotifierProviderElement<TopChatMenuBuilder, Widget>
    with TopChatMenuBuilderRef {
  _TopChatMenuBuilderProviderElement(super.provider);

  @override
  SidebarUtilityCassetteSpec get sidebarUtilityCassetteSpec =>
      (origin as TopChatMenuBuilderProvider).sidebarUtilityCassetteSpec;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
