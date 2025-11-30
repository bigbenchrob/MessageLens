// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'messages_for_handle_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MessageWithChatContext {

 int get messageId; String get messageGuid; int get chatId; String get chatGuid; String? get chatDisplayName; String get text; bool get isFromMe; DateTime get sentAt; String? get senderHandleRaw; String? get senderHandleDisplay;
/// Create a copy of MessageWithChatContext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageWithChatContextCopyWith<MessageWithChatContext> get copyWith => _$MessageWithChatContextCopyWithImpl<MessageWithChatContext>(this as MessageWithChatContext, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageWithChatContext&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.messageGuid, messageGuid) || other.messageGuid == messageGuid)&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.chatGuid, chatGuid) || other.chatGuid == chatGuid)&&(identical(other.chatDisplayName, chatDisplayName) || other.chatDisplayName == chatDisplayName)&&(identical(other.text, text) || other.text == text)&&(identical(other.isFromMe, isFromMe) || other.isFromMe == isFromMe)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.senderHandleRaw, senderHandleRaw) || other.senderHandleRaw == senderHandleRaw)&&(identical(other.senderHandleDisplay, senderHandleDisplay) || other.senderHandleDisplay == senderHandleDisplay));
}


@override
int get hashCode => Object.hash(runtimeType,messageId,messageGuid,chatId,chatGuid,chatDisplayName,text,isFromMe,sentAt,senderHandleRaw,senderHandleDisplay);

@override
String toString() {
  return 'MessageWithChatContext(messageId: $messageId, messageGuid: $messageGuid, chatId: $chatId, chatGuid: $chatGuid, chatDisplayName: $chatDisplayName, text: $text, isFromMe: $isFromMe, sentAt: $sentAt, senderHandleRaw: $senderHandleRaw, senderHandleDisplay: $senderHandleDisplay)';
}


}

/// @nodoc
abstract mixin class $MessageWithChatContextCopyWith<$Res>  {
  factory $MessageWithChatContextCopyWith(MessageWithChatContext value, $Res Function(MessageWithChatContext) _then) = _$MessageWithChatContextCopyWithImpl;
@useResult
$Res call({
 int messageId, String messageGuid, int chatId, String chatGuid, String? chatDisplayName, String text, bool isFromMe, DateTime sentAt, String? senderHandleRaw, String? senderHandleDisplay
});




}
/// @nodoc
class _$MessageWithChatContextCopyWithImpl<$Res>
    implements $MessageWithChatContextCopyWith<$Res> {
  _$MessageWithChatContextCopyWithImpl(this._self, this._then);

  final MessageWithChatContext _self;
  final $Res Function(MessageWithChatContext) _then;

/// Create a copy of MessageWithChatContext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messageId = null,Object? messageGuid = null,Object? chatId = null,Object? chatGuid = null,Object? chatDisplayName = freezed,Object? text = null,Object? isFromMe = null,Object? sentAt = null,Object? senderHandleRaw = freezed,Object? senderHandleDisplay = freezed,}) {
  return _then(_self.copyWith(
messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as int,messageGuid: null == messageGuid ? _self.messageGuid : messageGuid // ignore: cast_nullable_to_non_nullable
as String,chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as int,chatGuid: null == chatGuid ? _self.chatGuid : chatGuid // ignore: cast_nullable_to_non_nullable
as String,chatDisplayName: freezed == chatDisplayName ? _self.chatDisplayName : chatDisplayName // ignore: cast_nullable_to_non_nullable
as String?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,isFromMe: null == isFromMe ? _self.isFromMe : isFromMe // ignore: cast_nullable_to_non_nullable
as bool,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,senderHandleRaw: freezed == senderHandleRaw ? _self.senderHandleRaw : senderHandleRaw // ignore: cast_nullable_to_non_nullable
as String?,senderHandleDisplay: freezed == senderHandleDisplay ? _self.senderHandleDisplay : senderHandleDisplay // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageWithChatContext].
extension MessageWithChatContextPatterns on MessageWithChatContext {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageWithChatContext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageWithChatContext() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageWithChatContext value)  $default,){
final _that = this;
switch (_that) {
case _MessageWithChatContext():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageWithChatContext value)?  $default,){
final _that = this;
switch (_that) {
case _MessageWithChatContext() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int messageId,  String messageGuid,  int chatId,  String chatGuid,  String? chatDisplayName,  String text,  bool isFromMe,  DateTime sentAt,  String? senderHandleRaw,  String? senderHandleDisplay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageWithChatContext() when $default != null:
return $default(_that.messageId,_that.messageGuid,_that.chatId,_that.chatGuid,_that.chatDisplayName,_that.text,_that.isFromMe,_that.sentAt,_that.senderHandleRaw,_that.senderHandleDisplay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int messageId,  String messageGuid,  int chatId,  String chatGuid,  String? chatDisplayName,  String text,  bool isFromMe,  DateTime sentAt,  String? senderHandleRaw,  String? senderHandleDisplay)  $default,) {final _that = this;
switch (_that) {
case _MessageWithChatContext():
return $default(_that.messageId,_that.messageGuid,_that.chatId,_that.chatGuid,_that.chatDisplayName,_that.text,_that.isFromMe,_that.sentAt,_that.senderHandleRaw,_that.senderHandleDisplay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int messageId,  String messageGuid,  int chatId,  String chatGuid,  String? chatDisplayName,  String text,  bool isFromMe,  DateTime sentAt,  String? senderHandleRaw,  String? senderHandleDisplay)?  $default,) {final _that = this;
switch (_that) {
case _MessageWithChatContext() when $default != null:
return $default(_that.messageId,_that.messageGuid,_that.chatId,_that.chatGuid,_that.chatDisplayName,_that.text,_that.isFromMe,_that.sentAt,_that.senderHandleRaw,_that.senderHandleDisplay);case _:
  return null;

}
}

}

/// @nodoc


class _MessageWithChatContext implements MessageWithChatContext {
  const _MessageWithChatContext({required this.messageId, required this.messageGuid, required this.chatId, required this.chatGuid, required this.chatDisplayName, required this.text, required this.isFromMe, required this.sentAt, required this.senderHandleRaw, required this.senderHandleDisplay});
  

@override final  int messageId;
@override final  String messageGuid;
@override final  int chatId;
@override final  String chatGuid;
@override final  String? chatDisplayName;
@override final  String text;
@override final  bool isFromMe;
@override final  DateTime sentAt;
@override final  String? senderHandleRaw;
@override final  String? senderHandleDisplay;

/// Create a copy of MessageWithChatContext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageWithChatContextCopyWith<_MessageWithChatContext> get copyWith => __$MessageWithChatContextCopyWithImpl<_MessageWithChatContext>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageWithChatContext&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.messageGuid, messageGuid) || other.messageGuid == messageGuid)&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.chatGuid, chatGuid) || other.chatGuid == chatGuid)&&(identical(other.chatDisplayName, chatDisplayName) || other.chatDisplayName == chatDisplayName)&&(identical(other.text, text) || other.text == text)&&(identical(other.isFromMe, isFromMe) || other.isFromMe == isFromMe)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.senderHandleRaw, senderHandleRaw) || other.senderHandleRaw == senderHandleRaw)&&(identical(other.senderHandleDisplay, senderHandleDisplay) || other.senderHandleDisplay == senderHandleDisplay));
}


@override
int get hashCode => Object.hash(runtimeType,messageId,messageGuid,chatId,chatGuid,chatDisplayName,text,isFromMe,sentAt,senderHandleRaw,senderHandleDisplay);

@override
String toString() {
  return 'MessageWithChatContext(messageId: $messageId, messageGuid: $messageGuid, chatId: $chatId, chatGuid: $chatGuid, chatDisplayName: $chatDisplayName, text: $text, isFromMe: $isFromMe, sentAt: $sentAt, senderHandleRaw: $senderHandleRaw, senderHandleDisplay: $senderHandleDisplay)';
}


}

/// @nodoc
abstract mixin class _$MessageWithChatContextCopyWith<$Res> implements $MessageWithChatContextCopyWith<$Res> {
  factory _$MessageWithChatContextCopyWith(_MessageWithChatContext value, $Res Function(_MessageWithChatContext) _then) = __$MessageWithChatContextCopyWithImpl;
@override @useResult
$Res call({
 int messageId, String messageGuid, int chatId, String chatGuid, String? chatDisplayName, String text, bool isFromMe, DateTime sentAt, String? senderHandleRaw, String? senderHandleDisplay
});




}
/// @nodoc
class __$MessageWithChatContextCopyWithImpl<$Res>
    implements _$MessageWithChatContextCopyWith<$Res> {
  __$MessageWithChatContextCopyWithImpl(this._self, this._then);

  final _MessageWithChatContext _self;
  final $Res Function(_MessageWithChatContext) _then;

/// Create a copy of MessageWithChatContext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messageId = null,Object? messageGuid = null,Object? chatId = null,Object? chatGuid = null,Object? chatDisplayName = freezed,Object? text = null,Object? isFromMe = null,Object? sentAt = null,Object? senderHandleRaw = freezed,Object? senderHandleDisplay = freezed,}) {
  return _then(_MessageWithChatContext(
messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as int,messageGuid: null == messageGuid ? _self.messageGuid : messageGuid // ignore: cast_nullable_to_non_nullable
as String,chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as int,chatGuid: null == chatGuid ? _self.chatGuid : chatGuid // ignore: cast_nullable_to_non_nullable
as String,chatDisplayName: freezed == chatDisplayName ? _self.chatDisplayName : chatDisplayName // ignore: cast_nullable_to_non_nullable
as String?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,isFromMe: null == isFromMe ? _self.isFromMe : isFromMe // ignore: cast_nullable_to_non_nullable
as bool,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,senderHandleRaw: freezed == senderHandleRaw ? _self.senderHandleRaw : senderHandleRaw // ignore: cast_nullable_to_non_nullable
as String?,senderHandleDisplay: freezed == senderHandleDisplay ? _self.senderHandleDisplay : senderHandleDisplay // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
