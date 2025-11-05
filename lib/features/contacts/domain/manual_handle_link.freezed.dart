// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'manual_handle_link.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ManualHandleLink {

 int get handleId; String get handleIdentifier; int get participantId; String get participantName; DateTime get createdAt;
/// Create a copy of ManualHandleLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ManualHandleLinkCopyWith<ManualHandleLink> get copyWith => _$ManualHandleLinkCopyWithImpl<ManualHandleLink>(this as ManualHandleLink, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ManualHandleLink&&(identical(other.handleId, handleId) || other.handleId == handleId)&&(identical(other.handleIdentifier, handleIdentifier) || other.handleIdentifier == handleIdentifier)&&(identical(other.participantId, participantId) || other.participantId == participantId)&&(identical(other.participantName, participantName) || other.participantName == participantName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,handleId,handleIdentifier,participantId,participantName,createdAt);

@override
String toString() {
  return 'ManualHandleLink(handleId: $handleId, handleIdentifier: $handleIdentifier, participantId: $participantId, participantName: $participantName, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ManualHandleLinkCopyWith<$Res>  {
  factory $ManualHandleLinkCopyWith(ManualHandleLink value, $Res Function(ManualHandleLink) _then) = _$ManualHandleLinkCopyWithImpl;
@useResult
$Res call({
 int handleId, String handleIdentifier, int participantId, String participantName, DateTime createdAt
});




}
/// @nodoc
class _$ManualHandleLinkCopyWithImpl<$Res>
    implements $ManualHandleLinkCopyWith<$Res> {
  _$ManualHandleLinkCopyWithImpl(this._self, this._then);

  final ManualHandleLink _self;
  final $Res Function(ManualHandleLink) _then;

/// Create a copy of ManualHandleLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? handleId = null,Object? handleIdentifier = null,Object? participantId = null,Object? participantName = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
handleId: null == handleId ? _self.handleId : handleId // ignore: cast_nullable_to_non_nullable
as int,handleIdentifier: null == handleIdentifier ? _self.handleIdentifier : handleIdentifier // ignore: cast_nullable_to_non_nullable
as String,participantId: null == participantId ? _self.participantId : participantId // ignore: cast_nullable_to_non_nullable
as int,participantName: null == participantName ? _self.participantName : participantName // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ManualHandleLink].
extension ManualHandleLinkPatterns on ManualHandleLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ManualHandleLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ManualHandleLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ManualHandleLink value)  $default,){
final _that = this;
switch (_that) {
case _ManualHandleLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ManualHandleLink value)?  $default,){
final _that = this;
switch (_that) {
case _ManualHandleLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int handleId,  String handleIdentifier,  int participantId,  String participantName,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ManualHandleLink() when $default != null:
return $default(_that.handleId,_that.handleIdentifier,_that.participantId,_that.participantName,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int handleId,  String handleIdentifier,  int participantId,  String participantName,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ManualHandleLink():
return $default(_that.handleId,_that.handleIdentifier,_that.participantId,_that.participantName,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int handleId,  String handleIdentifier,  int participantId,  String participantName,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ManualHandleLink() when $default != null:
return $default(_that.handleId,_that.handleIdentifier,_that.participantId,_that.participantName,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _ManualHandleLink extends ManualHandleLink {
  const _ManualHandleLink({required this.handleId, required this.handleIdentifier, required this.participantId, required this.participantName, required this.createdAt}): super._();
  

@override final  int handleId;
@override final  String handleIdentifier;
@override final  int participantId;
@override final  String participantName;
@override final  DateTime createdAt;

/// Create a copy of ManualHandleLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ManualHandleLinkCopyWith<_ManualHandleLink> get copyWith => __$ManualHandleLinkCopyWithImpl<_ManualHandleLink>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ManualHandleLink&&(identical(other.handleId, handleId) || other.handleId == handleId)&&(identical(other.handleIdentifier, handleIdentifier) || other.handleIdentifier == handleIdentifier)&&(identical(other.participantId, participantId) || other.participantId == participantId)&&(identical(other.participantName, participantName) || other.participantName == participantName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,handleId,handleIdentifier,participantId,participantName,createdAt);

@override
String toString() {
  return 'ManualHandleLink(handleId: $handleId, handleIdentifier: $handleIdentifier, participantId: $participantId, participantName: $participantName, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ManualHandleLinkCopyWith<$Res> implements $ManualHandleLinkCopyWith<$Res> {
  factory _$ManualHandleLinkCopyWith(_ManualHandleLink value, $Res Function(_ManualHandleLink) _then) = __$ManualHandleLinkCopyWithImpl;
@override @useResult
$Res call({
 int handleId, String handleIdentifier, int participantId, String participantName, DateTime createdAt
});




}
/// @nodoc
class __$ManualHandleLinkCopyWithImpl<$Res>
    implements _$ManualHandleLinkCopyWith<$Res> {
  __$ManualHandleLinkCopyWithImpl(this._self, this._then);

  final _ManualHandleLink _self;
  final $Res Function(_ManualHandleLink) _then;

/// Create a copy of ManualHandleLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? handleId = null,Object? handleIdentifier = null,Object? participantId = null,Object? participantName = null,Object? createdAt = null,}) {
  return _then(_ManualHandleLink(
handleId: null == handleId ? _self.handleId : handleId // ignore: cast_nullable_to_non_nullable
as int,handleIdentifier: null == handleIdentifier ? _self.handleIdentifier : handleIdentifier // ignore: cast_nullable_to_non_nullable
as String,participantId: null == participantId ? _self.participantId : participantId // ignore: cast_nullable_to_non_nullable
as int,participantName: null == participantName ? _self.participantName : participantName // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
