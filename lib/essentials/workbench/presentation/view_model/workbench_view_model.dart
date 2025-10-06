import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/providers/workbench_form_definitions_provider.dart';
import '../../application/providers/workbench_query_actions_provider.dart';
import '../../application/providers/workbench_query_service_provider.dart';
import '../../domain/entities/workbench_query_action.dart';
import '../../domain/entities/workbench_query_models.dart';
import '../../domain/entities/workbench_view_state.dart';
import '../../domain/value_objects/workbench_form_field_definition.dart';

part 'workbench_view_model.g.dart';

@riverpod
class WorkbenchViewModel extends _$WorkbenchViewModel {
  @override
  WorkbenchViewState build() {
    return WorkbenchViewState.initial();
  }

  List<WorkbenchFormFieldDefinition> get fieldDefinitions {
    return ref.watch(workbenchFormDefinitionsProvider);
  }

  List<WorkbenchQueryAction> get actions {
    return ref.watch(workbenchQueryActionsProvider);
  }

  void updateField(WorkbenchFormFieldKey key, String value) {
    final updatedFields = {...state.fields, key: value};
    state = state.copyWith(fields: updatedFields);
  }

  Future<void> runQuery(WorkbenchQueryKind kind) async {
    state = state.copyWith(
      pendingKind: kind,
      isLoading: true,
      clearError: true,
    );

    try {
      final service = await ref.read(workbenchQueryServiceProvider.future);
      final normalizedRequest = service.normalizeRequest(
        state.request,
        state.fields,
      );

      final result = await service.execute(
        kind: kind,
        request: normalizedRequest,
      );

      state = state.copyWith(
        request: normalizedRequest,
        lastResult: result,
        isLoading: false,
        clearPendingKind: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '$error',
        clearPendingKind: true,
      );
    }
  }

  void clearResults() {
    state = state.copyWith(clearResult: true, clearError: true);
  }
}
