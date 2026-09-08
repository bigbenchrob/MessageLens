import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/config/theme/colors/theme_colors.dart';
import 'package:remember_this_text/config/theme/theme_typography.dart';
import 'package:remember_this_text/essentials/app_mode/application/app_mode_providers.dart';
import 'package:remember_this_text/features/conversations/presentation/widgets/conversation_signature_card_presentation.dart';

void main() {
  for (final brightness in Brightness.values) {
    test(
      'selected card uses the durable selected surface in ${brightness.name}',
      () {
        final container = ProviderContainer(
          overrides: [
            platformBrightnessProvider.overrideWith((ref) => brightness),
          ],
        );
        addTearDown(container.dispose);

        final colors = container.read(themeColorsProvider.notifier);
        final typography = container.read(themeTypographyProvider);
        final expected = colors.surfaces.selectedRegion;

        expect(
          conversationSignatureCardStyle(
            colors,
            typography,
          ).selectedBackgroundColor,
          expected,
        );
        expect(
          favouriteConversationSignatureCardStyle(
            colors,
            typography,
          ).selectedBackgroundColor,
          expected,
        );
        expect(expected, isNot(colors.surfaces.selected));
        expect(
          expected.toARGB32(),
          brightness == Brightness.light ? 0xFFD6EDFB : 0xFF3A5064,
        );
      },
    );
  }
}
