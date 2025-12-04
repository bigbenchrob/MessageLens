// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contacts_cassette_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ContactsCassetteSpec {

 int? get chosenContactId;
/// Create a copy of ContactsCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactsCassetteSpecCopyWith<ContactsCassetteSpec> get copyWith => _$ContactsCassetteSpecCopyWithImpl<ContactsCassetteSpec>(this as ContactsCassetteSpec, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactsCassetteSpec&&(identical(other.chosenContactId, chosenContactId) || other.chosenContactId == chosenContactId));
}


@override
int get hashCode => Object.hash(runtimeType,chosenContactId);

@override
String toString() {
  return 'ContactsCassetteSpec(chosenContactId: $chosenContactId)';
}


}

/// @nodoc
abstract mixin class $ContactsCassetteSpecCopyWith<$Res>  {
  factory $ContactsCassetteSpecCopyWith(ContactsCassetteSpec value, $Res Function(ContactsCassetteSpec) _then) = _$ContactsCassetteSpecCopyWithImpl;
@useResult
$Res call({
 int? chosenContactId
});




}
/// @nodoc
class _$ContactsCassetteSpecCopyWithImpl<$Res>
    implements $ContactsCassetteSpecCopyWith<$Res> {
  _$ContactsCassetteSpecCopyWithImpl(this._self, this._then);

  final ContactsCassetteSpec _self;
  final $Res Function(ContactsCassetteSpec) _then;

/// Create a copy of ContactsCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chosenContactId = freezed,}) {
  return _then(_self.copyWith(
chosenContactId: freezed == chosenContactId ? _self.chosenContactId : chosenContactId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContactsCassetteSpec].
extension ContactsCassetteSpecPatterns on ContactsCassetteSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ContactMenuSpec value)?  contactsFlatMenu,TResult Function( _ContactPickerSpec value)?  contactPicker,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactMenuSpec() when contactsFlatMenu != null:
return contactsFlatMenu(_that);case _ContactPickerSpec() when contactPicker != null:
return contactPicker(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ContactMenuSpec value)  contactsFlatMenu,required TResult Function( _ContactPickerSpec value)  contactPicker,}){
final _that = this;
switch (_that) {
case _ContactMenuSpec():
return contactsFlatMenu(_that);case _ContactPickerSpec():
return contactPicker(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ContactMenuSpec value)?  contactsFlatMenu,TResult? Function( _ContactPickerSpec value)?  contactPicker,}){
final _that = this;
switch (_that) {
case _ContactMenuSpec() when contactsFlatMenu != null:
return contactsFlatMenu(_that);case _ContactPickerSpec() when contactPicker != null:
return contactPicker(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int? chosenContactId)?  contactsFlatMenu,TResult Function( int? chosenContactId)?  contactPicker,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactMenuSpec() when contactsFlatMenu != null:
return contactsFlatMenu(_that.chosenContactId);case _ContactPickerSpec() when contactPicker != null:
return contactPicker(_that.chosenContactId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int? chosenContactId)  contactsFlatMenu,required TResult Function( int? chosenContactId)  contactPicker,}) {final _that = this;
switch (_that) {
case _ContactMenuSpec():
return contactsFlatMenu(_that.chosenContactId);case _ContactPickerSpec():
return contactPicker(_that.chosenContactId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int? chosenContactId)?  contactsFlatMenu,TResult? Function( int? chosenContactId)?  contactPicker,}) {final _that = this;
switch (_that) {
case _ContactMenuSpec() when contactsFlatMenu != null:
return contactsFlatMenu(_that.chosenContactId);case _ContactPickerSpec() when contactPicker != null:
return contactPicker(_that.chosenContactId);case _:
  return null;

}
}

}

/// @nodoc


class _ContactMenuSpec implements ContactsCassetteSpec {
  const _ContactMenuSpec({this.chosenContactId});
  

@override final  int? chosenContactId;

/// Create a copy of ContactsCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactMenuSpecCopyWith<_ContactMenuSpec> get copyWith => __$ContactMenuSpecCopyWithImpl<_ContactMenuSpec>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactMenuSpec&&(identical(other.chosenContactId, chosenContactId) || other.chosenContactId == chosenContactId));
}


@override
int get hashCode => Object.hash(runtimeType,chosenContactId);

@override
String toString() {
  return 'ContactsCassetteSpec.contactsFlatMenu(chosenContactId: $chosenContactId)';
}


}

/// @nodoc
abstract mixin class _$ContactMenuSpecCopyWith<$Res> implements $ContactsCassetteSpecCopyWith<$Res> {
  factory _$ContactMenuSpecCopyWith(_ContactMenuSpec value, $Res Function(_ContactMenuSpec) _then) = __$ContactMenuSpecCopyWithImpl;
@override @useResult
$Res call({
 int? chosenContactId
});




}
/// @nodoc
class __$ContactMenuSpecCopyWithImpl<$Res>
    implements _$ContactMenuSpecCopyWith<$Res> {
  __$ContactMenuSpecCopyWithImpl(this._self, this._then);

  final _ContactMenuSpec _self;
  final $Res Function(_ContactMenuSpec) _then;

/// Create a copy of ContactsCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chosenContactId = freezed,}) {
  return _then(_ContactMenuSpec(
chosenContactId: freezed == chosenContactId ? _self.chosenContactId : chosenContactId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class _ContactPickerSpec implements ContactsCassetteSpec {
  const _ContactPickerSpec({this.chosenContactId});
  

@override final  int? chosenContactId;

/// Create a copy of ContactsCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactPickerSpecCopyWith<_ContactPickerSpec> get copyWith => __$ContactPickerSpecCopyWithImpl<_ContactPickerSpec>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactPickerSpec&&(identical(other.chosenContactId, chosenContactId) || other.chosenContactId == chosenContactId));
}


@override
int get hashCode => Object.hash(runtimeType,chosenContactId);

@override
String toString() {
  return 'ContactsCassetteSpec.contactPicker(chosenContactId: $chosenContactId)';
}


}

/// @nodoc
abstract mixin class _$ContactPickerSpecCopyWith<$Res> implements $ContactsCassetteSpecCopyWith<$Res> {
  factory _$ContactPickerSpecCopyWith(_ContactPickerSpec value, $Res Function(_ContactPickerSpec) _then) = __$ContactPickerSpecCopyWithImpl;
@override @useResult
$Res call({
 int? chosenContactId
});




}
/// @nodoc
class __$ContactPickerSpecCopyWithImpl<$Res>
    implements _$ContactPickerSpecCopyWith<$Res> {
  __$ContactPickerSpecCopyWithImpl(this._self, this._then);

  final _ContactPickerSpec _self;
  final $Res Function(_ContactPickerSpec) _then;

/// Create a copy of ContactsCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chosenContactId = freezed,}) {
  return _then(_ContactPickerSpec(
chosenContactId: freezed == chosenContactId ? _self.chosenContactId : chosenContactId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
