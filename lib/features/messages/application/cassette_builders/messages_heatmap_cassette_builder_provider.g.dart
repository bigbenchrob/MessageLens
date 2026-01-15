// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_heatmap_cassette_builder_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messagesHeatmapCassetteBuilderHash() =>
    r'f58b1be15c44140cbbb95a1e04650293f45471ff';

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

/// See also [messagesHeatmapCassetteBuilder].
@ProviderFor(messagesHeatmapCassetteBuilder)
const messagesHeatmapCassetteBuilderProvider =
    MessagesHeatmapCassetteBuilderFamily();

/// See also [messagesHeatmapCassetteBuilder].
class MessagesHeatmapCassetteBuilderFamily
    extends Family<SidebarCassetteCardViewModel> {
  /// See also [messagesHeatmapCassetteBuilder].
  const MessagesHeatmapCassetteBuilderFamily();

  /// See also [messagesHeatmapCassetteBuilder].
  MessagesHeatmapCassetteBuilderProvider call({
    required int? contactId,
    required bool useV2Timeline,
  }) {
    return MessagesHeatmapCassetteBuilderProvider(
      contactId: contactId,
      useV2Timeline: useV2Timeline,
    );
  }

  @override
  MessagesHeatmapCassetteBuilderProvider getProviderOverride(
    covariant MessagesHeatmapCassetteBuilderProvider provider,
  ) {
    return call(
      contactId: provider.contactId,
      useV2Timeline: provider.useV2Timeline,
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
  String? get name => r'messagesHeatmapCassetteBuilderProvider';
}

/// See also [messagesHeatmapCassetteBuilder].
class MessagesHeatmapCassetteBuilderProvider
    extends AutoDisposeProvider<SidebarCassetteCardViewModel> {
  /// See also [messagesHeatmapCassetteBuilder].
  MessagesHeatmapCassetteBuilderProvider({
    required int? contactId,
    required bool useV2Timeline,
  }) : this._internal(
         (ref) => messagesHeatmapCassetteBuilder(
           ref as MessagesHeatmapCassetteBuilderRef,
           contactId: contactId,
           useV2Timeline: useV2Timeline,
         ),
         from: messagesHeatmapCassetteBuilderProvider,
         name: r'messagesHeatmapCassetteBuilderProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$messagesHeatmapCassetteBuilderHash,
         dependencies: MessagesHeatmapCassetteBuilderFamily._dependencies,
         allTransitiveDependencies:
             MessagesHeatmapCassetteBuilderFamily._allTransitiveDependencies,
         contactId: contactId,
         useV2Timeline: useV2Timeline,
       );

  MessagesHeatmapCassetteBuilderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contactId,
    required this.useV2Timeline,
  }) : super.internal();

  final int? contactId;
  final bool useV2Timeline;

  @override
  Override overrideWith(
    SidebarCassetteCardViewModel Function(
      MessagesHeatmapCassetteBuilderRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessagesHeatmapCassetteBuilderProvider._internal(
        (ref) => create(ref as MessagesHeatmapCassetteBuilderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contactId: contactId,
        useV2Timeline: useV2Timeline,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<SidebarCassetteCardViewModel> createElement() {
    return _MessagesHeatmapCassetteBuilderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesHeatmapCassetteBuilderProvider &&
        other.contactId == contactId &&
        other.useV2Timeline == useV2Timeline;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contactId.hashCode);
    hash = _SystemHash.combine(hash, useV2Timeline.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessagesHeatmapCassetteBuilderRef
    on AutoDisposeProviderRef<SidebarCassetteCardViewModel> {
  /// The parameter `contactId` of this provider.
  int? get contactId;

  /// The parameter `useV2Timeline` of this provider.
  bool get useV2Timeline;
}

class _MessagesHeatmapCassetteBuilderProviderElement
    extends AutoDisposeProviderElement<SidebarCassetteCardViewModel>
    with MessagesHeatmapCassetteBuilderRef {
  _MessagesHeatmapCassetteBuilderProviderElement(super.provider);

  @override
  int? get contactId =>
      (origin as MessagesHeatmapCassetteBuilderProvider).contactId;
  @override
  bool get useV2Timeline =>
      (origin as MessagesHeatmapCassetteBuilderProvider).useV2Timeline;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
