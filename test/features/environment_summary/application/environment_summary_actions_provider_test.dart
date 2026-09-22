import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_build_identity.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_environment.dart';
import 'package:remember_this_text/features/environment_summary/application/environment_summary_actions_provider.dart';
import 'package:remember_this_text/features/environment_summary/application/environment_summary_clipboard_writer.dart';
import 'package:remember_this_text/features/environment_summary/application/environment_summary_clipboard_writer_provider.dart';
import 'package:remember_this_text/features/environment_summary/domain/entities/environment_summary.dart';
import 'package:remember_this_text/features/environment_summary/domain/services/environment_summary_formatter.dart';

void main() {
  test('copies exactly one formatter result only when requested', () async {
    final writer = _RecordingClipboardWriter();
    final container = ProviderContainer(
      overrides: <Override>[
        environmentSummaryClipboardWriterProvider.overrideWith((ref) => writer),
      ],
    );
    addTearDown(container.dispose);
    final summary = _summary();

    expect(writer.writes, isEmpty);

    final result = await container
        .read(environmentSummaryActionsProvider.notifier)
        .copy(summary);

    expect(result, EnvironmentSummaryCopyResult.copied);
    expect(writer.writes, <String>[
      const EnvironmentSummaryFormatter().format(summary),
    ]);
  });

  test('reports clipboard failure without leaking the exception', () async {
    final container = ProviderContainer(
      overrides: <Override>[
        environmentSummaryClipboardWriterProvider.overrideWith(
          (ref) => const _FailingClipboardWriter(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container
        .read(environmentSummaryActionsProvider.notifier)
        .copy(_summary());

    expect(result, EnvironmentSummaryCopyResult.failed);
  });
}

EnvironmentSummary _summary() {
  return EnvironmentSummary(
    installation: const EnvironmentInstallationSummary(
      productName: 'MessageLens Development',
      semanticVersion: '0.2.126',
      buildNumber: '144',
      environment: ArchiveEnvironment.development,
      buildIdentity: ArchiveBuildIdentity.developmentDebug,
      bundleIdentifier: 'com.bigbenchsoftware.MessageLens.development',
      archiveInstanceId: '33333333-3333-4333-8333-333333333333',
      runtimeMode: EnvironmentRuntimeMode.debug,
      packageStatus: EnvironmentSectionStatus.ready,
    ),
    dataRoot: const EnvironmentDataRootSummary(
      canonicalPath: '/support',
      displayVolumeName: 'This Mac',
      availability: EnvironmentAvailability.connected,
      status: EnvironmentSectionStatus.ready,
    ),
    attachmentArchive: const EnvironmentAttachmentArchiveSummary(
      status: EnvironmentSectionStatus.unavailable,
      availability: EnvironmentAvailability.disconnected,
      isReadable: false,
      isPhysicallyWritable: false,
      locationGeneration: 0,
    ),
    messages: EnvironmentMessageDataSummary(
      status: EnvironmentSectionStatus.loading,
      sources: const <EnvironmentMessageSourceSummary>[],
    ),
    contacts: const EnvironmentContactsDataSummary(
      status: EnvironmentSectionStatus.notRetained,
      physicalSourceIdentityRetained: false,
    ),
    technical: EnvironmentTechnicalSummary(
      status: EnvironmentSectionStatus.loading,
      databaseStatus: EnvironmentSectionStatus.loading,
      ftsStatus: EnvironmentSectionStatus.loading,
      databases: const <EnvironmentDatabaseSummary>[],
    ),
  );
}

final class _RecordingClipboardWriter
    implements EnvironmentSummaryClipboardWriter {
  final List<String> writes = <String>[];

  @override
  Future<void> writeText(String text) async {
    writes.add(text);
  }
}

final class _FailingClipboardWriter
    implements EnvironmentSummaryClipboardWriter {
  const _FailingClipboardWriter();

  @override
  Future<void> writeText(String text) async {
    throw StateError('Clipboard unavailable.');
  }
}
