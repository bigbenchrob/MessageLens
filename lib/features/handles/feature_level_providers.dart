import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/sidebar/domain/entities/features/handles_cassette_spec.dart';
import 'presentation/cassettes/unmatched_handles_cassette.dart';

part 'feature_level_providers.g.dart';

@riverpod
class HandlesCassetteCoordinator extends _$HandlesCassetteCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  Widget buildForSpec(HandlesCassetteSpec spec) {
    return spec.when(
      unmatchedHandlesList: (_) => const UnmatchedHandlesCassette(),
    );
  }
}
