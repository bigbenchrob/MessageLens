// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_execution_gate_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$importExecutionGateHash() =>
    r'93208f85956e1d13cf047cd0f4a59dbd874dd463';

/// Global import/migration execution gate.
///
/// This acts as a single source of truth for who currently owns the import
/// execution token ("the ball"). Only one owner may run import/migration work
/// at a time. Re-entrant acquisition by the same owner is allowed.
///
/// Copied from [ImportExecutionGate].
@ProviderFor(ImportExecutionGate)
final importExecutionGateProvider =
    NotifierProvider<ImportExecutionGate, ImportExecutionGateState>.internal(
      ImportExecutionGate.new,
      name: r'importExecutionGateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$importExecutionGateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ImportExecutionGate = Notifier<ImportExecutionGateState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
