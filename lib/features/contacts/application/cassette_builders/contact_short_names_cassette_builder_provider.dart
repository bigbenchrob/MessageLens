import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/sidebar/presentation/models/cassette_card_view.dart';
import '../../presentation/cassettes/settings/contact_short_names_settings_cassette.dart';

part 'contact_short_names_cassette_builder_provider.g.dart';

@riverpod
CassetteCardView contactShortNamesCassetteBuilder(Ref ref) {
  return const CassetteCardView(
    title: 'Short Names',
    subtitle: 'How contact names appear throughout the app',
    sectionTitle: 'Display format',
    footerText:
        'Nicknames override imported contact names without modifying system data.',
    shouldExpand: false,
    child: ContactShortNamesSettingsCassette(),
  );
}
