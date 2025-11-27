// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sidebar_layout_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SidebarLayoutState {

 SidebarRootSpec get root; List<SidebarElementSpec> get elements;
/// Create a copy of SidebarLayoutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SidebarLayoutStateCopyWith<SidebarLayoutState> get copyWith => _$SidebarLayoutStateCopyWithImpl<SidebarLayoutState>(this as SidebarLayoutState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SidebarLayoutState&&(identical(other.root, root) || other.root == root)&&const DeepCollectionEquality().equals(other.elements, elements));
}


@override
int get hashCode => Object.hash(runtimeType,root,const DeepCollectionEquality().hash(elements));

@override
String toString() {
  return 'SidebarLayoutState(root: $root, elements: $elements)';
}


}

/// @nodoc
abstract mixin class $SidebarLayoutStateCopyWith<$Res>  {
  factory $SidebarLayoutStateCopyWith(SidebarLayoutState value, $Res Function(SidebarLayoutState) _then) = _$SidebarLayoutStateCopyWithImpl;
@useResult
$Res call({
 SidebarRootSpec root, List<SidebarElementSpec> elements
});


$SidebarRootSpecCopyWith<$Res> get root;

}
/// @nodoc
class _$SidebarLayoutStateCopyWithImpl<$Res>
    implements $SidebarLayoutStateCopyWith<$Res> {
  _$SidebarLayoutStateCopyWithImpl(this._self, this._then);

  final SidebarLayoutState _self;
  final $Res Function(SidebarLayoutState) _then;

/// Create a copy of SidebarLayoutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? root = null,Object? elements = null,}) {
  return _then(_self.copyWith(
root: null == root ? _self.root : root // ignore: cast_nullable_to_non_nullable
as SidebarRootSpec,elements: null == elements ? _self.elements : elements // ignore: cast_nullable_to_non_nullable
as List<SidebarElementSpec>,
  ));
}
/// Create a copy of SidebarLayoutState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SidebarRootSpecCopyWith<$Res> get root {
  
  return $SidebarRootSpecCopyWith<$Res>(_self.root, (value) {
    return _then(_self.copyWith(root: value));
  });
}
}


/// Adds pattern-matching-related methods to [SidebarLayoutState].
extension SidebarLayoutStatePatterns on SidebarLayoutState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SidebarLayoutState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SidebarLayoutState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SidebarLayoutState value)  $default,){
final _that = this;
switch (_that) {
case _SidebarLayoutState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SidebarLayoutState value)?  $default,){
final _that = this;
switch (_that) {
case _SidebarLayoutState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SidebarRootSpec root,  List<SidebarElementSpec> elements)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SidebarLayoutState() when $default != null:
return $default(_that.root,_that.elements);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SidebarRootSpec root,  List<SidebarElementSpec> elements)  $default,) {final _that = this;
switch (_that) {
case _SidebarLayoutState():
return $default(_that.root,_that.elements);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SidebarRootSpec root,  List<SidebarElementSpec> elements)?  $default,) {final _that = this;
switch (_that) {
case _SidebarLayoutState() when $default != null:
return $default(_that.root,_that.elements);case _:
  return null;

}
}

}

/// @nodoc


class _SidebarLayoutState implements SidebarLayoutState {
  const _SidebarLayoutState({required this.root, required final  List<SidebarElementSpec> elements}): _elements = elements;
  

@override final  SidebarRootSpec root;
 final  List<SidebarElementSpec> _elements;
@override List<SidebarElementSpec> get elements {
  if (_elements is EqualUnmodifiableListView) return _elements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_elements);
}


/// Create a copy of SidebarLayoutState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SidebarLayoutStateCopyWith<_SidebarLayoutState> get copyWith => __$SidebarLayoutStateCopyWithImpl<_SidebarLayoutState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SidebarLayoutState&&(identical(other.root, root) || other.root == root)&&const DeepCollectionEquality().equals(other._elements, _elements));
}


@override
int get hashCode => Object.hash(runtimeType,root,const DeepCollectionEquality().hash(_elements));

@override
String toString() {
  return 'SidebarLayoutState(root: $root, elements: $elements)';
}


}

/// @nodoc
abstract mixin class _$SidebarLayoutStateCopyWith<$Res> implements $SidebarLayoutStateCopyWith<$Res> {
  factory _$SidebarLayoutStateCopyWith(_SidebarLayoutState value, $Res Function(_SidebarLayoutState) _then) = __$SidebarLayoutStateCopyWithImpl;
@override @useResult
$Res call({
 SidebarRootSpec root, List<SidebarElementSpec> elements
});


@override $SidebarRootSpecCopyWith<$Res> get root;

}
/// @nodoc
class __$SidebarLayoutStateCopyWithImpl<$Res>
    implements _$SidebarLayoutStateCopyWith<$Res> {
  __$SidebarLayoutStateCopyWithImpl(this._self, this._then);

  final _SidebarLayoutState _self;
  final $Res Function(_SidebarLayoutState) _then;

/// Create a copy of SidebarLayoutState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? root = null,Object? elements = null,}) {
  return _then(_SidebarLayoutState(
root: null == root ? _self.root : root // ignore: cast_nullable_to_non_nullable
as SidebarRootSpec,elements: null == elements ? _self._elements : elements // ignore: cast_nullable_to_non_nullable
as List<SidebarElementSpec>,
  ));
}

/// Create a copy of SidebarLayoutState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SidebarRootSpecCopyWith<$Res> get root {
  
  return $SidebarRootSpecCopyWith<$Res>(_self.root, (value) {
    return _then(_self.copyWith(root: value));
  });
}
}

// dart format on
