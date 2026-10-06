import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/features/address_book_folders/domain/failures/folder_retrieval_failure.dart';
import 'package:remember_this_text/features/address_book_folders/infrastructure/data_sources/local/address_book_folder_path_finder.dart';
import 'package:remember_this_text/features/address_book_folders/infrastructure/repositories/address_book_folder_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDirectory;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'address_book_repository_test_',
    );
  });

  tearDown(() async {
    await tempDirectory.delete(recursive: true);
  });

  test('explicit empty Sources root produces unavailable result', () async {
    final sourcesRoot = Directory(path.join(tempDirectory.path, 'Sources'));
    await sourcesRoot.create(recursive: true);
    final repository = AddressBookFolderRepository(
      folderPathsFinder: AddressBookFolderPathsFinder.atSourcesRoot(
        sourcesRootPath: sourcesRoot.path,
      ),
    );

    final result = await repository.getFinalFolderAggregate();

    expect(result.isLeft(), isTrue);
    expect(
      result.fold((failure) => failure.kind, (_) => null),
      FolderRetrievalFailureKind.sourceUnavailable,
    );
  });

  test('viable zero-contact database remains a viable source', () async {
    final sourcesRoot = Directory(
      path.join(tempDirectory.path, 'one', 'two', 'three', 'Sources'),
    );
    final candidateDirectory = Directory(path.join(sourcesRoot.path, 'EMPTY'));
    await candidateDirectory.create(recursive: true);
    final databasePath = path.join(
      candidateDirectory.path,
      'AddressBook-v22.abcddb',
    );
    final database = await openDatabase(databasePath, version: 1);
    await database.execute('''
      CREATE TABLE ZABCDRECORD (
        Z_PK INTEGER PRIMARY KEY,
        ZCREATIONDATE REAL,
        ZMODIFICATIONDATE REAL
      )
    ''');
    await database.close();
    final repository = AddressBookFolderRepository(
      folderPathsFinder: AddressBookFolderPathsFinder.atSourcesRoot(
        sourcesRootPath: sourcesRoot.path,
      ),
    );

    final result = await repository.getFinalFolderAggregate();

    expect(result.isRight(), isTrue);
    expect(
      result
          .getOrElse(() => throw StateError('Expected viable aggregate.'))
          .folders
          .single
          .recordCount
          .getOrElse(0),
      0,
    );
  });

  test(
    'explicit viable Sources root uses normal read-only repository path',
    () async {
      final sourcesRoot = Directory(
        path.join(tempDirectory.path, 'one', 'two', 'three', 'Sources'),
      );
      final candidateDirectory = Directory(
        path.join(sourcesRoot.path, 'DISPOSABLE-CANDIDATE'),
      );
      await candidateDirectory.create(recursive: true);
      final databasePath = path.join(
        candidateDirectory.path,
        'AddressBook-v22.abcddb',
      );
      final database = await openDatabase(databasePath, version: 1);
      await database.execute('''
      CREATE TABLE ZABCDRECORD (
        Z_PK INTEGER PRIMARY KEY,
        ZCREATIONDATE REAL,
        ZMODIFICATIONDATE REAL
      )
    ''');
      await database.insert('ZABCDRECORD', <String, Object?>{
        'Z_PK': 1,
        'ZCREATIONDATE': 1.0,
        'ZMODIFICATIONDATE': 2.0,
      });
      await database.close();
      final repository = AddressBookFolderRepository(
        folderPathsFinder: AddressBookFolderPathsFinder.atSourcesRoot(
          sourcesRootPath: sourcesRoot.path,
        ),
      );

      final result = await repository.getFinalFolderAggregate();

      expect(result.isRight(), isTrue);
      expect(
        result
            .getOrElse(() => throw StateError('Expected viable aggregate.'))
            .mostRecentFolderPath,
        databasePath,
      );
      expect(
        result
            .getOrElse(() => throw StateError('Expected viable aggregate.'))
            .folders
            .single
            .recordCount
            .getOrElse(0),
        1,
      );
    },
  );

  test(
    'explicit Sources root never scans a candidate outside that root',
    () async {
      final disposableRoot = Directory(
        path.join(tempDirectory.path, 'disposable', 'Sources'),
      );
      final outsideCandidate = File(
        path.join(
          tempDirectory.path,
          'apple-managed-sentinel',
          'candidate',
          'AddressBook-v22.abcddb',
        ),
      );
      await disposableRoot.create(recursive: true);
      await outsideCandidate.parent.create(recursive: true);
      await outsideCandidate.writeAsString('unchanged');
      final finder = AddressBookFolderPathsFinder.atSourcesRoot(
        sourcesRootPath: disposableRoot.path,
      );

      expect(await finder.getAddressBookPaths(), isEmpty);
      expect(await outsideCandidate.readAsString(), 'unchanged');
    },
  );

  test('Contacts retrieval failures retain their Fair-Witness taxonomy', () {
    expect(
      classifyAddressBookFolderRetrievalFailure(
        const FileSystemException('Operation not permitted'),
      ),
      FolderRetrievalFailureKind.accessDenied,
    );
    expect(
      classifyAddressBookFolderRetrievalFailure(
        const FileSystemException('No such file'),
      ),
      FolderRetrievalFailureKind.sourceUnavailable,
    );
    expect(
      classifyAddressBookFolderRetrievalFailure(
        const FormatException('database disk image is malformed'),
      ),
      FolderRetrievalFailureKind.invalidOrCorrupt,
    );
    expect(
      classifyAddressBookFolderRetrievalFailure(StateError('inconclusive')),
      FolderRetrievalFailureKind.unknown,
    );
  });
}
