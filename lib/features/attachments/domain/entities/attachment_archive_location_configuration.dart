import 'dart:convert';

import 'package:meta/meta.dart';

/// The configured ownership mode for the active attachment archive root.
///
/// [customExternal] stores bookmark-backed identity plus display-only metadata.
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

/// Whether a resolved custom root is eligible for ordinary archive writes.
///
/// Merely selecting a directory never activates it. Phase Five may persist
/// [activeArchive] only after relocation and verification have succeeded.
enum AttachmentArchiveCustomWritePolicy {
  readOnlyUntilVerifiedRelocation('read_only_until_verified_relocation'),
  activeArchive('active_archive');

  const AttachmentArchiveCustomWritePolicy(this.serializedName);

  final String serializedName;

  static AttachmentArchiveCustomWritePolicy parse(String value) {
    return switch (value) {
      'read_only_until_verified_relocation' =>
        AttachmentArchiveCustomWritePolicy.readOnlyUntilVerifiedRelocation,
      'active_archive' => AttachmentArchiveCustomWritePolicy.activeArchive,
      _ => throw FormatException(
        'Unsupported attachment archive custom write policy: $value',
      ),
    };
  }
}

/// Versioned, machine-specific configuration for the attachment archive root.
///
/// Attachment rows retain archive-relative paths. This configuration selects
/// the root against which those paths are resolved and is not attachment
/// identity. [lastKnownPath] is never filesystem authority.
@immutable
final class AttachmentArchiveLocationConfiguration {
  const AttachmentArchiveLocationConfiguration._({
    required this.formatVersion,
    required this.mode,
    this.bookmarkDataBase64,
    this.lastKnownPath,
    this.volumeName,
    this.customWritePolicy,
  });

  const AttachmentArchiveLocationConfiguration.defaultInternal()
    : this._(
        formatVersion: currentFormatVersion,
        mode: AttachmentArchiveLocationMode.defaultInternal,
      );

  factory AttachmentArchiveLocationConfiguration.customExternal({
    required String bookmarkDataBase64,
    required String lastKnownPath,
    String? volumeName,
    AttachmentArchiveCustomWritePolicy customWritePolicy =
        AttachmentArchiveCustomWritePolicy.readOnlyUntilVerifiedRelocation,
  }) {
    final normalizedBookmark = _validateBookmarkData(bookmarkDataBase64);
    final normalizedLastKnownPath = lastKnownPath.trim();
    if (normalizedLastKnownPath.isEmpty) {
      throw const FormatException(
        'Custom attachment archive lastKnownPath must not be empty.',
      );
    }
    final normalizedVolumeName = volumeName?.trim();
    return AttachmentArchiveLocationConfiguration._(
      formatVersion: currentFormatVersion,
      mode: AttachmentArchiveLocationMode.customExternal,
      bookmarkDataBase64: normalizedBookmark,
      lastKnownPath: normalizedLastKnownPath,
      volumeName: normalizedVolumeName == null || normalizedVolumeName.isEmpty
          ? null
          : normalizedVolumeName,
      customWritePolicy: customWritePolicy,
    );
  }

  static const int currentFormatVersion = 1;

  final int formatVersion;
  final AttachmentArchiveLocationMode mode;
  final String? bookmarkDataBase64;
  final String? lastKnownPath;
  final String? volumeName;
  final AttachmentArchiveCustomWritePolicy? customWritePolicy;

  Map<String, Object> toJson() {
    return <String, Object>{
      'formatVersion': formatVersion,
      'mode': mode.serializedName,
      if (bookmarkDataBase64 case final bookmarkData?)
        'bookmarkDataBase64': bookmarkData,
      if (lastKnownPath case final displayPath?) 'lastKnownPath': displayPath,
      if (volumeName case final name?) 'volumeName': name,
      if (customWritePolicy case final policy?)
        'customWritePolicy': policy.serializedName,
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

    final parsedMode = AttachmentArchiveLocationMode.parse(mode);
    return switch (parsedMode) {
      AttachmentArchiveLocationMode.defaultInternal =>
        const AttachmentArchiveLocationConfiguration.defaultInternal(),
      AttachmentArchiveLocationMode.customExternal =>
        AttachmentArchiveLocationConfiguration.customExternal(
          bookmarkDataBase64: _readRequiredString(json, 'bookmarkDataBase64'),
          lastKnownPath: _readRequiredString(json, 'lastKnownPath'),
          volumeName: _readOptionalString(json, 'volumeName'),
          customWritePolicy: _readCustomWritePolicy(json),
        ),
    };
  }

  AttachmentArchiveLocationConfiguration withResolvedMetadata({
    required String bookmarkDataBase64,
    required String lastKnownPath,
    String? volumeName,
  }) {
    if (mode != AttachmentArchiveLocationMode.customExternal) {
      throw StateError(
        'Only custom attachment archive configuration has bookmark metadata.',
      );
    }
    return AttachmentArchiveLocationConfiguration.customExternal(
      bookmarkDataBase64: bookmarkDataBase64,
      lastKnownPath: lastKnownPath,
      volumeName: volumeName,
      customWritePolicy:
          customWritePolicy ??
          AttachmentArchiveCustomWritePolicy.readOnlyUntilVerifiedRelocation,
    );
  }

  AttachmentArchiveLocationConfiguration withCustomWritePolicy(
    AttachmentArchiveCustomWritePolicy policy,
  ) {
    if (mode != AttachmentArchiveLocationMode.customExternal) {
      throw StateError(
        'Only custom attachment archive configuration has a write policy.',
      );
    }
    return AttachmentArchiveLocationConfiguration.customExternal(
      bookmarkDataBase64: bookmarkDataBase64!,
      lastKnownPath: lastKnownPath!,
      volumeName: volumeName,
      customWritePolicy: policy,
    );
  }

  static String _validateBookmarkData(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw const FormatException(
        'Custom attachment archive bookmark data must not be empty.',
      );
    }
    try {
      final decoded = base64Decode(normalized);
      if (decoded.isEmpty) {
        throw const FormatException(
          'Custom attachment archive bookmark data must not be empty.',
        );
      }
    } on FormatException {
      throw const FormatException(
        'Custom attachment archive bookmark data must be valid base64.',
      );
    }
    return normalized;
  }

  static String _readRequiredString(Map<String, Object?> json, String key) {
    final value = _readOptionalString(json, key);
    if (value == null || value.trim().isEmpty) {
      throw FormatException(
        'Custom attachment archive $key must be a non-empty string.',
      );
    }
    return value;
  }

  static String? _readOptionalString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) {
      return null;
    }
    if (value is! String) {
      throw FormatException('Custom attachment archive $key must be a string.');
    }
    return value;
  }

  static AttachmentArchiveCustomWritePolicy _readCustomWritePolicy(
    Map<String, Object?> json,
  ) {
    final value = json['customWritePolicy'];
    if (value == null) {
      return AttachmentArchiveCustomWritePolicy.readOnlyUntilVerifiedRelocation;
    }
    if (value is! String) {
      throw const FormatException(
        'Custom attachment archive customWritePolicy must be a string.',
      );
    }
    return AttachmentArchiveCustomWritePolicy.parse(value);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AttachmentArchiveLocationConfiguration &&
            other.formatVersion == formatVersion &&
            other.mode == mode &&
            other.bookmarkDataBase64 == bookmarkDataBase64 &&
            other.lastKnownPath == lastKnownPath &&
            other.volumeName == volumeName &&
            other.customWritePolicy == customWritePolicy;
  }

  @override
  int get hashCode => Object.hash(
    formatVersion,
    mode,
    bookmarkDataBase64,
    lastKnownPath,
    volumeName,
    customWritePolicy,
  );
}
