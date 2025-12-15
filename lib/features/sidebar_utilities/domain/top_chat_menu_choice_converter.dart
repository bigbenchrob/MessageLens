// lib/features/sidebar_utilities/domain/top_chat_menu_choice_converter.dart

import 'package:json_annotation/json_annotation.dart';

import './sidebar_utilities_constants.dart';

class TopChatMenuChoiceConverter
    implements JsonConverter<TopChatMenuChoice, String> {
  const TopChatMenuChoiceConverter();

  @override
  TopChatMenuChoice fromJson(String json) => TopChatMenuChoice.fromId(json);

  @override
  String toJson(TopChatMenuChoice object) => object.id;
}
