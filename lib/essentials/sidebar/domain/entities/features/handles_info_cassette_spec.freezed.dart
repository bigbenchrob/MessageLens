// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'handles_info_cassette_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HandlesInfoCassetteSpec {

 HandlesInfoKey get key; HandlesCassetteChildVariant get childVariant;
/// Create a copy of HandlesInfoCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HandlesInfoCassetteSpecCopyWith<HandlesInfoCassetteSpec> get copyWith => _$HandlesInfoCassetteSpecCopyWithImpl<HandlesInfoCassetteSpec>(this as HandlesInfoCassetteSpec, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HandlesInfoCassetteSpec&&(identical(other.key, key) || other.key == key)&&(identical(other.childVariant, childVariant) || other.childVariant == childVariant));
}


@override
int get hashCode => Object.hash(runtimeType,key,childVariant);

@override
String toString() {
  return 'HandlesInfoCassetteSpec(key: $key, childVariant: $childVariant)';
}


}

/// @nodoc
abstract mixin class $HandlesInfoCassetteSpecCopyWith<$Res>  {
  factory $HandlesInfoCassetteSpecCopyWith(HandlesInfoCassetteSpec value, $Res Function(HandlesInfoCassetteSpec) _then) = _$HandlesInfoCassetteSpecCopyWithImpl;
@useResult
$Res call({
 HandlesInfoKey key, HandlesCassetteChildVariant childVariant
});




}
/// @nodoc
class _$HandlesInfoCassetteSpecCopyWithImpl<$Res>
    implements $HandlesInfoCassetteSpecCopyWith<$Res> {
  _$HandlesInfoCassetteSpecCopyWithImpl(this._self, this._then);

  final HandlesInfoCassetteSpec _self;
  final $Res Function(HandlesInfoCassetteSpec) _then;

/// Create a copy of HandlesInfoCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? childVariant = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as HandlesInfoKey,childVariant: null == childVariant ? _self.childVariant : childVariant // ignore: cast_nullable_to_non_nullable
as HandlesCassetteChildVariant,
  ));
}

}


/// Adds pattern-matching-related methods to [HandlesInfoCassetteSpec].
extension HandlesInfoCassetteSpecPatterns on HandlesInfoCassetteSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( HandlesInfoCassetteSpecInfoCard value)?  infoCard,required TResult orElse(),}){
final _that = this;
switch (_that) {
case HandlesInfoCassetteSpecInfoCard() when infoCard != null:
return infoCard(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( HandlesInfoCassetteSpecInfoCard value)  infoCard,}){
final _that = this;
switch (_that) {
case HandlesInfoCassetteSpecInfoCard():
return infoCard(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( HandlesInfoCassetteSpecInfoCard value)?  infoCard,}){
final _that = this;
switch (_that) {
case HandlesInfoCassetteSpecInfoCard() when infoCard != null:
return infoCard(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( HandlesInfoKey key,  HandlesCassetteChildVariant childVariant)?  infoCard,required TResult orElse(),}) {final _that = this;
switch (_that) {
case HandlesInfoCassetteSpecInfoCard() when infoCard != null:
return infoCard(_that.key,_that.childVariant);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( HandlesInfoKey key,  HandlesCassetteChildVariant childVariant)  infoCard,}) {final _that = this;
switch (_that) {
case HandlesInfoCassetteSpecInfoCard():
return infoCard(_that.key,_that.childVariant);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( HandlesInfoKey key,  HandlesCassetteChildVariant childVariant)?  infoCard,}) {final _that = this;
switch (_that) {
case HandlesInfoCassetteSpecInfoCard() when infoCard != null:
return infoCard(_that.key,_that.childVariant);case _:
  return null;

}
}

}

/// @nodoc


class HandlesInfoCassetteSpecInfoCard extends HandlesInfoCassetteSpec {
  const HandlesInfoCassetteSpecInfoCard({required this.key, required this.childVariant}): super._();
  

@override final  HandlesInfoKey key;
@override final  HandlesCassetteChildVariant childVariant;

/// Create a copy of HandlesInfoCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HandlesInfoCassetteSpecInfoCardCopyWith<HandlesInfoCassetteSpecInfoCard> get copyWith => _$HandlesInfoCassetteSpecInfoCardCopyWithImpl<HandlesInfoCassetteSpecInfoCard>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HandlesInfoCassetteSpecInfoCard&&(identical(other.key, key) || other.key == key)&&(identical(other.childVariant, childVariant) || other.childVariant == childVariant));
}


@override
int get hashCode => Object.hash(runtimeType,key,childVariant);

@override
String toString() {
  return 'HandlesInfoCassetteSpec.infoCard(key: $key, childVariant: $childVariant)';
}


}

/// @nodoc
abstract mixin class $HandlesInfoCassetteSpecInfoCardCopyWith<$Res> implements $HandlesInfoCassetteSpecCopyWith<$Res> {
  factory $HandlesInfoCassetteSpecInfoCardCopyWith(HandlesInfoCassetteSpecInfoCard value, $Res Function(HandlesInfoCassetteSpecInfoCard) _then) = _$HandlesInfoCassetteSpecInfoCardCopyWithImpl;
@override @useResult
$Res call({
 HandlesInfoKey key, HandlesCassetteChildVariant childVariant
});




}
/// @nodoc
class _$HandlesInfoCassetteSpecInfoCardCopyWithImpl<$Res>
    implements $HandlesInfoCassetteSpecInfoCardCopyWith<$Res> {
  _$HandlesInfoCassetteSpecInfoCardCopyWithImpl(this._self, this._then);

  final HandlesInfoCassetteSpecInfoCard _self;
  final $Res Function(HandlesInfoCassetteSpecInfoCard) _then;

/// Create a copy of HandlesInfoCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? childVariant = null,}) {
  return _then(HandlesInfoCassetteSpecInfoCard(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as HandlesInfoKey,childVariant: null == childVariant ? _self.childVariant : childVariant // ignore: cast_nullable_to_non_nullable
as HandlesCassetteChildVariant,
  ));
}


}

// dart format on
