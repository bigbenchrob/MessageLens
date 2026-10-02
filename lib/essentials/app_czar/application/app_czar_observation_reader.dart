import '../domain/app_czar_models.dart';

abstract interface class AppCzarObservationReader {
  Future<AppCzarRootObservation> readRoot();

  Future<AppCzarSourceObservation> readSource();

  Future<AppCzarDatabaseObservation> readImportStore();

  Future<AppCzarDatabaseObservation> readGraphStore();

  Future<AppCzarDatabaseObservation> readOverlay();

  Future<AppCzarArchiveObservation> readAttachmentArchive();
}

abstract interface class AppCzarAttachmentArchiveProbe {
  Future<AppCzarArchiveObservation> readCurrent();
}
