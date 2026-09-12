import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'startup_validation_telemetry_buffer.dart';

part 'startup_validation_telemetry_provider.g.dart';

@Riverpod(keepAlive: true)
StartupValidationTelemetryBuffer startupValidationTelemetry(Ref ref) {
  return StartupValidationTelemetryBuffer();
}
