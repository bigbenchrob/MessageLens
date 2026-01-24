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
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$SidebarUtilityCassetteSpecTopChatMenuToJson(
  _SidebarUtilityCassetteSpecTopChatMenu instance,
) => <String, dynamic>{
  'selectedChoice': _$TopChatMenuChoiceEnumMap[instance.selectedChoice]!,
  'runtimeType': instance.$type,
};

const _$TopChatMenuChoiceEnumMap = {
  TopChatMenuChoice.contacts: 'contacts',
  TopChatMenuChoice.strayEmails: 'strayEmails',
  TopChatMenuChoice.strayPhoneNumbers: 'strayPhoneNumbers',
  TopChatMenuChoice.searchAllMessages: 'searchAllMessages',
  TopChatMenuChoice.themePlayground: 'themePlayground',
};

_SidebarUtilityCassetteSpecSettingsMenu
_$SidebarUtilityCassetteSpecSettingsMenuFromJson(Map<String, dynamic> json) =>
    _SidebarUtilityCassetteSpecSettingsMenu(
      selectedChoice:
          $enumDecodeNullable(
            _$SettingsMenuChoiceEnumMap,
            json['selectedChoice'],
          ) ??
          SettingsMenuChoice.contacts,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$SidebarUtilityCassetteSpecSettingsMenuToJson(
  _SidebarUtilityCassetteSpecSettingsMenu instance,
) => <String, dynamic>{
  'selectedChoice': _$SettingsMenuChoiceEnumMap[instance.selectedChoice]!,
  'runtimeType': instance.$type,
};

const _$SettingsMenuChoiceEnumMap = {SettingsMenuChoice.contacts: 'contacts'};
