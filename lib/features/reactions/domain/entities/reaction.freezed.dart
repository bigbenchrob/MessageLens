// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Reaction {

@ReactionIdConverter() ReactionId get id;@MessageIdConverter() MessageId get messageId;@ContactIdConverter() ContactId get authorId; ReactionKind get kind; String? get customText; DateTime get createdAt; DateTime? get removedAt; dynamic get z;
/// Create a copy of Reaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReactionCopyWith<Reaction> get copyWith => _$ReactionCopyWithImpl<Reaction>(this as Reaction, _$identity);

  /// Serializes this Reaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Reaction&&(identical(other.id, id) || other.id == id)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.customText, customText) || other.customText == customText)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.removedAt, removedAt) || other.removedAt == removedAt)&&const DeepCollectionEquality().equals(other.z, z));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,messageId,authorId,kind,customText,createdAt,removedAt,const DeepCollectionEquality().hash(z));

@override
String toString() {
  return 'Reaction(id: $id, messageId: $messageId, authorId: $authorId, kind: $kind, customText: $customText, createdAt: $createdAt, removedAt: $removedAt, z: $z)';
}


}

/// @nodoc
abstract mixin class $ReactionCopyWith<$Res>  {
  factory $ReactionCopyWith(Reaction value, $Res Function(Reaction) _then) = _$ReactionCopyWithImpl;
@useResult
$Res call({
@ReactionIdConverter() ReactionId id,@MessageIdConverter() MessageId messageId,@ContactIdConverter() ContactId authorId, ReactionKind kind, String? customText, DateTime createdAt, DateTime? removedAt, dynamic z
});


$ReactionIdCopyWith<$Res> get id;$MessageIdCopyWith<$Res> get messageId;$ContactIdCopyWith<$Res> get authorId;

}
/// @nodoc
class _$ReactionCopyWithImpl<$Res>
    implements $ReactionCopyWith<$Res> {
  _$ReactionCopyWithImpl(this._self, this._then);

  final Reaction _self;
  final $Res Function(Reaction) _then;

/// Create a copy of Reaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? messageId = null,Object? authorId = null,Object? kind = null,Object? customText = freezed,Object? createdAt = null,Object? removedAt = freezed,Object? z = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ReactionId,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as MessageId,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as ContactId,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ReactionKind,customText: freezed == customText ? _self.customText : customText // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,removedAt: freezed == removedAt ? _self.removedAt : removedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,z: freezed == z ? _self.z : z // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}
/// Create a copy of Reaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReactionIdCopyWith<$Res> get id {
  
  return $ReactionIdCopyWith<$Res>(_self.id, (value) {
    return _then(_self.copyWith(id: value));
  });
}/// Create a copy of Reaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageIdCopyWith<$Res> get messageId {
  
  return $MessageIdCopyWith<$Res>(_self.messageId, (value) {
    return _then(_self.copyWith(messageId: value));
  });
}/// Create a copy of Reaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactIdCopyWith<$Res> get authorId {
  
  return $ContactIdCopyWith<$Res>(_self.authorId, (value) {
    return _then(_self.copyWith(authorId: value));
  });
}
}


/// Adds pattern-matching-related methods to [Reaction].
extension ReactionPatterns on Reaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Reaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Reaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Reaction value)  $default,){
final _that = this;
switch (_that) {
case _Reaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Reaction value)?  $default,){
final _that = this;
switch (_that) {
case _Reaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@ReactionIdConverter()  ReactionId id, @MessageIdConverter()  MessageId messageId, @ContactIdConverter()  ContactId authorId,  ReactionKind kind,  String? customText,  DateTime createdAt,  DateTime? removedAt,  dynamic z)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Reaction() when $default != null:
return $default(_that.id,_that.messageId,_that.authorId,_that.kind,_that.customText,_that.createdAt,_that.removedAt,_that.z);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@ReactionIdConverter()  ReactionId id, @MessageIdConverter()  MessageId messageId, @ContactIdConverter()  ContactId authorId,  ReactionKind kind,  String? customText,  DateTime createdAt,  DateTime? removedAt,  dynamic z)  $default,) {final _that = this;
switch (_that) {
case _Reaction():
return $default(_that.id,_that.messageId,_that.authorId,_that.kind,_that.customText,_that.createdAt,_that.removedAt,_that.z);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@ReactionIdConverter()  ReactionId id, @MessageIdConverter()  MessageId messageId, @ContactIdConverter()  ContactId authorId,  ReactionKind kind,  String? customText,  DateTime createdAt,  DateTime? removedAt,  dynamic z)?  $default,) {final _that = this;
switch (_that) {
case _Reaction() when $default != null:
return $default(_that.id,_that.messageId,_that.authorId,_that.kind,_that.customText,_that.createdAt,_that.removedAt,_that.z);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Reaction extends Reaction {
  const _Reaction({@ReactionIdConverter() required this.id, @MessageIdConverter() required this.messageId, @ContactIdConverter() required this.authorId, required this.kind, this.customText, required this.createdAt, this.removedAt, this.z}): super._();
  factory _Reaction.fromJson(Map<String, dynamic> json) => _$ReactionFromJson(json);

@override@ReactionIdConverter() final  ReactionId id;
@override@MessageIdConverter() final  MessageId messageId;
@override@ContactIdConverter() final  ContactId authorId;
@override final  ReactionKind kind;
@override final  String? customText;
@override final  DateTime createdAt;
@override final  DateTime? removedAt;
@override final  dynamic z;

/// Create a copy of Reaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReactionCopyWith<_Reaction> get copyWith => __$ReactionCopyWithImpl<_Reaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reaction&&(identical(other.id, id) || other.id == id)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.customText, customText) || other.customText == customText)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.removedAt, removedAt) || other.removedAt == removedAt)&&const DeepCollectionEquality().equals(other.z, z));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,messageId,authorId,kind,customText,createdAt,removedAt,const DeepCollectionEquality().hash(z));

@override
String toString() {
  return 'Reaction(id: $id, messageId: $messageId, authorId: $authorId, kind: $kind, customText: $customText, createdAt: $createdAt, removedAt: $removedAt, z: $z)';
}


}

/// @nodoc
abstract mixin class _$ReactionCopyWith<$Res> implements $ReactionCopyWith<$Res> {
  factory _$ReactionCopyWith(_Reaction value, $Res Function(_Reaction) _then) = __$ReactionCopyWithImpl;
@override @useResult
$Res call({
@ReactionIdConverter() ReactionId id,@MessageIdConverter() MessageId messageId,@ContactIdConverter() ContactId authorId, ReactionKind kind, String? customText, DateTime createdAt, DateTime? removedAt, dynamic z
});


@override $ReactionIdCopyWith<$Res> get id;@override $MessageIdCopyWith<$Res> get messageId;@override $ContactIdCopyWith<$Res> get authorId;

}
/// @nodoc
class __$ReactionCopyWithImpl<$Res>
    implements _$ReactionCopyWith<$Res> {
  __$ReactionCopyWithImpl(this._self, this._then);

  final _Reaction _self;
  final $Res Function(_Reaction) _then;

/// Create a copy of Reaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? messageId = null,Object? authorId = null,Object? kind = null,Object? customText = freezed,Object? createdAt = null,Object? removedAt = freezed,Object? z = freezed,}) {
  return _then(_Reaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ReactionId,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as MessageId,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as ContactId,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ReactionKind,customText: freezed == customText ? _self.customText : customText // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,removedAt: freezed == removedAt ? _self.removedAt : removedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,z: freezed == z ? _self.z : z // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

/// Create a copy of Reaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReactionIdCopyWith<$Res> get id {
  
  return $ReactionIdCopyWith<$Res>(_self.id, (value) {
    return _then(_self.copyWith(id: value));
  });
}/// Create a copy of Reaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageIdCopyWith<$Res> get messageId {
  
  return $MessageIdCopyWith<$Res>(_self.messageId, (value) {
    return _then(_self.copyWith(messageId: value));
  });
}/// Create a copy of Reaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactIdCopyWith<$Res> get authorId {
  
  return $ContactIdCopyWith<$Res>(_self.authorId, (value) {
    return _then(_self.copyWith(authorId: value));
  });
}
}

// dart format on
