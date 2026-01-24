// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cassette_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CassetteSpec {

 Object get spec;



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CassetteSpec&&const DeepCollectionEquality().equals(other.spec, spec));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(spec));

@override
String toString() {
  return 'CassetteSpec(spec: $spec)';
}


}

/// @nodoc
class $CassetteSpecCopyWith<$Res>  {
$CassetteSpecCopyWith(CassetteSpec _, $Res Function(CassetteSpec) __);
}


/// Adds pattern-matching-related methods to [CassetteSpec].
extension CassetteSpecPatterns on CassetteSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _CassetteSidebarWidget value)?  sidebarUtility,TResult Function( _CassetteSidebarUtilitySettings value)?  sidebarUtilitySettings,TResult Function( _CassettePresentation value)?  presentation,TResult Function( _CassetteContacts value)?  contacts,TResult Function( _CassetteContactsSettings value)?  contactsSettings,TResult Function( _CassetteContactsInfo value)?  contactsInfo,TResult Function( _CassetteHandles value)?  handles,TResult Function( _CassetteHandlesInfo value)?  handlesInfo,TResult Function( _CassetteMessages value)?  messages,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CassetteSidebarWidget() when sidebarUtility != null:
return sidebarUtility(_that);case _CassetteSidebarUtilitySettings() when sidebarUtilitySettings != null:
return sidebarUtilitySettings(_that);case _CassettePresentation() when presentation != null:
return presentation(_that);case _CassetteContacts() when contacts != null:
return contacts(_that);case _CassetteContactsSettings() when contactsSettings != null:
return contactsSettings(_that);case _CassetteContactsInfo() when contactsInfo != null:
return contactsInfo(_that);case _CassetteHandles() when handles != null:
return handles(_that);case _CassetteHandlesInfo() when handlesInfo != null:
return handlesInfo(_that);case _CassetteMessages() when messages != null:
return messages(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _CassetteSidebarWidget value)  sidebarUtility,required TResult Function( _CassetteSidebarUtilitySettings value)  sidebarUtilitySettings,required TResult Function( _CassettePresentation value)  presentation,required TResult Function( _CassetteContacts value)  contacts,required TResult Function( _CassetteContactsSettings value)  contactsSettings,required TResult Function( _CassetteContactsInfo value)  contactsInfo,required TResult Function( _CassetteHandles value)  handles,required TResult Function( _CassetteHandlesInfo value)  handlesInfo,required TResult Function( _CassetteMessages value)  messages,}){
final _that = this;
switch (_that) {
case _CassetteSidebarWidget():
return sidebarUtility(_that);case _CassetteSidebarUtilitySettings():
return sidebarUtilitySettings(_that);case _CassettePresentation():
return presentation(_that);case _CassetteContacts():
return contacts(_that);case _CassetteContactsSettings():
return contactsSettings(_that);case _CassetteContactsInfo():
return contactsInfo(_that);case _CassetteHandles():
return handles(_that);case _CassetteHandlesInfo():
return handlesInfo(_that);case _CassetteMessages():
return messages(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _CassetteSidebarWidget value)?  sidebarUtility,TResult? Function( _CassetteSidebarUtilitySettings value)?  sidebarUtilitySettings,TResult? Function( _CassettePresentation value)?  presentation,TResult? Function( _CassetteContacts value)?  contacts,TResult? Function( _CassetteContactsSettings value)?  contactsSettings,TResult? Function( _CassetteContactsInfo value)?  contactsInfo,TResult? Function( _CassetteHandles value)?  handles,TResult? Function( _CassetteHandlesInfo value)?  handlesInfo,TResult? Function( _CassetteMessages value)?  messages,}){
final _that = this;
switch (_that) {
case _CassetteSidebarWidget() when sidebarUtility != null:
return sidebarUtility(_that);case _CassetteSidebarUtilitySettings() when sidebarUtilitySettings != null:
return sidebarUtilitySettings(_that);case _CassettePresentation() when presentation != null:
return presentation(_that);case _CassetteContacts() when contacts != null:
return contacts(_that);case _CassetteContactsSettings() when contactsSettings != null:
return contactsSettings(_that);case _CassetteContactsInfo() when contactsInfo != null:
return contactsInfo(_that);case _CassetteHandles() when handles != null:
return handles(_that);case _CassetteHandlesInfo() when handlesInfo != null:
return handlesInfo(_that);case _CassetteMessages() when messages != null:
return messages(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( SidebarUtilityCassetteSpec spec)?  sidebarUtility,TResult Function( SidebarUtilitySettingsSpec spec)?  sidebarUtilitySettings,TResult Function( PresentationCassetteSpec spec)?  presentation,TResult Function( ContactsCassetteSpec spec)?  contacts,TResult Function( ContactsSettingsSpec spec)?  contactsSettings,TResult Function( ContactsInfoCassetteSpec spec)?  contactsInfo,TResult Function( HandlesCassetteSpec spec)?  handles,TResult Function( HandlesInfoCassetteSpec spec)?  handlesInfo,TResult Function( MessagesCassetteSpec spec)?  messages,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CassetteSidebarWidget() when sidebarUtility != null:
return sidebarUtility(_that.spec);case _CassetteSidebarUtilitySettings() when sidebarUtilitySettings != null:
return sidebarUtilitySettings(_that.spec);case _CassettePresentation() when presentation != null:
return presentation(_that.spec);case _CassetteContacts() when contacts != null:
return contacts(_that.spec);case _CassetteContactsSettings() when contactsSettings != null:
return contactsSettings(_that.spec);case _CassetteContactsInfo() when contactsInfo != null:
return contactsInfo(_that.spec);case _CassetteHandles() when handles != null:
return handles(_that.spec);case _CassetteHandlesInfo() when handlesInfo != null:
return handlesInfo(_that.spec);case _CassetteMessages() when messages != null:
return messages(_that.spec);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( SidebarUtilityCassetteSpec spec)  sidebarUtility,required TResult Function( SidebarUtilitySettingsSpec spec)  sidebarUtilitySettings,required TResult Function( PresentationCassetteSpec spec)  presentation,required TResult Function( ContactsCassetteSpec spec)  contacts,required TResult Function( ContactsSettingsSpec spec)  contactsSettings,required TResult Function( ContactsInfoCassetteSpec spec)  contactsInfo,required TResult Function( HandlesCassetteSpec spec)  handles,required TResult Function( HandlesInfoCassetteSpec spec)  handlesInfo,required TResult Function( MessagesCassetteSpec spec)  messages,}) {final _that = this;
switch (_that) {
case _CassetteSidebarWidget():
return sidebarUtility(_that.spec);case _CassetteSidebarUtilitySettings():
return sidebarUtilitySettings(_that.spec);case _CassettePresentation():
return presentation(_that.spec);case _CassetteContacts():
return contacts(_that.spec);case _CassetteContactsSettings():
return contactsSettings(_that.spec);case _CassetteContactsInfo():
return contactsInfo(_that.spec);case _CassetteHandles():
return handles(_that.spec);case _CassetteHandlesInfo():
return handlesInfo(_that.spec);case _CassetteMessages():
return messages(_that.spec);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( SidebarUtilityCassetteSpec spec)?  sidebarUtility,TResult? Function( SidebarUtilitySettingsSpec spec)?  sidebarUtilitySettings,TResult? Function( PresentationCassetteSpec spec)?  presentation,TResult? Function( ContactsCassetteSpec spec)?  contacts,TResult? Function( ContactsSettingsSpec spec)?  contactsSettings,TResult? Function( ContactsInfoCassetteSpec spec)?  contactsInfo,TResult? Function( HandlesCassetteSpec spec)?  handles,TResult? Function( HandlesInfoCassetteSpec spec)?  handlesInfo,TResult? Function( MessagesCassetteSpec spec)?  messages,}) {final _that = this;
switch (_that) {
case _CassetteSidebarWidget() when sidebarUtility != null:
return sidebarUtility(_that.spec);case _CassetteSidebarUtilitySettings() when sidebarUtilitySettings != null:
return sidebarUtilitySettings(_that.spec);case _CassettePresentation() when presentation != null:
return presentation(_that.spec);case _CassetteContacts() when contacts != null:
return contacts(_that.spec);case _CassetteContactsSettings() when contactsSettings != null:
return contactsSettings(_that.spec);case _CassetteContactsInfo() when contactsInfo != null:
return contactsInfo(_that.spec);case _CassetteHandles() when handles != null:
return handles(_that.spec);case _CassetteHandlesInfo() when handlesInfo != null:
return handlesInfo(_that.spec);case _CassetteMessages() when messages != null:
return messages(_that.spec);case _:
  return null;

}
}

}

/// @nodoc


class _CassetteSidebarWidget implements CassetteSpec {
  const _CassetteSidebarWidget(this.spec);
  

@override final  SidebarUtilityCassetteSpec spec;

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CassetteSidebarWidgetCopyWith<_CassetteSidebarWidget> get copyWith => __$CassetteSidebarWidgetCopyWithImpl<_CassetteSidebarWidget>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CassetteSidebarWidget&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'CassetteSpec.sidebarUtility(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$CassetteSidebarWidgetCopyWith<$Res> implements $CassetteSpecCopyWith<$Res> {
  factory _$CassetteSidebarWidgetCopyWith(_CassetteSidebarWidget value, $Res Function(_CassetteSidebarWidget) _then) = __$CassetteSidebarWidgetCopyWithImpl;
@useResult
$Res call({
 SidebarUtilityCassetteSpec spec
});


$SidebarUtilityCassetteSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$CassetteSidebarWidgetCopyWithImpl<$Res>
    implements _$CassetteSidebarWidgetCopyWith<$Res> {
  __$CassetteSidebarWidgetCopyWithImpl(this._self, this._then);

  final _CassetteSidebarWidget _self;
  final $Res Function(_CassetteSidebarWidget) _then;

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_CassetteSidebarWidget(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as SidebarUtilityCassetteSpec,
  ));
}

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SidebarUtilityCassetteSpecCopyWith<$Res> get spec {
  
  return $SidebarUtilityCassetteSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

/// @nodoc


class _CassetteSidebarUtilitySettings implements CassetteSpec {
  const _CassetteSidebarUtilitySettings(this.spec);
  

@override final  SidebarUtilitySettingsSpec spec;

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CassetteSidebarUtilitySettingsCopyWith<_CassetteSidebarUtilitySettings> get copyWith => __$CassetteSidebarUtilitySettingsCopyWithImpl<_CassetteSidebarUtilitySettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CassetteSidebarUtilitySettings&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'CassetteSpec.sidebarUtilitySettings(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$CassetteSidebarUtilitySettingsCopyWith<$Res> implements $CassetteSpecCopyWith<$Res> {
  factory _$CassetteSidebarUtilitySettingsCopyWith(_CassetteSidebarUtilitySettings value, $Res Function(_CassetteSidebarUtilitySettings) _then) = __$CassetteSidebarUtilitySettingsCopyWithImpl;
@useResult
$Res call({
 SidebarUtilitySettingsSpec spec
});


$SidebarUtilitySettingsSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$CassetteSidebarUtilitySettingsCopyWithImpl<$Res>
    implements _$CassetteSidebarUtilitySettingsCopyWith<$Res> {
  __$CassetteSidebarUtilitySettingsCopyWithImpl(this._self, this._then);

  final _CassetteSidebarUtilitySettings _self;
  final $Res Function(_CassetteSidebarUtilitySettings) _then;

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_CassetteSidebarUtilitySettings(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as SidebarUtilitySettingsSpec,
  ));
}

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SidebarUtilitySettingsSpecCopyWith<$Res> get spec {
  
  return $SidebarUtilitySettingsSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

/// @nodoc


class _CassettePresentation implements CassetteSpec {
  const _CassettePresentation(this.spec);
  

@override final  PresentationCassetteSpec spec;

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CassettePresentationCopyWith<_CassettePresentation> get copyWith => __$CassettePresentationCopyWithImpl<_CassettePresentation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CassettePresentation&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'CassetteSpec.presentation(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$CassettePresentationCopyWith<$Res> implements $CassetteSpecCopyWith<$Res> {
  factory _$CassettePresentationCopyWith(_CassettePresentation value, $Res Function(_CassettePresentation) _then) = __$CassettePresentationCopyWithImpl;
@useResult
$Res call({
 PresentationCassetteSpec spec
});


$PresentationCassetteSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$CassettePresentationCopyWithImpl<$Res>
    implements _$CassettePresentationCopyWith<$Res> {
  __$CassettePresentationCopyWithImpl(this._self, this._then);

  final _CassettePresentation _self;
  final $Res Function(_CassettePresentation) _then;

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_CassettePresentation(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as PresentationCassetteSpec,
  ));
}

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PresentationCassetteSpecCopyWith<$Res> get spec {
  
  return $PresentationCassetteSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

/// @nodoc


class _CassetteContacts implements CassetteSpec {
  const _CassetteContacts(this.spec);
  

@override final  ContactsCassetteSpec spec;

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CassetteContactsCopyWith<_CassetteContacts> get copyWith => __$CassetteContactsCopyWithImpl<_CassetteContacts>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CassetteContacts&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'CassetteSpec.contacts(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$CassetteContactsCopyWith<$Res> implements $CassetteSpecCopyWith<$Res> {
  factory _$CassetteContactsCopyWith(_CassetteContacts value, $Res Function(_CassetteContacts) _then) = __$CassetteContactsCopyWithImpl;
@useResult
$Res call({
 ContactsCassetteSpec spec
});


$ContactsCassetteSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$CassetteContactsCopyWithImpl<$Res>
    implements _$CassetteContactsCopyWith<$Res> {
  __$CassetteContactsCopyWithImpl(this._self, this._then);

  final _CassetteContacts _self;
  final $Res Function(_CassetteContacts) _then;

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_CassetteContacts(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as ContactsCassetteSpec,
  ));
}

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactsCassetteSpecCopyWith<$Res> get spec {
  
  return $ContactsCassetteSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

/// @nodoc


class _CassetteContactsSettings implements CassetteSpec {
  const _CassetteContactsSettings(this.spec);
  

@override final  ContactsSettingsSpec spec;

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CassetteContactsSettingsCopyWith<_CassetteContactsSettings> get copyWith => __$CassetteContactsSettingsCopyWithImpl<_CassetteContactsSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CassetteContactsSettings&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'CassetteSpec.contactsSettings(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$CassetteContactsSettingsCopyWith<$Res> implements $CassetteSpecCopyWith<$Res> {
  factory _$CassetteContactsSettingsCopyWith(_CassetteContactsSettings value, $Res Function(_CassetteContactsSettings) _then) = __$CassetteContactsSettingsCopyWithImpl;
@useResult
$Res call({
 ContactsSettingsSpec spec
});


$ContactsSettingsSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$CassetteContactsSettingsCopyWithImpl<$Res>
    implements _$CassetteContactsSettingsCopyWith<$Res> {
  __$CassetteContactsSettingsCopyWithImpl(this._self, this._then);

  final _CassetteContactsSettings _self;
  final $Res Function(_CassetteContactsSettings) _then;

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_CassetteContactsSettings(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as ContactsSettingsSpec,
  ));
}

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactsSettingsSpecCopyWith<$Res> get spec {
  
  return $ContactsSettingsSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

/// @nodoc


class _CassetteContactsInfo implements CassetteSpec {
  const _CassetteContactsInfo(this.spec);
  

@override final  ContactsInfoCassetteSpec spec;

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CassetteContactsInfoCopyWith<_CassetteContactsInfo> get copyWith => __$CassetteContactsInfoCopyWithImpl<_CassetteContactsInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CassetteContactsInfo&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'CassetteSpec.contactsInfo(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$CassetteContactsInfoCopyWith<$Res> implements $CassetteSpecCopyWith<$Res> {
  factory _$CassetteContactsInfoCopyWith(_CassetteContactsInfo value, $Res Function(_CassetteContactsInfo) _then) = __$CassetteContactsInfoCopyWithImpl;
@useResult
$Res call({
 ContactsInfoCassetteSpec spec
});


$ContactsInfoCassetteSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$CassetteContactsInfoCopyWithImpl<$Res>
    implements _$CassetteContactsInfoCopyWith<$Res> {
  __$CassetteContactsInfoCopyWithImpl(this._self, this._then);

  final _CassetteContactsInfo _self;
  final $Res Function(_CassetteContactsInfo) _then;

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_CassetteContactsInfo(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as ContactsInfoCassetteSpec,
  ));
}

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactsInfoCassetteSpecCopyWith<$Res> get spec {
  
  return $ContactsInfoCassetteSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

/// @nodoc


class _CassetteHandles implements CassetteSpec {
  const _CassetteHandles(this.spec);
  

@override final  HandlesCassetteSpec spec;

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CassetteHandlesCopyWith<_CassetteHandles> get copyWith => __$CassetteHandlesCopyWithImpl<_CassetteHandles>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CassetteHandles&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'CassetteSpec.handles(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$CassetteHandlesCopyWith<$Res> implements $CassetteSpecCopyWith<$Res> {
  factory _$CassetteHandlesCopyWith(_CassetteHandles value, $Res Function(_CassetteHandles) _then) = __$CassetteHandlesCopyWithImpl;
@useResult
$Res call({
 HandlesCassetteSpec spec
});


$HandlesCassetteSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$CassetteHandlesCopyWithImpl<$Res>
    implements _$CassetteHandlesCopyWith<$Res> {
  __$CassetteHandlesCopyWithImpl(this._self, this._then);

  final _CassetteHandles _self;
  final $Res Function(_CassetteHandles) _then;

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_CassetteHandles(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as HandlesCassetteSpec,
  ));
}

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HandlesCassetteSpecCopyWith<$Res> get spec {
  
  return $HandlesCassetteSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

/// @nodoc


class _CassetteHandlesInfo implements CassetteSpec {
  const _CassetteHandlesInfo(this.spec);
  

@override final  HandlesInfoCassetteSpec spec;

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CassetteHandlesInfoCopyWith<_CassetteHandlesInfo> get copyWith => __$CassetteHandlesInfoCopyWithImpl<_CassetteHandlesInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CassetteHandlesInfo&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'CassetteSpec.handlesInfo(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$CassetteHandlesInfoCopyWith<$Res> implements $CassetteSpecCopyWith<$Res> {
  factory _$CassetteHandlesInfoCopyWith(_CassetteHandlesInfo value, $Res Function(_CassetteHandlesInfo) _then) = __$CassetteHandlesInfoCopyWithImpl;
@useResult
$Res call({
 HandlesInfoCassetteSpec spec
});


$HandlesInfoCassetteSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$CassetteHandlesInfoCopyWithImpl<$Res>
    implements _$CassetteHandlesInfoCopyWith<$Res> {
  __$CassetteHandlesInfoCopyWithImpl(this._self, this._then);

  final _CassetteHandlesInfo _self;
  final $Res Function(_CassetteHandlesInfo) _then;

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_CassetteHandlesInfo(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as HandlesInfoCassetteSpec,
  ));
}

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HandlesInfoCassetteSpecCopyWith<$Res> get spec {
  
  return $HandlesInfoCassetteSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

/// @nodoc


class _CassetteMessages implements CassetteSpec {
  const _CassetteMessages(this.spec);
  

@override final  MessagesCassetteSpec spec;

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CassetteMessagesCopyWith<_CassetteMessages> get copyWith => __$CassetteMessagesCopyWithImpl<_CassetteMessages>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CassetteMessages&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'CassetteSpec.messages(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$CassetteMessagesCopyWith<$Res> implements $CassetteSpecCopyWith<$Res> {
  factory _$CassetteMessagesCopyWith(_CassetteMessages value, $Res Function(_CassetteMessages) _then) = __$CassetteMessagesCopyWithImpl;
@useResult
$Res call({
 MessagesCassetteSpec spec
});


$MessagesCassetteSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$CassetteMessagesCopyWithImpl<$Res>
    implements _$CassetteMessagesCopyWith<$Res> {
  __$CassetteMessagesCopyWithImpl(this._self, this._then);

  final _CassetteMessages _self;
  final $Res Function(_CassetteMessages) _then;

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_CassetteMessages(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as MessagesCassetteSpec,
  ));
}

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessagesCassetteSpecCopyWith<$Res> get spec {
  
  return $MessagesCassetteSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

// dart format on
