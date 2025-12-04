// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sidebar_utility_cassette_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SidebarUtilityCassetteSpec {

 int get chosenMenuIndex;
/// Create a copy of SidebarUtilityCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SidebarUtilityCassetteSpecCopyWith<SidebarUtilityCassetteSpec> get copyWith => _$SidebarUtilityCassetteSpecCopyWithImpl<SidebarUtilityCassetteSpec>(this as SidebarUtilityCassetteSpec, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SidebarUtilityCassetteSpec&&(identical(other.chosenMenuIndex, chosenMenuIndex) || other.chosenMenuIndex == chosenMenuIndex));
}


@override
int get hashCode => Object.hash(runtimeType,chosenMenuIndex);

@override
String toString() {
  return 'SidebarUtilityCassetteSpec(chosenMenuIndex: $chosenMenuIndex)';
}


}

/// @nodoc
abstract mixin class $SidebarUtilityCassetteSpecCopyWith<$Res>  {
  factory $SidebarUtilityCassetteSpecCopyWith(SidebarUtilityCassetteSpec value, $Res Function(SidebarUtilityCassetteSpec) _then) = _$SidebarUtilityCassetteSpecCopyWithImpl;
@useResult
$Res call({
 int chosenMenuIndex
});




}
/// @nodoc
class _$SidebarUtilityCassetteSpecCopyWithImpl<$Res>
    implements $SidebarUtilityCassetteSpecCopyWith<$Res> {
  _$SidebarUtilityCassetteSpecCopyWithImpl(this._self, this._then);

  final SidebarUtilityCassetteSpec _self;
  final $Res Function(SidebarUtilityCassetteSpec) _then;

/// Create a copy of SidebarUtilityCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chosenMenuIndex = null,}) {
  return _then(_self.copyWith(
chosenMenuIndex: null == chosenMenuIndex ? _self.chosenMenuIndex : chosenMenuIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SidebarUtilityCassetteSpec].
extension SidebarUtilityCassetteSpecPatterns on SidebarUtilityCassetteSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _SidebarUtilityCassetteSpec value)?  topChatMenu,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SidebarUtilityCassetteSpec() when topChatMenu != null:
return topChatMenu(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _SidebarUtilityCassetteSpec value)  topChatMenu,}){
final _that = this;
switch (_that) {
case _SidebarUtilityCassetteSpec():
return topChatMenu(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _SidebarUtilityCassetteSpec value)?  topChatMenu,}){
final _that = this;
switch (_that) {
case _SidebarUtilityCassetteSpec() when topChatMenu != null:
return topChatMenu(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int chosenMenuIndex)?  topChatMenu,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SidebarUtilityCassetteSpec() when topChatMenu != null:
return topChatMenu(_that.chosenMenuIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int chosenMenuIndex)  topChatMenu,}) {final _that = this;
switch (_that) {
case _SidebarUtilityCassetteSpec():
return topChatMenu(_that.chosenMenuIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int chosenMenuIndex)?  topChatMenu,}) {final _that = this;
switch (_that) {
case _SidebarUtilityCassetteSpec() when topChatMenu != null:
return topChatMenu(_that.chosenMenuIndex);case _:
  return null;

}
}

}

/// @nodoc


class _SidebarUtilityCassetteSpec implements SidebarUtilityCassetteSpec {
  const _SidebarUtilityCassetteSpec({this.chosenMenuIndex = 1});
  

@override@JsonKey() final  int chosenMenuIndex;

/// Create a copy of SidebarUtilityCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SidebarUtilityCassetteSpecCopyWith<_SidebarUtilityCassetteSpec> get copyWith => __$SidebarUtilityCassetteSpecCopyWithImpl<_SidebarUtilityCassetteSpec>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SidebarUtilityCassetteSpec&&(identical(other.chosenMenuIndex, chosenMenuIndex) || other.chosenMenuIndex == chosenMenuIndex));
}


@override
int get hashCode => Object.hash(runtimeType,chosenMenuIndex);

@override
String toString() {
  return 'SidebarUtilityCassetteSpec.topChatMenu(chosenMenuIndex: $chosenMenuIndex)';
}


}

/// @nodoc
abstract mixin class _$SidebarUtilityCassetteSpecCopyWith<$Res> implements $SidebarUtilityCassetteSpecCopyWith<$Res> {
  factory _$SidebarUtilityCassetteSpecCopyWith(_SidebarUtilityCassetteSpec value, $Res Function(_SidebarUtilityCassetteSpec) _then) = __$SidebarUtilityCassetteSpecCopyWithImpl;
@override @useResult
$Res call({
 int chosenMenuIndex
});




}
/// @nodoc
class __$SidebarUtilityCassetteSpecCopyWithImpl<$Res>
    implements _$SidebarUtilityCassetteSpecCopyWith<$Res> {
  __$SidebarUtilityCassetteSpecCopyWithImpl(this._self, this._then);

  final _SidebarUtilityCassetteSpec _self;
  final $Res Function(_SidebarUtilityCassetteSpec) _then;

/// Create a copy of SidebarUtilityCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chosenMenuIndex = null,}) {
  return _then(_SidebarUtilityCassetteSpec(
chosenMenuIndex: null == chosenMenuIndex ? _self.chosenMenuIndex : chosenMenuIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
