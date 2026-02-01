// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sidebar_utilities_cassette_content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SidebarUtilitiesCassetteContent {

 SidebarUtilityCassetteSpec get spec;
/// Create a copy of SidebarUtilitiesCassetteContent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SidebarUtilitiesCassetteContentCopyWith<SidebarUtilitiesCassetteContent> get copyWith => _$SidebarUtilitiesCassetteContentCopyWithImpl<SidebarUtilitiesCassetteContent>(this as SidebarUtilitiesCassetteContent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SidebarUtilitiesCassetteContent&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'SidebarUtilitiesCassetteContent(spec: $spec)';
}


}

/// @nodoc
abstract mixin class $SidebarUtilitiesCassetteContentCopyWith<$Res>  {
  factory $SidebarUtilitiesCassetteContentCopyWith(SidebarUtilitiesCassetteContent value, $Res Function(SidebarUtilitiesCassetteContent) _then) = _$SidebarUtilitiesCassetteContentCopyWithImpl;
@useResult
$Res call({
 SidebarUtilityCassetteSpec spec
});


$SidebarUtilityCassetteSpecCopyWith<$Res> get spec;

}
/// @nodoc
class _$SidebarUtilitiesCassetteContentCopyWithImpl<$Res>
    implements $SidebarUtilitiesCassetteContentCopyWith<$Res> {
  _$SidebarUtilitiesCassetteContentCopyWithImpl(this._self, this._then);

  final SidebarUtilitiesCassetteContent _self;
  final $Res Function(SidebarUtilitiesCassetteContent) _then;

/// Create a copy of SidebarUtilitiesCassetteContent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? spec = null,}) {
  return _then(_self.copyWith(
spec: null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as SidebarUtilityCassetteSpec,
  ));
}
/// Create a copy of SidebarUtilitiesCassetteContent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SidebarUtilityCassetteSpecCopyWith<$Res> get spec {
  
  return $SidebarUtilityCassetteSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}


/// Adds pattern-matching-related methods to [SidebarUtilitiesCassetteContent].
extension SidebarUtilitiesCassetteContentPatterns on SidebarUtilitiesCassetteContent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _TopChatMenuContent value)?  topChatMenu,TResult Function( _SettingsMenuContent value)?  settingsMenu,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TopChatMenuContent() when topChatMenu != null:
return topChatMenu(_that);case _SettingsMenuContent() when settingsMenu != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _TopChatMenuContent value)  topChatMenu,required TResult Function( _SettingsMenuContent value)  settingsMenu,}){
final _that = this;
switch (_that) {
case _TopChatMenuContent():
return topChatMenu(_that);case _SettingsMenuContent():
return settingsMenu(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _TopChatMenuContent value)?  topChatMenu,TResult? Function( _SettingsMenuContent value)?  settingsMenu,}){
final _that = this;
switch (_that) {
case _TopChatMenuContent() when topChatMenu != null:
return topChatMenu(_that);case _SettingsMenuContent() when settingsMenu != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( SidebarUtilityCassetteSpec spec)?  topChatMenu,TResult Function( SidebarUtilityCassetteSpec spec)?  settingsMenu,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TopChatMenuContent() when topChatMenu != null:
return topChatMenu(_that.spec);case _SettingsMenuContent() when settingsMenu != null:
return settingsMenu(_that.spec);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( SidebarUtilityCassetteSpec spec)  topChatMenu,required TResult Function( SidebarUtilityCassetteSpec spec)  settingsMenu,}) {final _that = this;
switch (_that) {
case _TopChatMenuContent():
return topChatMenu(_that.spec);case _SettingsMenuContent():
return settingsMenu(_that.spec);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( SidebarUtilityCassetteSpec spec)?  topChatMenu,TResult? Function( SidebarUtilityCassetteSpec spec)?  settingsMenu,}) {final _that = this;
switch (_that) {
case _TopChatMenuContent() when topChatMenu != null:
return topChatMenu(_that.spec);case _SettingsMenuContent() when settingsMenu != null:
return settingsMenu(_that.spec);case _:
  return null;

}
}

}

/// @nodoc


class _TopChatMenuContent extends SidebarUtilitiesCassetteContent {
  const _TopChatMenuContent({required this.spec}): super._();
  

@override final  SidebarUtilityCassetteSpec spec;

/// Create a copy of SidebarUtilitiesCassetteContent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TopChatMenuContentCopyWith<_TopChatMenuContent> get copyWith => __$TopChatMenuContentCopyWithImpl<_TopChatMenuContent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TopChatMenuContent&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'SidebarUtilitiesCassetteContent.topChatMenu(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$TopChatMenuContentCopyWith<$Res> implements $SidebarUtilitiesCassetteContentCopyWith<$Res> {
  factory _$TopChatMenuContentCopyWith(_TopChatMenuContent value, $Res Function(_TopChatMenuContent) _then) = __$TopChatMenuContentCopyWithImpl;
@override @useResult
$Res call({
 SidebarUtilityCassetteSpec spec
});


@override $SidebarUtilityCassetteSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$TopChatMenuContentCopyWithImpl<$Res>
    implements _$TopChatMenuContentCopyWith<$Res> {
  __$TopChatMenuContentCopyWithImpl(this._self, this._then);

  final _TopChatMenuContent _self;
  final $Res Function(_TopChatMenuContent) _then;

/// Create a copy of SidebarUtilitiesCassetteContent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_TopChatMenuContent(
spec: null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as SidebarUtilityCassetteSpec,
  ));
}

/// Create a copy of SidebarUtilitiesCassetteContent
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


class _SettingsMenuContent extends SidebarUtilitiesCassetteContent {
  const _SettingsMenuContent({required this.spec}): super._();
  

@override final  SidebarUtilityCassetteSpec spec;

/// Create a copy of SidebarUtilitiesCassetteContent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsMenuContentCopyWith<_SettingsMenuContent> get copyWith => __$SettingsMenuContentCopyWithImpl<_SettingsMenuContent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsMenuContent&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'SidebarUtilitiesCassetteContent.settingsMenu(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$SettingsMenuContentCopyWith<$Res> implements $SidebarUtilitiesCassetteContentCopyWith<$Res> {
  factory _$SettingsMenuContentCopyWith(_SettingsMenuContent value, $Res Function(_SettingsMenuContent) _then) = __$SettingsMenuContentCopyWithImpl;
@override @useResult
$Res call({
 SidebarUtilityCassetteSpec spec
});


@override $SidebarUtilityCassetteSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$SettingsMenuContentCopyWithImpl<$Res>
    implements _$SettingsMenuContentCopyWith<$Res> {
  __$SettingsMenuContentCopyWithImpl(this._self, this._then);

  final _SettingsMenuContent _self;
  final $Res Function(_SettingsMenuContent) _then;

/// Create a copy of SidebarUtilitiesCassetteContent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_SettingsMenuContent(
spec: null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as SidebarUtilityCassetteSpec,
  ));
}

/// Create a copy of SidebarUtilitiesCassetteContent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SidebarUtilityCassetteSpecCopyWith<$Res> get spec {
  
  return $SidebarUtilityCassetteSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

// dart format on
