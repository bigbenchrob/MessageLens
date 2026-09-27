/// Public seam for process-local exclusive-authority tenure.
export 'application/exclusive_authority_registry_provider.dart'
    show
        ExclusiveAuthorityRegistry,
        ExclusiveAuthorityTenure,
        exclusiveAuthorityRegistryProvider;
export 'domain/exclusive_authority_denied_exception.dart';
export 'domain/exclusive_authority_key.dart' show ExclusiveAuthorityKey;
export 'domain/exclusive_authority_proof_denied_exception.dart';
export 'domain/exclusive_authority_registry_state.dart';
