import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/workbench_query_action.dart';
import '../../domain/entities/workbench_query_models.dart';

part 'workbench_query_actions_provider.g.dart';

@riverpod
List<WorkbenchQueryAction> workbenchQueryActions(Ref ref) {
  return const [
    WorkbenchQueryAction(
      kind: WorkbenchQueryKind.handles,
      label: 'Handles',
      description: 'List handles for the provided user or handle ID',
    ),
    WorkbenchQueryAction(
      kind: WorkbenchQueryKind.chats,
      label: 'Chats',
      description: 'Fetch chats related to the selected user or handle',
    ),
    WorkbenchQueryAction(
      kind: WorkbenchQueryKind.messages,
      label: 'Messages',
      description: 'Show messages filtered by user, handle, or chat',
    ),
  ];
}
