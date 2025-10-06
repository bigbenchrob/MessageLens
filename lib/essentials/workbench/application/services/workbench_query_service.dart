import '../../domain/entities/workbench_query_models.dart';
import '../../domain/i_repositories/workbench_query_repository.dart';
import '../../domain/value_objects/workbench_form_field_definition.dart';

class WorkbenchQueryService {
  WorkbenchQueryService({required WorkbenchQueryRepository repository})
    : _repository = repository;

  final WorkbenchQueryRepository _repository;

  Future<WorkbenchQueryResult> execute({
    required WorkbenchQueryKind kind,
    required WorkbenchQueryRequest request,
  }) {
    return _repository.runQuery(kind: kind, request: request);
  }

  WorkbenchQueryRequest normalizeRequest(
    WorkbenchQueryRequest current,
    Map<WorkbenchFormFieldKey, String> rawFields,
  ) {
    var updated = current;

    void applyNumeric(WorkbenchFormFieldKey key) {
      final raw = rawFields[key];
      if (raw == null || raw.trim().isEmpty) {
        updated = updated.copyWith(
          userId: key == WorkbenchFormFieldKey.userId ? () => null : null,
          chatId: key == WorkbenchFormFieldKey.chatId ? () => null : null,
          handleId: key == WorkbenchFormFieldKey.handleId ? () => null : null,
          messageId: key == WorkbenchFormFieldKey.messageId ? () => null : null,
          limit: key == WorkbenchFormFieldKey.limit ? 50 : null,
        );
        return;
      }

      final parsed = int.tryParse(raw.trim());
      updated = switch (key) {
        WorkbenchFormFieldKey.userId => updated.copyWith(userId: () => parsed),
        WorkbenchFormFieldKey.chatId => updated.copyWith(chatId: () => parsed),
        WorkbenchFormFieldKey.handleId => updated.copyWith(
          handleId: () => parsed,
        ),
        WorkbenchFormFieldKey.messageId => updated.copyWith(
          messageId: () => parsed,
        ),
        WorkbenchFormFieldKey.limit => updated.copyWith(
          limit: parsed ?? updated.limit,
        ),
        _ => updated,
      };
    }

    applyNumeric(WorkbenchFormFieldKey.userId);
    applyNumeric(WorkbenchFormFieldKey.chatId);
    applyNumeric(WorkbenchFormFieldKey.handleId);
    applyNumeric(WorkbenchFormFieldKey.messageId);
    applyNumeric(WorkbenchFormFieldKey.limit);

    final search = rawFields[WorkbenchFormFieldKey.searchText];
    updated = updated.copyWith(
      searchText: () => search == null || search.isEmpty ? null : search,
    );

    return updated;
  }
}
