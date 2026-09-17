import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/features/settings/application/attachment_archive_relocation_actions_provider.dart';

void main() {
  test(
    'relocation actions fail closed while execution gate is disabled',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await expectLater(
        container
            .read(attachmentArchiveRelocationActionsProvider.notifier)
            .chooseDestination(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('awaiting explicit authorization'),
          ),
        ),
      );
    },
  );
}
