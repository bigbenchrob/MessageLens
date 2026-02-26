# Import Rationalization Checklist

## Phase 1: Folder Reorganization

### db_importers Base Class
- [ ] Move `application/services/base_table_importer.dart` → `domain/base_table_importer.dart`
- [ ] Update import paths in all files referencing it

### db_importers Individual Importers
- [ ] Create `application/importers/` folder
- [ ] Move `attachments_importer.dart`
- [ ] Move `chats_importer.dart`
- [ ] Move `contacts_content_importer.dart`
- [ ] Move `contacts_importer.dart`
- [ ] Move `handle_to_participant_importer.dart`
- [ ] Move `handles_importer.dart`
- [ ] Move `import_ledger_row_importers.dart`
- [ ] Move `messages_importer.dart`
- [ ] Move `message_attachment_importer.dart`
- [ ] Move `message_to_handle_importer.dart`
- [ ] Move `chat_to_handle_importer.dart`
- [ ] Update import paths in orchestrator
- [ ] Update import paths in any barrel files

### db_migrate Base Class
- [ ] Move `application/services/base_table_migrator.dart` → `domain/base_table_migrator.dart`
- [ ] Update import paths in all files referencing it

### db_migrate Individual Migrators
- [ ] Create `application/migrators/` folder
- [ ] Move `app_settings_migrator.dart`
- [ ] Move `attachments_migrator.dart`
- [ ] Move `chat_to_handle_migrator.dart`
- [ ] Move `chats_migrator.dart`
- [ ] Move `handle_to_participant_migrator.dart`
- [ ] Move `handles_migrator.dart`
- [ ] Move `message_read_marks_migrator.dart`
- [ ] Move `messages_migrator.dart`
- [ ] Move `participants_migrator.dart`
- [ ] Move `projection_state_migrator.dart`
- [ ] Move `reaction_counts_migrator.dart`
- [ ] Move `reactions_migrator.dart`
- [ ] Move `read_state_migrator.dart`
- [ ] Move `supabase_sync_logs_migrator.dart`
- [ ] Move `supabase_sync_state_migrator.dart`
- [ ] Update import paths in orchestrator

### Phase 1 Verification
- [ ] `flutter analyze` passes
- [ ] All existing tests pass
- [ ] App runs without errors

---

## Phase 2: Row Progress Reporting Infrastructure

### Domain Layer
- [ ] Add `inProgress` to `TableImportStatus` enum
- [ ] Add `rowsProcessed`, `totalRows`, `currentItem` fields to `TableImportProgressEvent`
- [ ] Create `RowProgressCallback` typedef
- [ ] Create `RowProgressReporter` mixin

### Migration Side (Parallel Changes)
- [ ] Add `inProgress` to `TableMigrationStatus` enum
- [ ] Add row fields to `TableMigrationProgressEvent`

### Orchestrator Updates
- [ ] Update `ImportOrchestrator` to pass row callback to importers
- [ ] Update `MigrationOrchestrator` to pass row callback to migrators

### Phase 2 Verification
- [ ] New types compile
- [ ] Orchestrators work with new callback pattern

---

## Phase 3: Implement Row Progress in Importers

- [ ] `MessagesImporter` (proof of concept first)
- [ ] `AttachmentsImporter`
- [ ] `ChatsImporter`
- [ ] `ContactsContentImporter`
- [ ] `ContactsImporter`
- [ ] `HandleToParticipantImporter`
- [ ] `HandlesImporter`
- [ ] `MessageAttachmentImporter`
- [ ] `MessageToHandleImporter`
- [ ] `ChatToHandleImporter`

---

## Phase 4: Implement Row Progress in Migrators

- [ ] `MessagesMigrator` (proof of concept first)
- [ ] `AttachmentsMigrator`
- [ ] `ChatsMigrator`
- [ ] `HandlesMigrator`
- [ ] `ParticipantsMigrator`
- [ ] (remaining migrators as needed)

---

## Phase 5: Developer Control Panel Integration

- [ ] Update `db_import_control_provider.dart` to handle row progress events
- [ ] Update UI to show progress bars during copy phase
- [ ] Manual test with real data

---

## Phase 6: Onboarding Integration

- [ ] Wire progress events to onboarding provider
- [ ] Replace indeterminate spinners with real progress bars
- [ ] Test full onboarding flow
- [ ] Update `Ftr.db-onboard` branch with changes

---

## Final Verification

- [ ] `flutter analyze` clean
- [ ] All tests pass
- [ ] Manual test: Developer import control panel
- [ ] Manual test: Full onboarding flow
- [ ] Commit and push
