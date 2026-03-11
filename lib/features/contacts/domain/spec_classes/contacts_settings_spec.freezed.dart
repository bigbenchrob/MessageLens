// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contacts_settings_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ContactsSettingsSpec {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactsSettingsSpec);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ContactsSettingsSpec()';
}


}

/// @nodoc
class $ContactsSettingsSpecCopyWith<$Res>  {
$ContactsSettingsSpecCopyWith(ContactsSettingsSpec _, $Res Function(ContactsSettingsSpec) __);
}


/// Adds pattern-matching-related methods to [ContactsSettingsSpec].
extension ContactsSettingsSpecPatterns on ContactsSettingsSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _DisplayNameInfo value)?  displayNameInfo,TResult Function( _ActionsMenu value)?  actionsMenu,TResult Function( _SendLogsInfo value)?  sendLogsInfo,TResult Function( _ReimportDataInfo value)?  reimportDataInfo,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DisplayNameInfo() when displayNameInfo != null:
return displayNameInfo(_that);case _ActionsMenu() when actionsMenu != null:
return actionsMenu(_that);case _SendLogsInfo() when sendLogsInfo != null:
return sendLogsInfo(_that);case _ReimportDataInfo() when reimportDataInfo != null:
return reimportDataInfo(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _DisplayNameInfo value)  displayNameInfo,required TResult Function( _ActionsMenu value)  actionsMenu,required TResult Function( _SendLogsInfo value)  sendLogsInfo,required TResult Function( _ReimportDataInfo value)  reimportDataInfo,}){
final _that = this;
switch (_that) {
case _DisplayNameInfo():
return displayNameInfo(_that);case _ActionsMenu():
return actionsMenu(_that);case _SendLogsInfo():
return sendLogsInfo(_that);case _ReimportDataInfo():
return reimportDataInfo(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _DisplayNameInfo value)?  displayNameInfo,TResult? Function( _ActionsMenu value)?  actionsMenu,TResult? Function( _SendLogsInfo value)?  sendLogsInfo,TResult? Function( _ReimportDataInfo value)?  reimportDataInfo,}){
final _that = this;
switch (_that) {
case _DisplayNameInfo() when displayNameInfo != null:
return displayNameInfo(_that);case _ActionsMenu() when actionsMenu != null:
return actionsMenu(_that);case _SendLogsInfo() when sendLogsInfo != null:
return sendLogsInfo(_that);case _ReimportDataInfo() when reimportDataInfo != null:
return reimportDataInfo(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  displayNameInfo,TResult Function( ActionsMenuChoice? selectedChoice)?  actionsMenu,TResult Function()?  sendLogsInfo,TResult Function()?  reimportDataInfo,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DisplayNameInfo() when displayNameInfo != null:
return displayNameInfo();case _ActionsMenu() when actionsMenu != null:
return actionsMenu(_that.selectedChoice);case _SendLogsInfo() when sendLogsInfo != null:
return sendLogsInfo();case _ReimportDataInfo() when reimportDataInfo != null:
return reimportDataInfo();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  displayNameInfo,required TResult Function( ActionsMenuChoice? selectedChoice)  actionsMenu,required TResult Function()  sendLogsInfo,required TResult Function()  reimportDataInfo,}) {final _that = this;
switch (_that) {
case _DisplayNameInfo():
return displayNameInfo();case _ActionsMenu():
return actionsMenu(_that.selectedChoice);case _SendLogsInfo():
return sendLogsInfo();case _ReimportDataInfo():
return reimportDataInfo();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  displayNameInfo,TResult? Function( ActionsMenuChoice? selectedChoice)?  actionsMenu,TResult? Function()?  sendLogsInfo,TResult? Function()?  reimportDataInfo,}) {final _that = this;
switch (_that) {
case _DisplayNameInfo() when displayNameInfo != null:
return displayNameInfo();case _ActionsMenu() when actionsMenu != null:
return actionsMenu(_that.selectedChoice);case _SendLogsInfo() when sendLogsInfo != null:
return sendLogsInfo();case _ReimportDataInfo() when reimportDataInfo != null:
return reimportDataInfo();case _:
  return null;

}
}

}

/// @nodoc


class _DisplayNameInfo implements ContactsSettingsSpec {
  const _DisplayNameInfo();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DisplayNameInfo);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ContactsSettingsSpec.displayNameInfo()';
}


}




/// @nodoc


class _ActionsMenu implements ContactsSettingsSpec {
  const _ActionsMenu({this.selectedChoice});
  

 final  ActionsMenuChoice? selectedChoice;

/// Create a copy of ContactsSettingsSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActionsMenuCopyWith<_ActionsMenu> get copyWith => __$ActionsMenuCopyWithImpl<_ActionsMenu>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActionsMenu&&(identical(other.selectedChoice, selectedChoice) || other.selectedChoice == selectedChoice));
}


@override
int get hashCode => Object.hash(runtimeType,selectedChoice);

@override
String toString() {
  return 'ContactsSettingsSpec.actionsMenu(selectedChoice: $selectedChoice)';
}


}

/// @nodoc
abstract mixin class _$ActionsMenuCopyWith<$Res> implements $ContactsSettingsSpecCopyWith<$Res> {
  factory _$ActionsMenuCopyWith(_ActionsMenu value, $Res Function(_ActionsMenu) _then) = __$ActionsMenuCopyWithImpl;
@useResult
$Res call({
 ActionsMenuChoice? selectedChoice
});




}
/// @nodoc
class __$ActionsMenuCopyWithImpl<$Res>
    implements _$ActionsMenuCopyWith<$Res> {
  __$ActionsMenuCopyWithImpl(this._self, this._then);

  final _ActionsMenu _self;
  final $Res Function(_ActionsMenu) _then;

/// Create a copy of ContactsSettingsSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? selectedChoice = freezed,}) {
  return _then(_ActionsMenu(
selectedChoice: freezed == selectedChoice ? _self.selectedChoice : selectedChoice // ignore: cast_nullable_to_non_nullable
as ActionsMenuChoice?,
  ));
}


}

/// @nodoc


class _SendLogsInfo implements ContactsSettingsSpec {
  const _SendLogsInfo();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SendLogsInfo);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ContactsSettingsSpec.sendLogsInfo()';
}


}




/// @nodoc


class _ReimportDataInfo implements ContactsSettingsSpec {
  const _ReimportDataInfo();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReimportDataInfo);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ContactsSettingsSpec.reimportDataInfo()';
}


}




// dart format on
