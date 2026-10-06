import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';

import '../../../../../core/util/paths_helper.dart';

class AddressBookFolderPathsFinder {
  final PathsHelper? _pathsHelper;
  final String? _explicitSourcesRootPath;
  final void Function(String dirPath, Object error, StackTrace stackTrace)?
  onDirectoryReadFailure;

  AddressBookFolderPathsFinder({
    required PathsHelper pathsHelper,
    this.onDirectoryReadFailure,
  }) : _pathsHelper = pathsHelper,
       _explicitSourcesRootPath = null;

  /// Uses an explicitly supplied Address Book `Sources` root.
  ///
  /// This keeps source substitution at the discovery boundary while preserving
  /// the repository's normal candidate validation and read-only query path.
  AddressBookFolderPathsFinder.atSourcesRoot({
    required String sourcesRootPath,
    this.onDirectoryReadFailure,
  }) : _pathsHelper = null,
       _explicitSourcesRootPath = sourcesRootPath;

  Future<List<String>> getAddressBookPaths() async {
    final dirList = await getAddressBookDirectories();
    final pathsList = dirList
        .map((dir) => '${dir.path}/AddressBook-v22.abcddb')
        .toList();
    return pathsList;
  }

  Future<List<Directory>> getAddressBookDirectories() async {
    const dirStub = 'Library/Application Support/AddressBook/Sources/';
    final parentDirPath =
        _explicitSourcesRootPath ?? _pathsHelper!.userGraft(dirStub);
    final dirObj = Directory(parentDirPath);
    final directories = await dirChatFolders(dirObj);

    return directories.toList();
  }

  Future<List<Directory>> dirChatFolders(Directory dir) {
    final directories = <Directory>[];
    final completer = Completer<List<Directory>>();
    final lister = dir.list(followLinks: false);

    lister.listen(
      (entity) {
        if (entity is! File) {
          if (directoryAtPathContainsAddressBookDB(entity.path)) {
            directories.add(Directory(entity.path));
          }
        }
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.complete(directories);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
      cancelOnError: true,
    );

    return completer.future;
  }

  bool directoryAtPathContainsAddressBookDB(String dirPath) {
    final dir = Directory(dirPath);
    var hasDB = false;
    try {
      if (dir.existsSync()) {
        for (final entity in dir.listSync(followLinks: false)) {
          final baseName = basename(entity.path);
          if (entity is File && baseName == 'AddressBook-v22.abcddb') {
            hasDB = true;
          }
        }
      }
    } catch (error, stackTrace) {
      onDirectoryReadFailure?.call(dirPath, error, stackTrace);
      return false;
    }

    return hasDB;
  }
}
