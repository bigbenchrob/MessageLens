// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_messages_evidence_presentation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$globalMessagesEvidencePresentationHash() =>
    r'2b7ac6ed4764e8cc535c12481745f799aa3a81fd';

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

/// See also [globalMessagesEvidencePresentation].
@ProviderFor(globalMessagesEvidencePresentation)
const globalMessagesEvidencePresentationProvider =
    GlobalMessagesEvidencePresentationFamily();

/// See also [globalMessagesEvidencePresentation].
class GlobalMessagesEvidencePresentationFamily
    extends Family<GlobalMessagesEvidencePresentationState> {
  /// See also [globalMessagesEvidencePresentation].
  const GlobalMessagesEvidencePresentationFamily();

  /// See also [globalMessagesEvidencePresentation].
  GlobalMessagesEvidencePresentationProvider call({DateTime? monthAnchor}) {
    return GlobalMessagesEvidencePresentationProvider(monthAnchor: monthAnchor);
  }

  @override
  GlobalMessagesEvidencePresentationProvider getProviderOverride(
    covariant GlobalMessagesEvidencePresentationProvider provider,
  ) {
    return call(monthAnchor: provider.monthAnchor);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'globalMessagesEvidencePresentationProvider';
}

/// See also [globalMessagesEvidencePresentation].
class GlobalMessagesEvidencePresentationProvider
    extends AutoDisposeProvider<GlobalMessagesEvidencePresentationState> {
  /// See also [globalMessagesEvidencePresentation].
  GlobalMessagesEvidencePresentationProvider({DateTime? monthAnchor})
    : this._internal(
        (ref) => globalMessagesEvidencePresentation(
          ref as GlobalMessagesEvidencePresentationRef,
          monthAnchor: monthAnchor,
        ),
        from: globalMessagesEvidencePresentationProvider,
        name: r'globalMessagesEvidencePresentationProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$globalMessagesEvidencePresentationHash,
        dependencies: GlobalMessagesEvidencePresentationFamily._dependencies,
        allTransitiveDependencies:
            GlobalMessagesEvidencePresentationFamily._allTransitiveDependencies,
        monthAnchor: monthAnchor,
      );

  GlobalMessagesEvidencePresentationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.monthAnchor,
  }) : super.internal();

  final DateTime? monthAnchor;

  @override
  Override overrideWith(
    GlobalMessagesEvidencePresentationState Function(
      GlobalMessagesEvidencePresentationRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GlobalMessagesEvidencePresentationProvider._internal(
        (ref) => create(ref as GlobalMessagesEvidencePresentationRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        monthAnchor: monthAnchor,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<GlobalMessagesEvidencePresentationState>
  createElement() {
    return _GlobalMessagesEvidencePresentationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GlobalMessagesEvidencePresentationProvider &&
        other.monthAnchor == monthAnchor;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, monthAnchor.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GlobalMessagesEvidencePresentationRef
    on AutoDisposeProviderRef<GlobalMessagesEvidencePresentationState> {
  /// The parameter `monthAnchor` of this provider.
  DateTime? get monthAnchor;
}

class _GlobalMessagesEvidencePresentationProviderElement
    extends AutoDisposeProviderElement<GlobalMessagesEvidencePresentationState>
    with GlobalMessagesEvidencePresentationRef {
  _GlobalMessagesEvidencePresentationProviderElement(super.provider);

  @override
  DateTime? get monthAnchor =>
      (origin as GlobalMessagesEvidencePresentationProvider).monthAnchor;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
