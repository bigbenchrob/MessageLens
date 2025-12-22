// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_chooser_view_builder_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactChooserViewBuilderHash() =>
    r'c52104eab2b62ac8878266610e4f9b057a27faeb';

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

/// Resolves which contact picker widget to display based on contact count.
///
/// This provider determines whether to show a flat list or grouped picker
/// by checking the total contact count against [kContactPickerGroupingThreshold].
///
/// Copied from [contactChooserViewBuilder].
@ProviderFor(contactChooserViewBuilder)
const contactChooserViewBuilderProvider = ContactChooserViewBuilderFamily();

/// Resolves which contact picker widget to display based on contact count.
///
/// This provider determines whether to show a flat list or grouped picker
/// by checking the total contact count against [kContactPickerGroupingThreshold].
///
/// Copied from [contactChooserViewBuilder].
class ContactChooserViewBuilderFamily extends Family<Widget> {
  /// Resolves which contact picker widget to display based on contact count.
  ///
  /// This provider determines whether to show a flat list or grouped picker
  /// by checking the total contact count against [kContactPickerGroupingThreshold].
  ///
  /// Copied from [contactChooserViewBuilder].
  const ContactChooserViewBuilderFamily();

  /// Resolves which contact picker widget to display based on contact count.
  ///
  /// This provider determines whether to show a flat list or grouped picker
  /// by checking the total contact count against [kContactPickerGroupingThreshold].
  ///
  /// Copied from [contactChooserViewBuilder].
  ContactChooserViewBuilderProvider call(ContactsCassetteSpec spec) {
    return ContactChooserViewBuilderProvider(spec);
  }

  @override
  ContactChooserViewBuilderProvider getProviderOverride(
    covariant ContactChooserViewBuilderProvider provider,
  ) {
    return call(provider.spec);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'contactChooserViewBuilderProvider';
}

/// Resolves which contact picker widget to display based on contact count.
///
/// This provider determines whether to show a flat list or grouped picker
/// by checking the total contact count against [kContactPickerGroupingThreshold].
///
/// Copied from [contactChooserViewBuilder].
class ContactChooserViewBuilderProvider extends AutoDisposeProvider<Widget> {
  /// Resolves which contact picker widget to display based on contact count.
  ///
  /// This provider determines whether to show a flat list or grouped picker
  /// by checking the total contact count against [kContactPickerGroupingThreshold].
  ///
  /// Copied from [contactChooserViewBuilder].
  ContactChooserViewBuilderProvider(ContactsCassetteSpec spec)
    : this._internal(
        (ref) => contactChooserViewBuilder(
          ref as ContactChooserViewBuilderRef,
          spec,
        ),
        from: contactChooserViewBuilderProvider,
        name: r'contactChooserViewBuilderProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contactChooserViewBuilderHash,
        dependencies: ContactChooserViewBuilderFamily._dependencies,
        allTransitiveDependencies:
            ContactChooserViewBuilderFamily._allTransitiveDependencies,
        spec: spec,
      );

  ContactChooserViewBuilderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.spec,
  }) : super.internal();

  final ContactsCassetteSpec spec;

  @override
  Override overrideWith(
    Widget Function(ContactChooserViewBuilderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContactChooserViewBuilderProvider._internal(
        (ref) => create(ref as ContactChooserViewBuilderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        spec: spec,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<Widget> createElement() {
    return _ContactChooserViewBuilderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactChooserViewBuilderProvider && other.spec == spec;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, spec.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContactChooserViewBuilderRef on AutoDisposeProviderRef<Widget> {
  /// The parameter `spec` of this provider.
  ContactsCassetteSpec get spec;
}

class _ContactChooserViewBuilderProviderElement
    extends AutoDisposeProviderElement<Widget>
    with ContactChooserViewBuilderRef {
  _ContactChooserViewBuilderProviderElement(super.provider);

  @override
  ContactsCassetteSpec get spec =>
      (origin as ContactChooserViewBuilderProvider).spec;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
