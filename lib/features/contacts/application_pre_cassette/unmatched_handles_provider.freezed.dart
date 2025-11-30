// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unmatched_handles_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UnmatchedHandleSummary {

 int get handleId; String get handleValue; String get serviceType; int get totalMessages; bool get isProbableSpam; DateTime? get lastMessageDate;
/// Create a copy of UnmatchedHandleSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnmatchedHandleSummaryCopyWith<UnmatchedHandleSummary> get copyWith => _$UnmatchedHandleSummaryCopyWithImpl<UnmatchedHandleSummary>(this as UnmatchedHandleSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnmatchedHandleSummary&&(identical(other.handleId, handleId) || other.handleId == handleId)&&(identical(other.handleValue, handleValue) || other.handleValue == handleValue)&&(identical(other.serviceType, serviceType) || other.serviceType == serviceType)&&(identical(other.totalMessages, totalMessages) || other.totalMessages == totalMessages)&&(identical(other.isProbableSpam, isProbableSpam) || other.isProbableSpam == isProbableSpam)&&(identical(other.lastMessageDate, lastMessageDate) || other.lastMessageDate == lastMessageDate));
}


@override
int get hashCode => Object.hash(runtimeType,handleId,handleValue,serviceType,totalMessages,isProbableSpam,lastMessageDate);

@override
String toString() {
  return 'UnmatchedHandleSummary(handleId: $handleId, handleValue: $handleValue, serviceType: $serviceType, totalMessages: $totalMessages, isProbableSpam: $isProbableSpam, lastMessageDate: $lastMessageDate)';
}


}

/// @nodoc
abstract mixin class $UnmatchedHandleSummaryCopyWith<$Res>  {
  factory $UnmatchedHandleSummaryCopyWith(UnmatchedHandleSummary value, $Res Function(UnmatchedHandleSummary) _then) = _$UnmatchedHandleSummaryCopyWithImpl;
@useResult
$Res call({
 int handleId, String handleValue, String serviceType, int totalMessages, bool isProbableSpam, DateTime? lastMessageDate
});




}
/// @nodoc
class _$UnmatchedHandleSummaryCopyWithImpl<$Res>
    implements $UnmatchedHandleSummaryCopyWith<$Res> {
  _$UnmatchedHandleSummaryCopyWithImpl(this._self, this._then);

  final UnmatchedHandleSummary _self;
  final $Res Function(UnmatchedHandleSummary) _then;

/// Create a copy of UnmatchedHandleSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? handleId = null,Object? handleValue = null,Object? serviceType = null,Object? totalMessages = null,Object? isProbableSpam = null,Object? lastMessageDate = freezed,}) {
  return _then(_self.copyWith(
handleId: null == handleId ? _self.handleId : handleId // ignore: cast_nullable_to_non_nullable
as int,handleValue: null == handleValue ? _self.handleValue : handleValue // ignore: cast_nullable_to_non_nullable
as String,serviceType: null == serviceType ? _self.serviceType : serviceType // ignore: cast_nullable_to_non_nullable
as String,totalMessages: null == totalMessages ? _self.totalMessages : totalMessages // ignore: cast_nullable_to_non_nullable
as int,isProbableSpam: null == isProbableSpam ? _self.isProbableSpam : isProbableSpam // ignore: cast_nullable_to_non_nullable
as bool,lastMessageDate: freezed == lastMessageDate ? _self.lastMessageDate : lastMessageDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UnmatchedHandleSummary].
extension UnmatchedHandleSummaryPatterns on UnmatchedHandleSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnmatchedHandleSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnmatchedHandleSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnmatchedHandleSummary value)  $default,){
final _that = this;
switch (_that) {
case _UnmatchedHandleSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnmatchedHandleSummary value)?  $default,){
final _that = this;
switch (_that) {
case _UnmatchedHandleSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int handleId,  String handleValue,  String serviceType,  int totalMessages,  bool isProbableSpam,  DateTime? lastMessageDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnmatchedHandleSummary() when $default != null:
return $default(_that.handleId,_that.handleValue,_that.serviceType,_that.totalMessages,_that.isProbableSpam,_that.lastMessageDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int handleId,  String handleValue,  String serviceType,  int totalMessages,  bool isProbableSpam,  DateTime? lastMessageDate)  $default,) {final _that = this;
switch (_that) {
case _UnmatchedHandleSummary():
return $default(_that.handleId,_that.handleValue,_that.serviceType,_that.totalMessages,_that.isProbableSpam,_that.lastMessageDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int handleId,  String handleValue,  String serviceType,  int totalMessages,  bool isProbableSpam,  DateTime? lastMessageDate)?  $default,) {final _that = this;
switch (_that) {
case _UnmatchedHandleSummary() when $default != null:
return $default(_that.handleId,_that.handleValue,_that.serviceType,_that.totalMessages,_that.isProbableSpam,_that.lastMessageDate);case _:
  return null;

}
}

}

/// @nodoc


class _UnmatchedHandleSummary implements UnmatchedHandleSummary {
  const _UnmatchedHandleSummary({required this.handleId, required this.handleValue, required this.serviceType, required this.totalMessages, required this.isProbableSpam, this.lastMessageDate});
  

@override final  int handleId;
@override final  String handleValue;
@override final  String serviceType;
@override final  int totalMessages;
@override final  bool isProbableSpam;
@override final  DateTime? lastMessageDate;

/// Create a copy of UnmatchedHandleSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnmatchedHandleSummaryCopyWith<_UnmatchedHandleSummary> get copyWith => __$UnmatchedHandleSummaryCopyWithImpl<_UnmatchedHandleSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnmatchedHandleSummary&&(identical(other.handleId, handleId) || other.handleId == handleId)&&(identical(other.handleValue, handleValue) || other.handleValue == handleValue)&&(identical(other.serviceType, serviceType) || other.serviceType == serviceType)&&(identical(other.totalMessages, totalMessages) || other.totalMessages == totalMessages)&&(identical(other.isProbableSpam, isProbableSpam) || other.isProbableSpam == isProbableSpam)&&(identical(other.lastMessageDate, lastMessageDate) || other.lastMessageDate == lastMessageDate));
}


@override
int get hashCode => Object.hash(runtimeType,handleId,handleValue,serviceType,totalMessages,isProbableSpam,lastMessageDate);

@override
String toString() {
  return 'UnmatchedHandleSummary(handleId: $handleId, handleValue: $handleValue, serviceType: $serviceType, totalMessages: $totalMessages, isProbableSpam: $isProbableSpam, lastMessageDate: $lastMessageDate)';
}


}

/// @nodoc
abstract mixin class _$UnmatchedHandleSummaryCopyWith<$Res> implements $UnmatchedHandleSummaryCopyWith<$Res> {
  factory _$UnmatchedHandleSummaryCopyWith(_UnmatchedHandleSummary value, $Res Function(_UnmatchedHandleSummary) _then) = __$UnmatchedHandleSummaryCopyWithImpl;
@override @useResult
$Res call({
 int handleId, String handleValue, String serviceType, int totalMessages, bool isProbableSpam, DateTime? lastMessageDate
});




}
/// @nodoc
class __$UnmatchedHandleSummaryCopyWithImpl<$Res>
    implements _$UnmatchedHandleSummaryCopyWith<$Res> {
  __$UnmatchedHandleSummaryCopyWithImpl(this._self, this._then);

  final _UnmatchedHandleSummary _self;
  final $Res Function(_UnmatchedHandleSummary) _then;

/// Create a copy of UnmatchedHandleSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? handleId = null,Object? handleValue = null,Object? serviceType = null,Object? totalMessages = null,Object? isProbableSpam = null,Object? lastMessageDate = freezed,}) {
  return _then(_UnmatchedHandleSummary(
handleId: null == handleId ? _self.handleId : handleId // ignore: cast_nullable_to_non_nullable
as int,handleValue: null == handleValue ? _self.handleValue : handleValue // ignore: cast_nullable_to_non_nullable
as String,serviceType: null == serviceType ? _self.serviceType : serviceType // ignore: cast_nullable_to_non_nullable
as String,totalMessages: null == totalMessages ? _self.totalMessages : totalMessages // ignore: cast_nullable_to_non_nullable
as int,isProbableSpam: null == isProbableSpam ? _self.isProbableSpam : isProbableSpam // ignore: cast_nullable_to_non_nullable
as bool,lastMessageDate: freezed == lastMessageDate ? _self.lastMessageDate : lastMessageDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
