/// Describes the available query categories supported by the workbench.
enum WorkbenchQueryKind { handles, chats, messages }

/// Captures the raw query parameters supplied by the developer in the
/// workbench UI. The parameters intentionally remain nullable so the
/// application layer can determine precedence rules (for example, a chatId
/// overrides userId when building a messages query).
class WorkbenchQueryRequest {
  const WorkbenchQueryRequest({
    this.userId,
    this.chatId,
    this.handleId,
    this.messageId,
    this.searchText,
    this.offset = 0,
    this.limit = 50,
  });

  final int? userId;
  final int? chatId;
  final int? handleId;
  final int? messageId;
  final String? searchText;
  final int offset;
  final int limit;

  bool get hasAnyPrimaryIdentifier {
    return userId != null ||
        chatId != null ||
        handleId != null ||
        messageId != null;
  }

  WorkbenchQueryRequest copyWith({
    int? Function()? userId,
    int? Function()? chatId,
    int? Function()? handleId,
    int? Function()? messageId,
    String? Function()? searchText,
    int? offset,
    int? limit,
  }) {
    return WorkbenchQueryRequest(
      userId: userId != null ? userId() : this.userId,
      chatId: chatId != null ? chatId() : this.chatId,
      handleId: handleId != null ? handleId() : this.handleId,
      messageId: messageId != null ? messageId() : this.messageId,
      searchText: searchText != null ? searchText() : this.searchText,
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
    );
  }
}

/// Represents a single value in a result row together with the header label.
class WorkbenchResultCell {
  const WorkbenchResultCell({required this.label, required this.displayValue});

  final String label;
  final String displayValue;
}

/// Represents a single row of results returned from a workbench query.
class WorkbenchResultRow {
  const WorkbenchResultRow({required this.kind, required this.cells});

  final WorkbenchQueryKind kind;
  final List<WorkbenchResultCell> cells;
}

/// Encapsulates the outcome of executing a workbench query, including the
/// source request and the returned rows. Pagination metadata will allow the UI
/// to render paging controls in future iterations.
class WorkbenchQueryResult {
  const WorkbenchQueryResult({
    required this.request,
    required this.kind,
    required this.rows,
    required this.totalCount,
  });

  final WorkbenchQueryRequest request;
  final WorkbenchQueryKind kind;
  final List<WorkbenchResultRow> rows;
  final int totalCount;
}
