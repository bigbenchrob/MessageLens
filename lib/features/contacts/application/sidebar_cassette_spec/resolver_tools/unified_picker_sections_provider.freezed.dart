// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unified_picker_sections_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PickerSection {

/// Unique key for this section (e.g. "RECENTS", "FAVORITES", "A", "B").
 String get key;/// Display label shown as the section header.
 String get label;/// Contacts in this section.
 List<ContactSummary> get contacts;/// The kind of section (for jump-bar offset logic, not for visual treatment).
 PickerSectionType get type;
/// Create a copy of PickerSection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PickerSectionCopyWith<PickerSection> get copyWith => _$PickerSectionCopyWithImpl<PickerSection>(this as PickerSection, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PickerSection&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&const DeepCollectionEquality().equals(other.contacts, contacts)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,key,label,const DeepCollectionEquality().hash(contacts),type);

@override
String toString() {
  return 'PickerSection(key: $key, label: $label, contacts: $contacts, type: $type)';
}


}

/// @nodoc
abstract mixin class $PickerSectionCopyWith<$Res>  {
  factory $PickerSectionCopyWith(PickerSection value, $Res Function(PickerSection) _then) = _$PickerSectionCopyWithImpl;
@useResult
$Res call({
 String key, String label, List<ContactSummary> contacts, PickerSectionType type
});




}
/// @nodoc
class _$PickerSectionCopyWithImpl<$Res>
    implements $PickerSectionCopyWith<$Res> {
  _$PickerSectionCopyWithImpl(this._self, this._then);

  final PickerSection _self;
  final $Res Function(PickerSection) _then;

/// Create a copy of PickerSection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? label = null,Object? contacts = null,Object? type = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,contacts: null == contacts ? _self.contacts : contacts // ignore: cast_nullable_to_non_nullable
as List<ContactSummary>,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PickerSectionType,
  ));
}

}


/// Adds pattern-matching-related methods to [PickerSection].
extension PickerSectionPatterns on PickerSection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PickerSection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PickerSection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PickerSection value)  $default,){
final _that = this;
switch (_that) {
case _PickerSection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PickerSection value)?  $default,){
final _that = this;
switch (_that) {
case _PickerSection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String label,  List<ContactSummary> contacts,  PickerSectionType type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PickerSection() when $default != null:
return $default(_that.key,_that.label,_that.contacts,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String label,  List<ContactSummary> contacts,  PickerSectionType type)  $default,) {final _that = this;
switch (_that) {
case _PickerSection():
return $default(_that.key,_that.label,_that.contacts,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String label,  List<ContactSummary> contacts,  PickerSectionType type)?  $default,) {final _that = this;
switch (_that) {
case _PickerSection() when $default != null:
return $default(_that.key,_that.label,_that.contacts,_that.type);case _:
  return null;

}
}

}

/// @nodoc


class _PickerSection implements PickerSection {
  const _PickerSection({required this.key, required this.label, required final  List<ContactSummary> contacts, required this.type}): _contacts = contacts;
  

/// Unique key for this section (e.g. "RECENTS", "FAVORITES", "A", "B").
@override final  String key;
/// Display label shown as the section header.
@override final  String label;
/// Contacts in this section.
 final  List<ContactSummary> _contacts;
/// Contacts in this section.
@override List<ContactSummary> get contacts {
  if (_contacts is EqualUnmodifiableListView) return _contacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_contacts);
}

/// The kind of section (for jump-bar offset logic, not for visual treatment).
@override final  PickerSectionType type;

/// Create a copy of PickerSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PickerSectionCopyWith<_PickerSection> get copyWith => __$PickerSectionCopyWithImpl<_PickerSection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PickerSection&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&const DeepCollectionEquality().equals(other._contacts, _contacts)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,key,label,const DeepCollectionEquality().hash(_contacts),type);

@override
String toString() {
  return 'PickerSection(key: $key, label: $label, contacts: $contacts, type: $type)';
}


}

/// @nodoc
abstract mixin class _$PickerSectionCopyWith<$Res> implements $PickerSectionCopyWith<$Res> {
  factory _$PickerSectionCopyWith(_PickerSection value, $Res Function(_PickerSection) _then) = __$PickerSectionCopyWithImpl;
@override @useResult
$Res call({
 String key, String label, List<ContactSummary> contacts, PickerSectionType type
});




}
/// @nodoc
class __$PickerSectionCopyWithImpl<$Res>
    implements _$PickerSectionCopyWith<$Res> {
  __$PickerSectionCopyWithImpl(this._self, this._then);

  final _PickerSection _self;
  final $Res Function(_PickerSection) _then;

/// Create a copy of PickerSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? label = null,Object? contacts = null,Object? type = null,}) {
  return _then(_PickerSection(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,contacts: null == contacts ? _self._contacts : contacts // ignore: cast_nullable_to_non_nullable
as List<ContactSummary>,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PickerSectionType,
  ));
}


}

/// @nodoc
mixin _$UnifiedPickerSections {

/// All sections in display order: RECENTS, FAVORITES, A, B, C, …
 List<PickerSection> get sections;/// Available letters for the jump bar (A–Z subset that has contacts).
 List<String> get alphabeticalLetters;/// Index offset: the first alphabetical section's position in [sections].
/// The jump bar maps letter index → `alphabeticalStartIndex + letterIndex`.
 int get alphabeticalStartIndex;/// Participant IDs of all user-designated favourites, regardless of which
/// section they currently appear in. Used to render a subtle favourite
/// indicator on rows outside the FAVORITES section.
 Set<int> get allFavoriteIds;
/// Create a copy of UnifiedPickerSections
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnifiedPickerSectionsCopyWith<UnifiedPickerSections> get copyWith => _$UnifiedPickerSectionsCopyWithImpl<UnifiedPickerSections>(this as UnifiedPickerSections, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnifiedPickerSections&&const DeepCollectionEquality().equals(other.sections, sections)&&const DeepCollectionEquality().equals(other.alphabeticalLetters, alphabeticalLetters)&&(identical(other.alphabeticalStartIndex, alphabeticalStartIndex) || other.alphabeticalStartIndex == alphabeticalStartIndex)&&const DeepCollectionEquality().equals(other.allFavoriteIds, allFavoriteIds));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(sections),const DeepCollectionEquality().hash(alphabeticalLetters),alphabeticalStartIndex,const DeepCollectionEquality().hash(allFavoriteIds));

@override
String toString() {
  return 'UnifiedPickerSections(sections: $sections, alphabeticalLetters: $alphabeticalLetters, alphabeticalStartIndex: $alphabeticalStartIndex, allFavoriteIds: $allFavoriteIds)';
}


}

/// @nodoc
abstract mixin class $UnifiedPickerSectionsCopyWith<$Res>  {
  factory $UnifiedPickerSectionsCopyWith(UnifiedPickerSections value, $Res Function(UnifiedPickerSections) _then) = _$UnifiedPickerSectionsCopyWithImpl;
@useResult
$Res call({
 List<PickerSection> sections, List<String> alphabeticalLetters, int alphabeticalStartIndex, Set<int> allFavoriteIds
});




}
/// @nodoc
class _$UnifiedPickerSectionsCopyWithImpl<$Res>
    implements $UnifiedPickerSectionsCopyWith<$Res> {
  _$UnifiedPickerSectionsCopyWithImpl(this._self, this._then);

  final UnifiedPickerSections _self;
  final $Res Function(UnifiedPickerSections) _then;

/// Create a copy of UnifiedPickerSections
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sections = null,Object? alphabeticalLetters = null,Object? alphabeticalStartIndex = null,Object? allFavoriteIds = null,}) {
  return _then(_self.copyWith(
sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as List<PickerSection>,alphabeticalLetters: null == alphabeticalLetters ? _self.alphabeticalLetters : alphabeticalLetters // ignore: cast_nullable_to_non_nullable
as List<String>,alphabeticalStartIndex: null == alphabeticalStartIndex ? _self.alphabeticalStartIndex : alphabeticalStartIndex // ignore: cast_nullable_to_non_nullable
as int,allFavoriteIds: null == allFavoriteIds ? _self.allFavoriteIds : allFavoriteIds // ignore: cast_nullable_to_non_nullable
as Set<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [UnifiedPickerSections].
extension UnifiedPickerSectionsPatterns on UnifiedPickerSections {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnifiedPickerSections value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnifiedPickerSections() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnifiedPickerSections value)  $default,){
final _that = this;
switch (_that) {
case _UnifiedPickerSections():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnifiedPickerSections value)?  $default,){
final _that = this;
switch (_that) {
case _UnifiedPickerSections() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PickerSection> sections,  List<String> alphabeticalLetters,  int alphabeticalStartIndex,  Set<int> allFavoriteIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnifiedPickerSections() when $default != null:
return $default(_that.sections,_that.alphabeticalLetters,_that.alphabeticalStartIndex,_that.allFavoriteIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PickerSection> sections,  List<String> alphabeticalLetters,  int alphabeticalStartIndex,  Set<int> allFavoriteIds)  $default,) {final _that = this;
switch (_that) {
case _UnifiedPickerSections():
return $default(_that.sections,_that.alphabeticalLetters,_that.alphabeticalStartIndex,_that.allFavoriteIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PickerSection> sections,  List<String> alphabeticalLetters,  int alphabeticalStartIndex,  Set<int> allFavoriteIds)?  $default,) {final _that = this;
switch (_that) {
case _UnifiedPickerSections() when $default != null:
return $default(_that.sections,_that.alphabeticalLetters,_that.alphabeticalStartIndex,_that.allFavoriteIds);case _:
  return null;

}
}

}

/// @nodoc


class _UnifiedPickerSections implements UnifiedPickerSections {
  const _UnifiedPickerSections({required final  List<PickerSection> sections, required final  List<String> alphabeticalLetters, required this.alphabeticalStartIndex, required final  Set<int> allFavoriteIds}): _sections = sections,_alphabeticalLetters = alphabeticalLetters,_allFavoriteIds = allFavoriteIds;
  

/// All sections in display order: RECENTS, FAVORITES, A, B, C, …
 final  List<PickerSection> _sections;
/// All sections in display order: RECENTS, FAVORITES, A, B, C, …
@override List<PickerSection> get sections {
  if (_sections is EqualUnmodifiableListView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sections);
}

/// Available letters for the jump bar (A–Z subset that has contacts).
 final  List<String> _alphabeticalLetters;
/// Available letters for the jump bar (A–Z subset that has contacts).
@override List<String> get alphabeticalLetters {
  if (_alphabeticalLetters is EqualUnmodifiableListView) return _alphabeticalLetters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_alphabeticalLetters);
}

/// Index offset: the first alphabetical section's position in [sections].
/// The jump bar maps letter index → `alphabeticalStartIndex + letterIndex`.
@override final  int alphabeticalStartIndex;
/// Participant IDs of all user-designated favourites, regardless of which
/// section they currently appear in. Used to render a subtle favourite
/// indicator on rows outside the FAVORITES section.
 final  Set<int> _allFavoriteIds;
/// Participant IDs of all user-designated favourites, regardless of which
/// section they currently appear in. Used to render a subtle favourite
/// indicator on rows outside the FAVORITES section.
@override Set<int> get allFavoriteIds {
  if (_allFavoriteIds is EqualUnmodifiableSetView) return _allFavoriteIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_allFavoriteIds);
}


/// Create a copy of UnifiedPickerSections
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnifiedPickerSectionsCopyWith<_UnifiedPickerSections> get copyWith => __$UnifiedPickerSectionsCopyWithImpl<_UnifiedPickerSections>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnifiedPickerSections&&const DeepCollectionEquality().equals(other._sections, _sections)&&const DeepCollectionEquality().equals(other._alphabeticalLetters, _alphabeticalLetters)&&(identical(other.alphabeticalStartIndex, alphabeticalStartIndex) || other.alphabeticalStartIndex == alphabeticalStartIndex)&&const DeepCollectionEquality().equals(other._allFavoriteIds, _allFavoriteIds));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_sections),const DeepCollectionEquality().hash(_alphabeticalLetters),alphabeticalStartIndex,const DeepCollectionEquality().hash(_allFavoriteIds));

@override
String toString() {
  return 'UnifiedPickerSections(sections: $sections, alphabeticalLetters: $alphabeticalLetters, alphabeticalStartIndex: $alphabeticalStartIndex, allFavoriteIds: $allFavoriteIds)';
}


}

/// @nodoc
abstract mixin class _$UnifiedPickerSectionsCopyWith<$Res> implements $UnifiedPickerSectionsCopyWith<$Res> {
  factory _$UnifiedPickerSectionsCopyWith(_UnifiedPickerSections value, $Res Function(_UnifiedPickerSections) _then) = __$UnifiedPickerSectionsCopyWithImpl;
@override @useResult
$Res call({
 List<PickerSection> sections, List<String> alphabeticalLetters, int alphabeticalStartIndex, Set<int> allFavoriteIds
});




}
/// @nodoc
class __$UnifiedPickerSectionsCopyWithImpl<$Res>
    implements _$UnifiedPickerSectionsCopyWith<$Res> {
  __$UnifiedPickerSectionsCopyWithImpl(this._self, this._then);

  final _UnifiedPickerSections _self;
  final $Res Function(_UnifiedPickerSections) _then;

/// Create a copy of UnifiedPickerSections
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sections = null,Object? alphabeticalLetters = null,Object? alphabeticalStartIndex = null,Object? allFavoriteIds = null,}) {
  return _then(_UnifiedPickerSections(
sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as List<PickerSection>,alphabeticalLetters: null == alphabeticalLetters ? _self._alphabeticalLetters : alphabeticalLetters // ignore: cast_nullable_to_non_nullable
as List<String>,alphabeticalStartIndex: null == alphabeticalStartIndex ? _self.alphabeticalStartIndex : alphabeticalStartIndex // ignore: cast_nullable_to_non_nullable
as int,allFavoriteIds: null == allFavoriteIds ? _self._allFavoriteIds : allFavoriteIds // ignore: cast_nullable_to_non_nullable
as Set<int>,
  ));
}


}

// dart format on
