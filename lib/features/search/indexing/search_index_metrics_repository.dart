import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'search_indexer.dart';

class SearchIndexMetricsRepository {
  SearchIndexMetricsRepository({SharedPreferences? preferences})
    : _preferences = preferences;

  final SharedPreferences? _preferences;
  final Map<String, SearchIndexerRunRecord> _memoryRecords = {};

  static const _storagePrefix = 'search_indexer_metrics_';

  Future<SearchIndexerRunRecord?> load(String indexerId) async {
    final prefs = _preferences;
    if (prefs == null) {
      return _memoryRecords[indexerId];
    }

    final raw = prefs.getString('$_storagePrefix$indexerId');
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return SearchIndexerRunRecord.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(String indexerId, SearchIndexerRunRecord record) async {
    final prefs = _preferences;
    if (prefs == null) {
      _memoryRecords[indexerId] = record;
      return;
    }

    final json = jsonEncode(record.toJson());
    await prefs.setString('$_storagePrefix$indexerId', json);
  }
}
