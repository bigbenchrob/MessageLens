// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_timeline_scope.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MessageTimelineScope {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageTimelineScope);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageTimelineScope()';
}


}

/// @nodoc
class $MessageTimelineScopeCopyWith<$Res>  {
$MessageTimelineScopeCopyWith(MessageTimelineScope _, $Res Function(MessageTimelineScope) __);
}


/// Adds pattern-matching-related methods to [MessageTimelineScope].
extension MessageTimelineScopePatterns on MessageTimelineScope {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GlobalTimelineScope value)?  global,TResult Function( ContactTimelineScope value)?  contact,TResult Function( ChatTimelineScope value)?  chat,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GlobalTimelineScope() when global != null:
return global(_that);case ContactTimelineScope() when contact != null:
return contact(_that);case ChatTimelineScope() when chat != null:
return chat(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GlobalTimelineScope value)  global,required TResult Function( ContactTimelineScope value)  contact,required TResult Function( ChatTimelineScope value)  chat,}){
final _that = this;
switch (_that) {
case GlobalTimelineScope():
return global(_that);case ContactTimelineScope():
return contact(_that);case ChatTimelineScope():
return chat(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GlobalTimelineScope value)?  global,TResult? Function( ContactTimelineScope value)?  contact,TResult? Function( ChatTimelineScope value)?  chat,}){
final _that = this;
switch (_that) {
case GlobalTimelineScope() when global != null:
return global(_that);case ContactTimelineScope() when contact != null:
return contact(_that);case ChatTimelineScope() when chat != null:
return chat(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  global,TResult Function( int contactId,  int? filterHandleId)?  contact,TResult Function( int chatId)?  chat,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GlobalTimelineScope() when global != null:
return global();case ContactTimelineScope() when contact != null:
return contact(_that.contactId,_that.filterHandleId);case ChatTimelineScope() when chat != null:
return chat(_that.chatId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  global,required TResult Function( int contactId,  int? filterHandleId)  contact,required TResult Function( int chatId)  chat,}) {final _that = this;
switch (_that) {
case GlobalTimelineScope():
return global();case ContactTimelineScope():
return contact(_that.contactId,_that.filterHandleId);case ChatTimelineScope():
return chat(_that.chatId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  global,TResult? Function( int contactId,  int? filterHandleId)?  contact,TResult? Function( int chatId)?  chat,}) {final _that = this;
switch (_that) {
case GlobalTimelineScope() when global != null:
return global();case ContactTimelineScope() when contact != null:
return contact(_that.contactId,_that.filterHandleId);case ChatTimelineScope() when chat != null:
return chat(_that.chatId);case _:
  return null;

}
}

}

/// @nodoc


class GlobalTimelineScope extends MessageTimelineScope {
  const GlobalTimelineScope(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GlobalTimelineScope);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageTimelineScope.global()';
}


}




/// @nodoc


class ContactTimelineScope extends MessageTimelineScope {
  const ContactTimelineScope({required this.contactId, this.filterHandleId}): super._();
  

 final  int contactId;
 final  int? filterHandleId;

/// Create a copy of MessageTimelineScope
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactTimelineScopeCopyWith<ContactTimelineScope> get copyWith => _$ContactTimelineScopeCopyWithImpl<ContactTimelineScope>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactTimelineScope&&(identical(other.contactId, contactId) || other.contactId == contactId)&&(identical(other.filterHandleId, filterHandleId) || other.filterHandleId == filterHandleId));
}


@override
int get hashCode => Object.hash(runtimeType,contactId,filterHandleId);

@override
String toString() {
  return 'MessageTimelineScope.contact(contactId: $contactId, filterHandleId: $filterHandleId)';
}


}

/// @nodoc
abstract mixin class $ContactTimelineScopeCopyWith<$Res> implements $MessageTimelineScopeCopyWith<$Res> {
  factory $ContactTimelineScopeCopyWith(ContactTimelineScope value, $Res Function(ContactTimelineScope) _then) = _$ContactTimelineScopeCopyWithImpl;
@useResult
$Res call({
 int contactId, int? filterHandleId
});




}
/// @nodoc
class _$ContactTimelineScopeCopyWithImpl<$Res>
    implements $ContactTimelineScopeCopyWith<$Res> {
  _$ContactTimelineScopeCopyWithImpl(this._self, this._then);

  final ContactTimelineScope _self;
  final $Res Function(ContactTimelineScope) _then;

/// Create a copy of MessageTimelineScope
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? contactId = null,Object? filterHandleId = freezed,}) {
  return _then(ContactTimelineScope(
contactId: null == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as int,filterHandleId: freezed == filterHandleId ? _self.filterHandleId : filterHandleId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class ChatTimelineScope extends MessageTimelineScope {
  const ChatTimelineScope({required this.chatId}): super._();
  

 final  int chatId;

/// Create a copy of MessageTimelineScope
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatTimelineScopeCopyWith<ChatTimelineScope> get copyWith => _$ChatTimelineScopeCopyWithImpl<ChatTimelineScope>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatTimelineScope&&(identical(other.chatId, chatId) || other.chatId == chatId));
}


@override
int get hashCode => Object.hash(runtimeType,chatId);

@override
String toString() {
  return 'MessageTimelineScope.chat(chatId: $chatId)';
}


}

/// @nodoc
abstract mixin class $ChatTimelineScopeCopyWith<$Res> implements $MessageTimelineScopeCopyWith<$Res> {
  factory $ChatTimelineScopeCopyWith(ChatTimelineScope value, $Res Function(ChatTimelineScope) _then) = _$ChatTimelineScopeCopyWithImpl;
@useResult
$Res call({
 int chatId
});




}
/// @nodoc
class _$ChatTimelineScopeCopyWithImpl<$Res>
    implements $ChatTimelineScopeCopyWith<$Res> {
  _$ChatTimelineScopeCopyWithImpl(this._self, this._then);

  final ChatTimelineScope _self;
  final $Res Function(ChatTimelineScope) _then;

/// Create a copy of MessageTimelineScope
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? chatId = null,}) {
  return _then(ChatTimelineScope(
chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
