// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sidebar_utility_settings_spec.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SidebarUtilitySettingsSpecSettingsMenu
_$SidebarUtilitySettingsSpecSettingsMenuFromJson(Map<String, dynamic> json) =>
    _SidebarUtilitySettingsSpecSettingsMenu(
      selectedChoice:
          $enumDecodeNullable(
            _$SettingsMenuChoiceEnumMap,
            json['selectedChoice'],
          ) ??
          SettingsMenuChoice.contacts,
    );

Map<String, dynamic> _$SidebarUtilitySettingsSpecSettingsMenuToJson(
  _SidebarUtilitySettingsSpecSettingsMenu instance,
) => <String, dynamic>{
  'selectedChoice': _$SettingsMenuChoiceEnumMap[instance.selectedChoice]!,
};

const _$SettingsMenuChoiceEnumMap = {SettingsMenuChoice.contacts: 'contacts'};
