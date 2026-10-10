import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_production_composition_eligibility_policy.dart';
import 'package:remember_this_text/essentials/app_czar/application/production_app_czar_activation.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';

void main() {
  const policy = AppCzarProductionCompositionEligibilityPolicy();

  test('requires an already-admitted archive authority', () {
    expect(policy.isEligible(null), isFalse);
  });

  test('recognizes the exact official production identity', () {
    expect(policy.isEligible(_productionAuthority()), isTrue);
  });

  test(
    'recognized production authority follows successful signature proof',
    () {
      const validator = ArchiveIdentityValidator(
        rootPolicy: _ProductionRootPolicy(),
      );
      final identity = validator.validate(
        claim: _productionClaim(productionSignatureIsValid: true),
        marker: _productionMarker(),
      );

      expect(
        policy.isEligible(ArchiveAccessAuthority(identity: identity)),
        isTrue,
      );
    },
  );

  test('invalid signature cannot produce eligible admitted identity', () {
    const validator = ArchiveIdentityValidator(
      rootPolicy: _ProductionRootPolicy(),
    );

    expect(
      () => validator.validate(
        claim: _productionClaim(productionSignatureIsValid: false),
        marker: _productionMarker(),
      ),
      throwsA(
        isA<ArchiveAdmissionException>().having(
          (error) => error.failure,
          'failure',
          ArchiveAdmissionFailure.invalidProductionSignature,
        ),
      ),
    );
  });

  test('production root spelling does not select global composition', () {
    expect(
      policy.isEligible(
        _productionAuthority(rootPath: '/another/admitted/production/root'),
      ),
      isTrue,
    );
  });

  test('production archive UUID does not select global composition', () {
    expect(
      policy.isEligible(
        _productionAuthority(
          archiveInstanceId: 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
        ),
      ),
      isTrue,
    );
  });

  test('rejects a wrong production bundle identifier', () {
    expect(
      policy.isEligible(
        _productionAuthority(bundleIdentifier: 'example.wrong.production'),
      ),
      isFalse,
    );
  });

  test('rejects a wrong production product name', () {
    expect(
      policy.isEligible(
        _productionAuthority(productName: 'MessageLens Preview'),
      ),
      isFalse,
    );
  });

  test('rejects production build with development environment', () {
    expect(
      policy.isEligible(
        _productionAuthority(environment: ArchiveEnvironment.development),
      ),
      isFalse,
    );
  });

  test('rejects production environment with development debug build', () {
    expect(
      policy.isEligible(
        _productionAuthority(
          buildIdentity: ArchiveBuildIdentity.developmentDebug,
        ),
      ),
      isFalse,
    );
  });

  test('rejects production environment with development profile build', () {
    expect(
      policy.isEligible(
        _productionAuthority(
          buildIdentity: ArchiveBuildIdentity.developmentProfile,
        ),
      ),
      isFalse,
    );
  });

  test('rejects production environment with development release build', () {
    expect(
      policy.isEligible(
        _productionAuthority(
          buildIdentity: ArchiveBuildIdentity.developmentRelease,
        ),
      ),
      isFalse,
    );
  });

  test('rejects FDA experiment identity', () {
    expect(
      policy.isEligible(
        _productionAuthority(
          environment: ArchiveEnvironment.development,
          buildIdentity: ArchiveBuildIdentity.fdaExperiment,
          bundleIdentifier:
              ArchiveIdentityValidator.fdaExperimentBundleIdentifier,
          productName: ArchiveIdentityValidator.fdaExperimentProductName,
        ),
      ),
      isFalse,
    );
  });

  test('rejects test harness identity', () {
    expect(
      policy.isEligible(
        _productionAuthority(
          environment: ArchiveEnvironment.test,
          buildIdentity: ArchiveBuildIdentity.testHarness,
          bundleIdentifier: 'com.bigbenchsoftware.MessageLens.tests',
          productName: 'MessageLens Tests',
        ),
      ),
      isFalse,
    );
  });

  test('production activation has only the disabled product value', () {
    expect(ProductionAppCzarActivation.disabled.isEnabled, isFalse);
  });
}

ArchiveAccessAuthority _productionAuthority({
  ArchiveEnvironment environment = ArchiveEnvironment.production,
  ArchiveBuildIdentity buildIdentity = ArchiveBuildIdentity.productionRelease,
  String rootPath = '/an/admitted/production/root',
  String archiveInstanceId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  String bundleIdentifier =
      ArchiveIdentityValidator.defaultProductionBundleIdentifier,
  String productName = ArchiveIdentityValidator.defaultProductionProductName,
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

NativeArchiveClaim _productionClaim({
  required bool productionSignatureIsValid,
}) {
  return NativeArchiveClaim(
    environment: ArchiveEnvironment.production,
    buildIdentity: ArchiveBuildIdentity.productionRelease,
    bundleIdentifier:
        ArchiveIdentityValidator.defaultProductionBundleIdentifier,
    productName: ArchiveIdentityValidator.defaultProductionProductName,
    canonicalRootPath: '/an/admitted/production/root',
    productionSignatureIsValid: productionSignatureIsValid,
  );
}

ArchiveMarker _productionMarker() {
  return ArchiveMarker(
    formatVersion: ArchiveMarker.currentFormatVersion,
    environment: ArchiveEnvironment.production,
    archiveInstanceId: ArchiveInstanceId(
      'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    ),
    createdAtUtc: DateTime.utc(2026),
  );
}

final class _ProductionRootPolicy implements CanonicalArchiveRootPolicy {
  const _ProductionRootPolicy();

  @override
  bool isCanonicalRoot({
    required ArchiveEnvironment environment,
    required String rootPath,
  }) {
    return environment == ArchiveEnvironment.production &&
        rootPath == '/an/admitted/production/root';
  }

  @override
  bool isPlatformApplicationSupportPath(String rootPath) {
    return false;
  }
}
