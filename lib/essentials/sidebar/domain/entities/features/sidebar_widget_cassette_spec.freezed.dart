// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sidebar_widget_cassette_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SidebarWidgetCassetteSpec {

 int get chosenMenuIndex;
/// Create a copy of SidebarWidgetCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SidebarWidgetCassetteSpecCopyWith<SidebarWidgetCassetteSpec> get copyWith => _$SidebarWidgetCassetteSpecCopyWithImpl<SidebarWidgetCassetteSpec>(this as SidebarWidgetCassetteSpec, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SidebarWidgetCassetteSpec&&(identical(other.chosenMenuIndex, chosenMenuIndex) || other.chosenMenuIndex == chosenMenuIndex));
}


@override
int get hashCode => Object.hash(runtimeType,chosenMenuIndex);

@override
String toString() {
  return 'SidebarWidgetCassetteSpec(chosenMenuIndex: $chosenMenuIndex)';
}


}

/// @nodoc
abstract mixin class $SidebarWidgetCassetteSpecCopyWith<$Res>  {
  factory $SidebarWidgetCassetteSpecCopyWith(SidebarWidgetCassetteSpec value, $Res Function(SidebarWidgetCassetteSpec) _then) = _$SidebarWidgetCassetteSpecCopyWithImpl;
@useResult
$Res call({
 int chosenMenuIndex
});




}
/// @nodoc
class _$SidebarWidgetCassetteSpecCopyWithImpl<$Res>
    implements $SidebarWidgetCassetteSpecCopyWith<$Res> {
  _$SidebarWidgetCassetteSpecCopyWithImpl(this._self, this._then);

  final SidebarWidgetCassetteSpec _self;
  final $Res Function(SidebarWidgetCassetteSpec) _then;

/// Create a copy of SidebarWidgetCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chosenMenuIndex = null,}) {
  return _then(_self.copyWith(
chosenMenuIndex: null == chosenMenuIndex ? _self.chosenMenuIndex : chosenMenuIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SidebarWidgetCassetteSpec].
extension SidebarWidgetCassetteSpecPatterns on SidebarWidgetCassetteSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _SidebarWidgetCassetteSpec value)?  topChatMenu,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SidebarWidgetCassetteSpec() when topChatMenu != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _SidebarWidgetCassetteSpec value)  topChatMenu,}){
final _that = this;
switch (_that) {
case _SidebarWidgetCassetteSpec():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _SidebarWidgetCassetteSpec value)?  topChatMenu,}){
final _that = this;
switch (_that) {
case _SidebarWidgetCassetteSpec() when topChatMenu != null:
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
case _SidebarWidgetCassetteSpec() when topChatMenu != null:
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
case _SidebarWidgetCassetteSpec():
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
case _SidebarWidgetCassetteSpec() when topChatMenu != null:
return topChatMenu(_that.chosenMenuIndex);case _:
  return null;

}
}

}

/// @nodoc


class _SidebarWidgetCassetteSpec implements SidebarWidgetCassetteSpec {
  const _SidebarWidgetCassetteSpec({this.chosenMenuIndex = 1});
  

@override@JsonKey() final  int chosenMenuIndex;

/// Create a copy of SidebarWidgetCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SidebarWidgetCassetteSpecCopyWith<_SidebarWidgetCassetteSpec> get copyWith => __$SidebarWidgetCassetteSpecCopyWithImpl<_SidebarWidgetCassetteSpec>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SidebarWidgetCassetteSpec&&(identical(other.chosenMenuIndex, chosenMenuIndex) || other.chosenMenuIndex == chosenMenuIndex));
}


@override
int get hashCode => Object.hash(runtimeType,chosenMenuIndex);

@override
String toString() {
  return 'SidebarWidgetCassetteSpec.topChatMenu(chosenMenuIndex: $chosenMenuIndex)';
}


}

/// @nodoc
abstract mixin class _$SidebarWidgetCassetteSpecCopyWith<$Res> implements $SidebarWidgetCassetteSpecCopyWith<$Res> {
  factory _$SidebarWidgetCassetteSpecCopyWith(_SidebarWidgetCassetteSpec value, $Res Function(_SidebarWidgetCassetteSpec) _then) = __$SidebarWidgetCassetteSpecCopyWithImpl;
@override @useResult
$Res call({
 int chosenMenuIndex
});




}
/// @nodoc
class __$SidebarWidgetCassetteSpecCopyWithImpl<$Res>
    implements _$SidebarWidgetCassetteSpecCopyWith<$Res> {
  __$SidebarWidgetCassetteSpecCopyWithImpl(this._self, this._then);

  final _SidebarWidgetCassetteSpec _self;
  final $Res Function(_SidebarWidgetCassetteSpec) _then;

/// Create a copy of SidebarWidgetCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chosenMenuIndex = null,}) {
  return _then(_SidebarWidgetCassetteSpec(
chosenMenuIndex: null == chosenMenuIndex ? _self.chosenMenuIndex : chosenMenuIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
