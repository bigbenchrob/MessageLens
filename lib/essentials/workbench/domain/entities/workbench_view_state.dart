import '../value_objects/workbench_form_field_definition.dart';
import 'workbench_query_models.dart';

class WorkbenchViewState {
  const WorkbenchViewState({
    required this.request,
    this.pendingKind,
    this.lastResult,
    this.isLoading = false,
    this.errorMessage,
    this.fields = const <WorkbenchFormFieldKey, String>{},
  });

  factory WorkbenchViewState.initial() {
    return const WorkbenchViewState(request: WorkbenchQueryRequest());
  }

  final WorkbenchQueryRequest request;
  final WorkbenchQueryKind? pendingKind;
  final WorkbenchQueryResult? lastResult;
  final bool isLoading;
  final String? errorMessage;
  final Map<WorkbenchFormFieldKey, String> fields;

  WorkbenchViewState copyWith({
    WorkbenchQueryRequest? request,
    WorkbenchQueryKind? pendingKind,
    bool clearPendingKind = false,
    WorkbenchQueryResult? lastResult,
    bool clearResult = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    Map<WorkbenchFormFieldKey, String>? fields,
  }) {
    return WorkbenchViewState(
      request: request ?? this.request,
      pendingKind: clearPendingKind ? null : pendingKind ?? this.pendingKind,
      lastResult: clearResult ? null : lastResult ?? this.lastResult,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      fields: fields ?? this.fields,
    );
  }
}
