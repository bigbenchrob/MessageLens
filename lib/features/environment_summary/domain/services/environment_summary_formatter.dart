import '../entities/environment_summary.dart';

final class EnvironmentSummaryFormatter {
  const EnvironmentSummaryFormatter();

  String format(EnvironmentSummary summary) {
    final messages = summary.messages;
    final contacts = summary.contacts;
    final technical = summary.technical;
    final buffer = StringBuffer()
      ..writeln('MessageLens Environment Summary')
      ..writeln()
      ..writeln('Installation')
      ..writeln('  Product: ${summary.installation.productName}')
      ..writeln('  Version: ${_version(summary.installation)}')
      ..writeln(
        '  Environment: ${summary.installation.environment.serializedName}',
      )
      ..writeln(
        '  Build identity: '
        '${summary.installation.buildIdentity.serializedName}',
      )
      ..writeln('  Bundle identifier: ${summary.installation.bundleIdentifier}')
      ..writeln()
      ..writeln('Data folder')
      ..writeln(
        '  Status: ${_sectionAvailability(summary.dataRoot.status, summary.dataRoot.availability)}',
      )
      ..writeln('  Volume: ${summary.dataRoot.displayVolumeName}')
      ..writeln('  Path: ${summary.dataRoot.canonicalPath}')
      ..writeln()
      ..writeln('Attachment archive')
      ..writeln('  Status: ${_attachmentStatus(summary.attachmentArchive)}')
      ..writeln(
        '  Volume: ${summary.attachmentArchive.volumeName ?? 'Unknown'}',
      )
      ..writeln(
        '  Path: '
        '${summary.attachmentArchive.canonicalPath ?? summary.attachmentArchive.displayPath ?? 'Unavailable'}',
      )
      ..writeln()
      ..writeln('Data')
      ..writeln(
        '  Messages in MessageLens: '
        '${_count(messages.projectedMessageCount, messages.status)}',
      )
      ..writeln('  Message sources: ${_sourceSummary(messages)}')
      ..writeln(
        '  Conversations: '
        '${_count(messages.conversationCount, messages.status)}',
      )
      ..writeln(
        '  Contacts in MessageLens: '
        '${_count(contacts.projectedContactCount, contacts.status)}',
      )
      ..writeln(
        '  Contacts provenance: Current Mac Contacts; '
        'physical source identity not retained',
      )
      ..writeln()
      ..writeln('Technical')
      ..writeln(
        '  Archive instance UUID: ${summary.installation.archiveInstanceId}',
      )
      ..writeln('  Startup admission: ${_startupAdmission(technical)}');

    for (final role in EnvironmentDatabaseRole.values) {
      buffer.writeln(
        '  ${_databaseLabel(role)}: '
        '${_databaseSummary(technical, role)}',
      );
    }
    buffer.writeln('  FTS rows: ${_ftsRows(technical)}');
    return buffer.toString().trimRight();
  }

  String _version(EnvironmentInstallationSummary installation) {
    final version = installation.semanticVersion;
    final build = installation.buildNumber;
    if (version == null || version.isEmpty) {
      return _sectionFallback(installation.packageStatus);
    }
    if (build == null || build.isEmpty) {
      return version;
    }
    return '$version+$build';
  }

  String _sourceSummary(EnvironmentMessageDataSummary messages) {
    if (messages.status != EnvironmentSectionStatus.ready) {
      return _sectionFallback(messages.status);
    }
    final currentSources = messages.sources
        .where(
          (source) =>
              source.kind == EnvironmentMessageSourceKind.currentMacMessages,
        )
        .length;
    final historicalSources = messages.sources.length - currentSources;
    return '${messages.sources.length} '
        '($currentSources current, $historicalSources historical)';
  }

  String _count(int? count, EnvironmentSectionStatus status) {
    if (count != null) {
      return '$count';
    }
    return _sectionFallback(status);
  }

  String _attachmentStatus(EnvironmentAttachmentArchiveSummary attachment) {
    if (attachment.status != EnvironmentSectionStatus.ready) {
      return _sectionFallback(attachment.status);
    }
    return switch (attachment.availability) {
      EnvironmentAvailability.connected =>
        attachment.isPhysicallyWritable
            ? 'Connected · read/write'
            : 'Connected',
      EnvironmentAvailability.readOnly => 'Connected · read-only',
      _ => _availability(attachment.availability),
    };
  }

  String _sectionAvailability(
    EnvironmentSectionStatus status,
    EnvironmentAvailability availability,
  ) {
    if (status != EnvironmentSectionStatus.ready) {
      return _sectionFallback(status);
    }
    return _availability(availability);
  }

  String _availability(EnvironmentAvailability availability) {
    return switch (availability) {
      EnvironmentAvailability.connected => 'Connected',
      EnvironmentAvailability.readOnly => 'Connected · read-only',
      EnvironmentAvailability.permissionRequired => 'Permission required',
      EnvironmentAvailability.disconnected => 'Disconnected',
      EnvironmentAvailability.missing => 'Missing',
      EnvironmentAvailability.invalid => 'Invalid',
      EnvironmentAvailability.unknown => 'Unknown',
    };
  }

  String _startupAdmission(EnvironmentTechnicalSummary technical) {
    final state = technical.installationState;
    final basis = technical.startupAdmissionBasis;
    if (state == null && basis == null) {
      return _sectionFallback(technical.status);
    }
    if (state == null) {
      return basis!.name;
    }
    if (basis == null) {
      return state.name;
    }
    return '${state.name} · ${basis.name}';
  }

  String _databaseSummary(
    EnvironmentTechnicalSummary technical,
    EnvironmentDatabaseRole role,
  ) {
    EnvironmentDatabaseSummary? database;
    for (final candidate in technical.databases) {
      if (candidate.role == role) {
        database = candidate;
        break;
      }
    }
    if (database == null) {
      return _sectionFallback(technical.databaseStatus);
    }
    if (!database.exists && role == EnvironmentDatabaseRole.presence) {
      return 'Not present · schema Unknown/${database.expectedVersion} · '
          'Unknown';
    }
    final actualVersion = database.userVersion?.toString() ?? 'Unknown';
    final size = database.sizeBytes == null
        ? 'Unknown'
        : '${database.sizeBytes} bytes';
    final path = database.exists ? database.path : '${database.path} · Missing';
    return '$path · schema $actualVersion/${database.expectedVersion} · $size';
  }

  String _ftsRows(EnvironmentTechnicalSummary technical) {
    if (technical.ftsStatus != EnvironmentSectionStatus.ready) {
      return _sectionFallback(technical.ftsStatus);
    }
    if (technical.ftsAvailable == false) {
      return 'Unavailable';
    }
    return technical.ftsRowCount?.toString() ?? 'Unknown';
  }

  String _sectionFallback(EnvironmentSectionStatus status) {
    return switch (status) {
      EnvironmentSectionStatus.ready => 'Unknown',
      EnvironmentSectionStatus.loading => 'Loading',
      EnvironmentSectionStatus.unavailable => 'Unavailable',
      EnvironmentSectionStatus.notRetained => 'Not retained',
      EnvironmentSectionStatus.failed => 'Failed',
    };
  }

  String _databaseLabel(EnvironmentDatabaseRole role) {
    return switch (role) {
      EnvironmentDatabaseRole.sourceImport => 'Import database',
      EnvironmentDatabaseRole.conversationGraph => 'Graph database',
      EnvironmentDatabaseRole.userOverlay => 'Overlay database',
      EnvironmentDatabaseRole.presence => 'Presence database',
    };
  }
}
