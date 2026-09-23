import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/config/theme/colors/theme_colors.dart';
import 'package:remember_this_text/essentials/app_mode/application/app_mode_providers.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_build_identity.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_environment.dart';
import 'package:remember_this_text/essentials/onboarding/domain/message_lens_installation_state.dart';
import 'package:remember_this_text/essentials/onboarding/domain/startup_installation_validation.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/environment_summary/application/environment_summary_clipboard_writer.dart';
import 'package:remember_this_text/features/environment_summary/application/environment_summary_clipboard_writer_provider.dart';
import 'package:remember_this_text/features/environment_summary/application/environment_summary_provider.dart';
import 'package:remember_this_text/features/environment_summary/domain/entities/environment_summary.dart';
import 'package:remember_this_text/features/environment_summary/domain/services/environment_summary_formatter.dart';
import 'package:remember_this_text/features/environment_summary/presentation/view/environment_summary_panel.dart';

void main() {
  testWidgets('renders the stable section order and collapsed details', (
    tester,
  ) async {
    await _pumpPanel(tester, summary: _summary());

    final positions = <double>[
      tester
          .getTopLeft(
            find.byKey(EnvironmentSummaryPanel.installationSectionKey),
          )
          .dy,
      tester
          .getTopLeft(find.byKey(EnvironmentSummaryPanel.dataRootSectionKey))
          .dy,
      tester
          .getTopLeft(find.byKey(EnvironmentSummaryPanel.attachmentSectionKey))
          .dy,
      tester
          .getTopLeft(find.byKey(EnvironmentSummaryPanel.messageSectionKey))
          .dy,
      tester
          .getTopLeft(find.byKey(EnvironmentSummaryPanel.contactsSectionKey))
          .dy,
      tester
          .getTopLeft(find.byKey(EnvironmentSummaryPanel.technicalToggleKey))
          .dy,
    ];

    expect(positions, orderedEquals(positions.toList()..sort()));
    expect(
      tester
          .getBottomRight(
            find.byKey(EnvironmentSummaryPanel.attachmentSectionKey),
          )
          .dy,
      lessThanOrEqualTo(900),
    );
    expect(find.text('This installation'), findsOneWidget);
    expect(find.text('Data folder'), findsOneWidget);
    expect(find.text('Attachment archive'), findsOneWidget);
    expect(find.text('Message data'), findsOneWidget);
    expect(find.text('Contacts data'), findsOneWidget);
    expect(find.byKey(EnvironmentSummaryPanel.technicalBodyKey), findsNothing);
  });

  testWidgets(
    'keeps identity visible while independent sections load or fail',
    (tester) async {
      await _pumpPanel(
        tester,
        summary: _summary(
          packageStatus: EnvironmentSectionStatus.failed,
          attachmentStatus: EnvironmentSectionStatus.loading,
          attachmentPath: null,
          messageStatus: EnvironmentSectionStatus.loading,
          contactsStatus: EnvironmentSectionStatus.unavailable,
        ),
      );

      expect(find.text('MessageLens Development'), findsOneWidget);
      expect(find.text('Development'), findsWidgets);
      expect(find.text('Failed'), findsOneWidget);
      expect(find.text('Status not available yet'), findsWidgets);
      expect(find.text('Loading'), findsWidgets);
      expect(find.text('Unavailable'), findsWidgets);
    },
  );

  testWidgets('rebuilds sections independently without replacing the page', (
    tester,
  ) async {
    var summary = _summary(
      attachmentStatus: EnvironmentSectionStatus.loading,
      attachmentPath: null,
      messageStatus: EnvironmentSectionStatus.loading,
      contactsStatus: EnvironmentSectionStatus.loading,
    );
    final container = ProviderContainer(
      overrides: <Override>[
        platformBrightnessProvider.overrideWith((ref) => Brightness.light),
        environmentSummaryProvider.overrideWith((ref) => summary),
      ],
    );
    addTearDown(container.dispose);
    await tester.binding.setSurfaceSize(const Size(1100, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: EnvironmentSummaryPanel()),
        ),
      ),
    );

    expect(find.text('MessageLens Development'), findsOneWidget);
    expect(find.byKey(EnvironmentSummaryPanel.dataRootPathKey), findsOneWidget);
    expect(find.text('Status not available yet'), findsWidgets);

    summary = _summary(
      attachmentAvailability: EnvironmentAvailability.readOnly,
      attachmentWritable: false,
      contactsStatus: EnvironmentSectionStatus.unavailable,
    );
    container.invalidate(environmentSummaryProvider);
    await tester.pump();

    expect(find.text('MessageLens Development'), findsOneWidget);
    expect(find.text('Connected · Read-only'), findsOneWidget);
    expect(find.text('1,234'), findsWidgets);
    expect(find.text('Unavailable'), findsWidgets);
  });

  for (final attachmentCase in <_AttachmentCase>[
    const _AttachmentCase(
      EnvironmentAvailability.connected,
      'Connected · Read/write',
      writable: true,
    ),
    const _AttachmentCase(
      EnvironmentAvailability.readOnly,
      'Connected · Read-only',
    ),
    const _AttachmentCase(EnvironmentAvailability.disconnected, 'Disconnected'),
    const _AttachmentCase(
      EnvironmentAvailability.permissionRequired,
      'Permission required',
    ),
    const _AttachmentCase(EnvironmentAvailability.missing, 'Folder missing'),
    const _AttachmentCase(
      EnvironmentAvailability.invalid,
      'Attachment location invalid',
    ),
  ]) {
    testWidgets('renders attachment state ${attachmentCase.label}', (
      tester,
    ) async {
      await _pumpPanel(
        tester,
        summary: _summary(
          attachmentAvailability: attachmentCase.availability,
          attachmentWritable: attachmentCase.writable,
        ),
      );

      expect(find.text(attachmentCase.label), findsOneWidget);
    });
  }

  testWidgets('renders Message source truth and Contacts provenance', (
    tester,
  ) async {
    await _pumpPanel(tester, summary: _summary());

    expect(find.text('1,234'), findsNWidgets(6));
    expect(find.text('1,234 messages'), findsNWidgets(2));
    expect(find.text('Current Mac Messages'), findsWidgets);
    expect(find.text('Imported family archive'), findsOneWidget);
    expect(find.text('Historical Messages archive'), findsOneWidget);
    expect(find.text('Loading'), findsWidgets);
    expect(find.text('Current Mac Contacts'), findsOneWidget);
    expect(
      find.text(
        'MessageLens does not retain the physical Contacts database that '
        'contributed these records.',
      ),
      findsNothing,
    );
  });

  testWidgets('preserves authoritative zero without inventing source cards', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      summary: _summary(zeroCounts: true, includeSources: false),
    );

    expect(find.text('0'), findsNWidgets(6));
    expect(find.text('No contributing Message sources.'), findsOneWidget);
    expect(find.text('Current Mac Messages'), findsNothing);
  });

  testWidgets('does not invent a source row for an empty source model', (
    tester,
  ) async {
    await _pumpPanel(tester, summary: _summary(includeSources: false));

    expect(find.text('No contributing Message sources.'), findsOneWidget);
    expect(find.text('Current Mac Messages'), findsNothing);
  });

  testWidgets('keeps Unknown, Unavailable, and Not retained distinct', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      summary: _summary(
        dataRootAvailability: EnvironmentAvailability.unknown,
        messageStatus: EnvironmentSectionStatus.unavailable,
        contactsStatus: EnvironmentSectionStatus.notRetained,
      ),
    );

    expect(find.text('Unknown'), findsWidgets);
    expect(find.text('Unavailable'), findsWidgets);
    expect(find.text('Not retained'), findsWidgets);
  });

  testWidgets('production and development fixtures use the same page shape', (
    tester,
  ) async {
    const productionRoot =
        '/Users/test/Library/Application Support/com.bigbenchsoftware.MessageLens';
    await _pumpPanel(
      tester,
      summary: _summary(
        environment: ArchiveEnvironment.production,
        dataRootPath: productionRoot,
        attachmentPath: '$productionRoot/attachment_archive',
      ),
    );

    expect(find.text('MessageLens'), findsOneWidget);
    expect(find.text('Production'), findsOneWidget);
    expect(
      find.byKey(EnvironmentSummaryPanel.installationSectionKey),
      findsOneWidget,
    );
    expect(
      find.byKey(EnvironmentSummaryPanel.technicalToggleKey),
      findsOneWidget,
    );
    expect(find.text(productionRoot), findsOneWidget);
  });

  testWidgets('expands exact technical evidence and preserves long paths', (
    tester,
  ) async {
    const longRoot =
        '/Volumes/Development Drive/A deliberately very long MessageLens '
        'folder name/with/many/nested/components/MessageLens Development';
    const longAttachmentPath =
        '/Volumes/External Archive/A deliberately very long attachment '
        'archive/folder/name/with/many/nested/components/attachment_archive';
    await _pumpPanel(
      tester,
      summary: _summary(
        dataRootPath: longRoot,
        attachmentPath: longAttachmentPath,
      ),
    );

    final pathWidget = tester.widget<SelectableText>(
      find.byKey(EnvironmentSummaryPanel.dataRootPathKey),
    );
    expect(pathWidget.data, longRoot);
    expect(pathWidget.maxLines, isNull);
    final attachmentPathWidget = tester.widget<SelectableText>(
      find.byKey(EnvironmentSummaryPanel.attachmentPathKey),
    );
    expect(attachmentPathWidget.data, longAttachmentPath);
    expect(attachmentPathWidget.maxLines, isNull);

    await tester.ensureVisible(
      find.byKey(EnvironmentSummaryPanel.technicalToggleKey),
    );
    await tester.tap(find.byKey(EnvironmentSummaryPanel.technicalToggleKey));
    await tester.pump();

    expect(
      find.byKey(EnvironmentSummaryPanel.technicalBodyKey),
      findsOneWidget,
    );
    expect(
      find.text('com.bigbenchsoftware.MessageLens.development'),
      findsOneWidget,
    );
    expect(find.text('Present · Schema mismatch'), findsOneWidget);
    expect(find.text('7 / 8'), findsOneWidget);
    expect(find.text('Unavailable'), findsWidgets);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Contacts physical source identity'), findsOneWidget);
    expect(find.text('Not retained'), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    testWidgets('uses semantic canvas color in ${brightness.name} mode', (
      tester,
    ) async {
      final container = await _pumpPanel(
        tester,
        summary: _summary(),
        brightness: brightness,
      );
      final canvas = tester.widget<ColoredBox>(find.byType(ColoredBox).first);

      expect(
        canvas.color,
        container.read(themeColorsProvider.notifier).surfaces.canvas,
      );
    });
  }

  testWidgets('exposes headings, status, and disclosure semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpPanel(tester, summary: _summary());

    expect(find.bySemanticsLabel('Environment'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('.*Connected · Read/write.*')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Technical Details'), findsOneWidget);
    expect(find.bySemanticsLabel('Copy Environment Summary'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('copies exact formatter output only after explicit activation', (
    tester,
  ) async {
    final summary = _summary();
    final writer = _RecordingClipboardWriter();
    await _pumpPanel(tester, summary: summary, clipboardWriter: writer);

    expect(writer.writes, isEmpty);
    expect(find.byKey(EnvironmentSummaryPanel.copyButtonKey), findsOneWidget);
    expect(
      tester.widget(find.byKey(EnvironmentSummaryPanel.copyButtonKey)),
      isA<TextButton>(),
    );
    expect(
      tester.getSize(find.byKey(EnvironmentSummaryPanel.copyButtonKey)).width,
      lessThanOrEqualTo(280),
    );
    expect(find.text('Copy Environment Summary'), findsOneWidget);
    expect(find.textContaining('Copy path'), findsNothing);
    expect(find.textContaining('Reveal in Finder'), findsNothing);

    await tester.tap(find.byKey(EnvironmentSummaryPanel.copyButtonKey));
    await tester.pumpAndSettle();

    expect(writer.writes, <String>[
      const EnvironmentSummaryFormatter().format(summary),
    ]);
    expect(find.text('Environment summary copied.'), findsOneWidget);
  });

  testWidgets('supports keyboard copy and announces successful feedback', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final writer = _RecordingClipboardWriter();
    await _pumpPanel(tester, summary: _summary(), clipboardWriter: writer);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(writer.writes, hasLength(1));
    expect(
      find.bySemanticsLabel('Environment summary copied.'),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('wraps without clipping in a narrow scaled center panel', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      summary: _summary(),
      surfaceSize: const Size(460, 760),
      textScaler: const TextScaler.linear(1.5),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester
          .getBottomRight(find.byKey(EnvironmentSummaryPanel.copyButtonKey))
          .dx,
      lessThanOrEqualTo(460),
    );
    expect(find.text('This installation'), findsOneWidget);
  });

  testWidgets('copies partial summaries without fabricating unsettled values', (
    tester,
  ) async {
    final summary = _summary(
      packageStatus: EnvironmentSectionStatus.failed,
      dataRootAvailability: EnvironmentAvailability.unknown,
      attachmentStatus: EnvironmentSectionStatus.loading,
      attachmentPath: null,
      messageStatus: EnvironmentSectionStatus.unavailable,
      contactsStatus: EnvironmentSectionStatus.notRetained,
      includeSources: false,
    );
    final writer = _RecordingClipboardWriter();
    await _pumpPanel(tester, summary: summary, clipboardWriter: writer);

    await tester.tap(find.byKey(EnvironmentSummaryPanel.copyButtonKey));
    await tester.pumpAndSettle();

    final copied = writer.writes.single;
    expect(copied, contains('Version: Failed'));
    expect(copied, contains('Data folder\n  Status: Unknown'));
    expect(copied, contains('Attachment archive\n  Status: Loading'));
    expect(copied, contains('Messages in MessageLens: Unavailable'));
    expect(copied, contains('Message sources: Unavailable'));
    expect(copied, contains('Contacts in MessageLens: Not retained'));
    expect(copied, contains('FTS rows: Unavailable'));
    expect(copied, isNot(contains('/Volumes/Archive/messages/chat.db')));
  });

  testWidgets('shows bounded failure feedback when clipboard writing fails', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpPanel(
      tester,
      summary: _summary(),
      clipboardWriter: const _FailingClipboardWriter(),
    );

    await tester.tap(find.byKey(EnvironmentSummaryPanel.copyButtonKey));
    await tester.pumpAndSettle();

    expect(
      find.text('MessageLens could not copy the environment summary.'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        'MessageLens could not copy the environment summary.',
      ),
      findsOneWidget,
    );
    expect(find.text('Copy Environment Summary'), findsOneWidget);
    semantics.dispose();
  });
}

Future<ProviderContainer> _pumpPanel(
  WidgetTester tester, {
  required EnvironmentSummary summary,
  Brightness brightness = Brightness.light,
  EnvironmentSummaryClipboardWriter? clipboardWriter,
  Size surfaceSize = const Size(1100, 900),
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  final overrides = <Override>[
    platformBrightnessProvider.overrideWith((ref) => brightness),
    environmentSummaryProvider.overrideWith((ref) => summary),
  ];
  if (clipboardWriter != null) {
    overrides.add(
      environmentSummaryClipboardWriterProvider.overrideWith(
        (ref) => clipboardWriter,
      ),
    );
  }
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  await tester.binding.setSurfaceSize(surfaceSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: surfaceSize, textScaler: textScaler),
          child: const Scaffold(body: EnvironmentSummaryPanel()),
        ),
      ),
    ),
  );
  await tester.pump();
  return container;
}

EnvironmentSummary _summary({
  EnvironmentSectionStatus packageStatus = EnvironmentSectionStatus.ready,
  EnvironmentSectionStatus attachmentStatus = EnvironmentSectionStatus.ready,
  String? attachmentPath = '/Volumes/External Archive/attachment_archive',
  EnvironmentAvailability attachmentAvailability =
      EnvironmentAvailability.connected,
  EnvironmentAvailability dataRootAvailability =
      EnvironmentAvailability.connected,
  bool attachmentWritable = true,
  EnvironmentSectionStatus messageStatus = EnvironmentSectionStatus.ready,
  EnvironmentSectionStatus contactsStatus = EnvironmentSectionStatus.ready,
  bool includeSources = true,
  bool zeroCounts = false,
  String dataRootPath = '/Volumes/Development/MessageLens Development',
  ArchiveEnvironment environment = ArchiveEnvironment.development,
}) {
  final count = zeroCounts ? 0 : 1234;
  final production = environment == ArchiveEnvironment.production;
  return EnvironmentSummary(
    installation: EnvironmentInstallationSummary(
      productName: production ? 'MessageLens' : 'MessageLens Development',
      semanticVersion: packageStatus == EnvironmentSectionStatus.ready
          ? '0.2.125'
          : null,
      buildNumber: packageStatus == EnvironmentSectionStatus.ready
          ? '143'
          : null,
      environment: environment,
      buildIdentity: production
          ? ArchiveBuildIdentity.productionRelease
          : ArchiveBuildIdentity.developmentDebug,
      bundleIdentifier: production
          ? 'com.bigbenchsoftware.MessageLens'
          : 'com.bigbenchsoftware.MessageLens.development',
      archiveInstanceId: '22222222-2222-4222-8222-222222222222',
      runtimeMode: EnvironmentRuntimeMode.debug,
      packageStatus: packageStatus,
      issue: packageStatus == EnvironmentSectionStatus.failed
          ? 'Package metadata failed.'
          : null,
    ),
    dataRoot: EnvironmentDataRootSummary(
      canonicalPath: dataRootPath,
      displayVolumeName: 'Development',
      availability: dataRootAvailability,
      status: EnvironmentSectionStatus.ready,
    ),
    attachmentArchive: EnvironmentAttachmentArchiveSummary(
      status: attachmentStatus,
      canonicalPath: attachmentPath,
      displayPath: attachmentPath,
      volumeName: attachmentPath == null ? null : 'External Archive',
      availability: attachmentAvailability,
      configurationMode: AttachmentArchiveLocationMode.customExternal,
      customWritePolicy: AttachmentArchiveCustomWritePolicy.activeArchive,
      isReadable: attachmentAvailability == EnvironmentAvailability.connected,
      isPhysicallyWritable: attachmentWritable,
      locationGeneration: 4,
    ),
    messages: EnvironmentMessageDataSummary(
      status: messageStatus,
      projectedMessageCount: messageStatus == EnvironmentSectionStatus.ready
          ? count
          : null,
      conversationCount: messageStatus == EnvironmentSectionStatus.ready
          ? count
          : null,
      attachmentReferenceCount: messageStatus == EnvironmentSectionStatus.ready
          ? count
          : null,
      sources: includeSources
          ? <EnvironmentMessageSourceSummary>[
              EnvironmentMessageSourceSummary(
                sourceId: 1,
                sourceKey: 'current',
                kind: EnvironmentMessageSourceKind.currentMacMessages,
                displayLabel: 'Current Mac Messages',
                projectedMessageCount: count,
                dateRangeStatus: EnvironmentSectionStatus.ready,
                earliestMessageUtc: DateTime.utc(2020),
                latestMessageUtc: DateTime.utc(2026),
              ),
              EnvironmentMessageSourceSummary(
                sourceId: 2,
                sourceKey: 'historical',
                kind: EnvironmentMessageSourceKind.historicalMessagesArchive,
                displayLabel: 'Imported family archive',
                canonicalSourcePath: '/Volumes/Archive/messages/chat.db',
                projectedMessageCount: count,
                dateRangeStatus: EnvironmentSectionStatus.loading,
              ),
            ]
          : const <EnvironmentMessageSourceSummary>[],
    ),
    contacts: EnvironmentContactsDataSummary(
      status: contactsStatus,
      projectedContactCount: contactsStatus == EnvironmentSectionStatus.ready
          ? count
          : null,
      linkedHandleCount: contactsStatus == EnvironmentSectionStatus.ready
          ? count
          : null,
      importedChannelCount: contactsStatus == EnvironmentSectionStatus.ready
          ? count
          : null,
      physicalSourceIdentityRetained: false,
    ),
    technical: EnvironmentTechnicalSummary(
      status: EnvironmentSectionStatus.unavailable,
      databaseStatus: EnvironmentSectionStatus.ready,
      ftsStatus: EnvironmentSectionStatus.unavailable,
      startupAdmissionBasis: StartupAdmissionBasis.boundedInspection,
      installationState: MessageLensInstallationStateKind.completed,
      maintenanceActive: true,
      ftsAvailable: null,
      databases: const <EnvironmentDatabaseSummary>[
        EnvironmentDatabaseSummary(
          role: EnvironmentDatabaseRole.conversationGraph,
          path: '/Volumes/Development/MessageLens/conversation_graph.db',
          exists: true,
          readable: true,
          sizeBytes: 1024,
          userVersion: 7,
          expectedVersion: 8,
        ),
      ],
    ),
  );
}

final class _AttachmentCase {
  const _AttachmentCase(this.availability, this.label, {this.writable = false});

  final EnvironmentAvailability availability;
  final bool writable;
  final String label;
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
