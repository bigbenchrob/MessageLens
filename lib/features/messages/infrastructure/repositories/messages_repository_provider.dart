import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'sqlite_messages_repository.dart';

part 'messages_repository_provider.g.dart';

/// Provides the [SqliteMessagesRepository] instance.
///
/// Wire real dependencies with ref.watch(...) as you implement infra.
@riverpod
class MessagesRepository extends _$MessagesRepository {
  @override
  SqliteMessagesRepository build() {
    // final db = ref.watch(workingDbProvider);
    // return SqliteMessagesRepository(db: db);
    return SqliteMessagesRepository();
  }
}
