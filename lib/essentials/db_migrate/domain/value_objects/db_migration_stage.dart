/// High-level stages emitted during the ledger-to-working projection pipeline.
///
/// Each stage exposes a stable [key] for analytics and a human-readable
/// [label] suitable for progress UI.
enum DbMigrationStage {
  preparingSources('preparingSources', 'Preparing ledger data'),
  clearingWorking('clearingWorking', 'Clearing working projections'),
  loadingContacts('loadingContacts', 'Loading contact metadata'),
  migratingIdentities('migratingIdentities', 'Projecting identities'),
  migratingChats('migratingChats', 'Projecting chats and participants'),
  migratingMessages('migratingMessages', 'Projecting messages'),
  migratingAttachments('migratingAttachments', 'Projecting attachments'),
  migratingReactions('migratingReactions', 'Projecting reactions'),
  indexing('indexing', 'Building indexes'),
  updatingProjectionState(
    'updatingProjectionState',
    'Updating projection state',
  ),
  mirroringSupabase('mirroringSupabase', 'Mirroring to Supabase'),
  completed('completed', 'Projection completed');

  const DbMigrationStage(this.key, this.label);

  /// Stable identifier suitable for logs/analytics.
  final String key;

  /// Human friendly description for progress UI.
  final String label;
}
