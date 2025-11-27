// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sidebar_element_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SidebarElementSpec {

 String get id; SidebarElementKind get kind; Object? get payload;
/// Create a copy of SidebarElementSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SidebarElementSpecCopyWith<SidebarElementSpec> get copyWith => _$SidebarElementSpecCopyWithImpl<SidebarElementSpec>(this as SidebarElementSpec, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SidebarElementSpec&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other.payload, payload));
}


@override
int get hashCode => Object.hash(runtimeType,id,kind,const DeepCollectionEquality().hash(payload));

@override
String toString() {
  return 'SidebarElementSpec(id: $id, kind: $kind, payload: $payload)';
}


}

/// @nodoc
abstract mixin class $SidebarElementSpecCopyWith<$Res>  {
  factory $SidebarElementSpecCopyWith(SidebarElementSpec value, $Res Function(SidebarElementSpec) _then) = _$SidebarElementSpecCopyWithImpl;
@useResult
$Res call({
 String id, SidebarElementKind kind, Object? payload
});




}
/// @nodoc
class _$SidebarElementSpecCopyWithImpl<$Res>
    implements $SidebarElementSpecCopyWith<$Res> {
  _$SidebarElementSpecCopyWithImpl(this._self, this._then);

  final SidebarElementSpec _self;
  final $Res Function(SidebarElementSpec) _then;

/// Create a copy of SidebarElementSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? payload = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as SidebarElementKind,payload: freezed == payload ? _self.payload : payload ,
  ));
}

}


/// Adds pattern-matching-related methods to [SidebarElementSpec].
extension SidebarElementSpecPatterns on SidebarElementSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SidebarElementSpec value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SidebarElementSpec() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SidebarElementSpec value)  $default,){
final _that = this;
switch (_that) {
case _SidebarElementSpec():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SidebarElementSpec value)?  $default,){
final _that = this;
switch (_that) {
case _SidebarElementSpec() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  SidebarElementKind kind,  Object? payload)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SidebarElementSpec() when $default != null:
return $default(_that.id,_that.kind,_that.payload);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  SidebarElementKind kind,  Object? payload)  $default,) {final _that = this;
switch (_that) {
case _SidebarElementSpec():
return $default(_that.id,_that.kind,_that.payload);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  SidebarElementKind kind,  Object? payload)?  $default,) {final _that = this;
switch (_that) {
case _SidebarElementSpec() when $default != null:
return $default(_that.id,_that.kind,_that.payload);case _:
  return null;

}
}

}

/// @nodoc


class _SidebarElementSpec extends SidebarElementSpec {
  const _SidebarElementSpec({required this.id, required this.kind, this.payload}): super._();
  

@override final  String id;
@override final  SidebarElementKind kind;
@override final  Object? payload;

/// Create a copy of SidebarElementSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SidebarElementSpecCopyWith<_SidebarElementSpec> get copyWith => __$SidebarElementSpecCopyWithImpl<_SidebarElementSpec>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SidebarElementSpec&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other.payload, payload));
}


@override
int get hashCode => Object.hash(runtimeType,id,kind,const DeepCollectionEquality().hash(payload));

@override
String toString() {
  return 'SidebarElementSpec(id: $id, kind: $kind, payload: $payload)';
}


}

/// @nodoc
abstract mixin class _$SidebarElementSpecCopyWith<$Res> implements $SidebarElementSpecCopyWith<$Res> {
  factory _$SidebarElementSpecCopyWith(_SidebarElementSpec value, $Res Function(_SidebarElementSpec) _then) = __$SidebarElementSpecCopyWithImpl;
@override @useResult
$Res call({
 String id, SidebarElementKind kind, Object? payload
});




}
/// @nodoc
class __$SidebarElementSpecCopyWithImpl<$Res>
    implements _$SidebarElementSpecCopyWith<$Res> {
  __$SidebarElementSpecCopyWithImpl(this._self, this._then);

  final _SidebarElementSpec _self;
  final $Res Function(_SidebarElementSpec) _then;

/// Create a copy of SidebarElementSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? payload = freezed,}) {
  return _then(_SidebarElementSpec(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as SidebarElementKind,payload: freezed == payload ? _self.payload : payload ,
  ));
}


}

// dart format on
