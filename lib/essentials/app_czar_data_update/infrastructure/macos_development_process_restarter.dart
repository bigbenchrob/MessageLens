import 'dart:io';

import '../application/app_czar_process_restarter.dart';

typedef DetachedProcessLauncher =
    Future<void> Function(String executable, List<String> arguments);
typedef CurrentProcessTerminator = void Function(int exitCode);

const macosRelaunchAfterExitScript =
    r'while /bin/kill -0 "$1" 2>/dev/null; do /bin/sleep 0.1; done; '
    r'exec /usr/bin/open -n "$2"';

String macosApplicationBundlePathForExecutable(String executablePath) {
  const marker = '.app/Contents/MacOS/';
  final markerIndex = executablePath.lastIndexOf(marker);
  if (markerIndex < 0) {
    throw StateError(
      'Cannot derive the current macOS application bundle from '
      '$executablePath.',
    );
  }
  return executablePath.substring(0, markerIndex + '.app'.length);
}

final class MacosDevelopmentProcessRestarter
    implements AppCzarProcessRestarter {
  MacosDevelopmentProcessRestarter({
    required bool developmentExecutionEnabled,
    String? resolvedExecutablePath,
    int? currentProcessId,
    bool? isMacOS,
    DetachedProcessLauncher? launchDetached,
    CurrentProcessTerminator? terminateCurrentProcess,
  }) : _developmentExecutionEnabled = developmentExecutionEnabled,
       _resolvedExecutablePath =
           resolvedExecutablePath ?? Platform.resolvedExecutable,
       _currentProcessId = currentProcessId ?? pid,
       _isMacOS = isMacOS ?? Platform.isMacOS,
       _launchDetached = launchDetached ?? _launchDetachedProcess,
       _terminateCurrentProcess = terminateCurrentProcess ?? exit;

  final bool _developmentExecutionEnabled;
  final String _resolvedExecutablePath;
  final int _currentProcessId;
  final bool _isMacOS;
  final DetachedProcessLauncher _launchDetached;
  final CurrentProcessTerminator _terminateCurrentProcess;

  @override
  Future<void> restartAndReassess() async {
    if (!_developmentExecutionEnabled) {
      throw StateError(
        'AppCzar process restart is available only to the exact development installation.',
      );
    }
    if (!_isMacOS) {
      throw StateError('AppCzar process restart requires macOS.');
    }

    final bundlePath = macosApplicationBundlePathForExecutable(
      _resolvedExecutablePath,
    );
    await _launchDetached('/bin/sh', <String>[
      '-c',
      macosRelaunchAfterExitScript,
      'messagelens-restart',
      '$_currentProcessId',
      bundlePath,
    ]);
    _terminateCurrentProcess(0);
  }

  static Future<void> _launchDetachedProcess(
    String executable,
    List<String> arguments,
  ) async {
    await Process.start(executable, arguments, mode: ProcessStartMode.detached);
  }
}
