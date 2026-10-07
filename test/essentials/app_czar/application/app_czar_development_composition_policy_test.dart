import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_development_composition_policy.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';

void main() {
  const policy = AppCzarDevelopmentCompositionPolicy();

  test('requires an already-admitted archive authority', () {
    expect(policy.admits(null), isFalse);
  });

  test('admits every recognized official development build identity', () {
    for (final buildIdentity in <ArchiveBuildIdentity>[
      ArchiveBuildIdentity.developmentDebug,
      ArchiveBuildIdentity.developmentProfile,
      ArchiveBuildIdentity.developmentRelease,
    ]) {
      expect(
        policy.admits(
          _authority(
            buildIdentity: buildIdentity,
            rootPath: '/private/tmp/disposable-${buildIdentity.name}',
            archiveInstanceId: '11111111-1111-4111-8111-111111111111',
          ),
        ),
        isTrue,
      );
    }
  });

  test('does not couple composition admission to the WD root or UUID', () {
    expect(policy.admits(_qualifiedWdAuthority()), isTrue);
    expect(
      policy.admits(
        _authority(
          rootPath: '/private/tmp/disposable-safe-empty',
          archiveInstanceId: '22222222-2222-4222-8222-222222222222',
        ),
      ),
      isTrue,
    );
  });

  test('rejects non-development and experiment build identities', () {
    expect(
      policy.admits(
        _authority(
          environment: ArchiveEnvironment.production,
          buildIdentity: ArchiveBuildIdentity.productionRelease,
          bundleIdentifier: 'com.bigbenchsoftware.MessageLens',
          productName: 'MessageLens',
        ),
      ),
      isFalse,
    );
    expect(
      policy.admits(
        _authority(buildIdentity: ArchiveBuildIdentity.fdaExperiment),
      ),
      isFalse,
    );
    expect(
      policy.admits(
        _authority(
          environment: ArchiveEnvironment.test,
          buildIdentity: ArchiveBuildIdentity.testHarness,
        ),
      ),
      isFalse,
    );
  });

  test('rejects a mismatched development application identity', () {
    expect(
      policy.admits(_authority(bundleIdentifier: 'example.wrong.bundle')),
      isFalse,
    );
    expect(policy.admits(_authority(productName: 'Wrong Product')), isFalse);
  });
}

ArchiveAccessAuthority _qualifiedWdAuthority() {
  return _authority(
    rootPath:
        '/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development',
    archiveInstanceId: 'e9310d3f-8dc8-4436-a48e-c4fb7cf8d4a5',
  );
}

ArchiveAccessAuthority _authority({
  ArchiveEnvironment environment = ArchiveEnvironment.development,
  ArchiveBuildIdentity buildIdentity = ArchiveBuildIdentity.developmentDebug,
  String rootPath = '/private/tmp/disposable-development-root',
  String archiveInstanceId = '11111111-1111-4111-8111-111111111111',
  String bundleIdentifier =
      AppCzarDevelopmentCompositionPolicy.developmentBundleIdentifier,
  String productName =
      AppCzarDevelopmentCompositionPolicy.developmentProductName,
}) {
  return ArchiveAccessAuthority(
    identity: ResolvedArchiveIdentity(
      environment: environment,
      buildIdentity: buildIdentity,
      archiveInstanceId: ArchiveInstanceId(archiveInstanceId),
      canonicalRootPath: rootPath,
      bundleIdentifier: bundleIdentifier,
      productName: productName,
    ),
  );
}
