import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app_czar/application/app_czar_development_composition_policy.dart';
import '../../archive_environment/feature_level_providers.dart'
    show admittedArchiveAccessAuthorityProvider;
import '../infrastructure/macos_development_process_restarter.dart';
import 'app_czar_process_restarter.dart';

part 'app_czar_process_restarter_provider.g.dart';

@riverpod
AppCzarProcessRestarter appCzarProcessRestarter(Ref ref) {
  final admittedAuthority = ref.watch(admittedArchiveAccessAuthorityProvider);
  return MacosDevelopmentProcessRestarter(
    developmentExecutionEnabled: const AppCzarDevelopmentCompositionPolicy()
        .admits(admittedAuthority),
  );
}
