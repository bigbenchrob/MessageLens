// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stray_handles_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StrayHandleSummary {

 int get handleId; String get handleValue; String get serviceType; int get totalMessages;/// ISO 8601 timestamp of when the user last reviewed this handle, or null
/// if never reviewed.
 String? get reviewedAt; DateTime? get lastMessageDate;
/// Create a copy of StrayHandleSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StrayHandleSummaryCopyWith<StrayHandleSummary> get copyWith => _$StrayHandleSummaryCopyWithImpl<StrayHandleSummary>(this as StrayHandleSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StrayHandleSummary&&(identical(other.handleId, handleId) || other.handleId == handleId)&&(identical(other.handleValue, handleValue) || other.handleValue == handleValue)&&(identical(other.serviceType, serviceType) || other.serviceType == serviceType)&&(identical(other.totalMessages, totalMessages) || other.totalMessages == totalMessages)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.lastMessageDate, lastMessageDate) || other.lastMessageDate == lastMessageDate));
}


@override
int get hashCode => Object.hash(runtimeType,handleId,handleValue,serviceType,totalMessages,reviewedAt,lastMessageDate);

@override
String toString() {
  return 'StrayHandleSummary(handleId: $handleId, handleValue: $handleValue, serviceType: $serviceType, totalMessages: $totalMessages, reviewedAt: $reviewedAt, lastMessageDate: $lastMessageDate)';
}


}

/// @nodoc
abstract mixin class $StrayHandleSummaryCopyWith<$Res>  {
  factory $StrayHandleSummaryCopyWith(StrayHandleSummary value, $Res Function(StrayHandleSummary) _then) = _$StrayHandleSummaryCopyWithImpl;
@useResult
$Res call({
 int handleId, String handleValue, String serviceType, int totalMessages, String? reviewedAt, DateTime? lastMessageDate
});




}
/// @nodoc
class _$StrayHandleSummaryCopyWithImpl<$Res>
    implements $StrayHandleSummaryCopyWith<$Res> {
  _$StrayHandleSummaryCopyWithImpl(this._self, this._then);

  final StrayHandleSummary _self;
  final $Res Function(StrayHandleSummary) _then;

/// Create a copy of StrayHandleSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? handleId = null,Object? handleValue = null,Object? serviceType = null,Object? totalMessages = null,Object? reviewedAt = freezed,Object? lastMessageDate = freezed,}) {
  return _then(_self.copyWith(
handleId: null == handleId ? _self.handleId : handleId // ignore: cast_nullable_to_non_nullable
as int,handleValue: null == handleValue ? _self.handleValue : handleValue // ignore: cast_nullable_to_non_nullable
as String,serviceType: null == serviceType ? _self.serviceType : serviceType // ignore: cast_nullable_to_non_nullable
as String,totalMessages: null == totalMessages ? _self.totalMessages : totalMessages // ignore: cast_nullable_to_non_nullable
as int,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,lastMessageDate: freezed == lastMessageDate ? _self.lastMessageDate : lastMessageDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [StrayHandleSummary].
extension StrayHandleSummaryPatterns on StrayHandleSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StrayHandleSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StrayHandleSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StrayHandleSummary value)  $default,){
final _that = this;
switch (_that) {
case _StrayHandleSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StrayHandleSummary value)?  $default,){
final _that = this;
switch (_that) {
case _StrayHandleSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int handleId,  String handleValue,  String serviceType,  int totalMessages,  String? reviewedAt,  DateTime? lastMessageDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StrayHandleSummary() when $default != null:
return $default(_that.handleId,_that.handleValue,_that.serviceType,_that.totalMessages,_that.reviewedAt,_that.lastMessageDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int handleId,  String handleValue,  String serviceType,  int totalMessages,  String? reviewedAt,  DateTime? lastMessageDate)  $default,) {final _that = this;
switch (_that) {
case _StrayHandleSummary():
return $default(_that.handleId,_that.handleValue,_that.serviceType,_that.totalMessages,_that.reviewedAt,_that.lastMessageDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int handleId,  String handleValue,  String serviceType,  int totalMessages,  String? reviewedAt,  DateTime? lastMessageDate)?  $default,) {final _that = this;
switch (_that) {
case _StrayHandleSummary() when $default != null:
return $default(_that.handleId,_that.handleValue,_that.serviceType,_that.totalMessages,_that.reviewedAt,_that.lastMessageDate);case _:
  return null;

}
}

}

/// @nodoc


class _StrayHandleSummary implements StrayHandleSummary {
  const _StrayHandleSummary({required this.handleId, required this.handleValue, required this.serviceType, required this.totalMessages, this.reviewedAt, this.lastMessageDate});
  

@override final  int handleId;
@override final  String handleValue;
@override final  String serviceType;
@override final  int totalMessages;
/// ISO 8601 timestamp of when the user last reviewed this handle, or null
/// if never reviewed.
@override final  String? reviewedAt;
@override final  DateTime? lastMessageDate;

/// Create a copy of StrayHandleSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StrayHandleSummaryCopyWith<_StrayHandleSummary> get copyWith => __$StrayHandleSummaryCopyWithImpl<_StrayHandleSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StrayHandleSummary&&(identical(other.handleId, handleId) || other.handleId == handleId)&&(identical(other.handleValue, handleValue) || other.handleValue == handleValue)&&(identical(other.serviceType, serviceType) || other.serviceType == serviceType)&&(identical(other.totalMessages, totalMessages) || other.totalMessages == totalMessages)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.lastMessageDate, lastMessageDate) || other.lastMessageDate == lastMessageDate));
}


@override
int get hashCode => Object.hash(runtimeType,handleId,handleValue,serviceType,totalMessages,reviewedAt,lastMessageDate);

@override
String toString() {
  return 'StrayHandleSummary(handleId: $handleId, handleValue: $handleValue, serviceType: $serviceType, totalMessages: $totalMessages, reviewedAt: $reviewedAt, lastMessageDate: $lastMessageDate)';
}


}

/// @nodoc
abstract mixin class _$StrayHandleSummaryCopyWith<$Res> implements $StrayHandleSummaryCopyWith<$Res> {
  factory _$StrayHandleSummaryCopyWith(_StrayHandleSummary value, $Res Function(_StrayHandleSummary) _then) = __$StrayHandleSummaryCopyWithImpl;
@override @useResult
$Res call({
 int handleId, String handleValue, String serviceType, int totalMessages, String? reviewedAt, DateTime? lastMessageDate
});




}
/// @nodoc
class __$StrayHandleSummaryCopyWithImpl<$Res>
    implements _$StrayHandleSummaryCopyWith<$Res> {
  __$StrayHandleSummaryCopyWithImpl(this._self, this._then);

  final _StrayHandleSummary _self;
  final $Res Function(_StrayHandleSummary) _then;

/// Create a copy of StrayHandleSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? handleId = null,Object? handleValue = null,Object? serviceType = null,Object? totalMessages = null,Object? reviewedAt = freezed,Object? lastMessageDate = freezed,}) {
  return _then(_StrayHandleSummary(
handleId: null == handleId ? _self.handleId : handleId // ignore: cast_nullable_to_non_nullable
as int,handleValue: null == handleValue ? _self.handleValue : handleValue // ignore: cast_nullable_to_non_nullable
as String,serviceType: null == serviceType ? _self.serviceType : serviceType // ignore: cast_nullable_to_non_nullable
as String,totalMessages: null == totalMessages ? _self.totalMessages : totalMessages // ignore: cast_nullable_to_non_nullable
as int,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,lastMessageDate: freezed == lastMessageDate ? _self.lastMessageDate : lastMessageDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
