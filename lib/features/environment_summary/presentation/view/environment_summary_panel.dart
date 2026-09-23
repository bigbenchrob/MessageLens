import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../core/util/count_label_formatter.dart';
import '../../../../core/util/date_label_formatter.dart';
import '../../../../essentials/navigation/feature_level_providers.dart'
    show CenterPanelReportLayout, PanelSection, PanelSectionLayoutStyle;
import '../../application/environment_summary_actions_provider.dart';
import '../../application/environment_summary_provider.dart';
import '../../domain/entities/environment_summary.dart';

class EnvironmentSummaryPanel extends ConsumerStatefulWidget {
  const EnvironmentSummaryPanel({super.key});

  static const installationSectionKey = Key('environment-summary-installation');
  static const dataRootSectionKey = Key('environment-summary-data-root');
  static const attachmentSectionKey = Key(
    'environment-summary-attachment-archive',
  );
  static const messageSectionKey = Key('environment-summary-message-data');
  static const contactsSectionKey = Key('environment-summary-contacts-data');
  static const technicalToggleKey = Key('environment-summary-technical-toggle');
  static const technicalBodyKey = Key('environment-summary-technical-body');
  static const dataRootPathKey = Key('environment-summary-data-root-path');
  static const attachmentPathKey = Key('environment-summary-attachment-path');
  static const copyButtonKey = Key('environment-summary-copy-button');

  @override
  ConsumerState<EnvironmentSummaryPanel> createState() =>
      _EnvironmentSummaryPanelState();
}

class _EnvironmentSummaryPanelState
    extends ConsumerState<EnvironmentSummaryPanel> {
  bool _technicalDetailsExpanded = false;
  bool _copyInProgress = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final summary = ref.watch(environmentSummaryProvider);

    return ColoredBox(
      color: colors.surfaces.canvas,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl + AppSpacing.sm,
          vertical: AppSpacing.xl,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        'Environment',
                        style: typography.title1.copyWith(
                          color: colors.content.textPrimary,
                        ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: TextButton.icon(
                        key: EnvironmentSummaryPanel.copyButtonKey,
                        onPressed: _copyInProgress
                            ? null
                            : () async {
                                await _copyEnvironmentSummary(summary);
                              },
                        icon: const Icon(Icons.copy_outlined, size: 16),
                        label: Text(
                          _copyInProgress
                              ? 'Copying…'
                              : 'Copy Environment Summary',
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.sm,
                          ),
                          foregroundColor: colors.content.textSecondary,
                          textStyle: typography.controlValue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'See which MessageLens installation is running, where its '
                  'data lives, and which sources currently contribute to it.',
                  style: typography.body.copyWith(
                    color: colors.content.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                CenterPanelReportLayout<_EnvironmentPanelSection>(
                  sections: [
                    for (final section in _EnvironmentPanelSection.values)
                      PanelSection<_EnvironmentPanelSection>(
                        layoutStyle: PanelSectionLayoutStyle.fullWidth,
                        children: [section],
                      ),
                  ],
                  childBuilder: (_, __, section) {
                    return switch (section) {
                      _EnvironmentPanelSection.installation =>
                        _InstallationSection(summary: summary),
                      _EnvironmentPanelSection.dataRoot => _DataRootSection(
                        summary: summary.dataRoot,
                      ),
                      _EnvironmentPanelSection.attachmentArchive =>
                        _AttachmentArchiveSection(
                          summary: summary.attachmentArchive,
                        ),
                      _EnvironmentPanelSection.messageData =>
                        _MessageDataSection(summary: summary.messages),
                      _EnvironmentPanelSection.contactsData =>
                        _ContactsDataSection(summary: summary.contacts),
                      _EnvironmentPanelSection.technicalDetails =>
                        _TechnicalDetailsDisclosure(
                          summary: summary,
                          expanded: _technicalDetailsExpanded,
                          onToggle: () {
                            setState(() {
                              _technicalDetailsExpanded =
                                  !_technicalDetailsExpanded;
                            });
                          },
                        ),
                    };
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _copyEnvironmentSummary(EnvironmentSummary summary) async {
    setState(() {
      _copyInProgress = true;
    });
    final result = await ref
        .read(environmentSummaryActionsProvider.notifier)
        .copy(summary);
    if (!mounted) {
      return;
    }
    setState(() {
      _copyInProgress = false;
    });

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            result == EnvironmentSummaryCopyResult.copied
                ? 'Environment summary copied.'
                : 'MessageLens could not copy the environment summary.',
          ),
        ),
      );
  }
}

enum _EnvironmentPanelSection {
  installation,
  dataRoot,
  attachmentArchive,
  messageData,
  contactsData,
  technicalDetails,
}

class _InstallationSection extends ConsumerWidget {
  const _InstallationSection({required this.summary});

  final EnvironmentSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installation = summary.installation;
    final version = _versionLabel(installation);
    final environment = _humanizeName(installation.environment.name);

    return _EnvironmentCard(
      key: EnvironmentSummaryPanel.installationSectionKey,
      heading: 'This installation',
      semanticLabel: 'This installation, $environment',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            installation.productName,
            style: _typography(
              ref,
            ).title2.copyWith(color: _colors(ref).content.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          _LabelValueLine(label: 'Version', value: version),
          const SizedBox(height: AppSpacing.sm),
          _LabelValueLine(label: 'Environment', value: environment),
        ],
      ),
    );
  }
}

class _DataRootSection extends ConsumerWidget {
  const _DataRootSection({required this.summary});

  final EnvironmentDataRootSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presentation = _sectionAvailabilityPresentation(
      status: summary.status,
      availability: summary.availability,
      colors: _colors(ref),
    );

    return _EnvironmentCard(
      key: EnvironmentSummaryPanel.dataRootSectionKey,
      heading: 'Data folder',
      semanticLabel:
          'Data folder, ${summary.displayVolumeName}, ${presentation.label}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LocationHeadline(
            name: summary.displayVolumeName,
            presentation: presentation,
          ),
          const SizedBox(height: AppSpacing.md),
          const _PathLabel(),
          const SizedBox(height: AppSpacing.xs),
          SelectableText(
            summary.canonicalPath,
            key: EnvironmentSummaryPanel.dataRootPathKey,
            style: _typography(ref).caption1.copyWith(
              color: _colors(ref).content.textPrimary,
              height: 1.4,
            ),
          ),
          if (summary.issue case final issue?) ...[
            const SizedBox(height: AppSpacing.sm),
            _IssueText(issue),
          ],
        ],
      ),
    );
  }
}

class _AttachmentArchiveSection extends ConsumerWidget {
  const _AttachmentArchiveSection({required this.summary});

  final EnvironmentAttachmentArchiveSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presentation = _attachmentPresentation(summary, _colors(ref));
    final path = summary.canonicalPath ?? summary.displayPath;
    final volumeName = summary.volumeName ?? 'Unknown volume';

    return _EnvironmentCard(
      key: EnvironmentSummaryPanel.attachmentSectionKey,
      heading: 'Attachment archive',
      semanticLabel: 'Attachment archive, $volumeName, ${presentation.label}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LocationHeadline(name: volumeName, presentation: presentation),
          const SizedBox(height: AppSpacing.md),
          if (path == null) ...[
            _SectionStateText(
              status: summary.status,
              loadingLabel: 'Status not available yet',
            ),
          ] else ...[
            const _PathLabel(),
            const SizedBox(height: AppSpacing.xs),
            SelectableText(
              path,
              key: EnvironmentSummaryPanel.attachmentPathKey,
              style: _typography(ref).caption1.copyWith(
                color: _colors(ref).content.textPrimary,
                height: 1.4,
              ),
            ),
          ],
          if (summary.issue case final issue?) ...[
            const SizedBox(height: AppSpacing.sm),
            _IssueText(issue),
          ],
        ],
      ),
    );
  }
}

class _MessageDataSection extends ConsumerWidget {
  const _MessageDataSection({required this.summary});

  final EnvironmentMessageDataSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _EnvironmentCard(
      key: EnvironmentSummaryPanel.messageSectionKey,
      heading: 'Message data',
      semanticLabel: 'Message data, ${_sectionStatusLabel(summary.status)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _MetricTile(
                label: 'Messages in MessageLens',
                value: _countValue(
                  summary.projectedMessageCount,
                  summary.status,
                ),
              ),
              _MetricTile(
                label: 'Conversations',
                value: _countValue(summary.conversationCount, summary.status),
              ),
              _MetricTile(
                label: 'Attachment references',
                value: _countValue(
                  summary.attachmentReferenceCount,
                  summary.status,
                ),
              ),
            ],
          ),
          if (summary.issue case final issue?) ...[
            const SizedBox(height: AppSpacing.sm),
            _IssueText(issue),
          ],
          const SizedBox(height: AppSpacing.lg),
          Semantics(
            header: true,
            child: Text(
              'Contributing Message sources',
              style: _typography(
                ref,
              ).title3.copyWith(color: _colors(ref).content.textPrimary),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (summary.status == EnvironmentSectionStatus.ready &&
              summary.sources.isEmpty)
            Text(
              'No contributing Message sources.',
              style: _typography(
                ref,
              ).caption1.copyWith(color: _colors(ref).content.textSecondary),
            )
          else if (summary.sources.isEmpty)
            _SectionStateText(status: summary.status)
          else
            for (final source in summary.sources) ...[
              _MessageSourceCard(source: source),
              if (source != summary.sources.last)
                const SizedBox(height: AppSpacing.sm),
            ],
        ],
      ),
    );
  }
}

class _MessageSourceCard extends ConsumerWidget {
  const _MessageSourceCard({required this.source});

  final EnvironmentMessageSourceSummary source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kindLabel = switch (source.kind) {
      EnvironmentMessageSourceKind.currentMacMessages => 'Current Mac Messages',
      EnvironmentMessageSourceKind.historicalMessagesArchive =>
        'Historical Messages archive',
    };
    final sourcePath = source.canonicalSourcePath;
    final dateRange = _dateRangeLabel(source);
    final messageCount = CountLabelFormatter.messages(
      source.projectedMessageCount,
    );

    return Semantics(
      container: true,
      label: '$kindLabel, ${source.displayLabel}, $messageCount, $dateRange',
      child: DecoratedBox(
        key: ValueKey<int>(source.sourceId),
        decoration: BoxDecoration(
          color: _colors(ref).surfaces.control,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          border: Border.all(color: _colors(ref).lines.borderSubtle),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                source.displayLabel,
                style: _typography(
                  ref,
                ).headline.copyWith(color: _colors(ref).content.textPrimary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                kindLabel,
                style: _typography(
                  ref,
                ).caption1.copyWith(color: _colors(ref).content.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              _LabelValueLine(label: 'Projected Messages', value: messageCount),
              const SizedBox(height: AppSpacing.xs),
              _LabelValueLine(label: 'Date range', value: dateRange),
              if (source.kind ==
                      EnvironmentMessageSourceKind.historicalMessagesArchive &&
                  sourcePath != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Recorded source identity',
                  style: _typography(
                    ref,
                  ).caption2.copyWith(color: _colors(ref).content.textTertiary),
                ),
                const SizedBox(height: AppSpacing.xs),
                SelectableText(
                  sourcePath,
                  key: ValueKey<String>(
                    'environment-message-source-path-${source.sourceId}',
                  ),
                  style: _typography(ref).caption2.copyWith(
                    color: _colors(ref).content.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactsDataSection extends ConsumerWidget {
  const _ContactsDataSection({required this.summary});

  final EnvironmentContactsDataSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _EnvironmentCard(
      key: EnvironmentSummaryPanel.contactsSectionKey,
      heading: 'Contacts data',
      semanticLabel: 'Contacts data, ${_sectionStatusLabel(summary.status)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Mac Contacts',
            style: _typography(
              ref,
            ).title3.copyWith(color: _colors(ref).content.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _MetricTile(
                label: 'Contacts in MessageLens',
                value: _countValue(
                  summary.projectedContactCount,
                  summary.status,
                ),
              ),
              _MetricTile(
                label: 'Linked handles',
                value: _countValue(summary.linkedHandleCount, summary.status),
              ),
              _MetricTile(
                label: 'Imported channels',
                value: _countValue(
                  summary.importedChannelCount,
                  summary.status,
                ),
              ),
            ],
          ),
          if (summary.issue case final issue?) ...[
            const SizedBox(height: AppSpacing.sm),
            _IssueText(issue),
          ],
        ],
      ),
    );
  }
}

class _TechnicalDetailsDisclosure extends ConsumerWidget {
  const _TechnicalDetailsDisclosure({
    required this.summary,
    required this.expanded,
    required this.onToggle,
  });

  final EnvironmentSummary summary;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Semantics(
            button: true,
            expanded: expanded,
            label: 'Technical Details',
            excludeSemantics: true,
            child: TextButton.icon(
              key: EnvironmentSummaryPanel.technicalToggleKey,
              onPressed: onToggle,
              icon: Icon(
                expanded ? Icons.expand_more : Icons.chevron_right,
                size: 20,
                color: _colors(ref).content.iconSecondary,
              ),
              label: Text(
                'Technical Details',
                style: _typography(ref).controlValue.copyWith(
                  color: _colors(ref).content.textSecondary,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.sm,
                ),
                foregroundColor: _colors(ref).content.textSecondary,
              ),
            ),
          ),
        ),
        if (expanded) ...[
          const SizedBox(height: AppSpacing.sm),
          _TechnicalDetailsBody(summary: summary),
        ],
      ],
    );
  }
}

class _TechnicalDetailsBody extends ConsumerWidget {
  const _TechnicalDetailsBody({required this.summary});

  final EnvironmentSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installation = summary.installation;
    final attachment = summary.attachmentArchive;
    final technical = summary.technical;
    final attachmentPath =
        attachment.canonicalPath ?? attachment.displayPath ?? 'Unavailable';

    return Semantics(
      container: true,
      label: 'Technical Environment details',
      child: DecoratedBox(
        key: EnvironmentSummaryPanel.technicalBodyKey,
        decoration: BoxDecoration(
          color: _colors(ref).surfaces.surface,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          border: Border.all(color: _colors(ref).lines.borderSubtle),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TechnicalRow(
                label: 'Environment',
                value: _humanizeName(installation.environment.name),
              ),
              _TechnicalRow(
                label: 'Build identity',
                value: _humanizeName(installation.buildIdentity.name),
              ),
              _TechnicalRow(
                label: 'Runtime mode',
                value: _humanizeName(installation.runtimeMode.name),
              ),
              _TechnicalRow(
                label: 'Bundle identifier',
                value: installation.bundleIdentifier,
                selectable: true,
              ),
              _TechnicalRow(
                label: 'Archive instance UUID',
                value: installation.archiveInstanceId,
                selectable: true,
              ),
              _TechnicalRow(
                label: 'Canonical data root',
                value: summary.dataRoot.canonicalPath,
                selectable: true,
              ),
              _TechnicalRow(
                label: 'Attachment root',
                value: attachmentPath,
                selectable: attachmentPath != 'Unavailable',
              ),
              _TechnicalRow(
                label: 'Attachment state',
                value: _attachmentPresentation(attachment, _colors(ref)).label,
              ),
              _TechnicalRow(
                label: 'Attachment generation',
                value: '${attachment.locationGeneration}',
              ),
              _TechnicalRow(
                label: 'Attachment mode',
                value: attachment.configurationMode == null
                    ? 'Unknown'
                    : _humanizeName(attachment.configurationMode!.name),
              ),
              _TechnicalRow(
                label: 'Attachment write policy',
                value: attachment.customWritePolicy == null
                    ? 'Unknown'
                    : _humanizeName(attachment.customWritePolicy!.name),
              ),
              _TechnicalRow(
                label: 'Startup installation state',
                value: technical.installationState == null
                    ? 'Unknown'
                    : _humanizeName(technical.installationState!.name),
              ),
              _TechnicalRow(
                label: 'Startup admission basis',
                value: technical.startupAdmissionBasis == null
                    ? 'Unknown'
                    : _humanizeName(technical.startupAdmissionBasis!.name),
              ),
              if (technical.maintenanceActive == true)
                const _TechnicalRow(label: 'Maintenance', value: 'Active'),
              _TechnicalRow(
                label: 'Contacts physical source identity',
                value: summary.contacts.physicalSourceIdentityRetained
                    ? 'Retained'
                    : 'Not retained',
              ),
              const SizedBox(height: AppSpacing.md),
              Semantics(
                header: true,
                child: Text(
                  'Databases',
                  style: _typography(
                    ref,
                  ).title3.copyWith(color: _colors(ref).content.textPrimary),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (technical.databases.isEmpty)
                _SectionStateText(status: technical.databaseStatus)
              else
                for (final database in technical.databases) ...[
                  _DatabaseSummaryCard(database: database),
                  if (database != technical.databases.last)
                    const SizedBox(height: AppSpacing.sm),
                ],
              const SizedBox(height: AppSpacing.md),
              _TechnicalRow(label: 'FTS', value: _ftsLabel(technical)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatabaseSummaryCard extends ConsumerWidget {
  const _DatabaseSummaryCard({required this.database});

  final EnvironmentDatabaseSummary database;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schemaMismatch =
        database.readable &&
        database.userVersion != null &&
        database.userVersion != database.expectedVersion;
    final status = !database.exists
        ? database.role == EnvironmentDatabaseRole.presence
              ? 'Not present'
              : 'Missing'
        : !database.readable
        ? 'Unreadable'
        : schemaMismatch
        ? 'Present · Schema mismatch'
        : 'Present';

    return Semantics(
      container: true,
      label: '${_databaseRoleLabel(database.role)}, $status',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _colors(ref).surfaces.control,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          border: Border.all(
            color: schemaMismatch
                ? _colors(ref).status.warning
                : _colors(ref).lines.borderSubtle,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _databaseRoleLabel(database.role),
                style: _typography(
                  ref,
                ).headline.copyWith(color: _colors(ref).content.textPrimary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                status,
                style: _typography(ref).caption1.copyWith(
                  color: schemaMismatch
                      ? _colors(ref).status.warning
                      : _colors(ref).content.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SelectableText(
                database.path,
                key: ValueKey<String>(
                  'environment-database-path-${database.role.name}',
                ),
                style: _typography(ref).caption2.copyWith(
                  color: _colors(ref).content.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _LabelValueLine(
                label: 'Schema actual / expected',
                value:
                    '${database.userVersion?.toString() ?? 'Unknown'} / '
                    '${database.expectedVersion}',
              ),
              const SizedBox(height: AppSpacing.xs),
              _LabelValueLine(
                label: 'Size',
                value: _byteSizeLabel(database.sizeBytes),
              ),
              if (database.issue case final issue?) ...[
                const SizedBox(height: AppSpacing.sm),
                _IssueText(issue),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EnvironmentCard extends ConsumerWidget {
  const _EnvironmentCard({
    super.key,
    required this.heading,
    required this.semanticLabel,
    required this.child,
  });

  final String heading;
  final String semanticLabel;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      container: true,
      label: semanticLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _colors(ref).surfaces.surface,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          border: Border.all(color: _colors(ref).lines.borderSubtle),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  heading,
                  style: _typography(
                    ref,
                  ).title3.copyWith(color: _colors(ref).content.textPrimary),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationHeadline extends ConsumerWidget {
  const _LocationHeadline({required this.name, required this.presentation});

  final String name;
  final _StatusPresentation presentation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          name,
          style: _typography(
            ref,
          ).title2.copyWith(color: _colors(ref).content.textPrimary),
        ),
        _StatusBadge(presentation: presentation),
      ],
    );
  }
}

class _StatusBadge extends ConsumerWidget {
  const _StatusBadge({required this.presentation});

  final _StatusPresentation presentation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      label: presentation.label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: presentation.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.lg),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(presentation.icon, size: 14, color: presentation.color),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  presentation.label,
                  style: _typography(
                    ref,
                  ).caption.copyWith(color: presentation.color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends ConsumerWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      label: '$label, $value',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _colors(ref).surfaces.control,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: SizedBox(
            width: 176,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: _typography(ref).title2.copyWith(
                    color: _colors(ref).content.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: _typography(ref).caption1.copyWith(
                    color: _colors(ref).content.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LabelValueLine extends ConsumerWidget {
  const _LabelValueLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        Text(
          '$label:',
          style: _typography(
            ref,
          ).caption.copyWith(color: _colors(ref).content.textSecondary),
        ),
        Text(
          value,
          style: _typography(
            ref,
          ).caption1.copyWith(color: _colors(ref).content.textPrimary),
        ),
      ],
    );
  }
}

class _TechnicalRow extends ConsumerWidget {
  const _TechnicalRow({
    required this.label,
    required this.value,
    this.selectable = false,
  });

  final String label;
  final String value;
  final bool selectable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final valueStyle = _typography(
      ref,
    ).caption1.copyWith(color: _colors(ref).content.textPrimary, height: 1.4);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 184,
            child: Text(
              label,
              style: _typography(
                ref,
              ).caption.copyWith(color: _colors(ref).content.textSecondary),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: selectable
                ? SelectableText(value, style: valueStyle)
                : Text(value, style: valueStyle),
          ),
        ],
      ),
    );
  }
}

class _PathLabel extends ConsumerWidget {
  const _PathLabel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      'Path',
      style: _typography(
        ref,
      ).caption2.copyWith(color: _colors(ref).content.textTertiary),
    );
  }
}

class _IssueText extends ConsumerWidget {
  const _IssueText(this.issue);

  final String issue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      issue,
      style: _typography(
        ref,
      ).caption1.copyWith(color: _colors(ref).content.textSecondary),
    );
  }
}

class _SectionStateText extends ConsumerWidget {
  const _SectionStateText({
    required this.status,
    this.loadingLabel = 'Loading',
  });

  final EnvironmentSectionStatus status;
  final String loadingLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = status == EnvironmentSectionStatus.loading
        ? loadingLabel
        : _sectionStatusLabel(status);
    return Semantics(
      label: label,
      child: Text(
        label,
        style: _typography(
          ref,
        ).caption1.copyWith(color: _colors(ref).content.textSecondary),
      ),
    );
  }
}

final class _StatusPresentation {
  const _StatusPresentation({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

ThemeColors _colors(WidgetRef ref) {
  ref.watch(themeColorsProvider);
  return ref.read(themeColorsProvider.notifier);
}

ThemeTypography _typography(WidgetRef ref) {
  return ref.watch(themeTypographyProvider);
}

String _versionLabel(EnvironmentInstallationSummary installation) {
  final version = installation.semanticVersion;
  final build = installation.buildNumber;
  if (version != null && version.isNotEmpty) {
    if (build != null && build.isNotEmpty) {
      return '$version ($build)';
    }
    return version;
  }
  return _sectionStatusLabel(installation.packageStatus);
}

String _countValue(int? value, EnvironmentSectionStatus status) {
  if (value != null) {
    return CountLabelFormatter.formatCount(value);
  }
  return _sectionStatusLabel(status);
}

String _dateRangeLabel(EnvironmentMessageSourceSummary source) {
  if (source.dateRangeStatus != EnvironmentSectionStatus.ready) {
    return _sectionStatusLabel(source.dateRangeStatus);
  }
  final earliest = source.earliestMessageUtc;
  final latest = source.latestMessageUtc;
  if (earliest == null || latest == null) {
    return 'Unknown';
  }
  return '${DateLabelFormatter.fullDate(earliest)} – '
      '${DateLabelFormatter.fullDate(latest)}';
}

String _sectionStatusLabel(EnvironmentSectionStatus status) {
  return switch (status) {
    EnvironmentSectionStatus.ready => 'Unknown',
    EnvironmentSectionStatus.loading => 'Loading',
    EnvironmentSectionStatus.unavailable => 'Unavailable',
    EnvironmentSectionStatus.notRetained => 'Not retained',
    EnvironmentSectionStatus.failed => 'Failed',
  };
}

_StatusPresentation _sectionAvailabilityPresentation({
  required EnvironmentSectionStatus status,
  required EnvironmentAvailability availability,
  required ThemeColors colors,
}) {
  if (status != EnvironmentSectionStatus.ready) {
    return _sectionStatusPresentation(status, colors);
  }
  return _availabilityPresentation(availability, colors);
}

_StatusPresentation _attachmentPresentation(
  EnvironmentAttachmentArchiveSummary summary,
  ThemeColors colors,
) {
  if (summary.status == EnvironmentSectionStatus.loading) {
    return _StatusPresentation(
      label: 'Status not available yet',
      color: colors.content.textSecondary,
      icon: Icons.hourglass_top,
    );
  }
  if (summary.status != EnvironmentSectionStatus.ready) {
    return _sectionStatusPresentation(summary.status, colors);
  }
  if (summary.availability == EnvironmentAvailability.connected &&
      summary.isPhysicallyWritable) {
    return _StatusPresentation(
      label: 'Connected · Read/write',
      color: colors.status.success,
      icon: Icons.check_circle_outline,
    );
  }
  if (summary.availability == EnvironmentAvailability.readOnly) {
    return _StatusPresentation(
      label: 'Connected · Read-only',
      color: colors.status.warning,
      icon: Icons.lock_outline,
    );
  }
  if (summary.availability == EnvironmentAvailability.invalid) {
    return _StatusPresentation(
      label: 'Attachment location invalid',
      color: colors.status.error,
      icon: Icons.error_outline,
    );
  }
  return _availabilityPresentation(summary.availability, colors);
}

_StatusPresentation _sectionStatusPresentation(
  EnvironmentSectionStatus status,
  ThemeColors colors,
) {
  return switch (status) {
    EnvironmentSectionStatus.ready => _StatusPresentation(
      label: 'Unknown',
      color: colors.content.textSecondary,
      icon: Icons.help_outline,
    ),
    EnvironmentSectionStatus.loading => _StatusPresentation(
      label: 'Loading',
      color: colors.content.textSecondary,
      icon: Icons.hourglass_top,
    ),
    EnvironmentSectionStatus.unavailable => _StatusPresentation(
      label: 'Unavailable',
      color: colors.status.warning,
      icon: Icons.cloud_off_outlined,
    ),
    EnvironmentSectionStatus.notRetained => _StatusPresentation(
      label: 'Not retained',
      color: colors.content.textSecondary,
      icon: Icons.remove_circle_outline,
    ),
    EnvironmentSectionStatus.failed => _StatusPresentation(
      label: 'Failed',
      color: colors.status.error,
      icon: Icons.error_outline,
    ),
  };
}

_StatusPresentation _availabilityPresentation(
  EnvironmentAvailability availability,
  ThemeColors colors,
) {
  return switch (availability) {
    EnvironmentAvailability.connected => _StatusPresentation(
      label: 'Connected',
      color: colors.status.success,
      icon: Icons.check_circle_outline,
    ),
    EnvironmentAvailability.readOnly => _StatusPresentation(
      label: 'Connected · Read-only',
      color: colors.status.warning,
      icon: Icons.lock_outline,
    ),
    EnvironmentAvailability.permissionRequired => _StatusPresentation(
      label: 'Permission required',
      color: colors.status.warning,
      icon: Icons.lock_outline,
    ),
    EnvironmentAvailability.disconnected => _StatusPresentation(
      label: 'Disconnected',
      color: colors.status.warning,
      icon: Icons.cloud_off_outlined,
    ),
    EnvironmentAvailability.missing => _StatusPresentation(
      label: 'Folder missing',
      color: colors.status.warning,
      icon: Icons.folder_off_outlined,
    ),
    EnvironmentAvailability.invalid => _StatusPresentation(
      label: 'Invalid',
      color: colors.status.error,
      icon: Icons.error_outline,
    ),
    EnvironmentAvailability.unknown => _StatusPresentation(
      label: 'Unknown',
      color: colors.content.textSecondary,
      icon: Icons.help_outline,
    ),
  };
}

String _humanizeName(String value) {
  if (value.isEmpty) {
    return value;
  }
  final spaced = value.replaceAllMapped(
    RegExp('([a-z0-9])([A-Z])'),
    (match) => '${match.group(1)} ${match.group(2)}',
  );
  return '${spaced[0].toUpperCase()}${spaced.substring(1)}';
}

String _databaseRoleLabel(EnvironmentDatabaseRole role) {
  return switch (role) {
    EnvironmentDatabaseRole.sourceImport => 'Source import database',
    EnvironmentDatabaseRole.conversationGraph => 'Conversation Graph database',
    EnvironmentDatabaseRole.userOverlay => 'User overlay database',
    EnvironmentDatabaseRole.presence => 'Presence database',
  };
}

String _byteSizeLabel(int? bytes) {
  if (bytes == null) {
    return 'Unknown';
  }
  if (bytes < 1024) {
    return '$bytes bytes';
  }
  final kibibytes = bytes / 1024;
  if (kibibytes < 1024) {
    return '${kibibytes.toStringAsFixed(1)} KB';
  }
  final mebibytes = kibibytes / 1024;
  if (mebibytes < 1024) {
    return '${mebibytes.toStringAsFixed(1)} MB';
  }
  return '${(mebibytes / 1024).toStringAsFixed(1)} GB';
}

String _ftsLabel(EnvironmentTechnicalSummary technical) {
  if (technical.ftsStatus != EnvironmentSectionStatus.ready) {
    return _sectionStatusLabel(technical.ftsStatus);
  }
  if (technical.ftsAvailable == false) {
    return 'Unavailable';
  }
  final count = technical.ftsRowCount;
  if (count == null) {
    return 'Unknown';
  }
  return CountLabelFormatter.rows(count);
}
