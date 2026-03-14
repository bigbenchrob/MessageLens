import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../db/feature_level_providers.dart';

part 'developer_mode_provider.g.dart';

enum DeveloperModeValue {
  user,
  developer;

  static DeveloperModeValue fromStorage(String? rawValue) {
    return switch (rawValue) {
      'developer' => DeveloperModeValue.developer,
      _ => DeveloperModeValue.user,
    };
  }

  String get storageValue {
    return switch (this) {
      DeveloperModeValue.user => 'user',
      DeveloperModeValue.developer => 'developer',
    };
  }
}

@riverpod
class DeveloperMode extends _$DeveloperMode {
  static const String _settingKey = 'developer_mode';

  @override
  Future<DeveloperModeValue> build() async {
    if (kReleaseMode) {
      return DeveloperModeValue.user;
    }

    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    final rawValue = await overlayDb.readOverlaySetting(_settingKey);
    if (rawValue == null) {
      return DeveloperModeValue.developer;
    }

    return DeveloperModeValue.fromStorage(rawValue);
  }

  Future<void> setMode(DeveloperModeValue mode) async {
    if (kReleaseMode) {
      state = const AsyncData(DeveloperModeValue.user);
      return;
    }

    state = await AsyncValue.guard(() async {
      final overlayDb = await ref.read(overlayDatabaseProvider.future);
      await overlayDb.writeOverlaySetting(
        settingKey: _settingKey,
        settingValue: mode.storageValue,
      );
      return mode;
    });
  }

  Future<void> setDeveloperModeEnabled(bool enabled) async {
    await setMode(
      enabled ? DeveloperModeValue.developer : DeveloperModeValue.user,
    );
  }

  Future<void> toggleMode() async {
    final nextMode = state.valueOrNull == DeveloperModeValue.developer
        ? DeveloperModeValue.user
        : DeveloperModeValue.developer;
    await setMode(nextMode);
  }
}
