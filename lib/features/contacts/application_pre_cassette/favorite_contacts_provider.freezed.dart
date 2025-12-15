// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorite_contacts_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FavoriteContactEntry {

 ContactSummary get contact; DateTime get pinnedAt; DateTime? get lastInteractionAt; DateTime get updatedAt;
/// Create a copy of FavoriteContactEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoriteContactEntryCopyWith<FavoriteContactEntry> get copyWith => _$FavoriteContactEntryCopyWithImpl<FavoriteContactEntry>(this as FavoriteContactEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoriteContactEntry&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.pinnedAt, pinnedAt) || other.pinnedAt == pinnedAt)&&(identical(other.lastInteractionAt, lastInteractionAt) || other.lastInteractionAt == lastInteractionAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,contact,pinnedAt,lastInteractionAt,updatedAt);

@override
String toString() {
  return 'FavoriteContactEntry(contact: $contact, pinnedAt: $pinnedAt, lastInteractionAt: $lastInteractionAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FavoriteContactEntryCopyWith<$Res>  {
  factory $FavoriteContactEntryCopyWith(FavoriteContactEntry value, $Res Function(FavoriteContactEntry) _then) = _$FavoriteContactEntryCopyWithImpl;
@useResult
$Res call({
 ContactSummary contact, DateTime pinnedAt, DateTime? lastInteractionAt, DateTime updatedAt
});


$ContactSummaryCopyWith<$Res> get contact;

}
/// @nodoc
class _$FavoriteContactEntryCopyWithImpl<$Res>
    implements $FavoriteContactEntryCopyWith<$Res> {
  _$FavoriteContactEntryCopyWithImpl(this._self, this._then);

  final FavoriteContactEntry _self;
  final $Res Function(FavoriteContactEntry) _then;

/// Create a copy of FavoriteContactEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contact = null,Object? pinnedAt = null,Object? lastInteractionAt = freezed,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
contact: null == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as ContactSummary,pinnedAt: null == pinnedAt ? _self.pinnedAt : pinnedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastInteractionAt: freezed == lastInteractionAt ? _self.lastInteractionAt : lastInteractionAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of FavoriteContactEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactSummaryCopyWith<$Res> get contact {
  
  return $ContactSummaryCopyWith<$Res>(_self.contact, (value) {
    return _then(_self.copyWith(contact: value));
  });
}
}


/// Adds pattern-matching-related methods to [FavoriteContactEntry].
extension FavoriteContactEntryPatterns on FavoriteContactEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoriteContactEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoriteContactEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoriteContactEntry value)  $default,){
final _that = this;
switch (_that) {
case _FavoriteContactEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoriteContactEntry value)?  $default,){
final _that = this;
switch (_that) {
case _FavoriteContactEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ContactSummary contact,  DateTime pinnedAt,  DateTime? lastInteractionAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoriteContactEntry() when $default != null:
return $default(_that.contact,_that.pinnedAt,_that.lastInteractionAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ContactSummary contact,  DateTime pinnedAt,  DateTime? lastInteractionAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FavoriteContactEntry():
return $default(_that.contact,_that.pinnedAt,_that.lastInteractionAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ContactSummary contact,  DateTime pinnedAt,  DateTime? lastInteractionAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FavoriteContactEntry() when $default != null:
return $default(_that.contact,_that.pinnedAt,_that.lastInteractionAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _FavoriteContactEntry implements FavoriteContactEntry {
  const _FavoriteContactEntry({required this.contact, required this.pinnedAt, this.lastInteractionAt, required this.updatedAt});
  

@override final  ContactSummary contact;
@override final  DateTime pinnedAt;
@override final  DateTime? lastInteractionAt;
@override final  DateTime updatedAt;

/// Create a copy of FavoriteContactEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoriteContactEntryCopyWith<_FavoriteContactEntry> get copyWith => __$FavoriteContactEntryCopyWithImpl<_FavoriteContactEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoriteContactEntry&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.pinnedAt, pinnedAt) || other.pinnedAt == pinnedAt)&&(identical(other.lastInteractionAt, lastInteractionAt) || other.lastInteractionAt == lastInteractionAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,contact,pinnedAt,lastInteractionAt,updatedAt);

@override
String toString() {
  return 'FavoriteContactEntry(contact: $contact, pinnedAt: $pinnedAt, lastInteractionAt: $lastInteractionAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FavoriteContactEntryCopyWith<$Res> implements $FavoriteContactEntryCopyWith<$Res> {
  factory _$FavoriteContactEntryCopyWith(_FavoriteContactEntry value, $Res Function(_FavoriteContactEntry) _then) = __$FavoriteContactEntryCopyWithImpl;
@override @useResult
$Res call({
 ContactSummary contact, DateTime pinnedAt, DateTime? lastInteractionAt, DateTime updatedAt
});


@override $ContactSummaryCopyWith<$Res> get contact;

}
/// @nodoc
class __$FavoriteContactEntryCopyWithImpl<$Res>
    implements _$FavoriteContactEntryCopyWith<$Res> {
  __$FavoriteContactEntryCopyWithImpl(this._self, this._then);

  final _FavoriteContactEntry _self;
  final $Res Function(_FavoriteContactEntry) _then;

/// Create a copy of FavoriteContactEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contact = null,Object? pinnedAt = null,Object? lastInteractionAt = freezed,Object? updatedAt = null,}) {
  return _then(_FavoriteContactEntry(
contact: null == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as ContactSummary,pinnedAt: null == pinnedAt ? _self.pinnedAt : pinnedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastInteractionAt: freezed == lastInteractionAt ? _self.lastInteractionAt : lastInteractionAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of FavoriteContactEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactSummaryCopyWith<$Res> get contact {
  
  return $ContactSummaryCopyWith<$Res>(_self.contact, (value) {
    return _then(_self.copyWith(contact: value));
  });
}
}

// dart format on
