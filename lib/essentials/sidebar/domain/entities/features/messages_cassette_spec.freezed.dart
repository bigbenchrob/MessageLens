// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'messages_cassette_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MessagesCassetteSpec {

 int? get contactId; bool get useV2Timeline;
/// Create a copy of MessagesCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessagesCassetteSpecCopyWith<MessagesCassetteSpec> get copyWith => _$MessagesCassetteSpecCopyWithImpl<MessagesCassetteSpec>(this as MessagesCassetteSpec, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessagesCassetteSpec&&(identical(other.contactId, contactId) || other.contactId == contactId)&&(identical(other.useV2Timeline, useV2Timeline) || other.useV2Timeline == useV2Timeline));
}


@override
int get hashCode => Object.hash(runtimeType,contactId,useV2Timeline);

@override
String toString() {
  return 'MessagesCassetteSpec(contactId: $contactId, useV2Timeline: $useV2Timeline)';
}


}

/// @nodoc
abstract mixin class $MessagesCassetteSpecCopyWith<$Res>  {
  factory $MessagesCassetteSpecCopyWith(MessagesCassetteSpec value, $Res Function(MessagesCassetteSpec) _then) = _$MessagesCassetteSpecCopyWithImpl;
@useResult
$Res call({
 int? contactId, bool useV2Timeline
});




}
/// @nodoc
class _$MessagesCassetteSpecCopyWithImpl<$Res>
    implements $MessagesCassetteSpecCopyWith<$Res> {
  _$MessagesCassetteSpecCopyWithImpl(this._self, this._then);

  final MessagesCassetteSpec _self;
  final $Res Function(MessagesCassetteSpec) _then;

/// Create a copy of MessagesCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contactId = freezed,Object? useV2Timeline = null,}) {
  return _then(_self.copyWith(
contactId: freezed == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as int?,useV2Timeline: null == useV2Timeline ? _self.useV2Timeline : useV2Timeline // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MessagesCassetteSpec].
extension MessagesCassetteSpecPatterns on MessagesCassetteSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _MessagesHeatMapSpec value)?  heatMap,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessagesHeatMapSpec() when heatMap != null:
return heatMap(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _MessagesHeatMapSpec value)  heatMap,}){
final _that = this;
switch (_that) {
case _MessagesHeatMapSpec():
return heatMap(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _MessagesHeatMapSpec value)?  heatMap,}){
final _that = this;
switch (_that) {
case _MessagesHeatMapSpec() when heatMap != null:
return heatMap(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int? contactId,  bool useV2Timeline)?  heatMap,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessagesHeatMapSpec() when heatMap != null:
return heatMap(_that.contactId,_that.useV2Timeline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int? contactId,  bool useV2Timeline)  heatMap,}) {final _that = this;
switch (_that) {
case _MessagesHeatMapSpec():
return heatMap(_that.contactId,_that.useV2Timeline);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int? contactId,  bool useV2Timeline)?  heatMap,}) {final _that = this;
switch (_that) {
case _MessagesHeatMapSpec() when heatMap != null:
return heatMap(_that.contactId,_that.useV2Timeline);case _:
  return null;

}
}

}

/// @nodoc


class _MessagesHeatMapSpec implements MessagesCassetteSpec {
  const _MessagesHeatMapSpec({this.contactId, this.useV2Timeline = false});
  

@override final  int? contactId;
@override@JsonKey() final  bool useV2Timeline;

/// Create a copy of MessagesCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessagesHeatMapSpecCopyWith<_MessagesHeatMapSpec> get copyWith => __$MessagesHeatMapSpecCopyWithImpl<_MessagesHeatMapSpec>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessagesHeatMapSpec&&(identical(other.contactId, contactId) || other.contactId == contactId)&&(identical(other.useV2Timeline, useV2Timeline) || other.useV2Timeline == useV2Timeline));
}


@override
int get hashCode => Object.hash(runtimeType,contactId,useV2Timeline);

@override
String toString() {
  return 'MessagesCassetteSpec.heatMap(contactId: $contactId, useV2Timeline: $useV2Timeline)';
}


}

/// @nodoc
abstract mixin class _$MessagesHeatMapSpecCopyWith<$Res> implements $MessagesCassetteSpecCopyWith<$Res> {
  factory _$MessagesHeatMapSpecCopyWith(_MessagesHeatMapSpec value, $Res Function(_MessagesHeatMapSpec) _then) = __$MessagesHeatMapSpecCopyWithImpl;
@override @useResult
$Res call({
 int? contactId, bool useV2Timeline
});




}
/// @nodoc
class __$MessagesHeatMapSpecCopyWithImpl<$Res>
    implements _$MessagesHeatMapSpecCopyWith<$Res> {
  __$MessagesHeatMapSpecCopyWithImpl(this._self, this._then);

  final _MessagesHeatMapSpec _self;
  final $Res Function(_MessagesHeatMapSpec) _then;

/// Create a copy of MessagesCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contactId = freezed,Object? useV2Timeline = null,}) {
  return _then(_MessagesHeatMapSpec(
contactId: freezed == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as int?,useV2Timeline: null == useV2Timeline ? _self.useV2Timeline : useV2Timeline // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
