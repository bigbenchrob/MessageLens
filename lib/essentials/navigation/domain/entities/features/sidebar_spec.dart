import 'package:freezed_annotation/freezed_annotation.dart';

import 'chat_view_mode.dart';
import 'contacts_list_spec.dart';
import 'handles_list_spec.dart';

part 'sidebar_spec.freezed.dart';

@freezed
abstract class SidebarSpec with _$SidebarSpec {
  /// Tier 1: Show contacts list, optionally filtered to one contact's chats
  const factory SidebarSpec.contacts({
    required ContactsListSpec listMode,
    int? selectedParticipantId,
    @Default(ChatViewMode.recentActivity) ChatViewMode chatViewMode,
  }) = SidebarSpecContacts;

  /// Tier 2: Show unmatched handles (no participant link)
  const factory SidebarSpec.unmatchedHandles({
    required HandlesListSpec listMode,
  }) = SidebarSpecUnmatchedHandles;
}
