/// Identifies the supported parameter slots in the workbench form.
enum WorkbenchFormFieldKey {
  userId,
  chatId,
  handleId,
  messageId,
  searchText,
  limit,
}

class WorkbenchFormFieldDefinition {
  const WorkbenchFormFieldDefinition({
    required this.key,
    required this.label,
    this.placeholder,
    this.helperText,
    this.isNumeric = false,
  });

  final WorkbenchFormFieldKey key;
  final String label;
  final String? placeholder;
  final String? helperText;
  final bool isNumeric;
}
