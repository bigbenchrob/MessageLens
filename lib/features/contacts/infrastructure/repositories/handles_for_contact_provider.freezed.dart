// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'handles_for_contact_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LinkedHandle {

 int get handleId; String get displayValue; String get service;/// Whether this link came from an overlay override (manual link)
/// rather than the working DB (address book auto-link).
 bool get isOverrideLink;
/// Create a copy of LinkedHandle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkedHandleCopyWith<LinkedHandle> get copyWith => _$LinkedHandleCopyWithImpl<LinkedHandle>(this as LinkedHandle, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkedHandle&&(identical(other.handleId, handleId) || other.handleId == handleId)&&(identical(other.displayValue, displayValue) || other.displayValue == displayValue)&&(identical(other.service, service) || other.service == service)&&(identical(other.isOverrideLink, isOverrideLink) || other.isOverrideLink == isOverrideLink));
}


@override
int get hashCode => Object.hash(runtimeType,handleId,displayValue,service,isOverrideLink);

@override
String toString() {
  return 'LinkedHandle(handleId: $handleId, displayValue: $displayValue, service: $service, isOverrideLink: $isOverrideLink)';
}


}

/// @nodoc
abstract mixin class $LinkedHandleCopyWith<$Res>  {
  factory $LinkedHandleCopyWith(LinkedHandle value, $Res Function(LinkedHandle) _then) = _$LinkedHandleCopyWithImpl;
@useResult
$Res call({
 int handleId, String displayValue, String service, bool isOverrideLink
});




}
/// @nodoc
class _$LinkedHandleCopyWithImpl<$Res>
    implements $LinkedHandleCopyWith<$Res> {
  _$LinkedHandleCopyWithImpl(this._self, this._then);

  final LinkedHandle _self;
  final $Res Function(LinkedHandle) _then;

/// Create a copy of LinkedHandle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? handleId = null,Object? displayValue = null,Object? service = null,Object? isOverrideLink = null,}) {
  return _then(_self.copyWith(
handleId: null == handleId ? _self.handleId : handleId // ignore: cast_nullable_to_non_nullable
as int,displayValue: null == displayValue ? _self.displayValue : displayValue // ignore: cast_nullable_to_non_nullable
as String,service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as String,isOverrideLink: null == isOverrideLink ? _self.isOverrideLink : isOverrideLink // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LinkedHandle].
extension LinkedHandlePatterns on LinkedHandle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LinkedHandle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LinkedHandle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LinkedHandle value)  $default,){
final _that = this;
switch (_that) {
case _LinkedHandle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LinkedHandle value)?  $default,){
final _that = this;
switch (_that) {
case _LinkedHandle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int handleId,  String displayValue,  String service,  bool isOverrideLink)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LinkedHandle() when $default != null:
return $default(_that.handleId,_that.displayValue,_that.service,_that.isOverrideLink);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int handleId,  String displayValue,  String service,  bool isOverrideLink)  $default,) {final _that = this;
switch (_that) {
case _LinkedHandle():
return $default(_that.handleId,_that.displayValue,_that.service,_that.isOverrideLink);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int handleId,  String displayValue,  String service,  bool isOverrideLink)?  $default,) {final _that = this;
switch (_that) {
case _LinkedHandle() when $default != null:
return $default(_that.handleId,_that.displayValue,_that.service,_that.isOverrideLink);case _:
  return null;

}
}

}

/// @nodoc


class _LinkedHandle implements LinkedHandle {
  const _LinkedHandle({required this.handleId, required this.displayValue, required this.service, required this.isOverrideLink});
  

@override final  int handleId;
@override final  String displayValue;
@override final  String service;
/// Whether this link came from an overlay override (manual link)
/// rather than the working DB (address book auto-link).
@override final  bool isOverrideLink;

/// Create a copy of LinkedHandle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LinkedHandleCopyWith<_LinkedHandle> get copyWith => __$LinkedHandleCopyWithImpl<_LinkedHandle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LinkedHandle&&(identical(other.handleId, handleId) || other.handleId == handleId)&&(identical(other.displayValue, displayValue) || other.displayValue == displayValue)&&(identical(other.service, service) || other.service == service)&&(identical(other.isOverrideLink, isOverrideLink) || other.isOverrideLink == isOverrideLink));
}


@override
int get hashCode => Object.hash(runtimeType,handleId,displayValue,service,isOverrideLink);

@override
String toString() {
  return 'LinkedHandle(handleId: $handleId, displayValue: $displayValue, service: $service, isOverrideLink: $isOverrideLink)';
}


}

/// @nodoc
abstract mixin class _$LinkedHandleCopyWith<$Res> implements $LinkedHandleCopyWith<$Res> {
  factory _$LinkedHandleCopyWith(_LinkedHandle value, $Res Function(_LinkedHandle) _then) = __$LinkedHandleCopyWithImpl;
@override @useResult
$Res call({
 int handleId, String displayValue, String service, bool isOverrideLink
});




}
/// @nodoc
class __$LinkedHandleCopyWithImpl<$Res>
    implements _$LinkedHandleCopyWith<$Res> {
  __$LinkedHandleCopyWithImpl(this._self, this._then);

  final _LinkedHandle _self;
  final $Res Function(_LinkedHandle) _then;

/// Create a copy of LinkedHandle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? handleId = null,Object? displayValue = null,Object? service = null,Object? isOverrideLink = null,}) {
  return _then(_LinkedHandle(
handleId: null == handleId ? _self.handleId : handleId // ignore: cast_nullable_to_non_nullable
as int,displayValue: null == displayValue ? _self.displayValue : displayValue // ignore: cast_nullable_to_non_nullable
as String,service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as String,isOverrideLink: null == isOverrideLink ? _self.isOverrideLink : isOverrideLink // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
