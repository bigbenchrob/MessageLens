import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/config/theme/colors/theme_colors.dart';
import 'package:remember_this_text/essentials/onboarding/application/advanced_start_fresh_action.dart';
import 'package:remember_this_text/essentials/onboarding/application/advanced_start_fresh_action_provider.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/widget_builders/settings_action_list.dart';

void main() {
  testWidgets('destructive action shows idle hover and pressed feedback', (
    tester,
  ) async {
    final action = _ControlledAdvancedStartFreshAction();
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          advancedStartFreshActionProvider.overrideWith((ref) => action),
        ],
        child: Builder(
          builder: (context) {
            container = ProviderScope.containerOf(context);
            return const MaterialApp(
              home: Scaffold(body: _ResetSettingsAction()),
            );
          },
        ),
      ),
    );

    final colors = container.read(themeColorsProvider.notifier);
    final surface = find.byKey(
      const ValueKey<String>(
        'settings-action-surface-ResetMessageDataRequested',
      ),
    );
    final semantics = find.byKey(
      const ValueKey<String>(
        'settings-action-semantics-ResetMessageDataRequested',
      ),
    );
    expect(
      _surfaceColor(tester, surface),
      colors.surfaces.canvas.withValues(alpha: 0),
    );
    expect(tester.getSemantics(semantics).flagsCollection.isEnabled, isTrue);

    final mouseRegion = tester.widget<MouseRegion>(
      find.ancestor(of: surface, matching: find.byType(MouseRegion)),
    );
    mouseRegion.onEnter!.call(const PointerEnterEvent());
    await tester.pump();
    expect(_surfaceColor(tester, surface), colors.surfaces.hover);

    final gestureDetector = tester.widget<GestureDetector>(
      find.ancestor(of: surface, matching: find.byType(GestureDetector)),
    );
    gestureDetector.onTapDown!.call(
      TapDownDetails(globalPosition: tester.getCenter(surface)),
    );
    await tester.pump();
    expect(_surfaceColor(tester, surface), colors.surfaces.pressed);

    gestureDetector.onTapUp!.call(
      TapUpDetails(
        kind: PointerDeviceKind.mouse,
        globalPosition: tester.getCenter(surface),
      ),
    );
    await tester.pump();
    expect(_surfaceColor(tester, surface), colors.surfaces.hover);
  });

  testWidgets(
    'slow classification immediately shows checking and disables redispatch',
    (tester) async {
      final action = _ControlledAdvancedStartFreshAction();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            advancedStartFreshActionProvider.overrideWith((ref) => action),
          ],
          child: const MaterialApp(
            home: Scaffold(body: _ResetSettingsAction()),
          ),
        ),
      );

      await tester.tap(find.text('Reset message data…'));
      await tester.pump();

      expect(action.requestCount, 1);
      expect(find.text('Checking reset availability…'), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      final semantics = find.byKey(
        const ValueKey<String>(
          'settings-action-semantics-ResetMessageDataRequested',
        ),
      );
      expect(tester.getSemantics(semantics).flagsCollection.isEnabled, isFalse);

      await tester.tap(find.text('Checking reset availability…'));
      await tester.pump();
      expect(action.requestCount, 1);

      action.completion.complete(AdvancedStartFreshActionResult.cancelled);
      await tester.pump();
      await tester.pump();

      expect(find.text('Reset message data…'), findsOneWidget);
      expect(find.text('Checking reset availability…'), findsNothing);
    },
  );
}

Color _surfaceColor(WidgetTester tester, Finder surface) {
  final decoratedBox = tester.widget<DecoratedBox>(surface);
  return (decoratedBox.decoration as BoxDecoration).color!;
}

final class _ControlledAdvancedStartFreshAction
    implements AdvancedStartFreshAction {
  final completion = Completer<AdvancedStartFreshActionResult>();
  int requestCount = 0;

  @override
  Future<AdvancedStartFreshActionResult> request() {
    requestCount += 1;
    return completion.future;
  }

  @override
  Future<AdvancedStartFreshActionResult> retry({required int occurrence}) {
    throw UnsupportedError('Retry is outside this interaction fixture.');
  }

  @override
  void dismissFailure({required int occurrence}) {}
}

final class _ResetSettingsAction extends StatelessWidget {
  const _ResetSettingsAction();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 320,
      child: SettingsActionList(
        actions: [
          SidebarActionDescriptor(
            label: 'Reset message data…',
            intent: ResetMessageDataRequested(),
            tone: SidebarActionTone.destructive,
          ),
        ],
        cassetteIndex: 1,
      ),
    );
  }
}
