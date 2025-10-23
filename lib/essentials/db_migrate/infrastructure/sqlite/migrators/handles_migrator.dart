import 'package:drift/drift.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../db/infrastructure/data_sources/local/working/working_database.dart';
import '../../../../db/shared/handle_identifier_utils.dart';
import '../../../application/services/base_table_migrator.dart';
import '../migration_context_sqlite.dart';

class HandlesMigrator extends BaseTableMigrator {
  const HandlesMigrator();

  @override
  String get name => 'handles';

  @override
  List<String> get dependsOn => const [];

  @override
  Future<void> validatePrereqs(MigrationContext ctx) async {
    final importDb = await ctx.importDb.database;
    await importDb.execute('PRAGMA foreign_keys = ON');

    final integrityRows = await importDb.rawQuery('PRAGMA integrity_check');
    final integrityStatus = integrityRows.isEmpty
        ? 'no result'
        : integrityRows.first.values.first;
    await expectTrueOrThrow(
      ok: integrityStatus == 'ok',
      errorCode: 'HANDLES_INTEGRITY_CHECK_FAILED',
      message: 'handles: PRAGMA integrity_check returned "$integrityStatus"',
    );

    final importCount = await count(ctx.importDb, 'handles');
    ctx.log('[handles] import count = $importCount');
    await expectTrueOrThrow(
      ok: importCount > 0,
      errorCode: 'HANDLES_NO_SOURCE_ROWS',
      message: 'handles: import database returned zero rows',
    );

    final duplicateIds = await _singleInt(importDb, '''
      SELECT COUNT(*) FROM (
        SELECT id FROM handles GROUP BY id HAVING COUNT(*) > 1
      )
    ''');
    await expectZeroOrThrow(
      duplicateIds,
      'HANDLES_DUPLICATE_PRIMARY_KEY',
      'handles: duplicate id values detected in import database',
    );

    final duplicateCompoundIdentifiers = await _singleInt(importDb, '''
      SELECT COUNT(*) FROM (
        SELECT compound_identifier FROM handles
        WHERE compound_identifier IS NOT NULL AND TRIM(compound_identifier) <> ''
        GROUP BY compound_identifier
        HAVING COUNT(*) > 1
      )
    ''');
    if (duplicateCompoundIdentifiers > 0) {
      ctx.log(
        '[handles] detected $duplicateCompoundIdentifiers compound identifier group(s); variants will be merged into canonical handles',
      );
    }

    final missingIdentifiers = await _singleInt(importDb, '''
      SELECT COUNT(*) FROM handles
      WHERE raw_identifier IS NULL OR TRIM(raw_identifier) = ''
    ''');
    await expectZeroOrThrow(
      missingIdentifiers,
      'HANDLES_MISSING_IDENTIFIER',
      'handles: raw_identifier contains NULL or empty values',
    );

    final invalidServices = await _singleInt(importDb, '''
      SELECT COUNT(*) FROM handles
      WHERE service NOT IN ('iMessage','iMessageLite','SMS','RCS','Unknown')
         OR service IS NULL
    ''');
    await expectZeroOrThrow(
      invalidServices,
      'HANDLES_INVALID_SERVICE',
      'handles: unexpected service value detected in import database',
    );
  }

  @override
  Future<void> copy(MigrationContext ctx) async {
    if (ctx.dryRun) {
      ctx.log('[handles] dry run – skipping copy');
      return;
    }

    ctx.handleIdCanonicalMap.clear();
    ctx.canonicalHandleInfo.clear();

    final importDb = await ctx.importDb.database;
    final sourceRows = await importDb.query('handles');

    final groups = <String, _HandleGroup>{};
    for (final row in sourceRows) {
      final parsed = _parseImportHandle(row);
      if (parsed == null) {
        continue;
      }
      final key = parsed.compoundIdentifier;
      final group = groups.putIfAbsent(
        key,
        () => _HandleGroup(
          service: parsed.service,
          normalized: parsed.canonicalNormalized,
          compoundIdentifier: parsed.compoundIdentifier,
        ),
      );
      group.rows.add(parsed);
    }

    final canonicalHandles = <_CanonicalHandle>[];
    final aliasRows = <_AliasRow>[];

    for (final group in groups.values) {
      final canonical = group.toCanonical();
      canonicalHandles.add(canonical);

      for (final parsed in group.rows) {
        ctx.handleIdCanonicalMap[parsed.id] = canonical.id;
        aliasRows.add(
          _AliasRow(
            sourceId: parsed.id,
            canonicalId: canonical.id,
            rawIdentifier: parsed.rawIdentifier,
            compoundIdentifier: parsed.compoundIdentifier,
            normalizedIdentifier: parsed.canonicalNormalized,
            service: parsed.service,
            aliasKind: _classifyAlias(parsed, canonical),
          ),
        );
      }
      ctx.canonicalHandleInfo[canonical.id] = CanonicalHandleInfo(
        compound: canonical.compoundIdentifier,
        display: canonical.displayName,
      );
    }

    canonicalHandles.sort((a, b) => a.id.compareTo(b.id));

    await _clearCanonicalMap(ctx);

    await ctx.workingDb.transaction(() async {
      await ctx.workingDb.customStatement('PRAGMA foreign_keys = ON');

      await ctx.workingDb.batch((batch) {
        for (final handle in canonicalHandles) {
          batch.insert(
            ctx.workingDb.workingHandles,
            WorkingHandlesCompanion.insert(
              id: Value(handle.id),
              rawIdentifier: handle.rawIdentifier,
              displayName: handle.displayName,
              compoundIdentifier: handle.compoundIdentifier,
              service: Value(handle.service),
              isIgnored: Value(handle.isIgnored),
              isVisible: Value(!handle.isIgnored),
              isBlacklisted: const Value(false),
              country: Value(handle.country),
              lastSeenUtc: Value(handle.lastSeenUtc),
              batchId: Value(handle.batchId),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });

      if (aliasRows.isNotEmpty) {
        await ctx.workingDb.batch((batch) {
          for (final alias in aliasRows) {
            batch.insert(
              ctx.workingDb.handleCanonicalMap,
              HandleCanonicalMapCompanion.insert(
                sourceHandleId: Value(alias.sourceId),
                canonicalHandleId: alias.canonicalId,
                rawIdentifier: alias.rawIdentifier,
                compoundIdentifier: alias.compoundIdentifier,
                normalizedIdentifier: alias.normalizedIdentifier,
                service: Value(alias.service),
                aliasKind: Value(alias.aliasKind),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        });
      }
    });

    for (final handle in canonicalHandles) {
      if (handle.aliasIds.length <= 1) {
        continue;
      }
      final aliases = handle.aliasIds.where((id) => id != handle.id).toList()
        ..sort();
      final preview = aliases.take(5).join(', ');
      final suffix = aliases.length > 5 ? '…' : '';
      ctx.log(
        '[handles] canonical ${handle.id} collapsed ${aliases.length} alias id(s): $preview$suffix',
      );
    }

    ctx.log(
      '[handles] projected ${canonicalHandles.length} canonical handle(s) from ${sourceRows.length} source row(s)',
    );
  }

  @override
  Future<void> postValidate(MigrationContext ctx) async {
    final src = await count(ctx.importDb, 'handles');
    final dst = await count(ctx.workingDb, 'handles');
    final canonical = ctx.handleIdCanonicalMap.values.toSet().length;
    final mapped = ctx.handleIdCanonicalMap.length;
    ctx.log('[handles] src=$src canonical=$canonical projected=$dst');

    await expectTrueOrThrow(
      ok: mapped == src,
      errorCode: 'HANDLES_MAP_INCOMPLETE',
      message:
          'handles: canonical map has $mapped entries but import has $src rows',
    );

    await expectTrueOrThrow(
      ok: dst == canonical,
      errorCode: 'HANDLES_ROW_MISMATCH',
      message:
          'handles: working has $dst rows but expected $canonical canonical rows',
    );
  }

  Future<int> _singleInt(Database db, String sql) async {
    final rows = await db.rawQuery(sql);
    if (rows.isEmpty) {
      return 0;
    }
    final value = rows.first.values.first;
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is BigInt) {
      return value.toInt();
    }
    return int.tryParse(value.toString()) ?? 0;
  }

  Future<void> _clearCanonicalMap(MigrationContext ctx) async {
    await ctx.workingDb.customStatement('DELETE FROM handle_canonical_map');
  }
}

class _AliasRow {
  const _AliasRow({
    required this.sourceId,
    required this.canonicalId,
    required this.rawIdentifier,
    required this.compoundIdentifier,
    required this.normalizedIdentifier,
    required this.service,
    required this.aliasKind,
  });

  final int sourceId;
  final int canonicalId;
  final String rawIdentifier;
  final String compoundIdentifier;
  final String normalizedIdentifier;
  final String service;
  final String aliasKind;
}

String _classifyAlias(_ParsedHandle alias, _CanonicalHandle canonical) {
  if (alias.id == canonical.id) {
    return 'canonical';
  }
  final aliasStripped = _stripKnownSchemes(alias.rawIdentifier);
  final canonicalStripped = _stripKnownSchemes(canonical.rawIdentifier);
  if (aliasStripped == canonicalStripped &&
      alias.rawIdentifier != canonical.rawIdentifier) {
    return 'scheme_variant';
  }
  if (alias.compoundIdentifier == canonical.compoundIdentifier) {
    return 'format_variant';
  }
  if (alias.canonicalNormalized == canonical.normalizedIdentifier) {
    return 'normalized_variant';
  }
  return 'variant';
}

class _HandleGroup {
  _HandleGroup({
    required this.service,
    required this.normalized,
    required this.compoundIdentifier,
  });

  final String service;
  final String normalized;
  final String compoundIdentifier;
  final List<_ParsedHandle> rows = <_ParsedHandle>[];

  _CanonicalHandle toCanonical() {
    if (rows.isEmpty) {
      throw StateError('Cannot canonicalize an empty handle group.');
    }

    rows.sort((a, b) => _compareHandlePreference(a, b, normalized));
    final canonicalRow = rows.first;
    final aliasIds = rows.map((row) => row.id).toList()..sort();
    final isIgnored = rows.any((row) => row.isIgnored);
    final country = rows
        .firstWhere(
          (row) => row.country != null && row.country!.isNotEmpty,
          orElse: () => canonicalRow,
        )
        .country;
    final lastSeen = _pickLatestTimestamp(rows.map((row) => row.lastSeenUtc));
    final batchId = _pickMaxInt(rows.map((row) => row.batchId));
    final display = _deriveDisplay(rows, normalized);
    final canonicalRaw = canonicalRow.rawIdentifier.trim();

    return _CanonicalHandle(
      id: canonicalRow.id,
      rawIdentifier: canonicalRaw,
      displayName: display,
      normalizedIdentifier: normalized,
      compoundIdentifier: compoundIdentifier,
      service: service,
      isIgnored: isIgnored,
      country: country,
      lastSeenUtc: lastSeen,
      batchId: batchId,
      aliasIds: aliasIds,
    );
  }
}

class _ParsedHandle {
  const _ParsedHandle({
    required this.id,
    required this.service,
    required this.rawIdentifier,
    required this.canonicalNormalized,
    required this.compoundIdentifier,
    required this.isIgnored,
    this.country,
    this.lastSeenUtc,
    this.batchId,
  });

  final int id;
  final String service;
  final String rawIdentifier;
  final String canonicalNormalized;
  final String compoundIdentifier;
  final bool isIgnored;
  final String? country;
  final String? lastSeenUtc;
  final int? batchId;
}

class _CanonicalHandle {
  const _CanonicalHandle({
    required this.id,
    required this.rawIdentifier,
    required this.displayName,
    required this.normalizedIdentifier,
    required this.compoundIdentifier,
    required this.service,
    required this.isIgnored,
    required this.country,
    required this.lastSeenUtc,
    required this.batchId,
    required this.aliasIds,
  });

  final int id;
  final String rawIdentifier;
  final String displayName;
  final String normalizedIdentifier;
  final String compoundIdentifier;
  final String service;
  final bool isIgnored;
  final String? country;
  final String? lastSeenUtc;
  final int? batchId;
  final List<int> aliasIds;
}

_ParsedHandle? _parseImportHandle(Map<String, Object?> row) {
  final idValue = row['id'];
  final raw = row['raw_identifier'] as String?;
  if (idValue == null || raw == null) {
    return null;
  }

  final id = _coerceToInt(idValue);
  final resolvedService = sanitizeHandleService(row['service'] as String?);
  final normalizedFromRow = row['normalized_identifier'] as String?;
  final canonicalNormalized = _resolveNormalized(raw, normalizedFromRow);
  final compoundFromRow = (row['compound_identifier'] as String?)?.trim();
  final compoundIdentifier =
      (compoundFromRow != null && compoundFromRow.isNotEmpty)
      ? compoundFromRow
      : buildCompoundIdentifier(
          normalizedIdentifier: canonicalNormalized,
          rawIdentifier: raw,
          service: resolvedService,
        );
  final isIgnored = (row['is_ignored'] as int?) == 1;
  final countryRaw = (row['country'] as String?)?.trim();
  final lastSeenRaw = (row['last_seen_utc'] as String?)?.trim();
  final batchId = _coerceToNullableInt(row['batch_id']);

  return _ParsedHandle(
    id: id,
    service: resolvedService,
    rawIdentifier: raw.trim(),
    canonicalNormalized: canonicalNormalized,
    compoundIdentifier: compoundIdentifier,
    isIgnored: isIgnored,
    country: countryRaw?.isEmpty == true ? null : countryRaw,
    lastSeenUtc: lastSeenRaw?.isEmpty == true ? null : lastSeenRaw,
    batchId: batchId,
  );
}

String _resolveNormalized(String raw, String? normalized) {
  final candidateFromRow = _normalizeIdentifier(normalized);
  final computed = _normalizeIdentifier(raw);
  final fallback = _fallbackNormalized(raw);
  return candidateFromRow ?? computed ?? fallback;
}

String? _normalizeIdentifier(String? value) {
  if (value == null) {
    return null;
  }
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  final withoutScheme = _stripKnownSchemes(trimmed);
  final lowered = withoutScheme.toLowerCase();
  if (lowered.contains('@')) {
    return lowered;
  }

  final digits = withoutScheme.replaceAll(RegExp(r'[^0-9+]'), '');
  if (digits.isEmpty) {
    return null;
  }

  var normalized = digits.replaceAll('+', '');
  if (normalized.isEmpty) {
    return null;
  }
  if (normalized.length == 11 && normalized.startsWith('1')) {
    normalized = normalized.substring(1);
  }
  return normalized;
}

String _fallbackNormalized(String raw) {
  final stripped = _stripKnownSchemes(raw).trim();
  if (stripped.isEmpty) {
    return raw.trim().toLowerCase();
  }
  return stripped.toLowerCase();
}

int _compareHandlePreference(
  _ParsedHandle a,
  _ParsedHandle b,
  String normalized,
) {
  final scoreA = _handlePreferenceScore(a, normalized);
  final scoreB = _handlePreferenceScore(b, normalized);
  if (scoreA != scoreB) {
    return scoreB.compareTo(scoreA);
  }
  return a.id.compareTo(b.id);
}

int _handlePreferenceScore(_ParsedHandle handle, String normalized) {
  final raw = handle.rawIdentifier.trim();
  final stripped = _stripKnownSchemes(raw);
  var score = 0;

  if (normalized.contains('@')) {
    if (stripped.toLowerCase() == normalized) {
      score += 200;
    }
  } else {
    final normalizedDigits = _digitsOnly(normalized);
    final rawDigits = _digitsOnly(stripped);
    if (normalizedDigits != null && rawDigits == normalizedDigits) {
      score += 120;
    }
    if (stripped.startsWith('+')) {
      score += 40;
    }
  }

  if (!raw.contains(':')) {
    score += 20;
  }

  if (raw.trim().startsWith('+')) {
    score += 10;
  }

  return score;
}

String _deriveDisplay(List<_ParsedHandle> rows, String normalized) {
  final cleaned = rows
      .map((row) => _stripKnownSchemes(row.rawIdentifier.trim()))
      .where((value) => value.isNotEmpty)
      .toList();

  // For email addresses, use normalized form
  if (normalized.contains('@')) {
    return normalized;
  }

  // For phone numbers, format into human-friendly display
  final digitsExpression = RegExp(r'^[0-9]+$');
  if (digitsExpression.hasMatch(normalized)) {
    final plusCandidate = cleaned.firstWhere(
      (value) => value.startsWith('+'),
      orElse: () => '',
    );
    
    // Format the phone number for display
    final rawToFormat = plusCandidate.isNotEmpty
        ? plusCandidate
        : (normalized.length >= 10 ? '+$normalized' : normalized);
    
    return formatPhoneNumberForDisplay(rawToFormat);
  }

  // Fallback to first cleaned value
  if (cleaned.isNotEmpty) {
    return formatPhoneNumberForDisplay(cleaned.first);
  }

  return normalized;
}

String _stripKnownSchemes(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return trimmed;
  }

  final lower = trimmed.toLowerCase();
  if (lower.startsWith('tel:')) {
    return trimmed.substring(trimmed.indexOf(':') + 1).trim();
  }
  if (lower.startsWith('mailto:')) {
    return trimmed.substring(trimmed.indexOf(':') + 1).trim();
  }
  return trimmed;
}

String? _pickLatestTimestamp(Iterable<String?> values) {
  String? latest;
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      continue;
    }
    if (latest == null || trimmed.compareTo(latest) > 0) {
      latest = trimmed;
    }
  }
  return latest;
}

int? _pickMaxInt(Iterable<int?> values) {
  int? result;
  for (final value in values) {
    if (value == null) {
      continue;
    }
    if (result == null || value > result) {
      result = value;
    }
  }
  return result;
}

String? _digitsOnly(String value) {
  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) {
    return null;
  }
  return digits;
}

int _coerceToInt(Object value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is BigInt) {
    return value.toInt();
  }
  return int.parse(value.toString());
}

int? _coerceToNullableInt(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is BigInt) {
    return value.toInt();
  }
  return int.tryParse(value.toString());
}
