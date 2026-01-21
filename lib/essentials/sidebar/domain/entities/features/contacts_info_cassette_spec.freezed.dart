// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contacts_info_cassette_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ContactsInfoCassetteSpec {

 ContactsInfoKey get key;
/// Create a copy of ContactsInfoCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactsInfoCassetteSpecCopyWith<ContactsInfoCassetteSpec> get copyWith => _$ContactsInfoCassetteSpecCopyWithImpl<ContactsInfoCassetteSpec>(this as ContactsInfoCassetteSpec, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactsInfoCassetteSpec&&(identical(other.key, key) || other.key == key));
}


@override
int get hashCode => Object.hash(runtimeType,key);

@override
String toString() {
  return 'ContactsInfoCassetteSpec(key: $key)';
}


}

/// @nodoc
abstract mixin class $ContactsInfoCassetteSpecCopyWith<$Res>  {
  factory $ContactsInfoCassetteSpecCopyWith(ContactsInfoCassetteSpec value, $Res Function(ContactsInfoCassetteSpec) _then) = _$ContactsInfoCassetteSpecCopyWithImpl;
@useResult
$Res call({
 ContactsInfoKey key
});




}
/// @nodoc
class _$ContactsInfoCassetteSpecCopyWithImpl<$Res>
    implements $ContactsInfoCassetteSpecCopyWith<$Res> {
  _$ContactsInfoCassetteSpecCopyWithImpl(this._self, this._then);

  final ContactsInfoCassetteSpec _self;
  final $Res Function(ContactsInfoCassetteSpec) _then;

/// Create a copy of ContactsInfoCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as ContactsInfoKey,
  ));
}

}


/// Adds pattern-matching-related methods to [ContactsInfoCassetteSpec].
extension ContactsInfoCassetteSpecPatterns on ContactsInfoCassetteSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ContactsInfoCassetteSpecInfoCard value)?  infoCard,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ContactsInfoCassetteSpecInfoCard() when infoCard != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ContactsInfoCassetteSpecInfoCard value)  infoCard,}){
final _that = this;
switch (_that) {
case ContactsInfoCassetteSpecInfoCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ContactsInfoCassetteSpecInfoCard value)?  infoCard,}){
final _that = this;
switch (_that) {
case ContactsInfoCassetteSpecInfoCard() when infoCard != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( ContactsInfoKey key)?  infoCard,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ContactsInfoCassetteSpecInfoCard() when infoCard != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( ContactsInfoKey key)  infoCard,}) {final _that = this;
switch (_that) {
case ContactsInfoCassetteSpecInfoCard():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( ContactsInfoKey key)?  infoCard,}) {final _that = this;
switch (_that) {
case ContactsInfoCassetteSpecInfoCard() when infoCard != null:
return infoCard(_that.key);case _:
  return null;

}
}

}

/// @nodoc


class ContactsInfoCassetteSpecInfoCard extends ContactsInfoCassetteSpec {
  const ContactsInfoCassetteSpecInfoCard({required this.key}): super._();
  

@override final  ContactsInfoKey key;

/// Create a copy of ContactsInfoCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactsInfoCassetteSpecInfoCardCopyWith<ContactsInfoCassetteSpecInfoCard> get copyWith => _$ContactsInfoCassetteSpecInfoCardCopyWithImpl<ContactsInfoCassetteSpecInfoCard>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactsInfoCassetteSpecInfoCard&&(identical(other.key, key) || other.key == key));
}


@override
int get hashCode => Object.hash(runtimeType,key);

@override
String toString() {
  return 'ContactsInfoCassetteSpec.infoCard(key: $key)';
}


}

/// @nodoc
abstract mixin class $ContactsInfoCassetteSpecInfoCardCopyWith<$Res> implements $ContactsInfoCassetteSpecCopyWith<$Res> {
  factory $ContactsInfoCassetteSpecInfoCardCopyWith(ContactsInfoCassetteSpecInfoCard value, $Res Function(ContactsInfoCassetteSpecInfoCard) _then) = _$ContactsInfoCassetteSpecInfoCardCopyWithImpl;
@override @useResult
$Res call({
 ContactsInfoKey key
});




}
/// @nodoc
class _$ContactsInfoCassetteSpecInfoCardCopyWithImpl<$Res>
    implements $ContactsInfoCassetteSpecInfoCardCopyWith<$Res> {
  _$ContactsInfoCassetteSpecInfoCardCopyWithImpl(this._self, this._then);

  final ContactsInfoCassetteSpecInfoCard _self;
  final $Res Function(ContactsInfoCassetteSpecInfoCard) _then;

/// Create a copy of ContactsInfoCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,}) {
  return _then(ContactsInfoCassetteSpecInfoCard(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as ContactsInfoKey,
  ));
}


}

// dart format on
