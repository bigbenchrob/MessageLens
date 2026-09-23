import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/archive_environment/domain.dart'
    show ArchiveBuildIdentity, ArchiveEnvironment;
import '../../../essentials/archive_environment/feature_level_providers.dart'
    show admittedArchiveAccessAuthorityProvider;

part 'attachment_archive_adoption_enablement_provider.g.dart';

const _authorizedDevelopmentBundleIdentifier =
    'com.bigbenchsoftware.MessageLens.development';
const _authorizedDevelopmentProductName = 'MessageLens Development';
const _authorizedDevelopmentRoot =
    '/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development';
const _authorizedDevelopmentArchiveInstanceId =
    'e9310d3f-8dc8-4436-a48e-c4fb7cf8d4a5';

/// Exact, fail-closed gate for the simplified development adoption workflow.
///
/// There is deliberately no runtime flag, preference, environment-variable
/// override, or production identity in this predicate.
@riverpod
bool attachmentArchiveAdoptionExecutionEnabled(Ref ref) {
  final authority = ref.watch(admittedArchiveAccessAuthorityProvider);
  if (authority == null) {
    return false;
  }

  final identity = authority.identity;
  final buildIdentityIsAuthorized = switch (identity.buildIdentity) {
    ArchiveBuildIdentity.developmentDebug ||
    ArchiveBuildIdentity.developmentProfile ||
    ArchiveBuildIdentity.developmentRelease => true,
    ArchiveBuildIdentity.fdaExperiment ||
    ArchiveBuildIdentity.productionRelease ||
    ArchiveBuildIdentity.testHarness => false,
  };

  return identity.environment == ArchiveEnvironment.development &&
      buildIdentityIsAuthorized &&
      identity.bundleIdentifier == _authorizedDevelopmentBundleIdentifier &&
      identity.productName == _authorizedDevelopmentProductName &&
      identity.canonicalRootPath == _authorizedDevelopmentRoot &&
      identity.archiveInstanceId.value ==
          _authorizedDevelopmentArchiveInstanceId;
}
