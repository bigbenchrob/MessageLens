/// Current on-disk schema version for the Conversation Graph database.
///
/// This dependency-light constant is shared by the database implementation and
/// read-only lifecycle inspectors so schema compatibility cannot drift between
/// those boundaries.
const int conversationGraphSchemaVersion = 3;
