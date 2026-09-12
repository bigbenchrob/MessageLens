import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart'
    show admittedArchiveAccessAuthorityProvider;
import 'package:remember_this_text/essentials/onboarding/application/message_lens_installation_state_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/message_lens_installation_state.dart';
import 'package:remember_this_text/essentials/onboarding/domain/startup_installation_validation.dart';

import '../../../test_support/test_archive_fixture.dart';

void main() {
  test(
    'provider classifies a pristine archive without creating persistence',
    () async {
      final fixture = await TestArchiveFixture.create(
        prefix: 'installation_state_provider_pristine_',
      );
      addTearDown(fixture.dispose);
      final container = ProviderContainer(
        overrides: <Override>[
          admittedArchiveAccessAuthorityProvider.overrideWith(
            (ref) => fixture.authority,
          ),
        ],
      );
      addTearDown(container.dispose);
      final before = _relativeArchiveEntries(fixture.root);

      final terminal = Completer<StartupAdmissionGranted>();
      final subscription = container.listen(
        messageLensInstallationStateProvider,
        (_, next) {
          final state = next.valueOrNull;
          if (state is StartupAdmissionGranted && !terminal.isCompleted) {
            terminal.complete(state);
          }
        },
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final state = (await terminal.future).installationState;

      expect(state.kind, MessageLensInstallationStateKind.virgin);
      expect(_relativeArchiveEntries(fixture.root), before);
    },
  );
}

Set<String> _relativeArchiveEntries(Directory root) {
  return root
      .listSync(recursive: true)
      .map((entry) => entry.path.substring(root.path.length + 1))
      .toSet();
}
