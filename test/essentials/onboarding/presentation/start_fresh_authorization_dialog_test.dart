import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/onboarding/presentation/start_fresh_authorization_dialog.dart';

void main() {
  testWidgets('describes the preservation-safe Start Fresh boundary', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: StartFreshAuthorizationDialog()),
      ),
    );

    expect(find.text('Start with a clean MessageLens setup?'), findsOneWidget);
    expect(find.textContaining('rebuildable imported-message'), findsOneWidget);
    expect(find.textContaining('Apple Messages and Contacts'), findsOneWidget);
    expect(find.textContaining('archived attachment payloads'), findsOneWidget);
    expect(
      find.textContaining('Historical Archive source folders'),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Start Fresh'), findsOneWidget);
  });

  testWidgets('uses the caller-supplied onboarding canvas as its barrier', (
    tester,
  ) async {
    const barrierColor = Color(0xFFE7EAEC);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  showStartFreshAuthorizationDialog(
                    context,
                    barrierColor: barrierColor,
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final barriers = tester.widgetList<ModalBarrier>(find.byType(ModalBarrier));
    expect(barriers.any((barrier) => barrier.color == barrierColor), isTrue);
  });

  testWidgets('Start Fresh acknowledgement admits only one submission', (
    tester,
  ) async {
    var completionCount = 0;
    bool? accepted;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  accepted = await showStartFreshAuthorizationDialog(
                    context,
                    barrierColor: const Color(0xFFE7EAEC),
                  );
                  completionCount += 1;
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final submit = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Start Fresh'),
    );

    submit.onPressed!.call();
    submit.onPressed!.call();
    await tester.pump();

    expect(find.text('Starting…'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(accepted, isTrue);
    expect(completionCount, 1);
    expect(tester.takeException(), isNull);
  });
}
