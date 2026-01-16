import 'package:riverpod_annotation/riverpod_annotation.dart';

import './repositories/sqlite_chats_repository.dart';

part 'chats_repository_provider.g.dart';

/// Provider for the ChatsRepository implementation.
///
/// Wire dependencies via `ref.watch(...)` when infrastructure is ready.
@riverpod
class ChatsRepositoryProvider extends _$ChatsRepositoryProvider {
  @override
  SqliteChatsRepository build() {
    // Example (uncomment & adapt when database is wired):
    // final db = ref.watch(workingDbProvider);
    // return SqliteChatsRepository(db: db);
    return SqliteChatsRepository();
  }
}
