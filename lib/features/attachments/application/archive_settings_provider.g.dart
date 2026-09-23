// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'archive_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$archiveSettingsHash() => r'229a9cdfcd76b6ee7332bf4283aa10ef446066e1';

/// Manages the attachment archive user preferences.
///
/// The archive-enabled flag is persisted in the overlay DB's
/// `overlay_settings` key-value table so it survives derived-data rebuilds.
///
/// Copied from [ArchiveSettings].
@ProviderFor(ArchiveSettings)
final archiveSettingsProvider =
    AsyncNotifierProvider<ArchiveSettings, ArchiveSettingsState>.internal(
      ArchiveSettings.new,
      name: r'archiveSettingsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$archiveSettingsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ArchiveSettings = AsyncNotifier<ArchiveSettingsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
