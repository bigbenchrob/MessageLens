import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'db_maintenance_lock_provider.g.dart';

/// Global maintenance lock used to temporarily suppress reads that would
/// re-open databases while destructive maintenance operations are running.
///
/// This is intentionally simple: UI/features can watch this and either show a
/// placeholder or avoid triggering DB provider creation.
@riverpod
class DbMaintenanceLock extends _$DbMaintenanceLock {
  @override
  bool build() => false;

  void begin() {
    state = true;
  }

  void end() {
    state = false;
  }
}
