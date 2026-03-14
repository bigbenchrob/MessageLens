// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'messages_info_cassette_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MessagesInfoCassetteSpec {

 MessagesInfoKey get key;
/// Create a copy of MessagesInfoCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessagesInfoCassetteSpecCopyWith<MessagesInfoCassetteSpec> get copyWith => _$MessagesInfoCassetteSpecCopyWithImpl<MessagesInfoCassetteSpec>(this as MessagesInfoCassetteSpec, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessagesInfoCassetteSpec&&(identical(other.key, key) || other.key == key));
}


@override
int get hashCode => Object.hash(runtimeType,key);

@override
String toString() {
  return 'MessagesInfoCassetteSpec(key: $key)';
}


}

/// @nodoc
abstract mixin class $MessagesInfoCassetteSpecCopyWith<$Res>  {
  factory $MessagesInfoCassetteSpecCopyWith(MessagesInfoCassetteSpec value, $Res Function(MessagesInfoCassetteSpec) _then) = _$MessagesInfoCassetteSpecCopyWithImpl;
@useResult
$Res call({
 MessagesInfoKey key
});




}
/// @nodoc
class _$MessagesInfoCassetteSpecCopyWithImpl<$Res>
    implements $MessagesInfoCassetteSpecCopyWith<$Res> {
  _$MessagesInfoCassetteSpecCopyWithImpl(this._self, this._then);

  final MessagesInfoCassetteSpec _self;
  final $Res Function(MessagesInfoCassetteSpec) _then;

/// Create a copy of MessagesInfoCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as MessagesInfoKey,
  ));
}

}


/// Adds pattern-matching-related methods to [MessagesInfoCassetteSpec].
extension MessagesInfoCassetteSpecPatterns on MessagesInfoCassetteSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MessagesInfoCassetteSpecInfoCard value)?  infoCard,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MessagesInfoCassetteSpecInfoCard() when infoCard != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MessagesInfoCassetteSpecInfoCard value)  infoCard,}){
final _that = this;
switch (_that) {
case MessagesInfoCassetteSpecInfoCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MessagesInfoCassetteSpecInfoCard value)?  infoCard,}){
final _that = this;
switch (_that) {
case MessagesInfoCassetteSpecInfoCard() when infoCard != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( MessagesInfoKey key)?  infoCard,required TResult orElse(),}) {final _that = this;
switch (_that) {
case MessagesInfoCassetteSpecInfoCard() when infoCard != null:
return infoCard(_that.key);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( MessagesInfoKey key)  infoCard,}) {final _that = this;
switch (_that) {
case MessagesInfoCassetteSpecInfoCard():
return infoCard(_that.key);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( MessagesInfoKey key)?  infoCard,}) {final _that = this;
switch (_that) {
case MessagesInfoCassetteSpecInfoCard() when infoCard != null:
return infoCard(_that.key);case _:
  return null;

}
}

}

/// @nodoc


class MessagesInfoCassetteSpecInfoCard extends MessagesInfoCassetteSpec {
  const MessagesInfoCassetteSpecInfoCard({required this.key}): super._();
  

@override final  MessagesInfoKey key;

/// Create a copy of MessagesInfoCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessagesInfoCassetteSpecInfoCardCopyWith<MessagesInfoCassetteSpecInfoCard> get copyWith => _$MessagesInfoCassetteSpecInfoCardCopyWithImpl<MessagesInfoCassetteSpecInfoCard>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessagesInfoCassetteSpecInfoCard&&(identical(other.key, key) || other.key == key));
}


@override
int get hashCode => Object.hash(runtimeType,key);

@override
String toString() {
  return 'MessagesInfoCassetteSpec.infoCard(key: $key)';
}


}

/// @nodoc
abstract mixin class $MessagesInfoCassetteSpecInfoCardCopyWith<$Res> implements $MessagesInfoCassetteSpecCopyWith<$Res> {
  factory $MessagesInfoCassetteSpecInfoCardCopyWith(MessagesInfoCassetteSpecInfoCard value, $Res Function(MessagesInfoCassetteSpecInfoCard) _then) = _$MessagesInfoCassetteSpecInfoCardCopyWithImpl;
@override @useResult
$Res call({
 MessagesInfoKey key
});




}
/// @nodoc
class _$MessagesInfoCassetteSpecInfoCardCopyWithImpl<$Res>
    implements $MessagesInfoCassetteSpecInfoCardCopyWith<$Res> {
  _$MessagesInfoCassetteSpecInfoCardCopyWithImpl(this._self, this._then);

  final MessagesInfoCassetteSpecInfoCard _self;
  final $Res Function(MessagesInfoCassetteSpecInfoCard) _then;

/// Create a copy of MessagesInfoCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,}) {
  return _then(MessagesInfoCassetteSpecInfoCard(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as MessagesInfoKey,
  ));
}


}

// dart format on
