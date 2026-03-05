// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'working_db_populated_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workingDbPopulatedHash() =>
    r'd608ddc7d49bf53d4bb81a99c242f3b2997c7bd7';

/// Whether `working.db` contains data (file exists and is non-empty).
///
/// Watches [messageDataVersionProvider] so it re-evaluates after migration
/// bumps that signal. Used to gate sidebar cascades and the top menu prompt
/// on first launch.
///
/// Copied from [WorkingDbPopulated].
@ProviderFor(WorkingDbPopulated)
final workingDbPopulatedProvider =
    NotifierProvider<WorkingDbPopulated, bool>.internal(
      WorkingDbPopulated.new,
      name: r'workingDbPopulatedProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$workingDbPopulatedHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WorkingDbPopulated = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
