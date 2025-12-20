// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'window_state_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WindowStateEntity {

 double get width; double get height; double get x; double get y; bool get isMinimized; double get sidebarWidth;
/// Create a copy of WindowStateEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WindowStateEntityCopyWith<WindowStateEntity> get copyWith => _$WindowStateEntityCopyWithImpl<WindowStateEntity>(this as WindowStateEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WindowStateEntity&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.isMinimized, isMinimized) || other.isMinimized == isMinimized)&&(identical(other.sidebarWidth, sidebarWidth) || other.sidebarWidth == sidebarWidth));
}


@override
int get hashCode => Object.hash(runtimeType,width,height,x,y,isMinimized,sidebarWidth);

@override
String toString() {
  return 'WindowStateEntity(width: $width, height: $height, x: $x, y: $y, isMinimized: $isMinimized, sidebarWidth: $sidebarWidth)';
}


}

/// @nodoc
abstract mixin class $WindowStateEntityCopyWith<$Res>  {
  factory $WindowStateEntityCopyWith(WindowStateEntity value, $Res Function(WindowStateEntity) _then) = _$WindowStateEntityCopyWithImpl;
@useResult
$Res call({
 double width, double height, double x, double y, bool isMinimized, double sidebarWidth
});




}
/// @nodoc
class _$WindowStateEntityCopyWithImpl<$Res>
    implements $WindowStateEntityCopyWith<$Res> {
  _$WindowStateEntityCopyWithImpl(this._self, this._then);

  final WindowStateEntity _self;
  final $Res Function(WindowStateEntity) _then;

/// Create a copy of WindowStateEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? width = null,Object? height = null,Object? x = null,Object? y = null,Object? isMinimized = null,Object? sidebarWidth = null,}) {
  return _then(_self.copyWith(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,isMinimized: null == isMinimized ? _self.isMinimized : isMinimized // ignore: cast_nullable_to_non_nullable
as bool,sidebarWidth: null == sidebarWidth ? _self.sidebarWidth : sidebarWidth // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [WindowStateEntity].
extension WindowStateEntityPatterns on WindowStateEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WindowStateEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WindowStateEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WindowStateEntity value)  $default,){
final _that = this;
switch (_that) {
case _WindowStateEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WindowStateEntity value)?  $default,){
final _that = this;
switch (_that) {
case _WindowStateEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double width,  double height,  double x,  double y,  bool isMinimized,  double sidebarWidth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WindowStateEntity() when $default != null:
return $default(_that.width,_that.height,_that.x,_that.y,_that.isMinimized,_that.sidebarWidth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double width,  double height,  double x,  double y,  bool isMinimized,  double sidebarWidth)  $default,) {final _that = this;
switch (_that) {
case _WindowStateEntity():
return $default(_that.width,_that.height,_that.x,_that.y,_that.isMinimized,_that.sidebarWidth);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double width,  double height,  double x,  double y,  bool isMinimized,  double sidebarWidth)?  $default,) {final _that = this;
switch (_that) {
case _WindowStateEntity() when $default != null:
return $default(_that.width,_that.height,_that.x,_that.y,_that.isMinimized,_that.sidebarWidth);case _:
  return null;

}
}

}

/// @nodoc


class _WindowStateEntity implements WindowStateEntity {
  const _WindowStateEntity({required this.width, required this.height, required this.x, required this.y, required this.isMinimized, required this.sidebarWidth});
  

@override final  double width;
@override final  double height;
@override final  double x;
@override final  double y;
@override final  bool isMinimized;
@override final  double sidebarWidth;

/// Create a copy of WindowStateEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WindowStateEntityCopyWith<_WindowStateEntity> get copyWith => __$WindowStateEntityCopyWithImpl<_WindowStateEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WindowStateEntity&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.isMinimized, isMinimized) || other.isMinimized == isMinimized)&&(identical(other.sidebarWidth, sidebarWidth) || other.sidebarWidth == sidebarWidth));
}


@override
int get hashCode => Object.hash(runtimeType,width,height,x,y,isMinimized,sidebarWidth);

@override
String toString() {
  return 'WindowStateEntity(width: $width, height: $height, x: $x, y: $y, isMinimized: $isMinimized, sidebarWidth: $sidebarWidth)';
}


}

/// @nodoc
abstract mixin class _$WindowStateEntityCopyWith<$Res> implements $WindowStateEntityCopyWith<$Res> {
  factory _$WindowStateEntityCopyWith(_WindowStateEntity value, $Res Function(_WindowStateEntity) _then) = __$WindowStateEntityCopyWithImpl;
@override @useResult
$Res call({
 double width, double height, double x, double y, bool isMinimized, double sidebarWidth
});




}
/// @nodoc
class __$WindowStateEntityCopyWithImpl<$Res>
    implements _$WindowStateEntityCopyWith<$Res> {
  __$WindowStateEntityCopyWithImpl(this._self, this._then);

  final _WindowStateEntity _self;
  final $Res Function(_WindowStateEntity) _then;

/// Create a copy of WindowStateEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? width = null,Object? height = null,Object? x = null,Object? y = null,Object? isMinimized = null,Object? sidebarWidth = null,}) {
  return _then(_WindowStateEntity(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,isMinimized: null == isMinimized ? _self.isMinimized : isMinimized // ignore: cast_nullable_to_non_nullable
as bool,sidebarWidth: null == sidebarWidth ? _self.sidebarWidth : sidebarWidth // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
