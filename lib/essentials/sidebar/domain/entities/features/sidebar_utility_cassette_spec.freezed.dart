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
SidebarUtilityCassetteSpec _$SidebarUtilityCassetteSpecFromJson(
  Map<String, dynamic> json
) {
    return _SidebarUtilityCassetteSpecTopChatMenu.fromJson(
      json
    );
}

/// @nodoc
mixin _$SidebarUtilityCassetteSpec {

 TopChatMenuChoice get selectedChoice;
/// Create a copy of SidebarUtilityCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SidebarUtilityCassetteSpecCopyWith<SidebarUtilityCassetteSpec> get copyWith => _$SidebarUtilityCassetteSpecCopyWithImpl<SidebarUtilityCassetteSpec>(this as SidebarUtilityCassetteSpec, _$identity);

  /// Serializes this SidebarUtilityCassetteSpec to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SidebarUtilityCassetteSpec&&(identical(other.selectedChoice, selectedChoice) || other.selectedChoice == selectedChoice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectedChoice);

@override
String toString() {
  return 'SidebarUtilityCassetteSpec(selectedChoice: $selectedChoice)';
}


}

/// @nodoc
abstract mixin class $SidebarUtilityCassetteSpecCopyWith<$Res>  {
  factory $SidebarUtilityCassetteSpecCopyWith(SidebarUtilityCassetteSpec value, $Res Function(SidebarUtilityCassetteSpec) _then) = _$SidebarUtilityCassetteSpecCopyWithImpl;
@useResult
$Res call({
 TopChatMenuChoice selectedChoice
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
@pragma('vm:prefer-inline') @override $Res call({Object? selectedChoice = null,}) {
  return _then(_self.copyWith(
selectedChoice: null == selectedChoice ? _self.selectedChoice : selectedChoice // ignore: cast_nullable_to_non_nullable
as TopChatMenuChoice,
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _SidebarUtilityCassetteSpecTopChatMenu value)?  topChatMenu,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SidebarUtilityCassetteSpecTopChatMenu() when topChatMenu != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _SidebarUtilityCassetteSpecTopChatMenu value)  topChatMenu,}){
final _that = this;
switch (_that) {
case _SidebarUtilityCassetteSpecTopChatMenu():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _SidebarUtilityCassetteSpecTopChatMenu value)?  topChatMenu,}){
final _that = this;
switch (_that) {
case _SidebarUtilityCassetteSpecTopChatMenu() when topChatMenu != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( TopChatMenuChoice selectedChoice)?  topChatMenu,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SidebarUtilityCassetteSpecTopChatMenu() when topChatMenu != null:
return topChatMenu(_that.selectedChoice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( TopChatMenuChoice selectedChoice)  topChatMenu,}) {final _that = this;
switch (_that) {
case _SidebarUtilityCassetteSpecTopChatMenu():
return topChatMenu(_that.selectedChoice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( TopChatMenuChoice selectedChoice)?  topChatMenu,}) {final _that = this;
switch (_that) {
case _SidebarUtilityCassetteSpecTopChatMenu() when topChatMenu != null:
return topChatMenu(_that.selectedChoice);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SidebarUtilityCassetteSpecTopChatMenu implements SidebarUtilityCassetteSpec {
  const _SidebarUtilityCassetteSpecTopChatMenu({this.selectedChoice = TopChatMenuChoice.contacts});
  factory _SidebarUtilityCassetteSpecTopChatMenu.fromJson(Map<String, dynamic> json) => _$SidebarUtilityCassetteSpecTopChatMenuFromJson(json);

@override@JsonKey() final  TopChatMenuChoice selectedChoice;

/// Create a copy of SidebarUtilityCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SidebarUtilityCassetteSpecTopChatMenuCopyWith<_SidebarUtilityCassetteSpecTopChatMenu> get copyWith => __$SidebarUtilityCassetteSpecTopChatMenuCopyWithImpl<_SidebarUtilityCassetteSpecTopChatMenu>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SidebarUtilityCassetteSpecTopChatMenuToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SidebarUtilityCassetteSpecTopChatMenu&&(identical(other.selectedChoice, selectedChoice) || other.selectedChoice == selectedChoice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectedChoice);

@override
String toString() {
  return 'SidebarUtilityCassetteSpec.topChatMenu(selectedChoice: $selectedChoice)';
}


}

/// @nodoc
abstract mixin class _$SidebarUtilityCassetteSpecTopChatMenuCopyWith<$Res> implements $SidebarUtilityCassetteSpecCopyWith<$Res> {
  factory _$SidebarUtilityCassetteSpecTopChatMenuCopyWith(_SidebarUtilityCassetteSpecTopChatMenu value, $Res Function(_SidebarUtilityCassetteSpecTopChatMenu) _then) = __$SidebarUtilityCassetteSpecTopChatMenuCopyWithImpl;
@override @useResult
$Res call({
 TopChatMenuChoice selectedChoice
});




}
/// @nodoc
class __$SidebarUtilityCassetteSpecTopChatMenuCopyWithImpl<$Res>
    implements _$SidebarUtilityCassetteSpecTopChatMenuCopyWith<$Res> {
  __$SidebarUtilityCassetteSpecTopChatMenuCopyWithImpl(this._self, this._then);

  final _SidebarUtilityCassetteSpecTopChatMenu _self;
  final $Res Function(_SidebarUtilityCassetteSpecTopChatMenu) _then;

/// Create a copy of SidebarUtilityCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedChoice = null,}) {
  return _then(_SidebarUtilityCassetteSpecTopChatMenu(
selectedChoice: null == selectedChoice ? _self.selectedChoice : selectedChoice // ignore: cast_nullable_to_non_nullable
as TopChatMenuChoice,
  ));
}


}

// dart format on
