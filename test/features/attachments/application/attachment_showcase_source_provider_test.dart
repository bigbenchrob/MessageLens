import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/features/attachments/application/attachment_showcase.dart';
import 'package:remember_this_text/features/attachments/application/attachment_showcase_source_provider.dart';

void main() {
  test(
    'rapid producers are synchronous and retain at most current plus latest',
    () {
      fakeAsync((async) {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final source = container.read(attachmentShowcaseSourceProvider.notifier)
          ..begin();

        for (var index = 0; index < 1000; index++) {
          source.offer(_item(index));
        }

        expect(
          container
              .read(attachmentShowcaseSourceProvider)
              ?.stablePresentationIdentity,
          'item-0',
        );
        expect(source.retainedItemCount, 2);
        async.elapse(AttachmentShowcaseSource.samplingCadence);
        expect(
          container
              .read(attachmentShowcaseSourceProvider)
              ?.stablePresentationIdentity,
          'item-999',
        );
        expect(source.retainedItemCount, 1);
      });
    },
  );

  test('stop drops pending operation progress and preserves last visual', () {
    fakeAsync((async) {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final source = container.read(attachmentShowcaseSourceProvider.notifier)
        ..begin()
        ..offer(_item(1))
        ..offer(_item(2))
        ..stop();

      async.elapse(AttachmentShowcaseSource.samplingCadence * 2);

      expect(
        container
            .read(attachmentShowcaseSourceProvider)
            ?.stablePresentationIdentity,
        'item-1',
      );
      expect(source.retainedItemCount, 1);
      source.offer(_item(3));
      expect(
        container
            .read(attachmentShowcaseSourceProvider)
            ?.stablePresentationIdentity,
        'item-1',
      );
    });
  });

  test('disposed consumer does not control or cancel the source', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(
      attachmentShowcaseSourceProvider,
      (previous, next) {},
    );
    final source = container.read(attachmentShowcaseSourceProvider.notifier)
      ..begin();
    subscription.close();

    source.offer(_item(4));

    expect(
      container
          .read(attachmentShowcaseSourceProvider)
          ?.stablePresentationIdentity,
      'item-4',
    );
  });
}

AttachmentShowcaseItem _item(int index) {
  return AttachmentShowcaseItem(
    resolvedPath: '/tmp/showcase-$index.jpg',
    mediaKind: AttachmentShowcaseMediaKind.image,
    stablePresentationIdentity: 'item-$index',
  );
}
