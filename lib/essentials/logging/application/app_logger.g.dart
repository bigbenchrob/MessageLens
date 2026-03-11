// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_logger.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appLoggerHash() => r'59bacc1f5a038607a109a2d1d7e7dfc9c6ac7f39';

/// Unified application logger.
///
/// Accepts structured log entries at four levels (`debug`, `info`, `warn`,
/// `error`) and writes them both to an in-memory buffer (exposed as provider
/// state) and to a persistent JSONL log file via [LogFileWriter].
///
/// The `debug` level is gated behind [kDebugMode] so release builds only
/// contain `info`, `warn`, and `error` entries.
///
/// Copied from [AppLogger].
@ProviderFor(AppLogger)
final appLoggerProvider = NotifierProvider<AppLogger, List<LogEntry>>.internal(
  AppLogger.new,
  name: r'appLoggerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appLoggerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppLogger = Notifier<List<LogEntry>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
