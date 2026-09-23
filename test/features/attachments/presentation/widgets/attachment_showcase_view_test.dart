import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/features/attachments/application/attachment_showcase.dart';
import 'package:remember_this_text/features/attachments/application/attachment_showcase_source_provider.dart';
import 'package:remember_this_text/features/attachments/presentation/widgets/attachment_showcase_view.dart';

void main() {
  testWidgets(
    'corrupt or deleted image path falls back without escaping error',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_app(container));
      container.read(attachmentShowcaseSourceProvider.notifier)
        ..begin()
        ..offer(
          const AttachmentShowcaseItem(
            resolvedPath: '/tmp/deleted-showcase-image.png',
            mediaKind: AttachmentShowcaseMediaKind.image,
            stablePresentationIdentity: 'corrupt',
          ),
        )
        ..stop();
      await tester.pump();
      final imageFinder = find.byKey(AttachmentShowcaseView.previewKey);
      final image = tester.widget<Image>(imageFinder);
      final fallback = image.errorBuilder!(
        tester.element(imageFinder),
        StateError('simulated decode failure'),
        StackTrace.current,
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: CupertinoApp(home: fallback),
        ),
      );

      expect(find.byKey(AttachmentShowcaseView.fallbackKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('unsupported media uses a bounded generic representation', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container));

    container.read(attachmentShowcaseSourceProvider.notifier)
      ..begin()
      ..offer(
        const AttachmentShowcaseItem(
          resolvedPath: '/tmp/example.bin',
          mediaKind: AttachmentShowcaseMediaKind.other,
          stablePresentationIdentity: 'other',
        ),
      )
      ..stop();
    await tester.pump();

    expect(find.text('Attachment added'), findsOneWidget);
    expect(
      tester
          .getSize(find.byKey(AttachmentShowcaseView.presentationAreaKey))
          .height,
      AttachmentShowcaseView.previewHeight,
    );
  });
}

Widget _app(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: const CupertinoApp(home: Center(child: AttachmentShowcaseView())),
  );
}
