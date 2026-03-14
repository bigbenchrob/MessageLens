// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dbImportMessageExtractorHash() =>
    r'258eb7e7bdaeef245ca6d3656b21e9637e094bca';

/// Provides the Rust-backed message extractor used to decode attributed blobs
/// during the database import pipeline.
///
/// Copied from [dbImportMessageExtractor].
@ProviderFor(dbImportMessageExtractor)
final dbImportMessageExtractorProvider =
    AutoDisposeProvider<MessageExtractorPort>.internal(
      dbImportMessageExtractor,
      name: r'dbImportMessageExtractorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dbImportMessageExtractorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DbImportMessageExtractorRef =
    AutoDisposeProviderRef<MessageExtractorPort>;
String _$orchestratedLedgerImportServiceHash() =>
    r'6aca1303b778d17d459a830947e8049a53a715d9';

/// High-level service orchestrating the ingest into the Sqflite ledger.
///
/// Copied from [orchestratedLedgerImportService].
@ProviderFor(orchestratedLedgerImportService)
final orchestratedLedgerImportServiceProvider =
    AutoDisposeProvider<OrchestratedLedgerImportService>.internal(
      orchestratedLedgerImportService,
      name: r'orchestratedLedgerImportServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$orchestratedLedgerImportServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OrchestratedLedgerImportServiceRef =
    AutoDisposeProviderRef<OrchestratedLedgerImportService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
