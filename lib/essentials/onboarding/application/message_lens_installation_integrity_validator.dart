import '../domain/startup_installation_validation.dart';

abstract interface class MessageLensInstallationIntegrityValidator {
  Future<InstallationDatabaseIntegrityValidation> validateDatabase({
    required String archiveRootPath,
    required InstallationDatabaseKey database,
  });
}
