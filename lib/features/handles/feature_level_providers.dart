import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/sidebar/domain/entities/features/handles_cassette_spec.dart';
import '../../essentials/sidebar/presentation/models/cassette_card_view.dart';
import 'presentation/cassettes/unmatched_handles_cassette.dart';

part 'feature_level_providers.g.dart';

@riverpod
class HandlesCassetteCoordinator extends _$HandlesCassetteCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  CassetteCardView buildForSpec(HandlesCassetteSpec spec) {
    return spec.when(
      unmatchedHandlesList: (_) => const CassetteCardView(
        title: 'Unmatched phone numbers & emails',
        subtitle:
            'Link stray handles to contacts to keep conversations organized.',
        child: UnmatchedHandlesCassette(),
      ),
    );
  }
}
