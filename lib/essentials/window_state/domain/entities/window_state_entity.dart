import 'package:freezed_annotation/freezed_annotation.dart';

part 'window_state_entity.freezed.dart';

@freezed
abstract class WindowStateEntity with _$WindowStateEntity {
  const factory WindowStateEntity({
    required double width,
    required double height,
    required double x,
    required double y,
    required bool isMinimized,
    required double sidebarWidth,
  }) = _WindowStateEntity;

  factory WindowStateEntity.defaultState() => const WindowStateEntity(
    width: 1200.0,
    height: 800.0,
    x: 100.0,
    y: 100.0,
    isMinimized: false,
    sidebarWidth: 320.0,
  );
}
