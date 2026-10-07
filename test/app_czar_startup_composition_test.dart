import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_development_composition_policy.dart';
import 'package:remember_this_text/essentials/app_czar/presentation/app_czar_startup_harness.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/services/startup_flags_service.dart';
import 'package:remember_this_text/main.dart';

void main() {
  const policy = AppCzarDevelopmentCompositionPolicy();

  test('qualified WD development identity selects AppCzar only', () {
    var admissionReports = 0;

    final presentation = selectMessageLensStartupPresentation(
      appCzarDevelopmentCompositionEnabled: policy.admits(
        _developmentAuthority(),
      ),
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
}

ArchiveAccessAuthority _developmentAuthority({
  String rootPath =
      '/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development',
  String archiveInstanceId = 'e9310d3f-8dc8-4436-a48e-c4fb7cf8d4a5',
}) {
  return ArchiveAccessAuthority(
    identity: ResolvedArchiveIdentity(
      environment: ArchiveEnvironment.development,
      buildIdentity: ArchiveBuildIdentity.developmentDebug,
      archiveInstanceId: ArchiveInstanceId(archiveInstanceId),
      canonicalRootPath: rootPath,
      bundleIdentifier: 'com.bigbenchsoftware.MessageLens.development',
      productName: 'MessageLens Development',
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
