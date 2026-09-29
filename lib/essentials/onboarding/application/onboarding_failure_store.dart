import '../domain/onboarding_environment_report.dart';

class PersistedOnboardingSourceImportFailure {
  const PersistedOnboardingSourceImportFailure({
    required this.failure,
    this.recordedAt,
  });

  final OnboardingPipelineFailure failure;
  final DateTime? recordedAt;
}

class PersistedOnboardingGraphProjectionFailure {
  const PersistedOnboardingGraphProjectionFailure({
    required this.failure,
    this.recordedAt,
  });

  final OnboardingPipelineFailure failure;
  final DateTime? recordedAt;
}

abstract interface class OnboardingFailureStore {
  Future<OnboardingPipelineFailure?> loadSourceImportFailure();

  Future<PersistedOnboardingSourceImportFailure?> loadSourceImportFailureEntry({
    void Function()? requirePersistentArchiveStoreAdmission,
  });

  Future<void> saveImportFailure({
    required String message,
    int batchId,
    DateTime? recordedAt,
    List<String> warnings,
  });

  Future<void> clearSourceImportFailure();

  Future<OnboardingPipelineFailure?> loadGraphProjectionFailure();

  Future<PersistedOnboardingGraphProjectionFailure?>
  loadGraphProjectionFailureEntry({
    void Function()? requirePersistentArchiveStoreAdmission,
  });

  Future<void> saveGraphProjectionFailure({
    required String message,
    int batchId,
    DateTime? recordedAt,
  });

  Future<void> clearGraphProjectionFailure();
}
