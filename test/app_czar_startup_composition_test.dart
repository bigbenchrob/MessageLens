import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_development_composition_policy.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_production_composition_eligibility_policy.dart';
import 'package:remember_this_text/essentials/app_czar/application/production_app_czar_activation.dart';
import 'package:remember_this_text/essentials/app_czar/presentation/app_czar_startup_harness.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/services/startup_flags_service.dart';
import 'package:remember_this_text/main.dart';

void main() {
  const policy = AppCzarDevelopmentCompositionPolicy();
  const productionPolicy = AppCzarProductionCompositionEligibilityPolicy();

  test('qualified WD development identity selects AppCzar only', () {
    var admissionReports = 0;

    final presentation = selectMessageLensStartupPresentation(
      appCzarDevelopmentCompositionEnabled: policy.admits(
        _developmentAuthority(),
      ),
      appCzarProductionCompositionEligible: false,
      productionAppCzarActivation: ProductionAppCzarActivation.disabled,
    );
    final root = buildMessageLensStartupPresentation(
      presentation: presentation,
      startupFlags: const StartupFlags.disabled(),
      onAppCzarOperatingAdmitted: () {
        admissionReports += 1;
      },
    );

    expect(presentation, MessageLensStartupPresentation.appCzarHarness);
    expect(root, isA<AppCzarStartupHarness>());
    expect(root, isNot(isA<StartupApp>()));
    final harness = root as AppCzarStartupHarness;
    expect(harness.onOperatingAdmitted, isNotNull);
    expect(admissionReports, 0);
    harness.onOperatingAdmitted!();
    expect(admissionReports, 1);
  });

  test('admitted disposable development root selects AppCzar only', () {
    final presentation = selectMessageLensStartupPresentation(
      appCzarDevelopmentCompositionEnabled: policy.admits(
        _developmentAuthority(
          rootPath: '/private/tmp/disposable-safe-empty',
          archiveInstanceId: '22222222-2222-4222-8222-222222222222',
        ),
      ),
      appCzarProductionCompositionEligible: false,
      productionAppCzarActivation: ProductionAppCzarActivation.disabled,
    );
    final root = buildMessageLensStartupPresentation(
      presentation: presentation,
      startupFlags: const StartupFlags.disabled(),
    );

    expect(presentation, MessageLensStartupPresentation.appCzarHarness);
    expect(root, isA<AppCzarStartupHarness>());
    expect(root, isNot(isA<StartupApp>()));
  });

  test('production identity preserves the legacy StartupApp root', () {
    final presentation = selectMessageLensStartupPresentation(
      appCzarDevelopmentCompositionEnabled: policy.admits(
        _productionAuthority(),
      ),
      appCzarProductionCompositionEligible: productionPolicy.isEligible(
        _productionAuthority(),
      ),
      productionAppCzarActivation: ProductionAppCzarActivation.disabled,
    );
    final root = buildMessageLensStartupPresentation(
      presentation: presentation,
      startupFlags: const StartupFlags.disabled(),
    );

    expect(presentation, MessageLensStartupPresentation.legacyStartup);
    expect(root, isA<StartupApp>());
    expect(root, isNot(isA<AppCzarStartupHarness>()));
    expect((root as StartupApp).admittedChild, isA<App>());
  });

  test('absent composition eligibility preserves the legacy route', () {
    final presentation = selectMessageLensStartupPresentation(
      appCzarDevelopmentCompositionEnabled: false,
      appCzarProductionCompositionEligible: false,
      productionAppCzarActivation: ProductionAppCzarActivation.disabled,
    );

    expect(presentation, MessageLensStartupPresentation.legacyStartup);
  });

  test('all official development build modes preserve AppCzar selection', () {
    for (final buildIdentity in <ArchiveBuildIdentity>[
      ArchiveBuildIdentity.developmentDebug,
      ArchiveBuildIdentity.developmentProfile,
      ArchiveBuildIdentity.developmentRelease,
    ]) {
      final presentation = selectMessageLensStartupPresentation(
        appCzarDevelopmentCompositionEnabled: policy.admits(
          _developmentAuthority(buildIdentity: buildIdentity),
        ),
        appCzarProductionCompositionEligible: false,
        productionAppCzarActivation: ProductionAppCzarActivation.disabled,
      );

      expect(
        presentation,
        MessageLensStartupPresentation.appCzarHarness,
        reason: buildIdentity.name,
      );
    }
  });

  test('unrecognized development identity preserves the legacy route', () {
    final presentation = selectMessageLensStartupPresentation(
      appCzarDevelopmentCompositionEnabled: policy.admits(
        _developmentAuthority(productName: 'Wrong Product'),
      ),
      appCzarProductionCompositionEligible: false,
      productionAppCzarActivation: ProductionAppCzarActivation.disabled,
    );

    expect(presentation, MessageLensStartupPresentation.legacyStartup);
  });

  test('hypothetical production truth table remains a test-only model', () {
    bool hypotheticalSelection({
      required bool eligible,
      required bool activationEnabled,
    }) {
      return eligible && activationEnabled;
    }

    expect(
      hypotheticalSelection(eligible: false, activationEnabled: false),
      isFalse,
    );
    expect(
      hypotheticalSelection(eligible: true, activationEnabled: false),
      isFalse,
    );
    expect(
      hypotheticalSelection(eligible: false, activationEnabled: true),
      isFalse,
    );
    expect(
      hypotheticalSelection(eligible: true, activationEnabled: true),
      isTrue,
    );
    expect(ProductionAppCzarActivation.disabled.isEnabled, isFalse);
  });
}

ArchiveAccessAuthority _developmentAuthority({
  String rootPath =
      '/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development',
  String archiveInstanceId = 'e9310d3f-8dc8-4436-a48e-c4fb7cf8d4a5',
  ArchiveBuildIdentity buildIdentity = ArchiveBuildIdentity.developmentDebug,
  String productName = 'MessageLens Development',
}) {
  return ArchiveAccessAuthority(
    identity: ResolvedArchiveIdentity(
      environment: ArchiveEnvironment.development,
      buildIdentity: buildIdentity,
      archiveInstanceId: ArchiveInstanceId(archiveInstanceId),
      canonicalRootPath: rootPath,
      bundleIdentifier: 'com.bigbenchsoftware.MessageLens.development',
      productName: productName,
    ),
  );
}

ArchiveAccessAuthority _productionAuthority() {
  return ArchiveAccessAuthority(
    identity: ResolvedArchiveIdentity(
      environment: ArchiveEnvironment.production,
      buildIdentity: ArchiveBuildIdentity.productionRelease,
      archiveInstanceId: ArchiveInstanceId(
        'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      ),
      canonicalRootPath:
          '/Users/example/Library/Application Support/com.bigbenchsoftware.MessageLens',
      bundleIdentifier: 'com.bigbenchsoftware.MessageLens',
      productName: 'MessageLens',
    ),
  );
}
