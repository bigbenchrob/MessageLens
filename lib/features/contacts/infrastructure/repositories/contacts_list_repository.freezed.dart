// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contacts_list_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ContactSummary {

 int get participantId; String get displayName; String get shortName; int get totalChats; int get totalMessages; DateTime? get lastMessageDate; ParticipantOrigin get origin; int get handleCount;
/// Create a copy of ContactSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactSummaryCopyWith<ContactSummary> get copyWith => _$ContactSummaryCopyWithImpl<ContactSummary>(this as ContactSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactSummary&&(identical(other.participantId, participantId) || other.participantId == participantId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.totalChats, totalChats) || other.totalChats == totalChats)&&(identical(other.totalMessages, totalMessages) || other.totalMessages == totalMessages)&&(identical(other.lastMessageDate, lastMessageDate) || other.lastMessageDate == lastMessageDate)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.handleCount, handleCount) || other.handleCount == handleCount));
}


@override
int get hashCode => Object.hash(runtimeType,participantId,displayName,shortName,totalChats,totalMessages,lastMessageDate,origin,handleCount);

@override
String toString() {
  return 'ContactSummary(participantId: $participantId, displayName: $displayName, shortName: $shortName, totalChats: $totalChats, totalMessages: $totalMessages, lastMessageDate: $lastMessageDate, origin: $origin, handleCount: $handleCount)';
}


}

/// @nodoc
abstract mixin class $ContactSummaryCopyWith<$Res>  {
  factory $ContactSummaryCopyWith(ContactSummary value, $Res Function(ContactSummary) _then) = _$ContactSummaryCopyWithImpl;
@useResult
$Res call({
 int participantId, String displayName, String shortName, int totalChats, int totalMessages, DateTime? lastMessageDate, ParticipantOrigin origin, int handleCount
});




}
/// @nodoc
class _$ContactSummaryCopyWithImpl<$Res>
    implements $ContactSummaryCopyWith<$Res> {
  _$ContactSummaryCopyWithImpl(this._self, this._then);

  final ContactSummary _self;
  final $Res Function(ContactSummary) _then;

/// Create a copy of ContactSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? participantId = null,Object? displayName = null,Object? shortName = null,Object? totalChats = null,Object? totalMessages = null,Object? lastMessageDate = freezed,Object? origin = null,Object? handleCount = null,}) {
  return _then(_self.copyWith(
participantId: null == participantId ? _self.participantId : participantId // ignore: cast_nullable_to_non_nullable
as int,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,shortName: null == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String,totalChats: null == totalChats ? _self.totalChats : totalChats // ignore: cast_nullable_to_non_nullable
as int,totalMessages: null == totalMessages ? _self.totalMessages : totalMessages // ignore: cast_nullable_to_non_nullable
as int,lastMessageDate: freezed == lastMessageDate ? _self.lastMessageDate : lastMessageDate // ignore: cast_nullable_to_non_nullable
as DateTime?,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as ParticipantOrigin,handleCount: null == handleCount ? _self.handleCount : handleCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ContactSummary].
extension ContactSummaryPatterns on ContactSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactSummary value)  $default,){
final _that = this;
switch (_that) {
case _ContactSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ContactSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int participantId,  String displayName,  String shortName,  int totalChats,  int totalMessages,  DateTime? lastMessageDate,  ParticipantOrigin origin,  int handleCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactSummary() when $default != null:
return $default(_that.participantId,_that.displayName,_that.shortName,_that.totalChats,_that.totalMessages,_that.lastMessageDate,_that.origin,_that.handleCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int participantId,  String displayName,  String shortName,  int totalChats,  int totalMessages,  DateTime? lastMessageDate,  ParticipantOrigin origin,  int handleCount)  $default,) {final _that = this;
switch (_that) {
case _ContactSummary():
return $default(_that.participantId,_that.displayName,_that.shortName,_that.totalChats,_that.totalMessages,_that.lastMessageDate,_that.origin,_that.handleCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int participantId,  String displayName,  String shortName,  int totalChats,  int totalMessages,  DateTime? lastMessageDate,  ParticipantOrigin origin,  int handleCount)?  $default,) {final _that = this;
switch (_that) {
case _ContactSummary() when $default != null:
return $default(_that.participantId,_that.displayName,_that.shortName,_that.totalChats,_that.totalMessages,_that.lastMessageDate,_that.origin,_that.handleCount);case _:
  return null;

}
}

}

/// @nodoc


class _ContactSummary extends ContactSummary {
  const _ContactSummary({required this.participantId, required this.displayName, required this.shortName, required this.totalChats, required this.totalMessages, this.lastMessageDate, required this.origin, required this.handleCount}): super._();
  

@override final  int participantId;
@override final  String displayName;
@override final  String shortName;
@override final  int totalChats;
@override final  int totalMessages;
@override final  DateTime? lastMessageDate;
@override final  ParticipantOrigin origin;
@override final  int handleCount;

/// Create a copy of ContactSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactSummaryCopyWith<_ContactSummary> get copyWith => __$ContactSummaryCopyWithImpl<_ContactSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactSummary&&(identical(other.participantId, participantId) || other.participantId == participantId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.totalChats, totalChats) || other.totalChats == totalChats)&&(identical(other.totalMessages, totalMessages) || other.totalMessages == totalMessages)&&(identical(other.lastMessageDate, lastMessageDate) || other.lastMessageDate == lastMessageDate)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.handleCount, handleCount) || other.handleCount == handleCount));
}


@override
int get hashCode => Object.hash(runtimeType,participantId,displayName,shortName,totalChats,totalMessages,lastMessageDate,origin,handleCount);

@override
String toString() {
  return 'ContactSummary(participantId: $participantId, displayName: $displayName, shortName: $shortName, totalChats: $totalChats, totalMessages: $totalMessages, lastMessageDate: $lastMessageDate, origin: $origin, handleCount: $handleCount)';
}


}

/// @nodoc
abstract mixin class _$ContactSummaryCopyWith<$Res> implements $ContactSummaryCopyWith<$Res> {
  factory _$ContactSummaryCopyWith(_ContactSummary value, $Res Function(_ContactSummary) _then) = __$ContactSummaryCopyWithImpl;
@override @useResult
$Res call({
 int participantId, String displayName, String shortName, int totalChats, int totalMessages, DateTime? lastMessageDate, ParticipantOrigin origin, int handleCount
});




}
/// @nodoc
class __$ContactSummaryCopyWithImpl<$Res>
    implements _$ContactSummaryCopyWith<$Res> {
  __$ContactSummaryCopyWithImpl(this._self, this._then);

  final _ContactSummary _self;
  final $Res Function(_ContactSummary) _then;

/// Create a copy of ContactSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? participantId = null,Object? displayName = null,Object? shortName = null,Object? totalChats = null,Object? totalMessages = null,Object? lastMessageDate = freezed,Object? origin = null,Object? handleCount = null,}) {
  return _then(_ContactSummary(
participantId: null == participantId ? _self.participantId : participantId // ignore: cast_nullable_to_non_nullable
as int,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,shortName: null == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String,totalChats: null == totalChats ? _self.totalChats : totalChats // ignore: cast_nullable_to_non_nullable
as int,totalMessages: null == totalMessages ? _self.totalMessages : totalMessages // ignore: cast_nullable_to_non_nullable
as int,lastMessageDate: freezed == lastMessageDate ? _self.lastMessageDate : lastMessageDate // ignore: cast_nullable_to_non_nullable
as DateTime?,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as ParticipantOrigin,handleCount: null == handleCount ? _self.handleCount : handleCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
