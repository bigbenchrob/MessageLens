import '../application/conversation_graph_build_observation.dart';

String conversationGraphBuildStageLabel(
  ConversationGraphBuildSuboperation? suboperation, {
  String preparingLabel = 'Preparing the supported graph build',
}) {
  return switch (suboperation) {
    null => preparingLabel,
    ConversationGraphBuildSuboperation.importChats => 'Importing conversations',
    ConversationGraphBuildSuboperation.importHandles => 'Importing handles',
    ConversationGraphBuildSuboperation.importContacts => 'Importing contacts',
    ConversationGraphBuildSuboperation.importContactEmailChannels =>
      'Importing contact email channels',
    ConversationGraphBuildSuboperation.importContactPhoneChannels =>
      'Importing contact phone channels',
    ConversationGraphBuildSuboperation.importMessages => 'Importing messages',
    ConversationGraphBuildSuboperation.extractRichText =>
      'Reading message formatting',
    ConversationGraphBuildSuboperation.persistRichText =>
      'Saving message formatting',
    ConversationGraphBuildSuboperation.importAttachments =>
      'Importing attachment facts',
    ConversationGraphBuildSuboperation.importChatMessageRelationships =>
      'Linking messages to conversations',
    ConversationGraphBuildSuboperation.importChatHandleRelationships =>
      'Linking handles to conversations',
    ConversationGraphBuildSuboperation.importMessageAttachmentRelationships =>
      'Linking attachments to messages',
    ConversationGraphBuildSuboperation.projectHandles => 'Updating handles',
    ConversationGraphBuildSuboperation.projectContacts => 'Updating contacts',
    ConversationGraphBuildSuboperation.projectChatHandleRelationships =>
      'Updating conversation participants',
    ConversationGraphBuildSuboperation.projectConversations =>
      'Updating conversation data',
    ConversationGraphBuildSuboperation.projectMessages =>
      'Updating message data',
    ConversationGraphBuildSuboperation.projectAttachments =>
      'Updating attachment data',
    ConversationGraphBuildSuboperation.projectChatMessageRelationships =>
      'Updating conversation-message links',
    ConversationGraphBuildSuboperation.projectMessageAttachmentRelationships =>
      'Updating message-attachment links',
  };
}
