// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'messages_view_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MessagesSpec {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessagesSpec);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessagesSpec()';
}


}

/// @nodoc
class $MessagesSpecCopyWith<$Res>  {
$MessagesSpecCopyWith(MessagesSpec _, $Res Function(MessagesSpec) __);
}


/// Adds pattern-matching-related methods to [MessagesSpec].
extension MessagesSpecPatterns on MessagesSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _MessagesForChat value)?  forChat,TResult Function( _MessagesForContact value)?  forContact,TResult Function( _MessagesGlobalTimeline value)?  globalTimeline,TResult Function( _MessagesForHandle value)?  forHandle,TResult Function( _MessagesHandleLens value)?  handleLens,TResult Function( _MessagesForChatInDateRange value)?  forChatInDateRange,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessagesForChat() when forChat != null:
return forChat(_that);case _MessagesForContact() when forContact != null:
return forContact(_that);case _MessagesGlobalTimeline() when globalTimeline != null:
return globalTimeline(_that);case _MessagesForHandle() when forHandle != null:
return forHandle(_that);case _MessagesHandleLens() when handleLens != null:
return handleLens(_that);case _MessagesForChatInDateRange() when forChatInDateRange != null:
return forChatInDateRange(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _MessagesForChat value)  forChat,required TResult Function( _MessagesForContact value)  forContact,required TResult Function( _MessagesGlobalTimeline value)  globalTimeline,required TResult Function( _MessagesForHandle value)  forHandle,required TResult Function( _MessagesHandleLens value)  handleLens,required TResult Function( _MessagesForChatInDateRange value)  forChatInDateRange,}){
final _that = this;
switch (_that) {
case _MessagesForChat():
return forChat(_that);case _MessagesForContact():
return forContact(_that);case _MessagesGlobalTimeline():
return globalTimeline(_that);case _MessagesForHandle():
return forHandle(_that);case _MessagesHandleLens():
return handleLens(_that);case _MessagesForChatInDateRange():
return forChatInDateRange(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _MessagesForChat value)?  forChat,TResult? Function( _MessagesForContact value)?  forContact,TResult? Function( _MessagesGlobalTimeline value)?  globalTimeline,TResult? Function( _MessagesForHandle value)?  forHandle,TResult? Function( _MessagesHandleLens value)?  handleLens,TResult? Function( _MessagesForChatInDateRange value)?  forChatInDateRange,}){
final _that = this;
switch (_that) {
case _MessagesForChat() when forChat != null:
return forChat(_that);case _MessagesForContact() when forContact != null:
return forContact(_that);case _MessagesGlobalTimeline() when globalTimeline != null:
return globalTimeline(_that);case _MessagesForHandle() when forHandle != null:
return forHandle(_that);case _MessagesHandleLens() when handleLens != null:
return handleLens(_that);case _MessagesForChatInDateRange() when forChatInDateRange != null:
return forChatInDateRange(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int chatId)?  forChat,TResult Function( int contactId,  DateTime? scrollToDate)?  forContact,TResult Function( DateTime? scrollToDate)?  globalTimeline,TResult Function( int handleId)?  forHandle,TResult Function( int handleId)?  handleLens,TResult Function( int chatId,  DateTime startDate,  DateTime endDate)?  forChatInDateRange,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessagesForChat() when forChat != null:
return forChat(_that.chatId);case _MessagesForContact() when forContact != null:
return forContact(_that.contactId,_that.scrollToDate);case _MessagesGlobalTimeline() when globalTimeline != null:
return globalTimeline(_that.scrollToDate);case _MessagesForHandle() when forHandle != null:
return forHandle(_that.handleId);case _MessagesHandleLens() when handleLens != null:
return handleLens(_that.handleId);case _MessagesForChatInDateRange() when forChatInDateRange != null:
return forChatInDateRange(_that.chatId,_that.startDate,_that.endDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int chatId)  forChat,required TResult Function( int contactId,  DateTime? scrollToDate)  forContact,required TResult Function( DateTime? scrollToDate)  globalTimeline,required TResult Function( int handleId)  forHandle,required TResult Function( int handleId)  handleLens,required TResult Function( int chatId,  DateTime startDate,  DateTime endDate)  forChatInDateRange,}) {final _that = this;
switch (_that) {
case _MessagesForChat():
return forChat(_that.chatId);case _MessagesForContact():
return forContact(_that.contactId,_that.scrollToDate);case _MessagesGlobalTimeline():
return globalTimeline(_that.scrollToDate);case _MessagesForHandle():
return forHandle(_that.handleId);case _MessagesHandleLens():
return handleLens(_that.handleId);case _MessagesForChatInDateRange():
return forChatInDateRange(_that.chatId,_that.startDate,_that.endDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int chatId)?  forChat,TResult? Function( int contactId,  DateTime? scrollToDate)?  forContact,TResult? Function( DateTime? scrollToDate)?  globalTimeline,TResult? Function( int handleId)?  forHandle,TResult? Function( int handleId)?  handleLens,TResult? Function( int chatId,  DateTime startDate,  DateTime endDate)?  forChatInDateRange,}) {final _that = this;
switch (_that) {
case _MessagesForChat() when forChat != null:
return forChat(_that.chatId);case _MessagesForContact() when forContact != null:
return forContact(_that.contactId,_that.scrollToDate);case _MessagesGlobalTimeline() when globalTimeline != null:
return globalTimeline(_that.scrollToDate);case _MessagesForHandle() when forHandle != null:
return forHandle(_that.handleId);case _MessagesHandleLens() when handleLens != null:
return handleLens(_that.handleId);case _MessagesForChatInDateRange() when forChatInDateRange != null:
return forChatInDateRange(_that.chatId,_that.startDate,_that.endDate);case _:
  return null;

}
}

}

/// @nodoc


class _MessagesForChat implements MessagesSpec {
  const _MessagesForChat({required this.chatId});
  

 final  int chatId;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessagesForChatCopyWith<_MessagesForChat> get copyWith => __$MessagesForChatCopyWithImpl<_MessagesForChat>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessagesForChat&&(identical(other.chatId, chatId) || other.chatId == chatId));
}


@override
int get hashCode => Object.hash(runtimeType,chatId);

@override
String toString() {
  return 'MessagesSpec.forChat(chatId: $chatId)';
}


}

/// @nodoc
abstract mixin class _$MessagesForChatCopyWith<$Res> implements $MessagesSpecCopyWith<$Res> {
  factory _$MessagesForChatCopyWith(_MessagesForChat value, $Res Function(_MessagesForChat) _then) = __$MessagesForChatCopyWithImpl;
@useResult
$Res call({
 int chatId
});




}
/// @nodoc
class __$MessagesForChatCopyWithImpl<$Res>
    implements _$MessagesForChatCopyWith<$Res> {
  __$MessagesForChatCopyWithImpl(this._self, this._then);

  final _MessagesForChat _self;
  final $Res Function(_MessagesForChat) _then;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? chatId = null,}) {
  return _then(_MessagesForChat(
chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _MessagesForContact implements MessagesSpec {
  const _MessagesForContact({required this.contactId, this.scrollToDate});
  

 final  int contactId;
 final  DateTime? scrollToDate;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessagesForContactCopyWith<_MessagesForContact> get copyWith => __$MessagesForContactCopyWithImpl<_MessagesForContact>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessagesForContact&&(identical(other.contactId, contactId) || other.contactId == contactId)&&(identical(other.scrollToDate, scrollToDate) || other.scrollToDate == scrollToDate));
}


@override
int get hashCode => Object.hash(runtimeType,contactId,scrollToDate);

@override
String toString() {
  return 'MessagesSpec.forContact(contactId: $contactId, scrollToDate: $scrollToDate)';
}


}

/// @nodoc
abstract mixin class _$MessagesForContactCopyWith<$Res> implements $MessagesSpecCopyWith<$Res> {
  factory _$MessagesForContactCopyWith(_MessagesForContact value, $Res Function(_MessagesForContact) _then) = __$MessagesForContactCopyWithImpl;
@useResult
$Res call({
 int contactId, DateTime? scrollToDate
});




}
/// @nodoc
class __$MessagesForContactCopyWithImpl<$Res>
    implements _$MessagesForContactCopyWith<$Res> {
  __$MessagesForContactCopyWithImpl(this._self, this._then);

  final _MessagesForContact _self;
  final $Res Function(_MessagesForContact) _then;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? contactId = null,Object? scrollToDate = freezed,}) {
  return _then(_MessagesForContact(
contactId: null == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as int,scrollToDate: freezed == scrollToDate ? _self.scrollToDate : scrollToDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc


class _MessagesGlobalTimeline implements MessagesSpec {
  const _MessagesGlobalTimeline({this.scrollToDate});
  

 final  DateTime? scrollToDate;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessagesGlobalTimelineCopyWith<_MessagesGlobalTimeline> get copyWith => __$MessagesGlobalTimelineCopyWithImpl<_MessagesGlobalTimeline>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessagesGlobalTimeline&&(identical(other.scrollToDate, scrollToDate) || other.scrollToDate == scrollToDate));
}


@override
int get hashCode => Object.hash(runtimeType,scrollToDate);

@override
String toString() {
  return 'MessagesSpec.globalTimeline(scrollToDate: $scrollToDate)';
}


}

/// @nodoc
abstract mixin class _$MessagesGlobalTimelineCopyWith<$Res> implements $MessagesSpecCopyWith<$Res> {
  factory _$MessagesGlobalTimelineCopyWith(_MessagesGlobalTimeline value, $Res Function(_MessagesGlobalTimeline) _then) = __$MessagesGlobalTimelineCopyWithImpl;
@useResult
$Res call({
 DateTime? scrollToDate
});




}
/// @nodoc
class __$MessagesGlobalTimelineCopyWithImpl<$Res>
    implements _$MessagesGlobalTimelineCopyWith<$Res> {
  __$MessagesGlobalTimelineCopyWithImpl(this._self, this._then);

  final _MessagesGlobalTimeline _self;
  final $Res Function(_MessagesGlobalTimeline) _then;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? scrollToDate = freezed,}) {
  return _then(_MessagesGlobalTimeline(
scrollToDate: freezed == scrollToDate ? _self.scrollToDate : scrollToDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc


class _MessagesForHandle implements MessagesSpec {
  const _MessagesForHandle({required this.handleId});
  

 final  int handleId;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessagesForHandleCopyWith<_MessagesForHandle> get copyWith => __$MessagesForHandleCopyWithImpl<_MessagesForHandle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessagesForHandle&&(identical(other.handleId, handleId) || other.handleId == handleId));
}


@override
int get hashCode => Object.hash(runtimeType,handleId);

@override
String toString() {
  return 'MessagesSpec.forHandle(handleId: $handleId)';
}


}

/// @nodoc
abstract mixin class _$MessagesForHandleCopyWith<$Res> implements $MessagesSpecCopyWith<$Res> {
  factory _$MessagesForHandleCopyWith(_MessagesForHandle value, $Res Function(_MessagesForHandle) _then) = __$MessagesForHandleCopyWithImpl;
@useResult
$Res call({
 int handleId
});




}
/// @nodoc
class __$MessagesForHandleCopyWithImpl<$Res>
    implements _$MessagesForHandleCopyWith<$Res> {
  __$MessagesForHandleCopyWithImpl(this._self, this._then);

  final _MessagesForHandle _self;
  final $Res Function(_MessagesForHandle) _then;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? handleId = null,}) {
  return _then(_MessagesForHandle(
handleId: null == handleId ? _self.handleId : handleId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _MessagesHandleLens implements MessagesSpec {
  const _MessagesHandleLens({required this.handleId});
  

 final  int handleId;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessagesHandleLensCopyWith<_MessagesHandleLens> get copyWith => __$MessagesHandleLensCopyWithImpl<_MessagesHandleLens>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessagesHandleLens&&(identical(other.handleId, handleId) || other.handleId == handleId));
}


@override
int get hashCode => Object.hash(runtimeType,handleId);

@override
String toString() {
  return 'MessagesSpec.handleLens(handleId: $handleId)';
}


}

/// @nodoc
abstract mixin class _$MessagesHandleLensCopyWith<$Res> implements $MessagesSpecCopyWith<$Res> {
  factory _$MessagesHandleLensCopyWith(_MessagesHandleLens value, $Res Function(_MessagesHandleLens) _then) = __$MessagesHandleLensCopyWithImpl;
@useResult
$Res call({
 int handleId
});




}
/// @nodoc
class __$MessagesHandleLensCopyWithImpl<$Res>
    implements _$MessagesHandleLensCopyWith<$Res> {
  __$MessagesHandleLensCopyWithImpl(this._self, this._then);

  final _MessagesHandleLens _self;
  final $Res Function(_MessagesHandleLens) _then;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? handleId = null,}) {
  return _then(_MessagesHandleLens(
handleId: null == handleId ? _self.handleId : handleId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _MessagesForChatInDateRange implements MessagesSpec {
  const _MessagesForChatInDateRange({required this.chatId, required this.startDate, required this.endDate});
  

 final  int chatId;
 final  DateTime startDate;
 final  DateTime endDate;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessagesForChatInDateRangeCopyWith<_MessagesForChatInDateRange> get copyWith => __$MessagesForChatInDateRangeCopyWithImpl<_MessagesForChatInDateRange>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessagesForChatInDateRange&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode => Object.hash(runtimeType,chatId,startDate,endDate);

@override
String toString() {
  return 'MessagesSpec.forChatInDateRange(chatId: $chatId, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class _$MessagesForChatInDateRangeCopyWith<$Res> implements $MessagesSpecCopyWith<$Res> {
  factory _$MessagesForChatInDateRangeCopyWith(_MessagesForChatInDateRange value, $Res Function(_MessagesForChatInDateRange) _then) = __$MessagesForChatInDateRangeCopyWithImpl;
@useResult
$Res call({
 int chatId, DateTime startDate, DateTime endDate
});




}
/// @nodoc
class __$MessagesForChatInDateRangeCopyWithImpl<$Res>
    implements _$MessagesForChatInDateRangeCopyWith<$Res> {
  __$MessagesForChatInDateRangeCopyWithImpl(this._self, this._then);

  final _MessagesForChatInDateRange _self;
  final $Res Function(_MessagesForChatInDateRange) _then;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? chatId = null,Object? startDate = null,Object? endDate = null,}) {
  return _then(_MessagesForChatInDateRange(
chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as int,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
