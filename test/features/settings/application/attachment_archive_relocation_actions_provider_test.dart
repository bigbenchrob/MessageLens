import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/features/settings/application/attachment_archive_relocation_actions_provider.dart';

void main() {
  test('legacy Settings relocation action boundary is inert', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      attachmentArchiveRelocationActionsProvider.notifier,
    );

    expect(notifier, isA<AttachmentArchiveRelocationActions>());
  });
}
