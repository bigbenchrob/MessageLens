/// Current on-disk schema version for the source-scoped import database.
const int sourceScopedImportSchemaVersion = 10;

/// Current on-disk schema version for the Conversation Graph database.
///
/// This dependency-light constant is shared by the database implementation and
/// read-only lifecycle inspectors so schema compatibility cannot drift between
/// those boundaries.
const int conversationGraphSchemaVersion = 3;

/// Current on-disk schema version for the user overlay database.
const int overlaySchemaVersion = 8;

/// Current on-disk schema version for the Presence database.
const int presenceSchemaVersion = 9;
