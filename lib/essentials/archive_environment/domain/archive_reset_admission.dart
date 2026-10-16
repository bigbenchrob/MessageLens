import '../../startup_presentation_evidence/domain/startup_presentation_evidence.dart'
    show StartupPresentationComposition;
import 'archive_mutation_operation.dart';

enum ArchiveResetAdmissionState { startupApp, appCzar, unavailable, revoked }

enum ArchiveResetDenialReason { unavailable, appCzar, revoked, bindingClosed }

final class ArchiveResetDenied implements Exception {
  const ArchiveResetDenied(this.reason);

  final ArchiveResetDenialReason reason;

  @override
  String toString() => 'Archive reset denied: ${reason.name}.';
}

/// A veto only: passing it never grants archive or mutation authority.
/// Selection is immutable; revocation is permanent for this root lifetime.
final class ArchiveResetAdmission {
  ArchiveResetAdmission.selected(StartupPresentationComposition composition)
    : _selection = composition;

  ArchiveResetAdmission.unavailable() : _selection = null;

  final StartupPresentationComposition? _selection;
  final Object epoch = Object();
  bool _revoked = false;

  static bool appliesTo(ArchiveMutationOperation operation) =>
      operation == ArchiveMutationOperation.startFresh ||
      operation == ArchiveMutationOperation.messageDataReset;

  ArchiveResetAdmissionState get state {
    if (_revoked) {
      return ArchiveResetAdmissionState.revoked;
    }
    return switch (_selection) {
      StartupPresentationComposition.startupApp =>
        ArchiveResetAdmissionState.startupApp,
      StartupPresentationComposition.appCzar =>
        ArchiveResetAdmissionState.appCzar,
      null => ArchiveResetAdmissionState.unavailable,
    };
  }

  void revoke() {
    _revoked = true;
  }

  ArchiveResetAdmissionBinding bind() => ArchiveResetAdmissionBinding._(this);

  void _requireAllowed() {
    switch (state) {
      case ArchiveResetAdmissionState.startupApp:
        return;
      case ArchiveResetAdmissionState.appCzar:
        throw const ArchiveResetDenied(ArchiveResetDenialReason.appCzar);
      case ArchiveResetAdmissionState.unavailable:
        throw const ArchiveResetDenied(ArchiveResetDenialReason.unavailable);
      case ArchiveResetAdmissionState.revoked:
        throw const ArchiveResetDenied(ArchiveResetDenialReason.revoked);
    }
  }
}

/// A consumer cannot substitute a newer root after disposal or ABA replacement.
final class ArchiveResetAdmissionBinding {
  ArchiveResetAdmissionBinding._(this._parent);

  final ArchiveResetAdmission _parent;
  bool _closed = false;

  Object get epoch => _parent.epoch;

  void close() {
    _closed = true;
  }

  void requireAllowed(ArchiveMutationOperation operation) {
    if (!ArchiveResetAdmission.appliesTo(operation)) {
      return;
    }
    if (_closed) {
      throw const ArchiveResetDenied(ArchiveResetDenialReason.bindingClosed);
    }
    _parent._requireAllowed();
  }

  bool isCurrentFor(ArchiveMutationOperation operation) {
    try {
      requireAllowed(operation);
      return true;
    } on ArchiveResetDenied {
      return false;
    }
  }
}
