import 'workbench_query_models.dart';

/// Describes a runnable query option surfaced in the workbench UI.
class WorkbenchQueryAction {
  const WorkbenchQueryAction({
    required this.kind,
    required this.label,
    required this.description,
  });

  final WorkbenchQueryKind kind;
  final String label;
  final String description;
}
