import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart'
    as overlay_db;
import '../../domain/entities/favorite_contact.dart';

/// Repository for reading and mutating overlay-scoped favorite contacts.
class FavoriteContactsRepository {
  const FavoriteContactsRepository(this._database);

  final overlay_db.OverlayDatabase _database;

  FavoriteContact mapRow(overlay_db.FavoriteContact row) {
    return FavoriteContact(
      participantId: row.participantId,
      sortOrder: row.sortOrder,
      pinnedAt: DateTime.parse(row.createdAtUtc).toUtc(),
      lastInteractionAt: row.lastInteractionUtc != null
          ? DateTime.parse(row.lastInteractionUtc!).toUtc()
          : null,
      updatedAt: DateTime.parse(row.updatedAtUtc).toUtc(),
    );
  }

  List<FavoriteContact> mapRows(List<overlay_db.FavoriteContact> rows) {
    return rows.map(mapRow).toList(growable: false);
  }

  Future<List<FavoriteContact>> getAllFavorites() async {
    final rows = await _database.getAllFavorites();
    return mapRows(rows);
  }

  Future<void> addFavorite({
    required int participantId,
    DateTime? lastInteractionAt,
  }) {
    return _database.addFavorite(participantId, lastInteractionAt);
  }

  Future<void> removeFavorite(int participantId) {
    return _database.removeFavorite(participantId);
  }

  Future<void> updateFavorite({
    required int participantId,
    DateTime? lastInteractionAt,
    int? sortOrder,
  }) {
    return _database.updateFavorite(
      participantId: participantId,
      lastInteractionUtc: lastInteractionAt,
      sortOrder: sortOrder,
    );
  }

  Future<int> countFavorites() {
    return _database.getFavoriteCount();
  }
}
