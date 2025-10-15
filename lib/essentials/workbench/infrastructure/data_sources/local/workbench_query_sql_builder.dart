import '../../../domain/entities/workbench_query_models.dart';

class WorkbenchSqlStatement {
  const WorkbenchSqlStatement({
    required this.sql,
    this.parameters = const <Object?>[],
  });

  final String sql;
  final List<Object?> parameters;
}

class WorkbenchQuerySqlBuilder {
  WorkbenchSqlStatement buildStatement({
    required WorkbenchQueryKind kind,
    required WorkbenchQueryRequest request,
  }) {
    switch (kind) {
      case WorkbenchQueryKind.handles:
        return _buildHandlesStatement(request);
      case WorkbenchQueryKind.chats:
        return _buildChatsStatement(request);
      case WorkbenchQueryKind.messages:
        return _buildMessagesStatement(request);
    }
  }

  WorkbenchSqlStatement _buildHandlesStatement(WorkbenchQueryRequest request) {
    final clauses = <String>[];
    final params = <Object?>[];
    final joins = <String>[];
    final searchText = request.searchText;
    final limit = request.limit;
    final offset = request.offset;

    if (request.handleId != null) {
      clauses.add('h.id = ?');
      params.add(request.handleId);
    }

    if (request.userId != null) {
      clauses.add('cpe.contact_id = ?');
      params.add(request.userId);
      joins.add('JOIN contact_phone_email cpe ON cpe.value = h.raw_identifier');
    }

    if (searchText != null && searchText.isNotEmpty) {
      clauses.add('(h.raw_identifier LIKE ? OR h.compound_identifier LIKE ?)');
      final pattern = '%$searchText%';
      params.addAll([pattern, pattern]);
    }

    final buffer = StringBuffer(
      'SELECT h.id, h.service, h.raw_identifier, '
      'h.compound_identifier, h.country, h.last_seen_utc, h.is_ignored '
      'FROM handles h',
    );

    if (joins.isNotEmpty) {
      buffer.write(' ${joins.join(' ')}');
    }

    if (clauses.isNotEmpty) {
      buffer.write(' WHERE ${clauses.join(' AND ')}');
    }

    buffer.write(' ORDER BY h.id DESC');
    buffer.write(' LIMIT ? OFFSET ?');
    params
      ..add(limit)
      ..add(offset);

    return WorkbenchSqlStatement(sql: buffer.toString(), parameters: params);
  }

  WorkbenchSqlStatement _buildChatsStatement(WorkbenchQueryRequest request) {
    final joins = <String>[];
    final clauses = <String>[];
    final params = <Object?>[];

    final limit = request.limit;
    final offset = request.offset;

    if (request.chatId != null) {
      clauses.add('c.id = ?');
      params.add(request.chatId);
    }

    if (request.handleId != null) {
      joins.add('JOIN chat_to_handle cth ON cth.chat_id = c.id');
      clauses.add('cth.handle_id = ?');
      params.add(request.handleId);
    }

    final userId = request.userId;
    if (userId != null) {
      joins.add('JOIN handles h ON h.id = cth.handle_id');
      joins.add('JOIN contact_phone_email cpe ON cpe.value = h.raw_identifier');
      clauses.add('cpe.contact_id = ?');
      params.add(userId);
    }

    final buffer = StringBuffer(
      'SELECT DISTINCT c.id, c.guid, c.display_name, c.service, c.is_group, '
      'c.created_at_utc, c.updated_at_utc, c.is_ignored '
      'FROM chats c',
    );

    if (joins.isNotEmpty) {
      buffer.write(' ${joins.join(' ')}');
    }

    if (clauses.isNotEmpty) {
      buffer.write(' WHERE ${clauses.join(' AND ')}');
    }

    buffer.write(' ORDER BY c.id DESC');
    buffer.write(' LIMIT ? OFFSET ?');
    params
      ..add(limit)
      ..add(offset);

    return WorkbenchSqlStatement(sql: buffer.toString(), parameters: params);
  }

  WorkbenchSqlStatement _buildMessagesStatement(WorkbenchQueryRequest request) {
    final joins = <String>['JOIN chats c ON c.id = m.chat_id'];
    final clauses = <String>[];
    final params = <Object?>[];

    final limit = request.limit;
    final offset = request.offset;
    final searchText = request.searchText;

    if (request.messageId != null) {
      clauses.add('m.id = ?');
      params.add(request.messageId);
    }

    if (request.chatId != null) {
      clauses.add('m.chat_id = ?');
      params.add(request.chatId);
    } else if (request.userId != null || request.handleId != null) {
      joins.add('LEFT JOIN chat_to_handle cth ON cth.chat_id = m.chat_id');
      joins.add(
        'LEFT JOIN handles h ON h.id = COALESCE(m.sender_handle_id, cth.handle_id)',
      );

      if (request.userId != null) {
        clauses.add('(h.owner_user_id = ?)');
        params.add(request.userId);
      }
      if (request.handleId != null) {
        clauses.add('(cth.handle_id = ? OR m.sender_handle_id = ?)');
        params.addAll([request.handleId, request.handleId]);
      }
    }

    if (searchText != null && searchText.isNotEmpty) {
      clauses.add('m.text LIKE ?');
      params.add('%$searchText%');
    }

    final buffer = StringBuffer(
      'SELECT m.id, m.chat_id, m.sender_handle_id, m.guid, m.text, m.date_utc, '
      'm.is_from_me, m.item_type, m.is_ignored, m.error_code '
      'FROM messages m ${joins.join(' ')}',
    );

    if (clauses.isNotEmpty) {
      buffer.write(' WHERE ${clauses.join(' AND ')}');
    }

    buffer.write(' ORDER BY m.date_utc DESC');
    buffer.write(' LIMIT ? OFFSET ?');
    params
      ..add(limit)
      ..add(offset);

    return WorkbenchSqlStatement(sql: buffer.toString(), parameters: params);
  }
}
