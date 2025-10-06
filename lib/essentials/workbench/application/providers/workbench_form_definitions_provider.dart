import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/value_objects/workbench_form_field_definition.dart';

part 'workbench_form_definitions_provider.g.dart';

@riverpod
List<WorkbenchFormFieldDefinition> workbenchFormDefinitions(Ref ref) {
  return const [
    WorkbenchFormFieldDefinition(
      key: WorkbenchFormFieldKey.userId,
      label: 'User ID',
      placeholder: 'e.g. 42',
      helperText: 'Limit results to a specific user',
      isNumeric: true,
    ),
    WorkbenchFormFieldDefinition(
      key: WorkbenchFormFieldKey.chatId,
      label: 'Chat ID',
      placeholder: 'Optional override when known',
      helperText: 'Overrides user ID for message queries',
      isNumeric: true,
    ),
    WorkbenchFormFieldDefinition(
      key: WorkbenchFormFieldKey.handleId,
      label: 'Handle ID',
      placeholder: 'Specific handle row ID',
      helperText: 'Narrows chats/handles to a single address',
      isNumeric: true,
    ),
    WorkbenchFormFieldDefinition(
      key: WorkbenchFormFieldKey.messageId,
      label: 'Message ID',
      placeholder: 'Jump directly to a message',
      helperText: 'Useful for inspecting a single record',
      isNumeric: true,
    ),
    WorkbenchFormFieldDefinition(
      key: WorkbenchFormFieldKey.searchText,
      label: 'Search Text',
      placeholder: 'Contains text filter',
      helperText: 'Applies to message body queries',
    ),
    WorkbenchFormFieldDefinition(
      key: WorkbenchFormFieldKey.limit,
      label: 'Limit',
      placeholder: 'Default 50',
      helperText: 'Adjust result size for debugging',
      isNumeric: true,
    ),
  ];
}
