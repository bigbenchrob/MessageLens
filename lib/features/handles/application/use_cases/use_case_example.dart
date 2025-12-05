// import 'package:responsive_sizer/responsive_sizer.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';

// import '../../../../domain_driven_development/value_objects.dart';
// import '../../../message/domain/entities/message_entity.dart';
// import '../../../message/infrastructure/repositories/message_repository.dart';
// import '../../infrastructure/repositories/chat_repository.dart';
// // import 'get_chats_interface.dart';

// part 'add_chat.g.dart';

// @riverpod
// class AddChatUseCase extends _$AddChatUseCase {
//   @override
//   Future<int> build(
//     String title,
//   ) async {
//     final repository = ref.watch(chatRepositoryProvider.notifier);
//     final newId = await repository.addChat(
//       title: title,
//     );
//     final messageRepository =
//         ref.watch(messageRepositoryProvider(newId).notifier);
//     final newMessageId = await messageRepository.addMessageEntity(
//       MessageEntity.welcome().copyWith(chatId: UniqueIntId(newId)),
//     );

//     return newMessageId;
//   }
// }
