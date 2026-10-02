import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar/presentation/app_czar_startup_harness.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart';
import 'package:remember_this_text/essentials/services/startup_flags_service.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_adoption_enablement_provider.dart';
import 'package:remember_this_text/main.dart';

void main() {
  test('exact authorized development identity selects AppCzar only', () {
    final container = ProviderContainer(
      overrides: [
        admittedArchiveAccessAuthorityProvider.overrideWithValue(
          _developmentAuthority(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final presentation = selectMessageLensStartupPresentation(
      exactDevelopmentGateEnabled: container.read(
        attachmentArchiveAdoptionExecutionEnabledProvider,
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
    final container = ProviderContainer(
      overrides: [
        admittedArchiveAccessAuthorityProvider.overrideWithValue(
          _productionAuthority(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final presentation = selectMessageLensStartupPresentation(
      exactDevelopmentGateEnabled: container.read(
        attachmentArchiveAdoptionExecutionEnabledProvider,
      ),
    );
    final root = buildMessageLensStartupPresentation(
      presentation: presentation,
      startupFlags: const StartupFlags.disabled(),
    );

    expect(presentation, MessageLensStartupPresentation.legacyStartup);
    expect(root, isA<StartupApp>());
    expect(root, isNot(isA<AppCzarStartupHarness>()));
  });
}

ArchiveAccessAuthority _developmentAuthority() {
  return ArchiveAccessAuthority(
    identity: ResolvedArchiveIdentity(
      environment: ArchiveEnvironment.development,
      buildIdentity: ArchiveBuildIdentity.developmentDebug,
      archiveInstanceId: ArchiveInstanceId(
        'e9310d3f-8dc8-4436-a48e-c4fb7cf8d4a5',
      ),
      canonicalRootPath:
          '/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development',
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
