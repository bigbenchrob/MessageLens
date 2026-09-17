import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

import '../../application/attachment_archive_relocation_journal_store.dart';
import '../../domain/entities/attachment_archive_relocation.dart';

final class FilesystemAttachmentArchiveRelocationJournalStore
    implements AttachmentArchiveRelocationJournalStore {
  const FilesystemAttachmentArchiveRelocationJournalStore({
    required String primaryArchiveRootPath,
  }) : _primaryArchiveRootPath = primaryArchiveRootPath;

  static const String journalDirectoryName = '.attachment_archive_relocations';
  static const String _currentFileName = 'current.json';
  static const String _journalFileName = 'journal.json';
  static const String _manifestFileName = 'manifest.ndjson';
  static const String _copyReceiptsFileName = 'copy_receipts.ndjson';

  final String _primaryArchiveRootPath;

  String get _rootPath =>
      path.join(_primaryArchiveRootPath, journalDirectoryName);

  @override
  Future<void> create(AttachmentArchiveRelocationJournal journal) async {
    _requireOperationId(journal.operationId);
    final root = Directory(_rootPath);
    await root.create(recursive: true);
    final operationDirectory = Directory(_operationPath(journal.operationId));
    if (operationDirectory.existsSync()) {
      throw StateError(
        'Attachment relocation operation already exists: '
        '${journal.operationId}',
      );
    }
    await operationDirectory.create();
    await _writeJsonAtomically(
      _journalPath(journal.operationId),
      journal.toJson(),
    );
    await _writeJsonAtomically(
      path.join(_rootPath, _currentFileName),
      <String, Object>{'operationId': journal.operationId},
    );
  }

  @override
  Future<void> save(AttachmentArchiveRelocationJournal journal) {
    _requireOperationId(journal.operationId);
    return _writeJsonAtomically(
      _journalPath(journal.operationId),
      journal.toJson(),
    );
  }

  @override
  Future<AttachmentArchiveRelocationJournal?> readCurrent() async {
    final root = Directory(_rootPath);
    if (!root.existsSync()) {
      return null;
    }
    final pending = <AttachmentArchiveRelocationJournal>[];
    for (final entity in root.listSync(followLinks: false)) {
      if (entity is! Directory) {
        continue;
      }
      final operationId = path.basename(entity.path);
      try {
        final journal = await read(operationId);
        if (!journal.stage.isTerminal) {
          pending.add(journal);
        }
      } on ArgumentError {
        continue;
      }
    }
    if (pending.length > 1) {
      throw StateError(
        'Multiple unfinished attachment relocation journals require review.',
      );
    }
    if (pending.length == 1) {
      return pending.single;
    }

    final pointer = File(path.join(_rootPath, _currentFileName));
    if (!pointer.existsSync()) {
      return null;
    }
    final decoded = jsonDecode(await pointer.readAsString());
    if (decoded is! Map || decoded['operationId'] is! String) {
      throw const FormatException(
        'Attachment relocation current pointer is invalid.',
      );
    }
    return read(decoded['operationId'] as String);
  }

  @override
  Future<AttachmentArchiveRelocationJournal> read(String operationId) async {
    _requireOperationId(operationId);
    final file = File(_journalPath(operationId));
    if (!file.existsSync()) {
      throw StateError(
        'Attachment relocation journal does not exist: $operationId',
      );
    }
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map) {
      throw const FormatException(
        'Attachment relocation journal must be a JSON object.',
      );
    }
    final journal = AttachmentArchiveRelocationJournal.fromJson(
      Map<String, Object?>.from(decoded),
    );
    if (journal.operationId != operationId) {
      throw const FormatException(
        'Attachment relocation journal operation identity mismatch.',
      );
    }
    return journal;
  }

  @override
  Future<void> beginManifest(String operationId) {
    return _createEmptyFile(_manifestPath(operationId));
  }

  @override
  Future<void> appendManifestEntry({
    required String operationId,
    required AttachmentArchiveRelocationManifestEntry entry,
  }) {
    return _appendJsonLine(_manifestPath(operationId), entry.toJson());
  }

  @override
  Stream<AttachmentArchiveRelocationManifestEntry> readManifest(
    String operationId,
  ) {
    return _readJsonLines(
      _manifestPath(operationId),
    ).map(AttachmentArchiveRelocationManifestEntry.fromJson);
  }

  @override
  Future<String> hashManifest(String operationId) async {
    final digest = await sha256
        .bind(File(_manifestPath(operationId)).openRead())
        .first;
    return digest.toString();
  }

  @override
  Future<void> beginCopyReceipts(String operationId) {
    return _createEmptyFile(_copyReceiptsPath(operationId));
  }

  @override
  Future<void> appendCopyReceipt({
    required String operationId,
    required AttachmentArchiveRelocationCopyReceipt receipt,
  }) {
    return _appendJsonLine(_copyReceiptsPath(operationId), receipt.toJson());
  }

  @override
  Stream<AttachmentArchiveRelocationCopyReceipt> readCopyReceipts(
    String operationId,
  ) {
    return _readJsonLines(
      _copyReceiptsPath(operationId),
    ).map(AttachmentArchiveRelocationCopyReceipt.fromJson);
  }

  Future<void> _createEmptyFile(String filePath) async {
    final file = File(filePath);
    final handle = await file.open(mode: FileMode.write);
    try {
      await handle.flush();
    } finally {
      await handle.close();
    }
  }

  Future<void> _appendJsonLine(
    String filePath,
    Map<String, Object?> json,
  ) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw StateError('Relocation journal stream does not exist: $filePath');
    }
    final handle = await file.open(mode: FileMode.append);
    try {
      await handle.writeString('${jsonEncode(json)}\n');
      await handle.flush();
    } finally {
      await handle.close();
    }
  }

  Stream<Map<String, Object?>> _readJsonLines(String filePath) async* {
    var lineNumber = 0;
    final lines = File(
      filePath,
    ).openRead().transform(utf8.decoder).transform(const LineSplitter());
    await for (final line in lines) {
      lineNumber++;
      if (line.isEmpty) {
        throw FormatException('Empty relocation journal line at $lineNumber.');
      }
      final decoded = jsonDecode(line);
      if (decoded is! Map) {
        throw FormatException(
          'Relocation journal line $lineNumber must be an object.',
        );
      }
      yield Map<String, Object?>.from(decoded);
    }
  }

  Future<void> _writeJsonAtomically(
    String filePath,
    Map<String, Object?> json,
  ) async {
    final temporary = File('$filePath.pending');
    if (temporary.existsSync()) {
      await temporary.delete();
    }
    await temporary.create(exclusive: true);
    final handle = await temporary.open(mode: FileMode.write);
    try {
      await handle.writeString(jsonEncode(json));
      await handle.flush();
    } finally {
      await handle.close();
    }
    await temporary.rename(filePath);
  }

  String _operationPath(String operationId) {
    _requireOperationId(operationId);
    return path.join(_rootPath, operationId);
  }

  String _journalPath(String operationId) =>
      path.join(_operationPath(operationId), _journalFileName);

  String _manifestPath(String operationId) =>
      path.join(_operationPath(operationId), _manifestFileName);

  String _copyReceiptsPath(String operationId) =>
      path.join(_operationPath(operationId), _copyReceiptsFileName);

  static void _requireOperationId(String operationId) {
    if (!RegExp(r'^[a-zA-Z0-9-]{1,80}$').hasMatch(operationId)) {
      throw ArgumentError.value(
        operationId,
        'operationId',
        'Relocation operation identity is unsafe.',
      );
    }
  }
}
