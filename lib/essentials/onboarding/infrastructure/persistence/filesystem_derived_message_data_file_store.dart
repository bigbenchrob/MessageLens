import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

import '../../application/derived_message_data_file_store.dart';

final class FilesystemDerivedMessageDataFileStore
    implements DerivedMessageDataFileStore, LocalDataRepairPhysicalFileStore {
  const FilesystemDerivedMessageDataFileStore({
    required this.databaseDirectory,
  });

  final String databaseDirectory;

  @override
  bool databaseBaseFileExists(String baseName) {
    return _isRegularFile(
      path.join(databaseDirectory, _validatedDatabaseBaseName(baseName)),
    );
  }

  @override
  Map<String, bool> databaseExistenceByBaseName(List<String> baseNames) {
    return {
      for (final baseName in baseNames)
        baseName: databaseBaseFileExists(baseName),
    };
  }

  @override
  Future<List<String>> deleteDatabaseBaseFiles(List<String> baseNames) async {
    final deletedFilePaths = <String>[];
    for (final baseName in baseNames) {
      final basePath = path.join(
        databaseDirectory,
        _validatedDatabaseBaseName(baseName),
      );
      for (final filePath in <String>[
        basePath,
        '$basePath-wal',
        '$basePath-shm',
      ]) {
        if (_isRegularFile(filePath)) {
          await File(filePath).delete();
          deletedFilePaths.add(filePath);
        }
      }
    }

    return deletedFilePaths;
  }

  @override
  Future<LocalDataRepairPhysicalSnapshot> captureLocalDataRepairSnapshot(
    List<String> resetBaseNames,
  ) async {
    final resetNames = _resetEntityNames(resetBaseNames);
    return LocalDataRepairPhysicalSnapshot(
      preservedEntries: (await _topLevelEvidence())
        ..removeWhere((name, _) => resetNames.contains(name)),
    );
  }

  @override
  Future<void> requireLocalDataRepairPostcondition({
    required LocalDataRepairPhysicalSnapshot before,
    required List<String> resetBaseNames,
  }) async {
    for (final name in _resetEntityNames(resetBaseNames)) {
      final candidate = path.join(databaseDirectory, name);
      if (FileSystemEntity.typeSync(candidate, followLinks: false) !=
          FileSystemEntityType.notFound) {
        throw StateError('Local Data Repair did not remove $name.');
      }
    }
    final after = (await _topLevelEvidence())
      ..removeWhere(
        (name, _) => _resetEntityNames(resetBaseNames).contains(name),
      );
    if (!_sameEvidence(before.preservedEntries, after)) {
      throw StateError(
        'Local Data Repair changed an entry outside its exact active derived-store footprint.',
      );
    }
  }

  Set<String> _resetEntityNames(List<String> resetBaseNames) {
    return <String>{
      for (final baseName in resetBaseNames) ...<String>{
        _validatedDatabaseBaseName(baseName),
        '$baseName-wal',
        '$baseName-shm',
      },
    };
  }

  Future<Map<String, String>> _topLevelEvidence() async {
    final directory = Directory(databaseDirectory);
    final evidence = <String, String>{};
    for (final entity in directory.listSync(followLinks: false)) {
      evidence[path.basename(entity.path)] = await _entityEvidence(entity);
    }
    return evidence;
  }

  Future<String> _entityEvidence(FileSystemEntity entity) async {
    final type = FileSystemEntity.typeSync(entity.path, followLinks: false);
    if (type == FileSystemEntityType.link) {
      return '$type:${await Link(entity.path).target()}';
    }
    final stat = entity.statSync();
    if (type == FileSystemEntityType.file) {
      final digest = await sha256.bind(File(entity.path).openRead()).first;
      return '$type:${stat.size}:$digest';
    }
    return '$type:${stat.size}:${stat.modified.microsecondsSinceEpoch}';
  }

  bool _sameEvidence(Map<String, String> left, Map<String, String> right) {
    if (left.length != right.length) {
      return false;
    }
    return left.entries.every((entry) => right[entry.key] == entry.value);
  }

  String _validatedDatabaseBaseName(String baseName) {
    if (baseName.isEmpty ||
        path.isAbsolute(baseName) ||
        baseName != path.basename(baseName) ||
        baseName.contains(r'\')) {
      throw ArgumentError.value(
        baseName,
        'baseName',
        'must be a database file base name, not a path',
      );
    }
    return baseName;
  }

  bool _isRegularFile(String filePath) {
    return FileSystemEntity.typeSync(filePath, followLinks: false) ==
        FileSystemEntityType.file;
  }
}
