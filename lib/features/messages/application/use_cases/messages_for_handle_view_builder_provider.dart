import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/view/messages_for_handle_view.dart';

part 'messages_for_handle_view_builder_provider.g.dart';

@riverpod
Widget messagesForHandleViewBuilder(Ref ref, int handleId) {
  return MessagesForHandleView(handleId: handleId);
}
