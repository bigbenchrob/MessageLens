// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cassette_rack_state_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CassetteRack {

 List<CassetteSpec> get cassettes;
/// Create a copy of CassetteRack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CassetteRackCopyWith<CassetteRack> get copyWith => _$CassetteRackCopyWithImpl<CassetteRack>(this as CassetteRack, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CassetteRack&&const DeepCollectionEquality().equals(other.cassettes, cassettes));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(cassettes));

@override
String toString() {
  return 'CassetteRack(cassettes: $cassettes)';
}


}

/// @nodoc
abstract mixin class $CassetteRackCopyWith<$Res>  {
  factory $CassetteRackCopyWith(CassetteRack value, $Res Function(CassetteRack) _then) = _$CassetteRackCopyWithImpl;
@useResult
$Res call({
 List<CassetteSpec> cassettes
});




}
/// @nodoc
class _$CassetteRackCopyWithImpl<$Res>
    implements $CassetteRackCopyWith<$Res> {
  _$CassetteRackCopyWithImpl(this._self, this._then);

  final CassetteRack _self;
  final $Res Function(CassetteRack) _then;

/// Create a copy of CassetteRack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cassettes = null,}) {
  return _then(_self.copyWith(
cassettes: null == cassettes ? _self.cassettes : cassettes // ignore: cast_nullable_to_non_nullable
as List<CassetteSpec>,
  ));
}

}


/// Adds pattern-matching-related methods to [CassetteRack].
extension CassetteRackPatterns on CassetteRack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CassetteRack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CassetteRack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CassetteRack value)  $default,){
final _that = this;
switch (_that) {
case _CassetteRack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CassetteRack value)?  $default,){
final _that = this;
switch (_that) {
case _CassetteRack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CassetteSpec> cassettes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CassetteRack() when $default != null:
return $default(_that.cassettes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CassetteSpec> cassettes)  $default,) {final _that = this;
switch (_that) {
case _CassetteRack():
return $default(_that.cassettes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CassetteSpec> cassettes)?  $default,) {final _that = this;
switch (_that) {
case _CassetteRack() when $default != null:
return $default(_that.cassettes);case _:
  return null;

}
}

}

/// @nodoc


class _CassetteRack extends CassetteRack {
  const _CassetteRack({final  List<CassetteSpec> cassettes = const <CassetteSpec>[]}): _cassettes = cassettes,super._();
  

 final  List<CassetteSpec> _cassettes;
@override@JsonKey() List<CassetteSpec> get cassettes {
  if (_cassettes is EqualUnmodifiableListView) return _cassettes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cassettes);
}


/// Create a copy of CassetteRack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CassetteRackCopyWith<_CassetteRack> get copyWith => __$CassetteRackCopyWithImpl<_CassetteRack>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CassetteRack&&const DeepCollectionEquality().equals(other._cassettes, _cassettes));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_cassettes));

@override
String toString() {
  return 'CassetteRack(cassettes: $cassettes)';
}


}

/// @nodoc
abstract mixin class _$CassetteRackCopyWith<$Res> implements $CassetteRackCopyWith<$Res> {
  factory _$CassetteRackCopyWith(_CassetteRack value, $Res Function(_CassetteRack) _then) = __$CassetteRackCopyWithImpl;
@override @useResult
$Res call({
 List<CassetteSpec> cassettes
});




}
/// @nodoc
class __$CassetteRackCopyWithImpl<$Res>
    implements _$CassetteRackCopyWith<$Res> {
  __$CassetteRackCopyWithImpl(this._self, this._then);

  final _CassetteRack _self;
  final $Res Function(_CassetteRack) _then;

/// Create a copy of CassetteRack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cassettes = null,}) {
  return _then(_CassetteRack(
cassettes: null == cassettes ? _self._cassettes : cassettes // ignore: cast_nullable_to_non_nullable
as List<CassetteSpec>,
  ));
}


}

// dart format on
