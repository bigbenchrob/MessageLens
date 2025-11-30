// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grouped_contacts_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GroupedContacts {

 Map<String, List<ContactSummary>> get groups; Map<String, int> get letterCounts; List<String> get availableLetters;
/// Create a copy of GroupedContacts
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupedContactsCopyWith<GroupedContacts> get copyWith => _$GroupedContactsCopyWithImpl<GroupedContacts>(this as GroupedContacts, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupedContacts&&const DeepCollectionEquality().equals(other.groups, groups)&&const DeepCollectionEquality().equals(other.letterCounts, letterCounts)&&const DeepCollectionEquality().equals(other.availableLetters, availableLetters));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(groups),const DeepCollectionEquality().hash(letterCounts),const DeepCollectionEquality().hash(availableLetters));

@override
String toString() {
  return 'GroupedContacts(groups: $groups, letterCounts: $letterCounts, availableLetters: $availableLetters)';
}


}

/// @nodoc
abstract mixin class $GroupedContactsCopyWith<$Res>  {
  factory $GroupedContactsCopyWith(GroupedContacts value, $Res Function(GroupedContacts) _then) = _$GroupedContactsCopyWithImpl;
@useResult
$Res call({
 Map<String, List<ContactSummary>> groups, Map<String, int> letterCounts, List<String> availableLetters
});




}
/// @nodoc
class _$GroupedContactsCopyWithImpl<$Res>
    implements $GroupedContactsCopyWith<$Res> {
  _$GroupedContactsCopyWithImpl(this._self, this._then);

  final GroupedContacts _self;
  final $Res Function(GroupedContacts) _then;

/// Create a copy of GroupedContacts
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groups = null,Object? letterCounts = null,Object? availableLetters = null,}) {
  return _then(_self.copyWith(
groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as Map<String, List<ContactSummary>>,letterCounts: null == letterCounts ? _self.letterCounts : letterCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,availableLetters: null == availableLetters ? _self.availableLetters : availableLetters // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupedContacts].
extension GroupedContactsPatterns on GroupedContacts {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupedContacts value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupedContacts() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupedContacts value)  $default,){
final _that = this;
switch (_that) {
case _GroupedContacts():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupedContacts value)?  $default,){
final _that = this;
switch (_that) {
case _GroupedContacts() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, List<ContactSummary>> groups,  Map<String, int> letterCounts,  List<String> availableLetters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupedContacts() when $default != null:
return $default(_that.groups,_that.letterCounts,_that.availableLetters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, List<ContactSummary>> groups,  Map<String, int> letterCounts,  List<String> availableLetters)  $default,) {final _that = this;
switch (_that) {
case _GroupedContacts():
return $default(_that.groups,_that.letterCounts,_that.availableLetters);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, List<ContactSummary>> groups,  Map<String, int> letterCounts,  List<String> availableLetters)?  $default,) {final _that = this;
switch (_that) {
case _GroupedContacts() when $default != null:
return $default(_that.groups,_that.letterCounts,_that.availableLetters);case _:
  return null;

}
}

}

/// @nodoc


class _GroupedContacts implements GroupedContacts {
  const _GroupedContacts({required final  Map<String, List<ContactSummary>> groups, required final  Map<String, int> letterCounts, required final  List<String> availableLetters}): _groups = groups,_letterCounts = letterCounts,_availableLetters = availableLetters;
  

 final  Map<String, List<ContactSummary>> _groups;
@override Map<String, List<ContactSummary>> get groups {
  if (_groups is EqualUnmodifiableMapView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_groups);
}

 final  Map<String, int> _letterCounts;
@override Map<String, int> get letterCounts {
  if (_letterCounts is EqualUnmodifiableMapView) return _letterCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_letterCounts);
}

 final  List<String> _availableLetters;
@override List<String> get availableLetters {
  if (_availableLetters is EqualUnmodifiableListView) return _availableLetters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableLetters);
}


/// Create a copy of GroupedContacts
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupedContactsCopyWith<_GroupedContacts> get copyWith => __$GroupedContactsCopyWithImpl<_GroupedContacts>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupedContacts&&const DeepCollectionEquality().equals(other._groups, _groups)&&const DeepCollectionEquality().equals(other._letterCounts, _letterCounts)&&const DeepCollectionEquality().equals(other._availableLetters, _availableLetters));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_groups),const DeepCollectionEquality().hash(_letterCounts),const DeepCollectionEquality().hash(_availableLetters));

@override
String toString() {
  return 'GroupedContacts(groups: $groups, letterCounts: $letterCounts, availableLetters: $availableLetters)';
}


}

/// @nodoc
abstract mixin class _$GroupedContactsCopyWith<$Res> implements $GroupedContactsCopyWith<$Res> {
  factory _$GroupedContactsCopyWith(_GroupedContacts value, $Res Function(_GroupedContacts) _then) = __$GroupedContactsCopyWithImpl;
@override @useResult
$Res call({
 Map<String, List<ContactSummary>> groups, Map<String, int> letterCounts, List<String> availableLetters
});




}
/// @nodoc
class __$GroupedContactsCopyWithImpl<$Res>
    implements _$GroupedContactsCopyWith<$Res> {
  __$GroupedContactsCopyWithImpl(this._self, this._then);

  final _GroupedContacts _self;
  final $Res Function(_GroupedContacts) _then;

/// Create a copy of GroupedContacts
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groups = null,Object? letterCounts = null,Object? availableLetters = null,}) {
  return _then(_GroupedContacts(
groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as Map<String, List<ContactSummary>>,letterCounts: null == letterCounts ? _self._letterCounts : letterCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,availableLetters: null == availableLetters ? _self._availableLetters : availableLetters // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
