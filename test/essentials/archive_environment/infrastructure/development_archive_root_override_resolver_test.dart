import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/infrastructure/development_archive_root_override_resolver.dart';

void main() {
  const resolver = DevelopmentArchiveRootOverrideResolver();
  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory(
      '/private/tmp',
    ).createTemp('messagelens development root ');
  });

  tearDown(() async {
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('keeps the default development root without an override', () {
    final root = resolver.resolveExpectedRoot(
      environment: ArchiveEnvironment.development,
      defaultRootPath: '/default/development',
      processEnvironment: const <String, String>{},
    );

    expect(root, '/default/development');
  });

  test('rejects a missing override when the build requires one', () {
    expect(
      () => resolver.resolveExpectedRoot(
        environment: ArchiveEnvironment.development,
        defaultRootPath: '/default/development',
        requireConfiguredOverride: true,
        processEnvironment: const <String, String>{},
      ),
      throwsA(
        isA<ArchiveAdmissionException>().having(
          (error) => error.failure,
          'failure',
          ArchiveAdmissionFailure.unavailableDevelopmentRootOverride,
        ),
      ),
    );
  });

  test('resolves an available development override canonically', () {
    final root = resolver.resolveExpectedRoot(
      environment: ArchiveEnvironment.development,
      defaultRootPath: '/default/development',
      processEnvironment: <String, String>{
        DevelopmentArchiveRootOverrideResolver
                .defaultDevelopmentArchiveRootEnvironmentVariable:
            temporaryDirectory.path,
      },
    );

    expect(root, temporaryDirectory.resolveSymbolicLinksSync());
  });

  test('canonicalizes equivalent existing path vectors identically', () {
    final nestedDirectory = Directory('${temporaryDirectory.path}/nested')
      ..createSync();
    final symlink = Link('${temporaryDirectory.path}/nested-link')
      ..createSync(nestedDirectory.path);
    final canonicalRoot = nestedDirectory.resolveSymbolicLinksSync();
    final tmpAlias = canonicalRoot.replaceFirst('/private/tmp/', '/tmp/');
    final vectors = <String>[
      canonicalRoot,
      '$canonicalRoot/',
      '${temporaryDirectory.path}/./nested',
      '${nestedDirectory.path}/../nested',
      tmpAlias,
      symlink.path,
    ];

    for (final vector in vectors) {
      final result = resolver.resolveExpectedRoot(
        environment: ArchiveEnvironment.development,
        defaultRootPath: '/default/development',
        processEnvironment: <String, String>{
          DevelopmentArchiveRootOverrideResolver
                  .defaultDevelopmentArchiveRootEnvironmentVariable:
              vector,
        },
      );

      expect(result, canonicalRoot, reason: 'vector: $vector');
    }
  });

  test('treats an empty override as absent', () {
    final root = resolver.resolveExpectedRoot(
      environment: ArchiveEnvironment.development,
      defaultRootPath: '/default/development',
      processEnvironment: const <String, String>{
        DevelopmentArchiveRootOverrideResolver
                .defaultDevelopmentArchiveRootEnvironmentVariable:
            '  \n ',
      },
    );

    expect(root, '/default/development');
  });

  test('rejects a missing configured development root', () {
    final missingRoot = '${temporaryDirectory.path}/missing';

    expect(
      () => resolver.resolveExpectedRoot(
        environment: ArchiveEnvironment.development,
        defaultRootPath: '/default/development',
        processEnvironment: <String, String>{
          DevelopmentArchiveRootOverrideResolver
                  .defaultDevelopmentArchiveRootEnvironmentVariable:
              missingRoot,
        },
      ),
      throwsA(
        isA<ArchiveAdmissionException>().having(
          (error) => error.failure,
          'failure',
          ArchiveAdmissionFailure.unavailableDevelopmentRootOverride,
        ),
      ),
    );
  });

  test('rejects a relative development override', () {
    expect(
      () => resolver.resolveExpectedRoot(
        environment: ArchiveEnvironment.development,
        defaultRootPath: '/default/development',
        processEnvironment: const <String, String>{
          DevelopmentArchiveRootOverrideResolver
                  .defaultDevelopmentArchiveRootEnvironmentVariable:
              'relative/archive',
        },
      ),
      throwsA(
        isA<ArchiveAdmissionException>().having(
          (error) => error.failure,
          'failure',
          ArchiveAdmissionFailure.invalidDevelopmentRootOverride,
        ),
      ),
    );
  });

  test('rejects an existing regular file as the override root', () {
    final file = File('${temporaryDirectory.path}/not-a-directory')
      ..writeAsStringSync('not a root');

    expect(
      () => resolver.resolveExpectedRoot(
        environment: ArchiveEnvironment.development,
        defaultRootPath: '/default/development',
        processEnvironment: <String, String>{
          DevelopmentArchiveRootOverrideResolver
                  .defaultDevelopmentArchiveRootEnvironmentVariable:
              file.path,
        },
      ),
      throwsA(
        isA<ArchiveAdmissionException>().having(
          (error) => error.failure,
          'failure',
          ArchiveAdmissionFailure.unavailableDevelopmentRootOverride,
        ),
      ),
    );
  });

  test('rejects the development override for production', () {
    expect(
      () => resolver.resolveExpectedRoot(
        environment: ArchiveEnvironment.production,
        defaultRootPath: '/default/production',
        processEnvironment: <String, String>{
          DevelopmentArchiveRootOverrideResolver
                  .defaultDevelopmentArchiveRootEnvironmentVariable:
              temporaryDirectory.path,
        },
      ),
      throwsA(
        isA<ArchiveAdmissionException>().having(
          (error) => error.failure,
          'failure',
          ArchiveAdmissionFailure.developmentRootOverrideNotPermitted,
        ),
      ),
    );
  });
}
