// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workbenchQueryRepositoryHash() =>
    r'c47d9b4dd38dd49db7acec04434378ae1379f5f7';

/// Provides the repository used by the workbench to inspect the import
/// database. The concrete implementation will be wired to the shared
/// SqfliteImportDatabase instance supplied by the database essentials module.
///
/// Copied from [workbenchQueryRepository].
@ProviderFor(workbenchQueryRepository)
final workbenchQueryRepositoryProvider =
    AutoDisposeFutureProvider<WorkbenchQueryRepository>.internal(
      workbenchQueryRepository,
      name: r'workbenchQueryRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$workbenchQueryRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WorkbenchQueryRepositoryRef =
    AutoDisposeFutureProviderRef<WorkbenchQueryRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
