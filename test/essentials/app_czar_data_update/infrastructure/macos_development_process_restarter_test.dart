import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/infrastructure/macos_development_process_restarter.dart';

void main() {
  test('derives the exact current application bundle', () {
    expect(
      macosApplicationBundlePathForExecutable(
        '/tmp/build/MessageLens Development.app/Contents/MacOS/MessageLens Development',
      ),
      '/tmp/build/MessageLens Development.app',
    );
    expect(
      () => macosApplicationBundlePathForExecutable('/tmp/MessageLens'),
      throwsStateError,
    );
  });

  test('launches a detached post-exit helper before terminating', () async {
    final events = <String>[];
    String? executable;
    List<String>? arguments;
    final restarter = MacosDevelopmentProcessRestarter(
      developmentExecutionEnabled: true,
      resolvedExecutablePath:
          '/tmp/build/MessageLens Development.app/Contents/MacOS/MessageLens Development',
      currentProcessId: 4242,
      isMacOS: true,
      launchDetached: (command, commandArguments) async {
        events.add('helper');
        executable = command;
        arguments = commandArguments;
      },
      terminateCurrentProcess: (exitCode) {
        events.add('exit:$exitCode');
      },
    );

    await restarter.restartAndReassess();

    expect(events, <String>['helper', 'exit:0']);
    expect(executable, '/bin/sh');
    expect(arguments, <String>[
      '-c',
      macosRelaunchAfterExitScript,
      'messagelens-restart',
      '4242',
      '/tmp/build/MessageLens Development.app',
    ]);
    expect(macosRelaunchAfterExitScript, contains('/bin/kill -0'));
    expect(macosRelaunchAfterExitScript, contains('/usr/bin/open -n'));
    expect(macosRelaunchAfterExitScript, isNot(contains('WD_ELEMENTS')));
    expect(
      macosRelaunchAfterExitScript,
      isNot(contains('MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT')),
    );
  });

  test('fails closed outside the exact development execution gate', () async {
    var launched = false;
    var terminated = false;
    final restarter = MacosDevelopmentProcessRestarter(
      developmentExecutionEnabled: false,
      resolvedExecutablePath:
          '/tmp/build/MessageLens.app/Contents/MacOS/MessageLens',
      currentProcessId: 10,
      isMacOS: true,
      launchDetached: (_, _) async {
        launched = true;
      },
      terminateCurrentProcess: (_) {
        terminated = true;
      },
    );

    await expectLater(restarter.restartAndReassess(), throwsStateError);
    expect(launched, isFalse);
    expect(terminated, isFalse);
  });

  test('fails closed outside macOS', () async {
    final restarter = MacosDevelopmentProcessRestarter(
      developmentExecutionEnabled: true,
      resolvedExecutablePath:
          '/tmp/build/MessageLens Development.app/Contents/MacOS/MessageLens Development',
      currentProcessId: 10,
      isMacOS: false,
      launchDetached: (_, _) async {},
      terminateCurrentProcess: (_) {},
    );

    await expectLater(restarter.restartAndReassess(), throwsStateError);
  });
}
