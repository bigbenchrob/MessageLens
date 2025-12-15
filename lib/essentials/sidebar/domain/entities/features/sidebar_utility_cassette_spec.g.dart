// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sidebar_utility_cassette_spec.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SidebarUtilityCassetteSpecTopChatMenu
_$SidebarUtilityCassetteSpecTopChatMenuFromJson(Map<String, dynamic> json) =>
    _SidebarUtilityCassetteSpecTopChatMenu(
      selectedChoice:
          $enumDecodeNullable(
            _$TopChatMenuChoiceEnumMap,
            json['selectedChoice'],
          ) ??
          TopChatMenuChoice.contacts,
    );

Map<String, dynamic> _$SidebarUtilityCassetteSpecTopChatMenuToJson(
  _SidebarUtilityCassetteSpecTopChatMenu instance,
) => <String, dynamic>{
  'selectedChoice': _$TopChatMenuChoiceEnumMap[instance.selectedChoice]!,
};

const _$TopChatMenuChoiceEnumMap = {
  TopChatMenuChoice.contacts: 'contacts',
  TopChatMenuChoice.unmatchedHandles: 'unmatchedHandles',
  TopChatMenuChoice.allMessages: 'allMessages',
  TopChatMenuChoice.themePlayground: 'themePlayground',
};
