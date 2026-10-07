import '../../archive_environment/domain.dart'
    show ArchiveAccessAuthority, ArchiveBuildIdentity, ArchiveEnvironment;

/// Selects the AppCzar composition for an already-admitted official
/// MessageLens Development process.
///
/// Archive admission remains the prerequisite for this policy. Physical root
/// and archive-instance restrictions belong to operation-specific mutation
/// authorities and deliberately do not select the process-wide semantic
/// architecture.
final class AppCzarDevelopmentCompositionPolicy {
  const AppCzarDevelopmentCompositionPolicy();

  static const developmentBundleIdentifier =
      'com.bigbenchsoftware.MessageLens.development';
  static const developmentProductName = 'MessageLens Development';

  bool admits(ArchiveAccessAuthority? authority) {
    if (authority == null) {
      return false;
    }

    final identity = authority.identity;
    final recognizedDevelopmentBuild = switch (identity.buildIdentity) {
      ArchiveBuildIdentity.developmentDebug ||
      ArchiveBuildIdentity.developmentProfile ||
      ArchiveBuildIdentity.developmentRelease => true,
      ArchiveBuildIdentity.fdaExperiment ||
      ArchiveBuildIdentity.productionRelease ||
      ArchiveBuildIdentity.testHarness => false,
    };

    return identity.environment == ArchiveEnvironment.development &&
        recognizedDevelopmentBuild &&
        identity.bundleIdentifier == developmentBundleIdentifier &&
        identity.productName == developmentProductName;
  }
}
