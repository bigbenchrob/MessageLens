// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'view_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ViewSpec {

 Object get spec;



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ViewSpec&&const DeepCollectionEquality().equals(other.spec, spec));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(spec));

@override
String toString() {
  return 'ViewSpec(spec: $spec)';
}


}

/// @nodoc
class $ViewSpecCopyWith<$Res>  {
$ViewSpecCopyWith(ViewSpec _, $Res Function(ViewSpec) __);
}


/// Adds pattern-matching-related methods to [ViewSpec].
extension ViewSpecPatterns on ViewSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ViewMessages value)?  messages,TResult Function( _ViewChats value)?  chats,TResult Function( _ViewContacts value)?  contacts,TResult Function( _ViewImport value)?  import,TResult Function( _ViewSettings value)?  settings,TResult Function( _ViewWorkbench value)?  workbench,TResult Function( _ViewSidebar value)?  sidebar,TResult Function( _BuildSidebarFromRoot value)?  sidebarRoot,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ViewMessages() when messages != null:
return messages(_that);case _ViewChats() when chats != null:
return chats(_that);case _ViewContacts() when contacts != null:
return contacts(_that);case _ViewImport() when import != null:
return import(_that);case _ViewSettings() when settings != null:
return settings(_that);case _ViewWorkbench() when workbench != null:
return workbench(_that);case _ViewSidebar() when sidebar != null:
return sidebar(_that);case _BuildSidebarFromRoot() when sidebarRoot != null:
return sidebarRoot(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ViewMessages value)  messages,required TResult Function( _ViewChats value)  chats,required TResult Function( _ViewContacts value)  contacts,required TResult Function( _ViewImport value)  import,required TResult Function( _ViewSettings value)  settings,required TResult Function( _ViewWorkbench value)  workbench,required TResult Function( _ViewSidebar value)  sidebar,required TResult Function( _BuildSidebarFromRoot value)  sidebarRoot,}){
final _that = this;
switch (_that) {
case _ViewMessages():
return messages(_that);case _ViewChats():
return chats(_that);case _ViewContacts():
return contacts(_that);case _ViewImport():
return import(_that);case _ViewSettings():
return settings(_that);case _ViewWorkbench():
return workbench(_that);case _ViewSidebar():
return sidebar(_that);case _BuildSidebarFromRoot():
return sidebarRoot(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ViewMessages value)?  messages,TResult? Function( _ViewChats value)?  chats,TResult? Function( _ViewContacts value)?  contacts,TResult? Function( _ViewImport value)?  import,TResult? Function( _ViewSettings value)?  settings,TResult? Function( _ViewWorkbench value)?  workbench,TResult? Function( _ViewSidebar value)?  sidebar,TResult? Function( _BuildSidebarFromRoot value)?  sidebarRoot,}){
final _that = this;
switch (_that) {
case _ViewMessages() when messages != null:
return messages(_that);case _ViewChats() when chats != null:
return chats(_that);case _ViewContacts() when contacts != null:
return contacts(_that);case _ViewImport() when import != null:
return import(_that);case _ViewSettings() when settings != null:
return settings(_that);case _ViewWorkbench() when workbench != null:
return workbench(_that);case _ViewSidebar() when sidebar != null:
return sidebar(_that);case _BuildSidebarFromRoot() when sidebarRoot != null:
return sidebarRoot(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( MessagesSpec spec)?  messages,TResult Function( ChatsSpec spec)?  chats,TResult Function( ContactsSpec spec)?  contacts,TResult Function( ImportSpec spec)?  import,TResult Function( SettingsSpec spec)?  settings,TResult Function( WorkbenchSpec spec)?  workbench,TResult Function( SidebarSpec spec)?  sidebar,TResult Function( SidebarRootSpec spec)?  sidebarRoot,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ViewMessages() when messages != null:
return messages(_that.spec);case _ViewChats() when chats != null:
return chats(_that.spec);case _ViewContacts() when contacts != null:
return contacts(_that.spec);case _ViewImport() when import != null:
return import(_that.spec);case _ViewSettings() when settings != null:
return settings(_that.spec);case _ViewWorkbench() when workbench != null:
return workbench(_that.spec);case _ViewSidebar() when sidebar != null:
return sidebar(_that.spec);case _BuildSidebarFromRoot() when sidebarRoot != null:
return sidebarRoot(_that.spec);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( MessagesSpec spec)  messages,required TResult Function( ChatsSpec spec)  chats,required TResult Function( ContactsSpec spec)  contacts,required TResult Function( ImportSpec spec)  import,required TResult Function( SettingsSpec spec)  settings,required TResult Function( WorkbenchSpec spec)  workbench,required TResult Function( SidebarSpec spec)  sidebar,required TResult Function( SidebarRootSpec spec)  sidebarRoot,}) {final _that = this;
switch (_that) {
case _ViewMessages():
return messages(_that.spec);case _ViewChats():
return chats(_that.spec);case _ViewContacts():
return contacts(_that.spec);case _ViewImport():
return import(_that.spec);case _ViewSettings():
return settings(_that.spec);case _ViewWorkbench():
return workbench(_that.spec);case _ViewSidebar():
return sidebar(_that.spec);case _BuildSidebarFromRoot():
return sidebarRoot(_that.spec);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( MessagesSpec spec)?  messages,TResult? Function( ChatsSpec spec)?  chats,TResult? Function( ContactsSpec spec)?  contacts,TResult? Function( ImportSpec spec)?  import,TResult? Function( SettingsSpec spec)?  settings,TResult? Function( WorkbenchSpec spec)?  workbench,TResult? Function( SidebarSpec spec)?  sidebar,TResult? Function( SidebarRootSpec spec)?  sidebarRoot,}) {final _that = this;
switch (_that) {
case _ViewMessages() when messages != null:
return messages(_that.spec);case _ViewChats() when chats != null:
return chats(_that.spec);case _ViewContacts() when contacts != null:
return contacts(_that.spec);case _ViewImport() when import != null:
return import(_that.spec);case _ViewSettings() when settings != null:
return settings(_that.spec);case _ViewWorkbench() when workbench != null:
return workbench(_that.spec);case _ViewSidebar() when sidebar != null:
return sidebar(_that.spec);case _BuildSidebarFromRoot() when sidebarRoot != null:
return sidebarRoot(_that.spec);case _:
  return null;

}
}

}

/// @nodoc


class _ViewMessages implements ViewSpec {
  const _ViewMessages(this.spec);
  

@override final  MessagesSpec spec;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ViewMessagesCopyWith<_ViewMessages> get copyWith => __$ViewMessagesCopyWithImpl<_ViewMessages>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewMessages&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'ViewSpec.messages(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$ViewMessagesCopyWith<$Res> implements $ViewSpecCopyWith<$Res> {
  factory _$ViewMessagesCopyWith(_ViewMessages value, $Res Function(_ViewMessages) _then) = __$ViewMessagesCopyWithImpl;
@useResult
$Res call({
 MessagesSpec spec
});


$MessagesSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$ViewMessagesCopyWithImpl<$Res>
    implements _$ViewMessagesCopyWith<$Res> {
  __$ViewMessagesCopyWithImpl(this._self, this._then);

  final _ViewMessages _self;
  final $Res Function(_ViewMessages) _then;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_ViewMessages(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as MessagesSpec,
  ));
}

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessagesSpecCopyWith<$Res> get spec {
  
  return $MessagesSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

/// @nodoc


class _ViewChats implements ViewSpec {
  const _ViewChats(this.spec);
  

@override final  ChatsSpec spec;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ViewChatsCopyWith<_ViewChats> get copyWith => __$ViewChatsCopyWithImpl<_ViewChats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewChats&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'ViewSpec.chats(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$ViewChatsCopyWith<$Res> implements $ViewSpecCopyWith<$Res> {
  factory _$ViewChatsCopyWith(_ViewChats value, $Res Function(_ViewChats) _then) = __$ViewChatsCopyWithImpl;
@useResult
$Res call({
 ChatsSpec spec
});


$ChatsSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$ViewChatsCopyWithImpl<$Res>
    implements _$ViewChatsCopyWith<$Res> {
  __$ViewChatsCopyWithImpl(this._self, this._then);

  final _ViewChats _self;
  final $Res Function(_ViewChats) _then;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_ViewChats(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as ChatsSpec,
  ));
}

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatsSpecCopyWith<$Res> get spec {
  
  return $ChatsSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

/// @nodoc


class _ViewContacts implements ViewSpec {
  const _ViewContacts(this.spec);
  

@override final  ContactsSpec spec;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ViewContactsCopyWith<_ViewContacts> get copyWith => __$ViewContactsCopyWithImpl<_ViewContacts>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewContacts&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'ViewSpec.contacts(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$ViewContactsCopyWith<$Res> implements $ViewSpecCopyWith<$Res> {
  factory _$ViewContactsCopyWith(_ViewContacts value, $Res Function(_ViewContacts) _then) = __$ViewContactsCopyWithImpl;
@useResult
$Res call({
 ContactsSpec spec
});


$ContactsSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$ViewContactsCopyWithImpl<$Res>
    implements _$ViewContactsCopyWith<$Res> {
  __$ViewContactsCopyWithImpl(this._self, this._then);

  final _ViewContacts _self;
  final $Res Function(_ViewContacts) _then;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_ViewContacts(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as ContactsSpec,
  ));
}

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactsSpecCopyWith<$Res> get spec {
  
  return $ContactsSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

/// @nodoc


class _ViewImport implements ViewSpec {
  const _ViewImport(this.spec);
  

@override final  ImportSpec spec;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ViewImportCopyWith<_ViewImport> get copyWith => __$ViewImportCopyWithImpl<_ViewImport>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewImport&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'ViewSpec.import(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$ViewImportCopyWith<$Res> implements $ViewSpecCopyWith<$Res> {
  factory _$ViewImportCopyWith(_ViewImport value, $Res Function(_ViewImport) _then) = __$ViewImportCopyWithImpl;
@useResult
$Res call({
 ImportSpec spec
});


$ImportSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$ViewImportCopyWithImpl<$Res>
    implements _$ViewImportCopyWith<$Res> {
  __$ViewImportCopyWithImpl(this._self, this._then);

  final _ViewImport _self;
  final $Res Function(_ViewImport) _then;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_ViewImport(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as ImportSpec,
  ));
}

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImportSpecCopyWith<$Res> get spec {
  
  return $ImportSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

/// @nodoc


class _ViewSettings implements ViewSpec {
  const _ViewSettings(this.spec);
  

@override final  SettingsSpec spec;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ViewSettingsCopyWith<_ViewSettings> get copyWith => __$ViewSettingsCopyWithImpl<_ViewSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewSettings&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'ViewSpec.settings(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$ViewSettingsCopyWith<$Res> implements $ViewSpecCopyWith<$Res> {
  factory _$ViewSettingsCopyWith(_ViewSettings value, $Res Function(_ViewSettings) _then) = __$ViewSettingsCopyWithImpl;
@useResult
$Res call({
 SettingsSpec spec
});


$SettingsSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$ViewSettingsCopyWithImpl<$Res>
    implements _$ViewSettingsCopyWith<$Res> {
  __$ViewSettingsCopyWithImpl(this._self, this._then);

  final _ViewSettings _self;
  final $Res Function(_ViewSettings) _then;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_ViewSettings(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as SettingsSpec,
  ));
}

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SettingsSpecCopyWith<$Res> get spec {
  
  return $SettingsSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

/// @nodoc


class _ViewWorkbench implements ViewSpec {
  const _ViewWorkbench(this.spec);
  

@override final  WorkbenchSpec spec;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ViewWorkbenchCopyWith<_ViewWorkbench> get copyWith => __$ViewWorkbenchCopyWithImpl<_ViewWorkbench>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewWorkbench&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'ViewSpec.workbench(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$ViewWorkbenchCopyWith<$Res> implements $ViewSpecCopyWith<$Res> {
  factory _$ViewWorkbenchCopyWith(_ViewWorkbench value, $Res Function(_ViewWorkbench) _then) = __$ViewWorkbenchCopyWithImpl;
@useResult
$Res call({
 WorkbenchSpec spec
});


$WorkbenchSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$ViewWorkbenchCopyWithImpl<$Res>
    implements _$ViewWorkbenchCopyWith<$Res> {
  __$ViewWorkbenchCopyWithImpl(this._self, this._then);

  final _ViewWorkbench _self;
  final $Res Function(_ViewWorkbench) _then;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_ViewWorkbench(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as WorkbenchSpec,
  ));
}

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkbenchSpecCopyWith<$Res> get spec {
  
  return $WorkbenchSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

/// @nodoc


class _ViewSidebar implements ViewSpec {
  const _ViewSidebar(this.spec);
  

@override final  SidebarSpec spec;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ViewSidebarCopyWith<_ViewSidebar> get copyWith => __$ViewSidebarCopyWithImpl<_ViewSidebar>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewSidebar&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'ViewSpec.sidebar(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$ViewSidebarCopyWith<$Res> implements $ViewSpecCopyWith<$Res> {
  factory _$ViewSidebarCopyWith(_ViewSidebar value, $Res Function(_ViewSidebar) _then) = __$ViewSidebarCopyWithImpl;
@useResult
$Res call({
 SidebarSpec spec
});


$SidebarSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$ViewSidebarCopyWithImpl<$Res>
    implements _$ViewSidebarCopyWith<$Res> {
  __$ViewSidebarCopyWithImpl(this._self, this._then);

  final _ViewSidebar _self;
  final $Res Function(_ViewSidebar) _then;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_ViewSidebar(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as SidebarSpec,
  ));
}

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SidebarSpecCopyWith<$Res> get spec {
  
  return $SidebarSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

/// @nodoc


class _BuildSidebarFromRoot implements ViewSpec {
  const _BuildSidebarFromRoot(this.spec);
  

@override final  SidebarRootSpec spec;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuildSidebarFromRootCopyWith<_BuildSidebarFromRoot> get copyWith => __$BuildSidebarFromRootCopyWithImpl<_BuildSidebarFromRoot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuildSidebarFromRoot&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'ViewSpec.sidebarRoot(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$BuildSidebarFromRootCopyWith<$Res> implements $ViewSpecCopyWith<$Res> {
  factory _$BuildSidebarFromRootCopyWith(_BuildSidebarFromRoot value, $Res Function(_BuildSidebarFromRoot) _then) = __$BuildSidebarFromRootCopyWithImpl;
@useResult
$Res call({
 SidebarRootSpec spec
});


$SidebarRootSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$BuildSidebarFromRootCopyWithImpl<$Res>
    implements _$BuildSidebarFromRootCopyWith<$Res> {
  __$BuildSidebarFromRootCopyWithImpl(this._self, this._then);

  final _BuildSidebarFromRoot _self;
  final $Res Function(_BuildSidebarFromRoot) _then;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_BuildSidebarFromRoot(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as SidebarRootSpec,
  ));
}

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SidebarRootSpecCopyWith<$Res> get spec {
  
  return $SidebarRootSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

// dart format on
