import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/config/theme/colors/theme_colors.dart';
import 'package:remember_this_text/config/theme/widgets/heatmap/activity_heatmap_color_scale.dart';
import 'package:remember_this_text/essentials/app_mode/application/app_mode_providers.dart';
import 'package:remember_this_text/features/conversations/presentation/widgets/conversation_signature_card_presentation.dart';
import 'package:remember_this_text/features/messages/domain/calendar_heatmap_timeline_data.dart';

void main() {
  const cases = <(int, MonthIntensity, Color)>[
    (0, MonthIntensity.empty, Color(0x00000000)),
    (1, MonthIntensity.fewDots, Color(0x00000000)),
    (3, MonthIntensity.fewDots, Color(0x00000000)),
    (4, MonthIntensity.sparse4To10, Color(0xFFE8E8E8)),
    (10, MonthIntensity.sparse4To10, Color(0xFFE8E8E8)),
    (11, MonthIntensity.sparse11To30, Color(0xFFCFCFCF)),
    (30, MonthIntensity.sparse11To30, Color(0xFFCFCFCF)),
    (31, MonthIntensity.sparse31To50, Color(0xFFA5A5A5)),
    (50, MonthIntensity.sparse31To50, Color(0xFFA5A5A5)),
    (51, MonthIntensity.active51To100, Color(0xFFFDE725)),
    (100, MonthIntensity.active51To100, Color(0xFFFDE725)),
    (101, MonthIntensity.active101To300, Color(0xFFAADC32)),
    (300, MonthIntensity.active101To300, Color(0xFFAADC32)),
    (301, MonthIntensity.active301To1000, Color(0xFF5CC863)),
    (1000, MonthIntensity.active301To1000, Color(0xFF5CC863)),
    (1001, MonthIntensity.active1001To3000, Color(0xFF28AE80)),
    (3000, MonthIntensity.active1001To3000, Color(0xFF28AE80)),
    (3001, MonthIntensity.active3001To10000, Color(0xFF2C728E)),
    (10000, MonthIntensity.active3001To10000, Color(0xFF2C728E)),
    (10001, MonthIntensity.active10001Plus, Color(0xFF472D7B)),
    (100000, MonthIntensity.active10001Plus, Color(0xFF472D7B)),
  ];

  test('explicit bins map boundary counts to the shared two-regime scale', () {
    for (final (count, intensity, color) in cases) {
      expect(
        MonthIntensity.fromMessageCount(count),
        intensity,
        reason: 'Unexpected intensity for $count messages',
      );
      expect(
        activityHeatmapColorForMessageCount(count),
        color,
        reason: 'Unexpected color for $count messages',
      );
    }
  });

  test('Conversation glyphs use the shared message-activity scale', () {
    for (final (count, _, color) in cases) {
      expect(
        conversationSignatureMonthColorForMessageCount(count),
        color,
        reason: 'Conversation glyph diverged at $count messages',
      );
    }
  });

  test('empty-month structural outline resolves independently by mode', () {
    const expectations = <Brightness, Color>{
      Brightness.light: Color(0xFFA8AEB0),
      Brightness.dark: Color(0xFFD0D0D0),
    };

    for (final MapEntry(key: brightness, value: expected)
        in expectations.entries) {
      final container = ProviderContainer(
        overrides: [
          platformBrightnessProvider.overrideWith((ref) => brightness),
        ],
      );
      addTearDown(container.dispose);

      final colors = container.read(themeColorsProvider.notifier);
      expect(colors.lines.heatmapEmptyMonthOutline, expected);
    }
  });
}
