import '../../presentation/view_model/shared/hydration/attachment_info.dart';

/// Lightweight view model representing a message row rendered in the UI.
class MessageListItem {
  const MessageListItem({
    required this.id,
    required this.guid,
    required this.isFromMe,
    required this.senderName,
    required this.text,
    required this.sentAt,
    required this.hasAttachments,
    this.attachments = const [],
  });

  final int id;
  final String guid;
  final bool isFromMe;
  final String senderName;
  final String text;
  final DateTime? sentAt;
  final bool hasAttachments;
  final List<AttachmentInfo> attachments;
}
