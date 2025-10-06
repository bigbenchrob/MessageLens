import 'package:freezed_annotation/freezed_annotation.dart';

part 'workbench_spec.freezed.dart';

@freezed
abstract class WorkbenchSpec with _$WorkbenchSpec {
  const factory WorkbenchSpec.panel() = _WorkbenchPanel;

  const WorkbenchSpec._();
}
