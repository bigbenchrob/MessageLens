import 'dart:convert';

import '../../../db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/onboarding_failure_store.dart';
import '../../domain/onboarding_environment_report.dart';

class OverlayOnboardingFailureStorage implements OnboardingFailureStore {
  OverlayOnboardingFailureStorage({
    required Future<OverlayDatabase> overlayDb,
    Future<String?> Function(OverlayDatabase overlayDb, String settingKey)?
    readOverlaySetting,
    void Function(String settingKey, Object error, StackTrace stackTrace)?
    onReadFailure,
  }) : _overlayDb = overlayDb,
       _readOverlaySetting =
           readOverlaySetting ?? _readOverlaySettingFromDatabase,
       _onReadFailure = onReadFailure;

  static const String _importFailureKey = 'onboarding_last_import_result';
  static const String _graphProjectionFailureKey =
      'onboarding_last_graph_projection_result';
  // Keep the historical key readable so existing persisted setup failures
  // survive the graph-projection terminology change.
  static const String _historicalGraphProjectionFailureKey =
      'onboarding_last_migration_result';
  static const String _recordedAtKey = 'recorded_at_utc';

  final Future<OverlayDatabase> _overlayDb;
  final Future<String?> Function(OverlayDatabase overlayDb, String settingKey)
  _readOverlaySetting;
  final void Function(String settingKey, Object error, StackTrace stackTrace)?
  _onReadFailure;

  @override
  Future<OnboardingPipelineFailure?> loadSourceImportFailure() async {
    return (await loadSourceImportFailureEntry())?.failure;
  }

  @override
  Future<PersistedOnboardingSourceImportFailure?> loadSourceImportFailureEntry({
    void Function()? requirePersistentArchiveStoreAdmission,
  }) async {
    late final OverlayDatabase overlayDb;
    requirePersistentArchiveStoreAdmission?.call();
    try {
      overlayDb = await _overlayDb;
    } catch (error, stackTrace) {
      _onReadFailure?.call(_importFailureKey, error, stackTrace);
      return null;
    }

    late final String? rawValue;
    requirePersistentArchiveStoreAdmission?.call();
    try {
      rawValue = await _readOverlaySetting(overlayDb, _importFailureKey);
    } catch (error, stackTrace) {
      _onReadFailure?.call(_importFailureKey, error, stackTrace);
      return null;
    }

    try {
      if (rawValue == null || rawValue.isEmpty) {
        return null;
      }

      final decoded = jsonDecode(rawValue);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final batchId = decoded['batch_id'] as int?;
      final success = decoded['success'] as bool?;
      if (batchId == null || success == null) {
        return null;
      }
      if (success) {
        return null;
      }

      return PersistedOnboardingSourceImportFailure(
        recordedAt: _asDateTime(decoded[_recordedAtKey]),
        failure: OnboardingPipelineFailure(
          phase: OnboardingPipelinePhase.import,
          batchId: batchId,
          message: decoded['error'] as String?,
        ),
      );
    } catch (error, stackTrace) {
      _onReadFailure?.call(_importFailureKey, error, stackTrace);
      return null;
    }
  }

  @override
  Future<void> saveImportFailure({
    required String message,
    int batchId = -1,
    DateTime? recordedAt,
    List<String> warnings = const <String>[],
  }) async {
    final summary = <String, Object?>{
      'batch_id': batchId,
      'success': false,
      'error': message,
      'warnings': warnings,
      _recordedAtKey: (recordedAt ?? DateTime.now().toUtc()).toIso8601String(),
    };
    await _writeJsonSetting(_importFailureKey, summary);
  }

  @override
  Future<void> clearSourceImportFailure() async {
    await _clearSetting(_importFailureKey);
  }

  @override
  Future<OnboardingPipelineFailure?> loadGraphProjectionFailure() async {
    return (await loadGraphProjectionFailureEntry())?.failure;
  }

  @override
  Future<PersistedOnboardingGraphProjectionFailure?>
  loadGraphProjectionFailureEntry({
    void Function()? requirePersistentArchiveStoreAdmission,
  }) async {
    final current = await _loadGraphProjectionFailureFromKey(
      _graphProjectionFailureKey,
      requirePersistentArchiveStoreAdmission:
          requirePersistentArchiveStoreAdmission,
    );
    if (current != null) {
      return current;
    }
    requirePersistentArchiveStoreAdmission?.call();
    return _loadGraphProjectionFailureFromKey(
      _historicalGraphProjectionFailureKey,
      requirePersistentArchiveStoreAdmission:
          requirePersistentArchiveStoreAdmission,
    );
  }

  @override
  Future<void> saveGraphProjectionFailure({
    required String message,
    int batchId = -1,
    DateTime? recordedAt,
  }) async {
    final summary = <String, Object?>{
      'batch_id': batchId,
      'success': false,
      'error': message,
      _recordedAtKey: (recordedAt ?? DateTime.now().toUtc()).toIso8601String(),
    };
    await _writeJsonSetting(_graphProjectionFailureKey, summary);
  }

  @override
  Future<void> clearGraphProjectionFailure() async {
    await _clearSetting(_graphProjectionFailureKey);
    await _clearSetting(_historicalGraphProjectionFailureKey);
  }

  Future<PersistedOnboardingGraphProjectionFailure?>
  _loadGraphProjectionFailureFromKey(
    String settingKey, {
    void Function()? requirePersistentArchiveStoreAdmission,
  }) async {
    late final OverlayDatabase overlayDb;
    requirePersistentArchiveStoreAdmission?.call();
    try {
      overlayDb = await _overlayDb;
    } catch (error, stackTrace) {
      _onReadFailure?.call(settingKey, error, stackTrace);
      return null;
    }

    late final String? rawValue;
    requirePersistentArchiveStoreAdmission?.call();
    try {
      rawValue = await _readOverlaySetting(overlayDb, settingKey);
    } catch (error, stackTrace) {
      _onReadFailure?.call(settingKey, error, stackTrace);
      return null;
    }

    try {
      if (rawValue == null || rawValue.isEmpty) {
        return null;
      }

      final decoded = jsonDecode(rawValue);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final batchId = decoded['batch_id'] as int?;
      final success = decoded['success'] as bool?;
      if (batchId == null || success == null) {
        return null;
      }
      if (success) {
        return null;
      }

      return PersistedOnboardingGraphProjectionFailure(
        recordedAt: _asDateTime(decoded[_recordedAtKey]),
        failure: OnboardingPipelineFailure(
          phase: OnboardingPipelinePhase.graphProjection,
          batchId: batchId,
          message: decoded['error'] as String?,
        ),
      );
    } catch (error, stackTrace) {
      _onReadFailure?.call(settingKey, error, stackTrace);
      return null;
    }
  }

  static Future<String?> _readOverlaySettingFromDatabase(
    OverlayDatabase overlayDb,
    String settingKey,
  ) {
    return overlayDb.readOverlaySetting(settingKey);
  }

  Future<void> _writeJsonSetting(
    String settingKey,
    Map<String, Object?> value,
  ) async {
    final overlayDb = await _overlayDb;
    await overlayDb.writeOverlaySetting(
      settingKey: settingKey,
      settingValue: jsonEncode(value),
    );
  }

  Future<void> _clearSetting(String settingKey) async {
    final overlayDb = await _overlayDb;
    await overlayDb.writeOverlaySetting(
      settingKey: settingKey,
      settingValue: '',
    );
  }

  DateTime? _asDateTime(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value)?.toUtc();
  }
}
