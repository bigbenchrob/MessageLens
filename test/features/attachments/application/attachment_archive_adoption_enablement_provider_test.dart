import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_adoption_enablement_provider.dart';

const _authorizedRoot =
    '/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development';
const _authorizedInstanceId = 'e9310d3f-8dc8-4436-a48e-c4fb7cf8d4a5';
const _productionRoot =
    '/Users/example/Library/Application Support/com.bigbenchsoftware.MessageLens';

void main() {
  for (final buildIdentity in <ArchiveBuildIdentity>[
    ArchiveBuildIdentity.developmentDebug,
    ArchiveBuildIdentity.developmentProfile,
    ArchiveBuildIdentity.developmentRelease,
  ]) {
    test('allows the exact ${buildIdentity.name} development identity', () {
      expect(_readGate(_authority(buildIdentity: buildIdentity)), isTrue);
    });
  }

  test('fails closed before archive admission', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(attachmentArchiveAdoptionExecutionEnabledProvider),
      isFalse,
    );
  });

  final mismatches = <String, ArchiveAccessAuthority>{
    'environment': _authority(environment: ArchiveEnvironment.production),
    'FDA build identity': _authority(
      buildIdentity: ArchiveBuildIdentity.fdaExperiment,
    ),
    'test build identity': _authority(
      buildIdentity: ArchiveBuildIdentity.testHarness,
    ),
    'production build identity': _authority(
      buildIdentity: ArchiveBuildIdentity.productionRelease,
    ),
    'bundle identifier': _authority(
      bundleIdentifier: 'com.bigbenchsoftware.MessageLens',
    ),
    'product name': _authority(productName: 'MessageLens'),
    'canonical root': _authority(canonicalRootPath: '$_authorizedRoot-other'),
    'archive instance': _authority(
      archiveInstanceId: 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    ),
  };

  for (final mismatch in mismatches.entries) {
    test('rejects a single ${mismatch.key} mismatch', () {
      expect(_readGate(mismatch.value), isFalse);
    });
  }

  test('rejects the complete production application identity', () {
    expect(
      _readGate(
        _authority(
          environment: ArchiveEnvironment.production,
          buildIdentity: ArchiveBuildIdentity.productionRelease,
          bundleIdentifier: 'com.bigbenchsoftware.MessageLens',
          productName: 'MessageLens',
          canonicalRootPath: _productionRoot,
        ),
      ),
      isFalse,
    );
  });

  test('rejects the complete FDA experiment application identity', () {
    expect(
      _readGate(
        _authority(
          buildIdentity: ArchiveBuildIdentity.fdaExperiment,
          bundleIdentifier: 'com.bigbenchsoftware.MessageLens.fdaexperiment',
          productName: 'MessageLens FDA Experiment',
        ),
      ),
      isFalse,
    );
  });

  test('rejects the complete test application identity', () {
    expect(
      _readGate(
        _authority(
          environment: ArchiveEnvironment.test,
          buildIdentity: ArchiveBuildIdentity.testHarness,
          bundleIdentifier: 'com.bigbenchsoftware.MessageLens.tests',
          productName: 'MessageLens Tests',
        ),
      ),
      isFalse,
    );
  });
}

bool _readGate(ArchiveAccessAuthority authority) {
  final container = ProviderContainer(
    overrides: [
      admittedArchiveAccessAuthorityProvider.overrideWithValue(authority),
    ],
  );
  addTearDown(container.dispose);
  return container.read(attachmentArchiveAdoptionExecutionEnabledProvider);
}

ArchiveAccessAuthority _authority({
  ArchiveEnvironment environment = ArchiveEnvironment.development,
  ArchiveBuildIdentity buildIdentity = ArchiveBuildIdentity.developmentDebug,
  String bundleIdentifier = 'com.bigbenchsoftware.MessageLens.development',
  String productName = 'MessageLens Development',
  String canonicalRootPath = _authorizedRoot,
  String archiveInstanceId = _authorizedInstanceId,
}) {
  return ArchiveAccessAuthority(
    identity: ResolvedArchiveIdentity(
      environment: environment,
      buildIdentity: buildIdentity,
      archiveInstanceId: ArchiveInstanceId(archiveInstanceId),
      canonicalRootPath: canonicalRootPath,
      bundleIdentifier: bundleIdentifier,
      productName: productName,
    ),
  );
}
