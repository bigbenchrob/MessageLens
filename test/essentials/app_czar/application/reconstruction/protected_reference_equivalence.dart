import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/essentials/db/app_database_schema_versions.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/contacts/application/read_models/contact_summary_identity.dart';
import 'package:remember_this_text/features/handles/application/read_models/handle_identity.dart';
import 'package:remember_this_text/features/handles/domain/utilities/handle_normalizer.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/message_evidence_identity.dart';
import 'package:sqflite/sqflite.dart';

enum ProtectedReferenceTruth { trueValue, falseValue, unknown }

enum ProtectedReferenceDimension {
  overlayIntentMaterial,
  targetIdentity,
  compatibilityResolution,
  sourceOccurrenceProvenance,
  attachmentPayloadCoverage,
}

enum ProtectedReferenceUnknownReason {
  unsupportedSchema,
  unreadableSource,
  unqualifiedLookup,
  ambiguousFallback,
  missingIdentityField,
  rowLimit,
  byteLimit,
}

final class ProtectedReferenceLimits {
  const ProtectedReferenceLimits({
    this.maxRowsPerTable = 128,
    this.maxMaterialBytes = 256 * 1024,
    this.maxDiagnostics = 32,
  });

  final int maxRowsPerTable;
  final int maxMaterialBytes;
  final int maxDiagnostics;
}

final class ProtectedReferenceWorld {
  const ProtectedReferenceWorld({
    required this.overlay,
    required this.graph,
    required this.ledger,
    this.productionLookupQualified = true,
  });

  final OverlayDatabase overlay;
  final ConversationGraphDatabase graph;
  final Database ledger;
  final bool productionLookupQualified;
}

final class ProtectedReferenceDimensionEvidence {
  const ProtectedReferenceDimensionEvidence({
    required this.truth,
    this.unknownReason,
    this.assessed = true,
  });

  final ProtectedReferenceTruth truth;
  final ProtectedReferenceUnknownReason? unknownReason;
  final bool assessed;
}

final class ProtectedReferenceObservation {
  const ProtectedReferenceObservation({
    required this.truth,
    required this.materialByReference,
    required this.targetsByReference,
    required this.diagnostics,
    required this.unknownReason,
  });

  final ProtectedReferenceTruth truth;
  final Map<String, String> materialByReference;
  final Map<String, ProtectedReferenceTargetEvidence> targetsByReference;
  final List<String> diagnostics;
  final ProtectedReferenceUnknownReason? unknownReason;
}

final class ProtectedReferenceTargetEvidence {
  const ProtectedReferenceTargetEvidence({
    required this.truth,
    required this.targetIdentity,
    required this.compatibilityIdentity,
    required this.provenanceIdentity,
    required this.unknownReason,
  });

  factory ProtectedReferenceTargetEvidence.known({
    required String targetIdentity,
    String? compatibilityIdentity,
    String? provenanceIdentity,
  }) {
    return ProtectedReferenceTargetEvidence(
      truth: ProtectedReferenceTruth.trueValue,
      targetIdentity: targetIdentity,
      compatibilityIdentity: compatibilityIdentity,
      provenanceIdentity: provenanceIdentity,
      unknownReason: null,
    );
  }

  factory ProtectedReferenceTargetEvidence.contradiction() {
    return const ProtectedReferenceTargetEvidence(
      truth: ProtectedReferenceTruth.falseValue,
      targetIdentity: null,
      compatibilityIdentity: null,
      provenanceIdentity: null,
      unknownReason: null,
    );
  }

  factory ProtectedReferenceTargetEvidence.unknown(
    ProtectedReferenceUnknownReason reason,
  ) {
    return ProtectedReferenceTargetEvidence(
      truth: ProtectedReferenceTruth.unknown,
      targetIdentity: null,
      compatibilityIdentity: null,
      provenanceIdentity: null,
      unknownReason: reason,
    );
  }

  final ProtectedReferenceTruth truth;
  final String? targetIdentity;
  final String? compatibilityIdentity;
  final String? provenanceIdentity;
  final ProtectedReferenceUnknownReason? unknownReason;
}

final class ProtectedReferenceComparison {
  const ProtectedReferenceComparison({
    required this.truth,
    required this.dimensions,
    required this.diagnostics,
    required this.diagnosticsTruncated,
  });

  final ProtectedReferenceTruth truth;
  final Map<ProtectedReferenceDimension, ProtectedReferenceDimensionEvidence>
  dimensions;
  final List<String> diagnostics;
  final bool diagnosticsTruncated;
}

/// Test-only bounded reader for protected overlay references.
///
/// Every database is supplied by the caller. This helper never opens an
/// application root, live source, archive, or provider-owned database, and it
/// never writes to any supplied database.
final class ProtectedReferenceEquivalenceReader {
  const ProtectedReferenceEquivalenceReader({
    this.limits = const ProtectedReferenceLimits(),
  });

  final ProtectedReferenceLimits limits;

  Future<ProtectedReferenceObservation> observe(
    ProtectedReferenceWorld world,
  ) async {
    if (!world.productionLookupQualified) {
      return const ProtectedReferenceObservation(
        truth: ProtectedReferenceTruth.unknown,
        materialByReference: <String, String>{},
        targetsByReference: <String, ProtectedReferenceTargetEvidence>{},
        diagnostics: <String>['lookup.unqualified'],
        unknownReason: ProtectedReferenceUnknownReason.unqualifiedLookup,
      );
    }

    try {
      final overlayVersion = await _driftVersion(world.overlay);
      final graphVersion = await _graphVersion(world.graph);
      final ledgerVersion = await world.ledger.getVersion();
      if (overlayVersion != overlaySchemaVersion ||
          graphVersion != conversationGraphSchemaVersion ||
          ledgerVersion != sourceScopedImportSchemaVersion) {
        return const ProtectedReferenceObservation(
          truth: ProtectedReferenceTruth.unknown,
          materialByReference: <String, String>{},
          targetsByReference: <String, ProtectedReferenceTargetEvidence>{},
          diagnostics: <String>['schema.unsupported'],
          unknownReason: ProtectedReferenceUnknownReason.unsupportedSchema,
        );
      }

      final rows = await _readOverlayRows(world.overlay);
      final graph = await _readGraph(world.graph, world.ledger);
      final material = <String, String>{};
      final targets = <String, ProtectedReferenceTargetEvidence>{};
      var materialBytes = 0;

      for (final row in rows) {
        final encoded = _canonicalJson(row.data);
        materialBytes += utf8.encode(encoded).length;
        if (materialBytes > limits.maxMaterialBytes) {
          throw const _BoundedReadFailure(
            ProtectedReferenceUnknownReason.byteLimit,
            'limit.bytes',
          );
        }
        material[row.storageKey] = encoded;
        targets[row.storageKey] = _resolve(row, graph);
      }

      final truth = _aggregateTruth(targets.values.map((value) => value.truth));
      final firstUnknown = targets.values
          .where((value) => value.truth == ProtectedReferenceTruth.unknown)
          .map((value) => value.unknownReason)
          .whereType<ProtectedReferenceUnknownReason>()
          .firstOrNull;
      final diagnostics = <String>{};
      for (final entry in targets.entries) {
        if (entry.value.truth == ProtectedReferenceTruth.falseValue) {
          diagnostics.add('${_tableFromStorageKey(entry.key)}.unresolved');
        } else if (entry.value.truth == ProtectedReferenceTruth.unknown) {
          diagnostics.add('${_tableFromStorageKey(entry.key)}.ambiguous');
        }
      }
      final sortedDiagnostics = diagnostics.toList()..sort();
      return ProtectedReferenceObservation(
        truth: truth,
        materialByReference: Map.unmodifiable(material),
        targetsByReference: Map.unmodifiable(targets),
        diagnostics: List.unmodifiable(
          sortedDiagnostics.take(limits.maxDiagnostics),
        ),
        unknownReason: firstUnknown,
      );
    } on _BoundedReadFailure catch (error) {
      return ProtectedReferenceObservation(
        truth: ProtectedReferenceTruth.unknown,
        materialByReference: const <String, String>{},
        targetsByReference: const <String, ProtectedReferenceTargetEvidence>{},
        diagnostics: <String>[error.diagnostic],
        unknownReason: error.reason,
      );
    } on Object {
      return const ProtectedReferenceObservation(
        truth: ProtectedReferenceTruth.unknown,
        materialByReference: <String, String>{},
        targetsByReference: <String, ProtectedReferenceTargetEvidence>{},
        diagnostics: <String>['source.unreadable'],
        unknownReason: ProtectedReferenceUnknownReason.unreadableSource,
      );
    }
  }

  Future<ProtectedReferenceComparison> compare({
    required ProtectedReferenceWorld expected,
    required ProtectedReferenceWorld observed,
  }) async {
    final expectedObservation = await observe(expected);
    final observedObservation = await observe(observed);
    final diagnostics = <String>{};
    final unavailableReason =
        _unavailableObservationReason(expectedObservation) ??
        _unavailableObservationReason(observedObservation);
    final comparisonAvailable = unavailableReason == null;

    final materialTruth = comparisonAvailable
        ? _compareStrings(
            expectedObservation.materialByReference,
            observedObservation.materialByReference,
            diagnosticPrefix: 'material',
            diagnostics: diagnostics,
          )
        : ProtectedReferenceTruth.unknown;
    final targetTruth = comparisonAvailable
        ? _compareTargets(
            expectedObservation.targetsByReference,
            observedObservation.targetsByReference,
            selector: (value) => value.targetIdentity,
            diagnosticPrefix: 'target',
            diagnostics: diagnostics,
          )
        : ProtectedReferenceTruth.unknown;
    final compatibilityTruth = comparisonAvailable
        ? _compareTargets(
            _onlyCompatibility(expectedObservation.targetsByReference),
            _onlyCompatibility(observedObservation.targetsByReference),
            selector: (value) => value.compatibilityIdentity,
            diagnosticPrefix: 'compatibility',
            diagnostics: diagnostics,
          )
        : ProtectedReferenceTruth.unknown;
    final provenanceTruth = comparisonAvailable
        ? _compareTargets(
            _onlyCompatibility(expectedObservation.targetsByReference),
            _onlyCompatibility(observedObservation.targetsByReference),
            selector: (value) => value.provenanceIdentity,
            diagnosticPrefix: 'provenance',
            diagnostics: diagnostics,
          )
        : ProtectedReferenceTruth.unknown;

    final dimensions =
        <ProtectedReferenceDimension, ProtectedReferenceDimensionEvidence>{
          ProtectedReferenceDimension.overlayIntentMaterial:
              ProtectedReferenceDimensionEvidence(
                truth: materialTruth,
                unknownReason: unavailableReason,
                assessed: comparisonAvailable,
              ),
          ProtectedReferenceDimension.targetIdentity:
              ProtectedReferenceDimensionEvidence(
                truth: targetTruth,
                unknownReason: unavailableReason,
                assessed: comparisonAvailable,
              ),
          ProtectedReferenceDimension.compatibilityResolution:
              ProtectedReferenceDimensionEvidence(
                truth: compatibilityTruth,
                unknownReason: unavailableReason,
                assessed: comparisonAvailable,
              ),
          ProtectedReferenceDimension.sourceOccurrenceProvenance:
              ProtectedReferenceDimensionEvidence(
                truth: provenanceTruth,
                unknownReason: unavailableReason,
                assessed: comparisonAvailable,
              ),
          ProtectedReferenceDimension.attachmentPayloadCoverage:
              const ProtectedReferenceDimensionEvidence(
                truth: ProtectedReferenceTruth.unknown,
                unknownReason:
                    ProtectedReferenceUnknownReason.missingIdentityField,
                assessed: false,
              ),
        };

    final comparisonTruth = _aggregateTruth(<ProtectedReferenceTruth>[
      materialTruth,
      targetTruth,
      compatibilityTruth,
      provenanceTruth,
    ]);
    diagnostics.addAll(expectedObservation.diagnostics);
    diagnostics.addAll(observedObservation.diagnostics);
    final allDiagnostics = diagnostics.toList()..sort();
    return ProtectedReferenceComparison(
      truth: comparisonTruth,
      dimensions: Map.unmodifiable(dimensions),
      diagnostics: List.unmodifiable(
        allDiagnostics.take(limits.maxDiagnostics),
      ),
      diagnosticsTruncated: allDiagnostics.length > limits.maxDiagnostics,
    );
  }

  Future<List<_OverlayReferenceRow>> _readOverlayRows(
    OverlayDatabase database,
  ) async {
    final result = <_OverlayReferenceRow>[];
    for (final spec in _overlaySpecs) {
      final rows = await database
          .customSelect(
            'SELECT * FROM ${spec.table} ORDER BY ${spec.orderBy} '
            'LIMIT ${limits.maxRowsPerTable + 1}',
          )
          .get();
      if (rows.length > limits.maxRowsPerTable) {
        throw const _BoundedReadFailure(
          ProtectedReferenceUnknownReason.rowLimit,
          'limit.rows',
        );
      }
      for (final driftRow in rows) {
        final data = Map<String, Object?>.from(driftRow.data);
        final identity = <String, Object?>{};
        var missingIdentity = false;
        for (final column in spec.identityColumns) {
          final value = data[column];
          identity[column] = value;
          missingIdentity = missingIdentity || value == null;
        }
        final suffix = missingIdentity
            ? 'missing-${result.length}'
            : _canonicalJson(identity);
        result.add(
          _OverlayReferenceRow(
            spec: spec,
            data: data,
            storageKey: '${spec.table}|$suffix',
            identityMissing: missingIdentity,
          ),
        );
      }
    }
    result.sort(
      (first, second) => first.storageKey.compareTo(second.storageKey),
    );
    return result;
  }

  Future<_GraphInventory> _readGraph(
    ConversationGraphDatabase graph,
    Database ledger,
  ) async {
    Future<List<Map<String, Object?>>> graphRows(String sql) async {
      final rows = await graph.selectRows(
        '$sql LIMIT ${limits.maxRowsPerTable + 1}',
      );
      if (rows.length > limits.maxRowsPerTable) {
        throw const _BoundedReadFailure(
          ProtectedReferenceUnknownReason.rowLimit,
          'limit.rows',
        );
      }
      return rows;
    }

    final sourceRows = await ledger.rawQuery(
      'SELECT source_id, source_key, source_kind FROM source_registry '
      'ORDER BY source_id LIMIT ?',
      <Object?>[limits.maxRowsPerTable + 1],
    );
    if (sourceRows.length > limits.maxRowsPerTable) {
      throw const _BoundedReadFailure(
        ProtectedReferenceUnknownReason.rowLimit,
        'limit.rows',
      );
    }

    return _GraphInventory(
      sources: {
        for (final row in sourceRows)
          row['source_id']! as int: _SourceIdentity(
            key: row['source_key']! as String,
            kind: row['source_kind']! as String,
          ),
      },
      messages: {
        for (final row in await graphRows('SELECT ss_id, guid FROM messages'))
          row['ss_id']! as int: row['guid'] as String?,
      },
      chats: {
        for (final row in await graphRows('SELECT ss_id FROM chats'))
          row['ss_id']! as int,
      },
      contacts: {
        for (final row in await graphRows('SELECT contact_id FROM contacts'))
          row['contact_id']! as int,
      },
      handles: {
        for (final row in await graphRows('SELECT ss_id, id FROM handles'))
          row['ss_id']! as int: row['id']! as String,
      },
      canonicalHandles: {
        for (final row in await graphRows(
          'SELECT canonical_handle_ss_id, normalized_identifier '
          'FROM canonical_handles',
        ))
          row['canonical_handle_ss_id']! as int:
              row['normalized_identifier']! as String,
      },
      handleAliases: {
        for (final row in await graphRows(
          'SELECT handle_ss_id, canonical_handle_ss_id, normalized_identifier '
          'FROM handle_aliases',
        ))
          row['handle_ss_id']! as int: _HandleAlias(
            canonicalId: row['canonical_handle_ss_id']! as int,
            normalized: row['normalized_identifier']! as String,
          ),
      },
      attachments: {
        for (final row in await graphRows('SELECT ss_id FROM attachments'))
          row['ss_id']! as int,
      },
      messageToAttachment: {
        for (final row in await graphRows(
          'SELECT message_ss_id, attachment_ss_id FROM message_to_attachment',
        ))
          '${row['message_ss_id']}|${row['attachment_ss_id']}',
      },
    );
  }

  ProtectedReferenceTargetEvidence _resolve(
    _OverlayReferenceRow row,
    _GraphInventory graph,
  ) {
    if (row.identityMissing) {
      return ProtectedReferenceTargetEvidence.unknown(
        ProtectedReferenceUnknownReason.missingIdentityField,
      );
    }
    final data = row.data;
    switch (row.spec.kind) {
      case _ReferenceKind.contact:
        return _resolveContact(data['participant_id']! as int, graph);
      case _ReferenceKind.chat:
        return _resolveChat(data['chat_id']! as int, graph);
      case _ReferenceKind.message:
        final id = data[row.spec.identityColumns.first]! as int;
        return _resolveMessage(id, graph);
      case _ReferenceKind.messageGuid:
        return _resolveMessageGuid(data['message_guid']! as String, graph);
      case _ReferenceKind.messageGuidWithLocalTag:
        final message = _resolveMessageGuid(
          data['message_guid']! as String,
          graph,
        );
        return _appendLocalIdentity(message, 'tag:${data['tag_normalized']}');
      case _ReferenceKind.conversationTagAssignment:
        final conversation = _resolveChat(
          data['conversation_id']! as int,
          graph,
        );
        return _appendLocalIdentity(conversation, 'tag-id:${data['tag_id']}');
      case _ReferenceKind.handleBridge:
        final handle = _resolveHandle(data['handle_id']! as int, graph);
        if (handle.truth != ProtectedReferenceTruth.trueValue) {
          return handle;
        }
        final participantId = data['participant_id'] as int?;
        final virtualId = data['virtual_participant_id'] as int?;
        if (participantId != null && virtualId != null) {
          return ProtectedReferenceTargetEvidence.unknown(
            ProtectedReferenceUnknownReason.ambiguousFallback,
          );
        }
        if (participantId == null && virtualId == null) {
          return _appendLocalIdentity(handle, 'reviewed-unlinked');
        }
        if (participantId != null) {
          final participant = _resolveContact(participantId, graph);
          return _combine(handle, participant);
        }
        if (virtualId! < 1000000000) {
          return ProtectedReferenceTargetEvidence.contradiction();
        }
        return _appendLocalIdentity(handle, 'virtual:$virtualId');
      case _ReferenceKind.handle:
        return _resolveHandle(data['handle_id']! as int, graph);
      case _ReferenceKind.normalizedHandle:
        return _resolveNormalizedHandle(
          data['normalized_handle']! as String,
          graph,
        );
      case _ReferenceKind.archivedAttachment:
        return _resolveArchivedAttachment(data, graph);
      case _ReferenceKind.virtualParticipant:
        final id = data['id']! as int;
        return id >= 1000000000
            ? ProtectedReferenceTargetEvidence.known(
                targetIdentity: 'overlay:virtual:$id',
              )
            : ProtectedReferenceTargetEvidence.contradiction();
      case _ReferenceKind.local:
        return ProtectedReferenceTargetEvidence.known(
          targetIdentity: 'overlay:${row.spec.table}:${row.storageKey}',
        );
    }
  }

  ProtectedReferenceTargetEvidence _resolveContact(
    int value,
    _GraphInventory graph,
  ) {
    final candidates = contactIdentityKeyVariants(
      value,
    ).where(graph.contacts.contains).toSet();
    return _resolveDirectSet('contact', candidates, graph);
  }

  ProtectedReferenceTargetEvidence _resolveChat(
    int value,
    _GraphInventory graph,
  ) {
    final canonical = canonicalConversationEvidenceId(value);
    final candidates = <int>{
      value,
      canonical,
    }.where(graph.chats.contains).toSet();
    return _resolveDirectSet('chat', candidates, graph);
  }

  ProtectedReferenceTargetEvidence _resolveMessage(
    int value,
    _GraphInventory graph,
  ) {
    final canonical = canonicalMessageEvidenceId(value);
    final candidates = <int>{
      value,
      canonical,
    }.where(graph.messages.containsKey).toSet();
    return _resolveDirectSet('message', candidates, graph);
  }

  ProtectedReferenceTargetEvidence _resolveMessageGuid(
    String guid,
    _GraphInventory graph,
  ) {
    if (guid.isEmpty) {
      return ProtectedReferenceTargetEvidence.unknown(
        ProtectedReferenceUnknownReason.missingIdentityField,
      );
    }
    final candidates = graph.messages.entries
        .where((entry) => entry.value == guid)
        .map((entry) => entry.key)
        .toSet();
    if (candidates.length > 1) {
      return ProtectedReferenceTargetEvidence.unknown(
        ProtectedReferenceUnknownReason.ambiguousFallback,
      );
    }
    return _resolveDirectSet('message', candidates, graph);
  }

  ProtectedReferenceTargetEvidence _resolveHandle(
    int value,
    _GraphInventory graph,
  ) {
    final variants = handleIdentityKeyVariants(value);
    final rawCandidates = variants.where(graph.handles.containsKey).toSet();
    final representatives = <int>{};
    for (final raw in rawCandidates) {
      representatives.add(graph.handleAliases[raw]?.canonicalId ?? raw);
    }
    for (final variant in variants) {
      if (graph.canonicalHandles.containsKey(variant)) {
        representatives.add(variant);
      }
    }
    if (representatives.length > 1) {
      return ProtectedReferenceTargetEvidence.unknown(
        ProtectedReferenceUnknownReason.ambiguousFallback,
      );
    }
    return _resolveDirectSet('canonical-handle', representatives, graph);
  }

  ProtectedReferenceTargetEvidence _resolveNormalizedHandle(
    String value,
    _GraphInventory graph,
  ) {
    final normalized = normalizeHandleIdentifier(value);
    if (normalized.isEmpty) {
      return ProtectedReferenceTargetEvidence.unknown(
        ProtectedReferenceUnknownReason.missingIdentityField,
      );
    }
    final candidates = <int>{};
    for (final entry in graph.canonicalHandles.entries) {
      if (normalizeHandleIdentifier(entry.value) == normalized) {
        candidates.add(entry.key);
      }
    }
    for (final alias in graph.handleAliases.values) {
      if (normalizeHandleIdentifier(alias.normalized) == normalized) {
        candidates.add(alias.canonicalId);
      }
    }
    if (candidates.length > 1) {
      return ProtectedReferenceTargetEvidence.unknown(
        ProtectedReferenceUnknownReason.ambiguousFallback,
      );
    }
    return _resolveDirectSet('canonical-handle', candidates, graph);
  }

  ProtectedReferenceTargetEvidence _resolveArchivedAttachment(
    Map<String, Object?> data,
    _GraphInventory graph,
  ) {
    final guid = data['message_guid']! as String;
    final attachmentRowId = data['import_attachment_id']! as int;
    if (guid.isEmpty) {
      return ProtectedReferenceTargetEvidence.unknown(
        ProtectedReferenceUnknownReason.missingIdentityField,
      );
    }
    final messages = graph.messages.entries
        .where((entry) => entry.value == guid)
        .map((entry) => entry.key)
        .toList(growable: false);
    if (messages.length > 1) {
      return ProtectedReferenceTargetEvidence.unknown(
        ProtectedReferenceUnknownReason.ambiguousFallback,
      );
    }
    if (messages.isEmpty) {
      return ProtectedReferenceTargetEvidence.contradiction();
    }
    final messageId = messages.single;
    final attachmentId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: attachmentRowId,
    );
    if (!ArchiveCompatibilityKey.supportsLiveGraphEndpoints(
          messageSsId: messageId,
          attachmentSsId: attachmentId,
        ) ||
        !graph.attachments.contains(attachmentId) ||
        !graph.messageToAttachment.contains('$messageId|$attachmentId')) {
      return ProtectedReferenceTargetEvidence.contradiction();
    }
    final messageIdentity = graph.sourceIdentity('message', messageId);
    final attachmentIdentity = graph.sourceIdentity('attachment', attachmentId);
    if (messageIdentity == null || attachmentIdentity == null) {
      return ProtectedReferenceTargetEvidence.contradiction();
    }
    final key = ArchiveCompatibilityKey.fromStoredTuple(
      messageGuid: guid,
      importAttachmentId: attachmentRowId,
    );
    return ProtectedReferenceTargetEvidence.known(
      targetIdentity: '$messageIdentity+$attachmentIdentity',
      compatibilityIdentity:
          'live:${key.archiveCompatibilityAttachmentId}:unique-guid',
      provenanceIdentity:
          '${graph.sourceIdentity('source', messageId)}>'
          '${graph.sourceIdentity('source', attachmentId)}',
    );
  }

  ProtectedReferenceTargetEvidence _resolveDirectSet(
    String kind,
    Set<int> candidates,
    _GraphInventory graph,
  ) {
    if (candidates.isEmpty) {
      return ProtectedReferenceTargetEvidence.contradiction();
    }
    if (candidates.length > 1) {
      return ProtectedReferenceTargetEvidence.unknown(
        ProtectedReferenceUnknownReason.ambiguousFallback,
      );
    }
    final identity = graph.sourceIdentity(kind, candidates.single);
    if (identity == null) {
      return ProtectedReferenceTargetEvidence.contradiction();
    }
    return ProtectedReferenceTargetEvidence.known(targetIdentity: identity);
  }

  static ProtectedReferenceTargetEvidence _appendLocalIdentity(
    ProtectedReferenceTargetEvidence base,
    String localIdentity,
  ) {
    if (base.truth != ProtectedReferenceTruth.trueValue) {
      return base;
    }
    return ProtectedReferenceTargetEvidence.known(
      targetIdentity: '${base.targetIdentity}+$localIdentity',
      compatibilityIdentity: base.compatibilityIdentity,
      provenanceIdentity: base.provenanceIdentity,
    );
  }

  static ProtectedReferenceTargetEvidence _combine(
    ProtectedReferenceTargetEvidence first,
    ProtectedReferenceTargetEvidence second,
  ) {
    if (first.truth == ProtectedReferenceTruth.falseValue ||
        second.truth == ProtectedReferenceTruth.falseValue) {
      return ProtectedReferenceTargetEvidence.contradiction();
    }
    if (first.truth == ProtectedReferenceTruth.unknown ||
        second.truth == ProtectedReferenceTruth.unknown) {
      return ProtectedReferenceTargetEvidence.unknown(
        first.unknownReason ??
            second.unknownReason ??
            ProtectedReferenceUnknownReason.ambiguousFallback,
      );
    }
    return ProtectedReferenceTargetEvidence.known(
      targetIdentity: '${first.targetIdentity}+${second.targetIdentity}',
    );
  }

  static Future<int> _driftVersion(OverlayDatabase database) async {
    final row = await database.customSelect('PRAGMA user_version').getSingle();
    return row.data['user_version']! as int;
  }

  static Future<int> _graphVersion(ConversationGraphDatabase database) async {
    final rows = await database.selectRows('PRAGMA user_version');
    return rows.single['user_version']! as int;
  }
}

/// Runs a disposable qualification scope and always releases handles before
/// deleting its directory. Cleanup is attempted after success, failure, and
/// cancellation; cleanup failures are never silently swallowed.
Future<T> runProtectedReferenceDisposableScope<T>({
  required Future<T> Function() action,
  required Future<void> Function() closeHandles,
  required Future<void> Function() deleteDirectory,
}) async {
  Object? actionError;
  StackTrace? actionStack;
  try {
    return await action();
  } on Object catch (error, stack) {
    actionError = error;
    actionStack = stack;
  } finally {
    Object? cleanupError;
    StackTrace? cleanupStack;
    try {
      await closeHandles();
    } on Object catch (error, stack) {
      cleanupError = error;
      cleanupStack = stack;
    }
    try {
      await deleteDirectory();
    } on Object catch (error, stack) {
      cleanupError ??= error;
      cleanupStack ??= stack;
    }
    if (cleanupError != null) {
      Error.throwWithStackTrace(cleanupError, cleanupStack!);
    }
  }
  Error.throwWithStackTrace(actionError, actionStack);
}

enum _ReferenceKind {
  contact,
  chat,
  message,
  messageGuid,
  messageGuidWithLocalTag,
  conversationTagAssignment,
  handleBridge,
  handle,
  normalizedHandle,
  archivedAttachment,
  virtualParticipant,
  local,
}

final class _OverlayTableSpec {
  const _OverlayTableSpec({
    required this.table,
    required this.identityColumns,
    required this.kind,
  });

  final String table;
  final List<String> identityColumns;
  final _ReferenceKind kind;

  String get orderBy => identityColumns.join(', ');
}

const _overlaySpecs = <_OverlayTableSpec>[
  _OverlayTableSpec(
    table: 'participant_overrides',
    identityColumns: <String>['participant_id'],
    kind: _ReferenceKind.contact,
  ),
  _OverlayTableSpec(
    table: 'chat_overrides',
    identityColumns: <String>['chat_id'],
    kind: _ReferenceKind.chat,
  ),
  _OverlayTableSpec(
    table: 'message_annotations',
    identityColumns: <String>['message_id'],
    kind: _ReferenceKind.message,
  ),
  _OverlayTableSpec(
    table: 'message_intent_overlays',
    identityColumns: <String>['message_ss_id'],
    kind: _ReferenceKind.message,
  ),
  _OverlayTableSpec(
    table: 'message_intent_tags',
    identityColumns: <String>['message_ss_id', 'tag_normalized'],
    kind: _ReferenceKind.message,
  ),
  _OverlayTableSpec(
    table: 'message_user_flags',
    identityColumns: <String>['message_guid'],
    kind: _ReferenceKind.messageGuid,
  ),
  _OverlayTableSpec(
    table: 'message_user_tags',
    identityColumns: <String>['message_guid', 'tag_normalized'],
    kind: _ReferenceKind.messageGuidWithLocalTag,
  ),
  _OverlayTableSpec(
    table: 'conversation_tags',
    identityColumns: <String>['id'],
    kind: _ReferenceKind.local,
  ),
  _OverlayTableSpec(
    table: 'conversation_tag_assignments',
    identityColumns: <String>['conversation_id', 'tag_id'],
    kind: _ReferenceKind.conversationTagAssignment,
  ),
  _OverlayTableSpec(
    table: 'handle_to_participant_overrides',
    identityColumns: <String>['handle_id'],
    kind: _ReferenceKind.handleBridge,
  ),
  _OverlayTableSpec(
    table: 'virtual_participants',
    identityColumns: <String>['id'],
    kind: _ReferenceKind.virtualParticipant,
  ),
  _OverlayTableSpec(
    table: 'overlay_settings',
    identityColumns: <String>['key'],
    kind: _ReferenceKind.local,
  ),
  _OverlayTableSpec(
    table: 'favorite_contacts',
    identityColumns: <String>['participant_id'],
    kind: _ReferenceKind.contact,
  ),
  _OverlayTableSpec(
    table: 'handle_visibility_overrides',
    identityColumns: <String>['handle_id'],
    kind: _ReferenceKind.handle,
  ),
  _OverlayTableSpec(
    table: 'dismissed_handles',
    identityColumns: <String>['normalized_handle'],
    kind: _ReferenceKind.normalizedHandle,
  ),
  _OverlayTableSpec(
    table: 'archived_attachments',
    identityColumns: <String>['message_guid', 'import_attachment_id'],
    kind: _ReferenceKind.archivedAttachment,
  ),
];

final class _OverlayReferenceRow {
  const _OverlayReferenceRow({
    required this.spec,
    required this.data,
    required this.storageKey,
    required this.identityMissing,
  });

  final _OverlayTableSpec spec;
  final Map<String, Object?> data;
  final String storageKey;
  final bool identityMissing;
}

final class _SourceIdentity {
  const _SourceIdentity({required this.key, required this.kind});

  final String key;
  final String kind;
}

final class _HandleAlias {
  const _HandleAlias({required this.canonicalId, required this.normalized});

  final int canonicalId;
  final String normalized;
}

final class _GraphInventory {
  const _GraphInventory({
    required this.sources,
    required this.messages,
    required this.chats,
    required this.contacts,
    required this.handles,
    required this.canonicalHandles,
    required this.handleAliases,
    required this.attachments,
    required this.messageToAttachment,
  });

  final Map<int, _SourceIdentity> sources;
  final Map<int, String?> messages;
  final Set<int> chats;
  final Set<int> contacts;
  final Map<int, String> handles;
  final Map<int, String> canonicalHandles;
  final Map<int, _HandleAlias> handleAliases;
  final Set<int> attachments;
  final Set<String> messageToAttachment;

  String? sourceIdentity(String kind, int packedId) {
    try {
      final sourceId = SourceScopedRowKey.unpackSourceId(packedId);
      final sourceRowId = SourceScopedRowKey.unpackSourceRowId(packedId);
      final source = sources[sourceId];
      if (source == null) {
        return null;
      }
      if (kind == 'source') {
        return '${source.kind}:${source.key}';
      }
      return '$kind:${source.kind}:${source.key}:$sourceRowId';
    } on RangeError {
      return null;
    }
  }
}

final class _BoundedReadFailure implements Exception {
  const _BoundedReadFailure(this.reason, this.diagnostic);

  final ProtectedReferenceUnknownReason reason;
  final String diagnostic;
}

ProtectedReferenceTruth _compareStrings(
  Map<String, String> expected,
  Map<String, String> observed, {
  required String diagnosticPrefix,
  required Set<String> diagnostics,
}) {
  var truth = ProtectedReferenceTruth.trueValue;
  for (final key in <String>{...expected.keys, ...observed.keys}) {
    if (!expected.containsKey(key)) {
      diagnostics.add('$diagnosticPrefix.extra.${_tableFromStorageKey(key)}');
      truth = ProtectedReferenceTruth.falseValue;
    } else if (!observed.containsKey(key)) {
      diagnostics.add('$diagnosticPrefix.missing.${_tableFromStorageKey(key)}');
      truth = ProtectedReferenceTruth.falseValue;
    } else if (expected[key] != observed[key]) {
      diagnostics.add('$diagnosticPrefix.changed.${_tableFromStorageKey(key)}');
      truth = ProtectedReferenceTruth.falseValue;
    }
  }
  return truth;
}

ProtectedReferenceUnknownReason? _unavailableObservationReason(
  ProtectedReferenceObservation observation,
) {
  if (observation.truth != ProtectedReferenceTruth.unknown ||
      observation.materialByReference.isNotEmpty ||
      observation.targetsByReference.isNotEmpty) {
    return null;
  }
  return switch (observation.unknownReason) {
    ProtectedReferenceUnknownReason.unsupportedSchema ||
    ProtectedReferenceUnknownReason.unreadableSource ||
    ProtectedReferenceUnknownReason.unqualifiedLookup ||
    ProtectedReferenceUnknownReason.rowLimit ||
    ProtectedReferenceUnknownReason.byteLimit => observation.unknownReason,
    ProtectedReferenceUnknownReason.ambiguousFallback ||
    ProtectedReferenceUnknownReason.missingIdentityField ||
    null => null,
  };
}

ProtectedReferenceTruth _compareTargets(
  Map<String, ProtectedReferenceTargetEvidence> expected,
  Map<String, ProtectedReferenceTargetEvidence> observed, {
  required String? Function(ProtectedReferenceTargetEvidence) selector,
  required String diagnosticPrefix,
  required Set<String> diagnostics,
}) {
  var sawUnknown = false;
  var sawFalse = false;
  for (final key in <String>{...expected.keys, ...observed.keys}) {
    final expectedValue = expected[key];
    final observedValue = observed[key];
    final table = _tableFromStorageKey(key);
    if (expectedValue == null || observedValue == null) {
      diagnostics.add('$diagnosticPrefix.missing.$table');
      sawFalse = true;
      continue;
    }
    if (expectedValue.truth == ProtectedReferenceTruth.falseValue ||
        observedValue.truth == ProtectedReferenceTruth.falseValue) {
      diagnostics.add('$diagnosticPrefix.unresolved.$table');
      sawFalse = true;
      continue;
    }
    if (expectedValue.truth == ProtectedReferenceTruth.unknown ||
        observedValue.truth == ProtectedReferenceTruth.unknown) {
      diagnostics.add('$diagnosticPrefix.ambiguous.$table');
      sawUnknown = true;
      continue;
    }
    if (selector(expectedValue) != selector(observedValue)) {
      diagnostics.add('$diagnosticPrefix.rebound.$table');
      sawFalse = true;
    }
  }
  if (sawFalse) {
    return ProtectedReferenceTruth.falseValue;
  }
  if (sawUnknown) {
    return ProtectedReferenceTruth.unknown;
  }
  return ProtectedReferenceTruth.trueValue;
}

Map<String, ProtectedReferenceTargetEvidence> _onlyCompatibility(
  Map<String, ProtectedReferenceTargetEvidence> source,
) {
  return {
    for (final entry in source.entries)
      if (_tableFromStorageKey(entry.key) == 'archived_attachments')
        entry.key: entry.value,
  };
}

ProtectedReferenceTruth _aggregateTruth(
  Iterable<ProtectedReferenceTruth> truths,
) {
  var sawUnknown = false;
  for (final truth in truths) {
    if (truth == ProtectedReferenceTruth.falseValue) {
      return ProtectedReferenceTruth.falseValue;
    }
    sawUnknown = sawUnknown || truth == ProtectedReferenceTruth.unknown;
  }
  return sawUnknown
      ? ProtectedReferenceTruth.unknown
      : ProtectedReferenceTruth.trueValue;
}

String _tableFromStorageKey(String key) => key.split('|').first;

String _canonicalJson(Object? value) {
  Object? normalize(Object? current) {
    if (current is Uint8List) {
      return base64Encode(current);
    }
    if (current is Map) {
      final keys = current.keys.map((key) => key.toString()).toList()..sort();
      return <String, Object?>{
        for (final key in keys) key: normalize(current[key]),
      };
    }
    if (current is Iterable) {
      return current.map(normalize).toList(growable: false);
    }
    return current;
  }

  return jsonEncode(normalize(value));
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
