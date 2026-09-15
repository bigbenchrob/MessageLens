import 'dart:convert';

import 'package:meta/meta.dart';

/// The configured ownership mode for the active attachment archive root.
///
/// Phase One operates only [defaultInternal]. [customExternal] reserves the
/// persisted discriminator that later phases will extend with bookmark-backed
/// identity without replacing this configuration contract.
enum AttachmentArchiveLocationMode {
  defaultInternal('default_internal'),
  customExternal('custom_external');

  const AttachmentArchiveLocationMode(this.serializedName);

  final String serializedName;

  static AttachmentArchiveLocationMode parse(String value) {
    return switch (value) {
      'default_internal' => AttachmentArchiveLocationMode.defaultInternal,
      'custom_external' => AttachmentArchiveLocationMode.customExternal,
      _ => throw FormatException(
        'Unsupported attachment archive location mode: $value',
      ),
    };
  }
}

/// Versioned, machine-specific configuration for the attachment archive root.
///
/// Attachment rows retain archive-relative paths. This configuration selects
/// the root against which those paths are resolved and is not attachment
/// identity.
@immutable
final class AttachmentArchiveLocationConfiguration {
  const AttachmentArchiveLocationConfiguration._({
    required this.formatVersion,
    required this.mode,
  });

  const AttachmentArchiveLocationConfiguration.defaultInternal()
    : this._(
        formatVersion: currentFormatVersion,
        mode: AttachmentArchiveLocationMode.defaultInternal,
      );

  static const int currentFormatVersion = 1;

  final int formatVersion;
  final AttachmentArchiveLocationMode mode;

  Map<String, Object> toJson() {
    return <String, Object>{
      'formatVersion': formatVersion,
      'mode': mode.serializedName,
    };
  }

  String toPersistedValue() => jsonEncode(toJson());

  factory AttachmentArchiveLocationConfiguration.fromPersistedValue(
    String value,
  ) {
    final decoded = jsonDecode(value);
    if (decoded is! Map) {
      throw const FormatException(
        'Attachment archive location configuration must be a JSON object.',
      );
    }
    return AttachmentArchiveLocationConfiguration.fromJson(
      Map<String, Object?>.from(decoded),
    );
  }

  factory AttachmentArchiveLocationConfiguration.fromJson(
    Map<String, Object?> json,
  ) {
    final formatVersion = json['formatVersion'];
    final mode = json['mode'];
    if (formatVersion is! int) {
      throw const FormatException(
        'Attachment archive location formatVersion must be an integer.',
      );
    }
    if (formatVersion != currentFormatVersion) {
      throw FormatException(
        'Unsupported attachment archive location formatVersion: '
        '$formatVersion',
      );
    }
    if (mode is! String) {
      throw const FormatException(
        'Attachment archive location mode must be a string.',
      );
    }

    return AttachmentArchiveLocationConfiguration._(
      formatVersion: formatVersion,
      mode: AttachmentArchiveLocationMode.parse(mode),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AttachmentArchiveLocationConfiguration &&
            other.formatVersion == formatVersion &&
            other.mode == mode;
  }

  @override
  int get hashCode => Object.hash(formatVersion, mode);
}
