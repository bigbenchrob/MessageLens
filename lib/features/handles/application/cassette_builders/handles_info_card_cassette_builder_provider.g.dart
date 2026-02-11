// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handles_info_card_cassette_builder_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$handlesInfoCardCassetteBuilderHash() =>
    r'be708218c026e55c84b0f1917a065dcfaac62441';

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

/// Builds the cassette view model for handles info cards.
///
/// Info cards display explanatory text without controls or data.
/// They always have a child cassette that follows.
///
/// This builder returns a [SidebarCassetteCardViewModel] with
/// [CassetteCardType.info], which tells [CassetteWidgetCoordinator]
/// to render a [SidebarInfoCard] instead of [SidebarCassetteCard].
///
/// Copied from [handlesInfoCardCassetteBuilder].
@ProviderFor(handlesInfoCardCassetteBuilder)
const handlesInfoCardCassetteBuilderProvider =
    HandlesInfoCardCassetteBuilderFamily();

/// Builds the cassette view model for handles info cards.
///
/// Info cards display explanatory text without controls or data.
/// They always have a child cassette that follows.
///
/// This builder returns a [SidebarCassetteCardViewModel] with
/// [CassetteCardType.info], which tells [CassetteWidgetCoordinator]
/// to render a [SidebarInfoCard] instead of [SidebarCassetteCard].
///
/// Copied from [handlesInfoCardCassetteBuilder].
class HandlesInfoCardCassetteBuilderFamily
    extends Family<SidebarCassetteCardViewModel> {
  /// Builds the cassette view model for handles info cards.
  ///
  /// Info cards display explanatory text without controls or data.
  /// They always have a child cassette that follows.
  ///
  /// This builder returns a [SidebarCassetteCardViewModel] with
  /// [CassetteCardType.info], which tells [CassetteWidgetCoordinator]
  /// to render a [SidebarInfoCard] instead of [SidebarCassetteCard].
  ///
  /// Copied from [handlesInfoCardCassetteBuilder].
  const HandlesInfoCardCassetteBuilderFamily();

  /// Builds the cassette view model for handles info cards.
  ///
  /// Info cards display explanatory text without controls or data.
  /// They always have a child cassette that follows.
  ///
  /// This builder returns a [SidebarCassetteCardViewModel] with
  /// [CassetteCardType.info], which tells [CassetteWidgetCoordinator]
  /// to render a [SidebarInfoCard] instead of [SidebarCassetteCard].
  ///
  /// Copied from [handlesInfoCardCassetteBuilder].
  HandlesInfoCardCassetteBuilderProvider call({
    String? title,
    required String message,
    String? footnote,
  }) {
    return HandlesInfoCardCassetteBuilderProvider(
      title: title,
      message: message,
      footnote: footnote,
    );
  }

  @override
  HandlesInfoCardCassetteBuilderProvider getProviderOverride(
    covariant HandlesInfoCardCassetteBuilderProvider provider,
  ) {
    return call(
      title: provider.title,
      message: provider.message,
      footnote: provider.footnote,
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
  String? get name => r'handlesInfoCardCassetteBuilderProvider';
}

/// Builds the cassette view model for handles info cards.
///
/// Info cards display explanatory text without controls or data.
/// They always have a child cassette that follows.
///
/// This builder returns a [SidebarCassetteCardViewModel] with
/// [CassetteCardType.info], which tells [CassetteWidgetCoordinator]
/// to render a [SidebarInfoCard] instead of [SidebarCassetteCard].
///
/// Copied from [handlesInfoCardCassetteBuilder].
class HandlesInfoCardCassetteBuilderProvider
    extends AutoDisposeProvider<SidebarCassetteCardViewModel> {
  /// Builds the cassette view model for handles info cards.
  ///
  /// Info cards display explanatory text without controls or data.
  /// They always have a child cassette that follows.
  ///
  /// This builder returns a [SidebarCassetteCardViewModel] with
  /// [CassetteCardType.info], which tells [CassetteWidgetCoordinator]
  /// to render a [SidebarInfoCard] instead of [SidebarCassetteCard].
  ///
  /// Copied from [handlesInfoCardCassetteBuilder].
  HandlesInfoCardCassetteBuilderProvider({
    String? title,
    required String message,
    String? footnote,
  }) : this._internal(
         (ref) => handlesInfoCardCassetteBuilder(
           ref as HandlesInfoCardCassetteBuilderRef,
           title: title,
           message: message,
           footnote: footnote,
         ),
         from: handlesInfoCardCassetteBuilderProvider,
         name: r'handlesInfoCardCassetteBuilderProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$handlesInfoCardCassetteBuilderHash,
         dependencies: HandlesInfoCardCassetteBuilderFamily._dependencies,
         allTransitiveDependencies:
             HandlesInfoCardCassetteBuilderFamily._allTransitiveDependencies,
         title: title,
         message: message,
         footnote: footnote,
       );

  HandlesInfoCardCassetteBuilderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.title,
    required this.message,
    required this.footnote,
  }) : super.internal();

  final String? title;
  final String message;
  final String? footnote;

  @override
  Override overrideWith(
    SidebarCassetteCardViewModel Function(
      HandlesInfoCardCassetteBuilderRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HandlesInfoCardCassetteBuilderProvider._internal(
        (ref) => create(ref as HandlesInfoCardCassetteBuilderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        title: title,
        message: message,
        footnote: footnote,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<SidebarCassetteCardViewModel> createElement() {
    return _HandlesInfoCardCassetteBuilderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HandlesInfoCardCassetteBuilderProvider &&
        other.title == title &&
        other.message == message &&
        other.footnote == footnote;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, title.hashCode);
    hash = _SystemHash.combine(hash, message.hashCode);
    hash = _SystemHash.combine(hash, footnote.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HandlesInfoCardCassetteBuilderRef
    on AutoDisposeProviderRef<SidebarCassetteCardViewModel> {
  /// The parameter `title` of this provider.
  String? get title;

  /// The parameter `message` of this provider.
  String get message;

  /// The parameter `footnote` of this provider.
  String? get footnote;
}

class _HandlesInfoCardCassetteBuilderProviderElement
    extends AutoDisposeProviderElement<SidebarCassetteCardViewModel>
    with HandlesInfoCardCassetteBuilderRef {
  _HandlesInfoCardCassetteBuilderProviderElement(super.provider);

  @override
  String? get title => (origin as HandlesInfoCardCassetteBuilderProvider).title;
  @override
  String get message =>
      (origin as HandlesInfoCardCassetteBuilderProvider).message;
  @override
  String? get footnote =>
      (origin as HandlesInfoCardCassetteBuilderProvider).footnote;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
