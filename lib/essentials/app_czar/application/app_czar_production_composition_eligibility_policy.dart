import '../../archive_environment/domain.dart'
    show
        ArchiveAccessAuthority,
        ArchiveBuildIdentity,
        ArchiveEnvironment,
        ArchiveIdentityValidator;

/// Recognizes an already-admitted official production application identity.
///
/// Possession of [ArchiveAccessAuthority] is the signature-proof boundary:
/// [ArchiveIdentityValidator] rejects an invalid production signature before
/// an authority can be returned by archive admission. This policy neither
/// admits an archive nor reinterprets raw native claim evidence.
final class AppCzarProductionCompositionEligibilityPolicy {
  const AppCzarProductionCompositionEligibilityPolicy();

  bool isEligible(ArchiveAccessAuthority? authority) {
    if (authority == null) {
      return false;
    }

    final identity = authority.identity;
    return identity.environment == ArchiveEnvironment.production &&
        identity.buildIdentity == ArchiveBuildIdentity.productionRelease &&
        identity.bundleIdentifier ==
            ArchiveIdentityValidator.defaultProductionBundleIdentifier &&
        identity.productName ==
            ArchiveIdentityValidator.defaultProductionProductName;
  }
}
