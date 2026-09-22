final class EnvironmentPackageInfoEvidence {
  const EnvironmentPackageInfoEvidence({
    required this.semanticVersion,
    required this.buildNumber,
  });

  final String semanticVersion;
  final String buildNumber;
}

abstract interface class EnvironmentPackageInfoReader {
  Future<EnvironmentPackageInfoEvidence> read();
}
