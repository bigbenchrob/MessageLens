import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/archive_environment/application/archive_admission_service.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_admission_exception.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_build_identity.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_environment.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_identity_validator.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_marker.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/native_archive_claim.dart';
import 'package:remember_this_text/essentials/archive_environment/infrastructure/development_archive_root_override_resolver.dart';
import 'package:remember_this_text/essentials/archive_environment/infrastructure/exact_canonical_archive_root_policy.dart';
import 'package:remember_this_text/essentials/archive_environment/infrastructure/file_system_archive_marker_store.dart';

void main() {
  late Directory temporaryDirectory;

  setUp(() {
    temporaryDirectory = Directory.systemTemp.createTempSync(
      'messagelens-admission-',
    );
  });

  tearDown(() {
    if (temporaryDirectory.existsSync()) {
      temporaryDirectory.deleteSync(recursive: true);
    }
  });

  test('development creates and admits a marker in an empty root', () async {
    final root = Directory('${temporaryDirectory.path}/development');
    final authority = await _serviceFor(
      root,
    ).admit(_developmentClaim(root.path));

    expect(authority.rootPath, root.path);
    expect(authority.identity.environment, ArchiveEnvironment.development);
    expect(
      File(
        '${root.path}/${FileSystemArchiveMarkerStore.markerFileName}',
      ).existsSync(),
      isTrue,
    );
  });

  test(
    'filesystem-canonical disposable development override is admitted',
    () async {
      final root = Directory(
        '/private/tmp',
      ).createTempSync('messagelens admission ');
      addTearDown(() {
        if (root.existsSync()) {
          root.deleteSync(recursive: true);
        }
      });
      final tmpAlias = root.path.replaceFirst('/private/tmp/', '/tmp/');
      final expectedRoot = const DevelopmentArchiveRootOverrideResolver()
          .resolveExpectedRoot(
            environment: ArchiveEnvironment.development,
            defaultRootPath: '/unused',
            processEnvironment: {
              DevelopmentArchiveRootOverrideResolver
                      .defaultDevelopmentArchiveRootEnvironmentVariable:
                  tmpAlias,
            },
          );
      final service = _serviceFor(Directory(expectedRoot));

      final authority = await service.admit(_developmentClaim(expectedRoot));

      expect(expectedRoot, root.path);
      expect(authority.rootPath, root.path);
      expect(
        File(
          '${root.path}/${FileSystemArchiveMarkerStore.markerFileName}',
        ).existsSync(),
        isTrue,
      );
    },
  );

  test(
    'native process lock is allowed before initial marker creation',
    () async {
      final root = Directory('${temporaryDirectory.path}/development');
      await root.create();
      await File(
        '${root.path}/MessageLens.instance.lock',
      ).writeAsString('locked by native bootstrap');

      final authority = await _serviceFor(
        root,
      ).admit(_developmentClaim(root.path));

      expect(authority.rootPath, root.path);
    },
  );

  test('development refuses a non-empty unmarked root', () async {
    final root = Directory('${temporaryDirectory.path}/development');
    await root.create();
    await File('${root.path}/unexpected.db').writeAsString('data');

    await expectLater(
      _serviceFor(root).admit(_developmentClaim(root.path)),
      throwsA(
        isA<ArchiveAdmissionException>().having(
          (error) => error.failure,
          'failure',
          ArchiveAdmissionFailure.nonEmptyUnmarkedArchive,
        ),
      ),
    );
  });

  test('production creates and admits a marker in an absent root', () async {
    final root = Directory('${temporaryDirectory.path}/production');

    final authority = await _serviceFor(
      root,
    ).admit(_productionClaim(root.path));
    final marker = await FileSystemArchiveMarkerStore(
      rootPath: root.path,
    ).read();

    expect(authority.identity.environment, ArchiveEnvironment.production);
    expect(marker, isNotNull);
    expect(marker?.environment, ArchiveEnvironment.production);
    expect(marker?.archiveInstanceId, authority.identity.archiveInstanceId);
  });

  test(
    'production creates its initial marker beside the native process lock',
    () async {
      final root = Directory('${temporaryDirectory.path}/production');
      await root.create();
      await File(
        '${root.path}/MessageLens.instance.lock',
      ).writeAsString('locked by native bootstrap');

      await _serviceFor(root).admit(_productionClaim(root.path));

      expect(
        File(
          '${root.path}/${FileSystemArchiveMarkerStore.markerFileName}',
        ).existsSync(),
        isTrue,
      );
      expect(
        await File('${root.path}/MessageLens.instance.lock').readAsString(),
        'locked by native bootstrap',
      );
    },
  );

  test('production rejects every non-empty unmarked root', () async {
    final root = Directory('${temporaryDirectory.path}/production');
    await root.create();
    await File('${root.path}/unrecognized.db').writeAsString('data');

    await expectLater(
      _serviceFor(root).admit(_productionClaim(root.path)),
      throwsA(
        isA<ArchiveAdmissionException>().having(
          (error) => error.failure,
          'failure',
          ArchiveAdmissionFailure.nonEmptyUnmarkedArchive,
        ),
      ),
    );
  });

  test(
    'non-canonical production claim is rejected before root admission',
    () async {
      final root = Directory('${temporaryDirectory.path}/production');
      final policy = ExactCanonicalArchiveRootPolicy(
        canonicalRoots: {ArchiveEnvironment.production: root.path},
        platformApplicationSupportRoot:
            '/Users/test/Library/Application Support',
      );
      final service = ArchiveAdmissionService(
        validator: ArchiveIdentityValidator(rootPolicy: policy),
        markerStore: FileSystemArchiveMarkerStore(rootPath: root.path),
      );

      await expectLater(
        service.admit(_productionClaim('${root.path}/different')),
        throwsA(
          isA<ArchiveAdmissionException>().having(
            (error) => error.failure,
            'failure',
            ArchiveAdmissionFailure.nonCanonicalRoot,
          ),
        ),
      );
    },
  );

  test('development refuses a production marker', () async {
    final root = Directory('${temporaryDirectory.path}/development');
    final store = FileSystemArchiveMarkerStore(rootPath: root.path);
    await store.createInitialMarker(
      ArchiveMarker.fromJson({
        'formatVersion': ArchiveMarker.currentFormatVersion,
        'environment': 'production',
        'archiveInstanceId': 'b8bd0bce-29ef-4e58-9f44-579748f490aa',
        'createdAtUtc': '2026-07-27T12:00:00.000Z',
      }),
    );

    await expectLater(
      _serviceFor(root).admit(_developmentClaim(root.path)),
      throwsA(
        isA<ArchiveAdmissionException>().having(
          (error) => error.failure,
          'failure',
          ArchiveAdmissionFailure.markerEnvironmentMismatch,
        ),
      ),
    );
  });
}

ArchiveAdmissionService _serviceFor(Directory root) {
  final policy = ExactCanonicalArchiveRootPolicy(
    canonicalRoots: {
      ArchiveEnvironment.development: root.path,
      ArchiveEnvironment.production: root.path,
    },
    platformApplicationSupportRoot: '/Users/test/Library/Application Support',
  );
  return ArchiveAdmissionService(
    validator: ArchiveIdentityValidator(rootPolicy: policy),
    markerStore: FileSystemArchiveMarkerStore(rootPath: root.path),
    currentTime: () => DateTime.utc(2026, 7, 27, 12),
  );
}

NativeArchiveClaim _developmentClaim(String rootPath) {
  return NativeArchiveClaim(
    environment: ArchiveEnvironment.development,
    buildIdentity: ArchiveBuildIdentity.developmentDebug,
    bundleIdentifier:
        ArchiveIdentityValidator.defaultDevelopmentBundleIdentifier,
    productName: ArchiveIdentityValidator.defaultDevelopmentProductName,
    canonicalRootPath: rootPath,
    productionSignatureIsValid: true,
  );
}

NativeArchiveClaim _productionClaim(String rootPath) {
  return NativeArchiveClaim(
    environment: ArchiveEnvironment.production,
    buildIdentity: ArchiveBuildIdentity.productionRelease,
    bundleIdentifier:
        ArchiveIdentityValidator.defaultProductionBundleIdentifier,
    productName: ArchiveIdentityValidator.defaultProductionProductName,
    canonicalRootPath: rootPath,
    productionSignatureIsValid: true,
  );
}
