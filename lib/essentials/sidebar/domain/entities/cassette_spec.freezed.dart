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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _CassetteSidebarWidget value)?  sidebarUtility,TResult Function( _CasetteContacts value)?  contacts,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CassetteSidebarWidget() when sidebarUtility != null:
return sidebarUtility(_that);case _CasetteContacts() when contacts != null:
return contacts(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _CassetteSidebarWidget value)  sidebarUtility,required TResult Function( _CasetteContacts value)  contacts,}){
final _that = this;
switch (_that) {
case _CassetteSidebarWidget():
return sidebarUtility(_that);case _CasetteContacts():
return contacts(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _CassetteSidebarWidget value)?  sidebarUtility,TResult? Function( _CasetteContacts value)?  contacts,}){
final _that = this;
switch (_that) {
case _CassetteSidebarWidget() when sidebarUtility != null:
return sidebarUtility(_that);case _CasetteContacts() when contacts != null:
return contacts(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( SidebarUtilityCassetteSpec spec)?  sidebarUtility,TResult Function( ContactsCassetteSpec spec)?  contacts,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CassetteSidebarWidget() when sidebarUtility != null:
return sidebarUtility(_that.spec);case _CasetteContacts() when contacts != null:
return contacts(_that.spec);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( SidebarUtilityCassetteSpec spec)  sidebarUtility,required TResult Function( ContactsCassetteSpec spec)  contacts,}) {final _that = this;
switch (_that) {
case _CassetteSidebarWidget():
return sidebarUtility(_that.spec);case _CasetteContacts():
return contacts(_that.spec);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( SidebarUtilityCassetteSpec spec)?  sidebarUtility,TResult? Function( ContactsCassetteSpec spec)?  contacts,}) {final _that = this;
switch (_that) {
case _CassetteSidebarWidget() when sidebarUtility != null:
return sidebarUtility(_that.spec);case _CasetteContacts() when contacts != null:
return contacts(_that.spec);case _:
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


class _CasetteContacts implements CassetteSpec {
  const _CasetteContacts(this.spec);
  

@override final  ContactsCassetteSpec spec;

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CasetteContactsCopyWith<_CasetteContacts> get copyWith => __$CasetteContactsCopyWithImpl<_CasetteContacts>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CasetteContacts&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'CassetteSpec.contacts(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$CasetteContactsCopyWith<$Res> implements $CassetteSpecCopyWith<$Res> {
  factory _$CasetteContactsCopyWith(_CasetteContacts value, $Res Function(_CasetteContacts) _then) = __$CasetteContactsCopyWithImpl;
@useResult
$Res call({
 ContactsCassetteSpec spec
});


$ContactsCassetteSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$CasetteContactsCopyWithImpl<$Res>
    implements _$CasetteContactsCopyWith<$Res> {
  __$CasetteContactsCopyWithImpl(this._self, this._then);

  final _CasetteContacts _self;
  final $Res Function(_CasetteContacts) _then;

/// Create a copy of CassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_CasetteContacts(
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

// dart format on
