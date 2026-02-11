import 'package:drift/drift.dart';

import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../../infrastructure/data_sources/contact_message_index_data_source.dart';
import 'ordinal_strategy.dart';

/// Ordinal strategy for messages with a specific contact.
///
/// Queries the contact_message_index table which contains all messages
/// with a contact across all their handles/chats in chronological order.
class ContactOrdinalStrategy implements OrdinalStrategy {
  ContactOrdinalStrategy(this._db, this.contactId)
    : _dataSource = ContactMessageIndexDataSource(_db);

  final WorkingDatabase _db;
  final int contactId;
  final ContactMessageIndexDataSource _dataSource;

  @override
  Future<int> getTotalCount() => _dataSource.getTotalCount(contactId);

  @override
  Future<int?> getFirstOrdinalOnOrAfter(DateTime date) async {
    // Find first message on or after the given date for this contact.
    final isoString = date.toUtc().toIso8601String();
    final result =
        await (_db.selectOnly(_db.contactMessageIndex)
              ..addColumns([_db.contactMessageIndex.ordinal.min()])
              ..where(
                _db.contactMessageIndex.contactId.equals(contactId) &
                    _db.contactMessageIndex.sentAtUtc.isNotNull() &
                    _db.contactMessageIndex.sentAtUtc.isBiggerOrEqualValue(
                      isoString,
                    ),
              ))
            .getSingleOrNull();

    return result?.read(_db.contactMessageIndex.ordinal.min());
  }

  @override
  Future<int?> getFirstOrdinalForMonth(String monthKey) =>
      _dataSource.getFirstOrdinalForMonth(contactId, monthKey);

  @override
  Future<int?> getMessageIdByOrdinal(int ordinal) =>
      _dataSource.getMessageIdByOrdinal(contactId, ordinal);
}
