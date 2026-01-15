import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/sidebar/domain/entities/features/handles_cassette_spec.dart';
import '../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'presentation/cassettes/stray_emails_cassette.dart';
import 'presentation/cassettes/stray_phone_numbers_cassette.dart';
import 'presentation/cassettes/unmatched_handles_cassette.dart';

part 'feature_level_providers.g.dart';

@riverpod
class HandlesCassetteCoordinator extends _$HandlesCassetteCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  SidebarCassetteCardViewModel buildForSpec(HandlesCassetteSpec spec) {
    return spec.when(
      unmatchedHandlesList: (_) => const SidebarCassetteCardViewModel(
        title: 'Unmatched phone numbers & emails',
        subtitle:
            'Link stray handles to contacts to keep conversations organized.',
        child: UnmatchedHandlesCassette(),
      ),
      strayPhoneNumbers: () => const SidebarCassetteCardViewModel(
        title: 'Stray phone numbers',
        subtitle:
            'Phone numbers not linked to any contact in your address book.',
        child: StrayPhoneNumbersCassette(),
      ),
      strayEmails: () => const SidebarCassetteCardViewModel(
        title: 'Stray emails',
        subtitle:
            'Email addresses not linked to any contact in your address book.',
        child: StrayEmailsCassette(),
      ),
    );
  }
}
