// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorite_contact.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FavoriteContact {

 int get participantId; int get sortOrder; DateTime get pinnedAt; DateTime? get lastInteractionAt; DateTime get updatedAt;
/// Create a copy of FavoriteContact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoriteContactCopyWith<FavoriteContact> get copyWith => _$FavoriteContactCopyWithImpl<FavoriteContact>(this as FavoriteContact, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoriteContact&&(identical(other.participantId, participantId) || other.participantId == participantId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.pinnedAt, pinnedAt) || other.pinnedAt == pinnedAt)&&(identical(other.lastInteractionAt, lastInteractionAt) || other.lastInteractionAt == lastInteractionAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,participantId,sortOrder,pinnedAt,lastInteractionAt,updatedAt);

@override
String toString() {
  return 'FavoriteContact(participantId: $participantId, sortOrder: $sortOrder, pinnedAt: $pinnedAt, lastInteractionAt: $lastInteractionAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FavoriteContactCopyWith<$Res>  {
  factory $FavoriteContactCopyWith(FavoriteContact value, $Res Function(FavoriteContact) _then) = _$FavoriteContactCopyWithImpl;
@useResult
$Res call({
 int participantId, int sortOrder, DateTime pinnedAt, DateTime? lastInteractionAt, DateTime updatedAt
});




}
/// @nodoc
class _$FavoriteContactCopyWithImpl<$Res>
    implements $FavoriteContactCopyWith<$Res> {
  _$FavoriteContactCopyWithImpl(this._self, this._then);

  final FavoriteContact _self;
  final $Res Function(FavoriteContact) _then;

/// Create a copy of FavoriteContact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? participantId = null,Object? sortOrder = null,Object? pinnedAt = null,Object? lastInteractionAt = freezed,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
participantId: null == participantId ? _self.participantId : participantId // ignore: cast_nullable_to_non_nullable
as int,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,pinnedAt: null == pinnedAt ? _self.pinnedAt : pinnedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastInteractionAt: freezed == lastInteractionAt ? _self.lastInteractionAt : lastInteractionAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FavoriteContact].
extension FavoriteContactPatterns on FavoriteContact {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoriteContact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoriteContact() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoriteContact value)  $default,){
final _that = this;
switch (_that) {
case _FavoriteContact():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoriteContact value)?  $default,){
final _that = this;
switch (_that) {
case _FavoriteContact() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int participantId,  int sortOrder,  DateTime pinnedAt,  DateTime? lastInteractionAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoriteContact() when $default != null:
return $default(_that.participantId,_that.sortOrder,_that.pinnedAt,_that.lastInteractionAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int participantId,  int sortOrder,  DateTime pinnedAt,  DateTime? lastInteractionAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FavoriteContact():
return $default(_that.participantId,_that.sortOrder,_that.pinnedAt,_that.lastInteractionAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int participantId,  int sortOrder,  DateTime pinnedAt,  DateTime? lastInteractionAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FavoriteContact() when $default != null:
return $default(_that.participantId,_that.sortOrder,_that.pinnedAt,_that.lastInteractionAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _FavoriteContact extends FavoriteContact {
  const _FavoriteContact({required this.participantId, required this.sortOrder, required this.pinnedAt, this.lastInteractionAt, required this.updatedAt}): super._();
  

@override final  int participantId;
@override final  int sortOrder;
@override final  DateTime pinnedAt;
@override final  DateTime? lastInteractionAt;
@override final  DateTime updatedAt;

/// Create a copy of FavoriteContact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoriteContactCopyWith<_FavoriteContact> get copyWith => __$FavoriteContactCopyWithImpl<_FavoriteContact>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoriteContact&&(identical(other.participantId, participantId) || other.participantId == participantId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.pinnedAt, pinnedAt) || other.pinnedAt == pinnedAt)&&(identical(other.lastInteractionAt, lastInteractionAt) || other.lastInteractionAt == lastInteractionAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,participantId,sortOrder,pinnedAt,lastInteractionAt,updatedAt);

@override
String toString() {
  return 'FavoriteContact(participantId: $participantId, sortOrder: $sortOrder, pinnedAt: $pinnedAt, lastInteractionAt: $lastInteractionAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FavoriteContactCopyWith<$Res> implements $FavoriteContactCopyWith<$Res> {
  factory _$FavoriteContactCopyWith(_FavoriteContact value, $Res Function(_FavoriteContact) _then) = __$FavoriteContactCopyWithImpl;
@override @useResult
$Res call({
 int participantId, int sortOrder, DateTime pinnedAt, DateTime? lastInteractionAt, DateTime updatedAt
});




}
/// @nodoc
class __$FavoriteContactCopyWithImpl<$Res>
    implements _$FavoriteContactCopyWith<$Res> {
  __$FavoriteContactCopyWithImpl(this._self, this._then);

  final _FavoriteContact _self;
  final $Res Function(_FavoriteContact) _then;

/// Create a copy of FavoriteContact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? participantId = null,Object? sortOrder = null,Object? pinnedAt = null,Object? lastInteractionAt = freezed,Object? updatedAt = null,}) {
  return _then(_FavoriteContact(
participantId: null == participantId ? _self.participantId : participantId // ignore: cast_nullable_to_non_nullable
as int,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,pinnedAt: null == pinnedAt ? _self.pinnedAt : pinnedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastInteractionAt: freezed == lastInteractionAt ? _self.lastInteractionAt : lastInteractionAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
