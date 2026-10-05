import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/application/app_czar_operating_currentness_controller.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/application/app_czar_operating_session_controller.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/domain/app_czar_operating_currentness_models.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/domain/app_czar_operating_session_state.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/presentation/app_czar_operating_currentness_status.dart';

void main() {
  testWidgets('status host starts currentness only after exact admission', (
    tester,
  ) async {
    var dormantCreations = 0;
    await tester.pumpWidget(
      _host(
        session: const AppCzarOperatingSessionState.dormant(),
        createCurrentness: () {
          dormantCreations++;
          return _RecordingCurrentnessController();
        },
      ),
    );
    await tester.pump();
    expect(dormantCreations, 0);

    final admittedCurrentness = _RecordingCurrentnessController();
    await tester.pumpWidget(
      _host(
        session: _admittedSession,
        createCurrentness: () => admittedCurrentness,
      ),
    );
    expect(admittedCurrentness.startCalls, 1);
    await tester.pump();
    expect(admittedCurrentness.startCalls, 1);
  });

  testWidgets('issue is painted before restart admission', (tester) async {
    final currentness = _RecordingCurrentnessController(issue: true);
    await tester.pumpWidget(
      _host(session: _admittedSession, createCurrentness: () => currentness),
    );

    expect(
      find.byKey(AppCzarOperatingCurrentnessStatusHost.issueKey),
      findsOneWidget,
    );
    expect(currentness.restartCalls, 0);

    await tester.pump();
    expect(
      find.byKey(AppCzarOperatingCurrentnessStatusHost.issueKey),
      findsOneWidget,
    );
    expect(currentness.restartCalls, 1);
  });
}

Widget _host({
  required AppCzarOperatingSessionState session,
  required AppCzarOperatingCurrentnessController Function() createCurrentness,
}) {
  return ProviderScope(
    key: ValueKey<AppCzarOperatingSessionPhase>(session.phase),
    overrides: <Override>[
      appCzarOperatingSessionControllerProvider.overrideWith(
        () => _FixedSessionController(session),
      ),
      appCzarOperatingCurrentnessControllerProvider(
        _occurrence,
      ).overrideWith(createCurrentness),
    ],
    child: const MacosApp(
      home: Stack(children: <Widget>[AppCzarOperatingCurrentnessStatusHost()]),
    ),
  );
}

final class _FixedSessionController extends AppCzarOperatingSessionController {
  _FixedSessionController(this.fixedState);

  final AppCzarOperatingSessionState fixedState;

  @override
  AppCzarOperatingSessionState build() => fixedState;
}

final class _RecordingCurrentnessController
    extends AppCzarOperatingCurrentnessController {
  _RecordingCurrentnessController({this.issue = false});

  final bool issue;
  int startCalls = 0;
  int restartCalls = 0;

  @override
  AppCzarOperatingCurrentnessState build(
    AppCzarOperatingSessionOccurrence occurrence,
  ) {
    if (!issue) {
      return AppCzarOperatingCurrentnessState.idle(occurrence);
    }
    return AppCzarOperatingCurrentnessState(
      occurrence: occurrence,
      phase: AppCzarOperatingCurrentnessPhase.issue,
      issueKind: AppCzarOperatingCurrentnessIssueKind.sourceUnknown,
      issue: 'Fresh source evidence was inconclusive.',
    );
  }

  @override
  void start() {
    startCalls++;
  }

  @override
  Future<void> restartAfterIssuePresented() async {
    restartCalls++;
  }
}

const _occurrence = AppCzarOperatingSessionOccurrence(
  processSequence: 88,
  assessmentGeneration: 14,
  admittedArchiveScopeIdentity: 'scope-14',
  admittedArchiveProbeGeneration: 3,
  admittedArchiveResolvedPath: '/test/archive',
);

const _admittedSession = AppCzarOperatingSessionState(
  phase: AppCzarOperatingSessionPhase.admitted,
  assessmentGeneration: 14,
  occurrence: _occurrence,
);
