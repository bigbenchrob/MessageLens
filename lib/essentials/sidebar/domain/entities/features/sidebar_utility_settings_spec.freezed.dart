// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sidebar_utility_settings_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
SidebarUtilitySettingsSpec _$SidebarUtilitySettingsSpecFromJson(
  Map<String, dynamic> json
) {
    return _SidebarUtilitySettingsSpecSettingsMenu.fromJson(
      json
    );
}

/// @nodoc
mixin _$SidebarUtilitySettingsSpec {

 SettingsMenuChoice get selectedChoice;
/// Create a copy of SidebarUtilitySettingsSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SidebarUtilitySettingsSpecCopyWith<SidebarUtilitySettingsSpec> get copyWith => _$SidebarUtilitySettingsSpecCopyWithImpl<SidebarUtilitySettingsSpec>(this as SidebarUtilitySettingsSpec, _$identity);

  /// Serializes this SidebarUtilitySettingsSpec to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SidebarUtilitySettingsSpec&&(identical(other.selectedChoice, selectedChoice) || other.selectedChoice == selectedChoice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectedChoice);

@override
String toString() {
  return 'SidebarUtilitySettingsSpec(selectedChoice: $selectedChoice)';
}


}

/// @nodoc
abstract mixin class $SidebarUtilitySettingsSpecCopyWith<$Res>  {
  factory $SidebarUtilitySettingsSpecCopyWith(SidebarUtilitySettingsSpec value, $Res Function(SidebarUtilitySettingsSpec) _then) = _$SidebarUtilitySettingsSpecCopyWithImpl;
@useResult
$Res call({
 SettingsMenuChoice selectedChoice
});




}
/// @nodoc
class _$SidebarUtilitySettingsSpecCopyWithImpl<$Res>
    implements $SidebarUtilitySettingsSpecCopyWith<$Res> {
  _$SidebarUtilitySettingsSpecCopyWithImpl(this._self, this._then);

  final SidebarUtilitySettingsSpec _self;
  final $Res Function(SidebarUtilitySettingsSpec) _then;

/// Create a copy of SidebarUtilitySettingsSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedChoice = null,}) {
  return _then(_self.copyWith(
selectedChoice: null == selectedChoice ? _self.selectedChoice : selectedChoice // ignore: cast_nullable_to_non_nullable
as SettingsMenuChoice,
  ));
}

}


/// Adds pattern-matching-related methods to [SidebarUtilitySettingsSpec].
extension SidebarUtilitySettingsSpecPatterns on SidebarUtilitySettingsSpec {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _SidebarUtilitySettingsSpecSettingsMenu value)?  settingsMenu,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SidebarUtilitySettingsSpecSettingsMenu() when settingsMenu != null:
return settingsMenu(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _SidebarUtilitySettingsSpecSettingsMenu value)  settingsMenu,}){
final _that = this;
switch (_that) {
case _SidebarUtilitySettingsSpecSettingsMenu():
return settingsMenu(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _SidebarUtilitySettingsSpecSettingsMenu value)?  settingsMenu,}){
final _that = this;
switch (_that) {
case _SidebarUtilitySettingsSpecSettingsMenu() when settingsMenu != null:
return settingsMenu(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( SettingsMenuChoice selectedChoice)?  settingsMenu,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SidebarUtilitySettingsSpecSettingsMenu() when settingsMenu != null:
return settingsMenu(_that.selectedChoice);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( SettingsMenuChoice selectedChoice)  settingsMenu,}) {final _that = this;
switch (_that) {
case _SidebarUtilitySettingsSpecSettingsMenu():
return settingsMenu(_that.selectedChoice);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( SettingsMenuChoice selectedChoice)?  settingsMenu,}) {final _that = this;
switch (_that) {
case _SidebarUtilitySettingsSpecSettingsMenu() when settingsMenu != null:
return settingsMenu(_that.selectedChoice);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SidebarUtilitySettingsSpecSettingsMenu implements SidebarUtilitySettingsSpec {
  const _SidebarUtilitySettingsSpecSettingsMenu({this.selectedChoice = SettingsMenuChoice.contacts});
  factory _SidebarUtilitySettingsSpecSettingsMenu.fromJson(Map<String, dynamic> json) => _$SidebarUtilitySettingsSpecSettingsMenuFromJson(json);

@override@JsonKey() final  SettingsMenuChoice selectedChoice;

/// Create a copy of SidebarUtilitySettingsSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SidebarUtilitySettingsSpecSettingsMenuCopyWith<_SidebarUtilitySettingsSpecSettingsMenu> get copyWith => __$SidebarUtilitySettingsSpecSettingsMenuCopyWithImpl<_SidebarUtilitySettingsSpecSettingsMenu>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SidebarUtilitySettingsSpecSettingsMenuToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SidebarUtilitySettingsSpecSettingsMenu&&(identical(other.selectedChoice, selectedChoice) || other.selectedChoice == selectedChoice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectedChoice);

@override
String toString() {
  return 'SidebarUtilitySettingsSpec.settingsMenu(selectedChoice: $selectedChoice)';
}


}

/// @nodoc
abstract mixin class _$SidebarUtilitySettingsSpecSettingsMenuCopyWith<$Res> implements $SidebarUtilitySettingsSpecCopyWith<$Res> {
  factory _$SidebarUtilitySettingsSpecSettingsMenuCopyWith(_SidebarUtilitySettingsSpecSettingsMenu value, $Res Function(_SidebarUtilitySettingsSpecSettingsMenu) _then) = __$SidebarUtilitySettingsSpecSettingsMenuCopyWithImpl;
@override @useResult
$Res call({
 SettingsMenuChoice selectedChoice
});




}
/// @nodoc
class __$SidebarUtilitySettingsSpecSettingsMenuCopyWithImpl<$Res>
    implements _$SidebarUtilitySettingsSpecSettingsMenuCopyWith<$Res> {
  __$SidebarUtilitySettingsSpecSettingsMenuCopyWithImpl(this._self, this._then);

  final _SidebarUtilitySettingsSpecSettingsMenu _self;
  final $Res Function(_SidebarUtilitySettingsSpecSettingsMenu) _then;

/// Create a copy of SidebarUtilitySettingsSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedChoice = null,}) {
  return _then(_SidebarUtilitySettingsSpecSettingsMenu(
selectedChoice: null == selectedChoice ? _self.selectedChoice : selectedChoice // ignore: cast_nullable_to_non_nullable
as SettingsMenuChoice,
  ));
}


}

// dart format on
