import 'package:freezed_annotation/freezed_annotation.dart';

part 'sidebar_root_spec.freezed.dart';

/// When you see a SidebarRootSpec.contacts(), build the top of what will be
/// a sidebar
@freezed
abstract class SidebarRootSpec with _$SidebarRootSpec {
  const factory SidebarRootSpec.contacts() = _ContactsRoot;
  const factory SidebarRootSpec.unmatched() = _UnmatchedRoot;
  const factory SidebarRootSpec.allMessages() = _AllMessagesRoot;
}
