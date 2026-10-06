import 'package:dartz/dartz.dart';

import '../../domain/entities/address_book_folder_aggregate.dart';
import '../../domain/entities/address_book_folder_entity.dart';
import '../../domain/failures/folder_retrieval_failure.dart';
import '../data_sources/local/address_book_db_helper_multi_instance.dart';
import '../data_sources/local/address_book_folder_path_finder.dart';

class AddressBookFolderRepository {
  final AddressBookFolderPathsFinder folderPathsFinder;

  AddressBookFolderRepository({required this.folderPathsFinder});

  Future<Either<FolderRetrievalFailure, AddressBookFolderAggregate>>
  getFinalFolderAggregate() async {
    try {
      final candidatePaths = await folderPathsFinder.getAddressBookPaths();
      if (candidatePaths.isEmpty) {
        return const Left(
          FolderRetrievalFailure(
            message: 'No address book folders found',
            kind: FolderRetrievalFailureKind.sourceUnavailable,
          ),
        );
      }

      final viablePathScan = await _filterViablePaths(candidatePaths);
      if (viablePathScan.viablePaths.isEmpty) {
        return Left(
          FolderRetrievalFailure(
            message:
                'No viable address book folders found'
                '${viablePathScan.rejectionSummary}',
            kind: viablePathScan.failureKind,
          ),
        );
      }

      final folders = await Future.wait(
        viablePathScan.viablePaths.map((path) => _processToFolderEntity(path)),
        eagerError: true,
      );

      final aggregate = AddressBookFolderAggregate(folders);
      return Right(aggregate);
    } catch (error) {
      return Left(
        FolderRetrievalFailure(
          message: 'Folder retrieval failed: $error',
          kind: classifyAddressBookFolderRetrievalFailure(error),
        ),
      );
    }
  }

  Future<_ViableAddressBookPathScan> _filterViablePaths(
    List<String> paths,
  ) async {
    final viablePaths = <String>[];
    final rejectedReasons = <String>[];
    final rejectedKinds = <FolderRetrievalFailureKind>[];
    for (final path in paths) {
      final rejection = await _addressBookDbRejection(path);
      if (rejection == null) {
        viablePaths.add(path);
      } else {
        rejectedReasons.add('$path: ${rejection.message}');
        rejectedKinds.add(rejection.kind);
      }
    }
    return _ViableAddressBookPathScan(
      viablePaths: viablePaths,
      rejectedReasons: rejectedReasons,
      rejectedKinds: rejectedKinds,
    );
  }

  Future<_AddressBookPathRejection?> _addressBookDbRejection(
    String path,
  ) async {
    final helper = AddressBookDbHelperMultiInstance(path);
    try {
      await helper.verifyReadable();
      return null;
    } catch (error) {
      return _AddressBookPathRejection(
        message: '$error',
        kind: classifyAddressBookFolderRetrievalFailure(error),
      );
    } finally {
      await helper.close();
    }
  }

  Future<AddressBookFolderEntity> _processToFolderEntity(String path) async {
    final helper = AddressBookDbHelperMultiInstance(path);
    try {
      final result = await helper.readRows(_qsAddressFolderInfo(path));
      final jsonResult = result.first;
      return AddressBookFolderEntity.fromJson(jsonResult);
    } catch (error) {
      throw FolderRetrievalFailure(
        message:
            'Conversion of AddressBook path to folder entity failed for '
            '$path: $error',
        kind: classifyAddressBookFolderRetrievalFailure(error),
      );
    } finally {
      await helper.close();
    }
  }

  String _qsAddressFolderInfo(String path) {
    return '''
      SELECT  '$path' AS path,
              MAX(Z_PK) AS maxId,
              COUNT(Z_PK) AS count,
              MAX(ZCREATIONDATE) AS creationDateMax,
              MAX(ZMODIFICATIONDATE) AS modificationDateMax
        FROM  ZABCDRECORD
    ''';
  }
}

FolderRetrievalFailureKind classifyAddressBookFolderRetrievalFailure(
  Object error,
) {
  if (error is FolderRetrievalFailure) {
    return error.kind;
  }
  final normalized = '$error'.toLowerCase();
  if (normalized.contains('permission denied') ||
      normalized.contains('operation not permitted') ||
      normalized.contains('not authorized') ||
      normalized.contains('authorization denied')) {
    return FolderRetrievalFailureKind.accessDenied;
  }
  if (normalized.contains('malformed') ||
      normalized.contains('corrupt') ||
      normalized.contains('not a database') ||
      normalized.contains('file is encrypted')) {
    return FolderRetrievalFailureKind.invalidOrCorrupt;
  }
  if (normalized.contains('no such file') ||
      normalized.contains('cannot open') ||
      normalized.contains("couldn't be opened")) {
    return FolderRetrievalFailureKind.sourceUnavailable;
  }
  return FolderRetrievalFailureKind.unknown;
}

class _AddressBookPathRejection {
  const _AddressBookPathRejection({required this.message, required this.kind});

  final String message;
  final FolderRetrievalFailureKind kind;
}

class _ViableAddressBookPathScan {
  const _ViableAddressBookPathScan({
    required this.viablePaths,
    required this.rejectedReasons,
    required this.rejectedKinds,
  });

  final List<String> viablePaths;
  final List<String> rejectedReasons;
  final List<FolderRetrievalFailureKind> rejectedKinds;

  FolderRetrievalFailureKind get failureKind {
    if (rejectedKinds.contains(FolderRetrievalFailureKind.accessDenied)) {
      return FolderRetrievalFailureKind.accessDenied;
    }
    if (rejectedKinds.contains(FolderRetrievalFailureKind.invalidOrCorrupt)) {
      return FolderRetrievalFailureKind.invalidOrCorrupt;
    }
    if (rejectedKinds.every(
      (kind) => kind == FolderRetrievalFailureKind.sourceUnavailable,
    )) {
      return FolderRetrievalFailureKind.sourceUnavailable;
    }
    return FolderRetrievalFailureKind.unknown;
  }

  String get rejectionSummary {
    if (rejectedReasons.isEmpty) {
      return '';
    }

    return ': ${rejectedReasons.join('; ')}';
  }
}
