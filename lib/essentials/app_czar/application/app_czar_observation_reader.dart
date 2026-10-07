import '../domain/app_czar_models.dart';

abstract interface class AppCzarObservationReader {
  Future<AppCzarRootObservation> readRoot();

  Future<AppCzarSourceObservation> readSource();

  Future<AppCzarDatabaseObservation> readImportStore();

  Future<AppCzarDatabaseObservation> readGraphStore();

  Future<AppCzarDatabaseObservation> readOverlay();

  Future<AppCzarArchiveObservation> readAttachmentArchive();
}

abstract interface class AppCzarInitialConstructionScopeReader {
  Future<AppCzarInitialConstructionScopeObservation>
  readInitialConstructionScope();
}

abstract interface class AppCzarContactsPrerequisiteReader {
  Future<AppCzarContactsPrerequisiteObservation> readContactsPrerequisite();
}

abstract interface class AppCzarLocalDataRepairSafetyReader {
  Future<AppCzarLocalDataRepairSafetyObservation> readLocalDataRepairSafety({
    required AppCzarArchiveObservation attachmentArchive,
  });
}

abstract interface class AppCzarAttachmentArchiveProbe {
  Future<AppCzarArchiveObservation> readCurrent();
}
