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





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactsCassetteSpec);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ContactsCassetteSpec()';
}


}

/// @nodoc
class $ContactsCassetteSpecCopyWith<$Res>  {
$ContactsCassetteSpecCopyWith(ContactsCassetteSpec _, $Res Function(ContactsCassetteSpec) __);
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ContactChooserSpec value)?  contactChooser,TResult Function( _ContactSelectionControlSpec value)?  contactSelectionControl,TResult Function( _ContactHeroSummarySpec value)?  contactHeroSummary,TResult Function( _HandleFilterSpec value)?  handleFilter,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactChooserSpec() when contactChooser != null:
return contactChooser(_that);case _ContactSelectionControlSpec() when contactSelectionControl != null:
return contactSelectionControl(_that);case _ContactHeroSummarySpec() when contactHeroSummary != null:
return contactHeroSummary(_that);case _HandleFilterSpec() when handleFilter != null:
return handleFilter(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ContactChooserSpec value)  contactChooser,required TResult Function( _ContactSelectionControlSpec value)  contactSelectionControl,required TResult Function( _ContactHeroSummarySpec value)  contactHeroSummary,required TResult Function( _HandleFilterSpec value)  handleFilter,}){
final _that = this;
switch (_that) {
case _ContactChooserSpec():
return contactChooser(_that);case _ContactSelectionControlSpec():
return contactSelectionControl(_that);case _ContactHeroSummarySpec():
return contactHeroSummary(_that);case _HandleFilterSpec():
return handleFilter(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ContactChooserSpec value)?  contactChooser,TResult? Function( _ContactSelectionControlSpec value)?  contactSelectionControl,TResult? Function( _ContactHeroSummarySpec value)?  contactHeroSummary,TResult? Function( _HandleFilterSpec value)?  handleFilter,}){
final _that = this;
switch (_that) {
case _ContactChooserSpec() when contactChooser != null:
return contactChooser(_that);case _ContactSelectionControlSpec() when contactSelectionControl != null:
return contactSelectionControl(_that);case _ContactHeroSummarySpec() when contactHeroSummary != null:
return contactHeroSummary(_that);case _HandleFilterSpec() when handleFilter != null:
return handleFilter(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int? chosenContactId)?  contactChooser,TResult Function( int chosenContactId)?  contactSelectionControl,TResult Function( int chosenContactId)?  contactHeroSummary,TResult Function( int contactId,  int? selectedHandleId)?  handleFilter,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactChooserSpec() when contactChooser != null:
return contactChooser(_that.chosenContactId);case _ContactSelectionControlSpec() when contactSelectionControl != null:
return contactSelectionControl(_that.chosenContactId);case _ContactHeroSummarySpec() when contactHeroSummary != null:
return contactHeroSummary(_that.chosenContactId);case _HandleFilterSpec() when handleFilter != null:
return handleFilter(_that.contactId,_that.selectedHandleId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int? chosenContactId)  contactChooser,required TResult Function( int chosenContactId)  contactSelectionControl,required TResult Function( int chosenContactId)  contactHeroSummary,required TResult Function( int contactId,  int? selectedHandleId)  handleFilter,}) {final _that = this;
switch (_that) {
case _ContactChooserSpec():
return contactChooser(_that.chosenContactId);case _ContactSelectionControlSpec():
return contactSelectionControl(_that.chosenContactId);case _ContactHeroSummarySpec():
return contactHeroSummary(_that.chosenContactId);case _HandleFilterSpec():
return handleFilter(_that.contactId,_that.selectedHandleId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int? chosenContactId)?  contactChooser,TResult? Function( int chosenContactId)?  contactSelectionControl,TResult? Function( int chosenContactId)?  contactHeroSummary,TResult? Function( int contactId,  int? selectedHandleId)?  handleFilter,}) {final _that = this;
switch (_that) {
case _ContactChooserSpec() when contactChooser != null:
return contactChooser(_that.chosenContactId);case _ContactSelectionControlSpec() when contactSelectionControl != null:
return contactSelectionControl(_that.chosenContactId);case _ContactHeroSummarySpec() when contactHeroSummary != null:
return contactHeroSummary(_that.chosenContactId);case _HandleFilterSpec() when handleFilter != null:
return handleFilter(_that.contactId,_that.selectedHandleId);case _:
  return null;

}
}

}

/// @nodoc


class _ContactChooserSpec implements ContactsCassetteSpec {
  const _ContactChooserSpec({this.chosenContactId});
  

 final  int? chosenContactId;

/// Create a copy of ContactsCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactChooserSpecCopyWith<_ContactChooserSpec> get copyWith => __$ContactChooserSpecCopyWithImpl<_ContactChooserSpec>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactChooserSpec&&(identical(other.chosenContactId, chosenContactId) || other.chosenContactId == chosenContactId));
}


@override
int get hashCode => Object.hash(runtimeType,chosenContactId);

@override
String toString() {
  return 'ContactsCassetteSpec.contactChooser(chosenContactId: $chosenContactId)';
}


}

/// @nodoc
abstract mixin class _$ContactChooserSpecCopyWith<$Res> implements $ContactsCassetteSpecCopyWith<$Res> {
  factory _$ContactChooserSpecCopyWith(_ContactChooserSpec value, $Res Function(_ContactChooserSpec) _then) = __$ContactChooserSpecCopyWithImpl;
@useResult
$Res call({
 int? chosenContactId
});




}
/// @nodoc
class __$ContactChooserSpecCopyWithImpl<$Res>
    implements _$ContactChooserSpecCopyWith<$Res> {
  __$ContactChooserSpecCopyWithImpl(this._self, this._then);

  final _ContactChooserSpec _self;
  final $Res Function(_ContactChooserSpec) _then;

/// Create a copy of ContactsCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? chosenContactId = freezed,}) {
  return _then(_ContactChooserSpec(
chosenContactId: freezed == chosenContactId ? _self.chosenContactId : chosenContactId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class _ContactSelectionControlSpec implements ContactsCassetteSpec {
  const _ContactSelectionControlSpec({required this.chosenContactId});
  

 final  int chosenContactId;

/// Create a copy of ContactsCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactSelectionControlSpecCopyWith<_ContactSelectionControlSpec> get copyWith => __$ContactSelectionControlSpecCopyWithImpl<_ContactSelectionControlSpec>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactSelectionControlSpec&&(identical(other.chosenContactId, chosenContactId) || other.chosenContactId == chosenContactId));
}


@override
int get hashCode => Object.hash(runtimeType,chosenContactId);

@override
String toString() {
  return 'ContactsCassetteSpec.contactSelectionControl(chosenContactId: $chosenContactId)';
}


}

/// @nodoc
abstract mixin class _$ContactSelectionControlSpecCopyWith<$Res> implements $ContactsCassetteSpecCopyWith<$Res> {
  factory _$ContactSelectionControlSpecCopyWith(_ContactSelectionControlSpec value, $Res Function(_ContactSelectionControlSpec) _then) = __$ContactSelectionControlSpecCopyWithImpl;
@useResult
$Res call({
 int chosenContactId
});




}
/// @nodoc
class __$ContactSelectionControlSpecCopyWithImpl<$Res>
    implements _$ContactSelectionControlSpecCopyWith<$Res> {
  __$ContactSelectionControlSpecCopyWithImpl(this._self, this._then);

  final _ContactSelectionControlSpec _self;
  final $Res Function(_ContactSelectionControlSpec) _then;

/// Create a copy of ContactsCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? chosenContactId = null,}) {
  return _then(_ContactSelectionControlSpec(
chosenContactId: null == chosenContactId ? _self.chosenContactId : chosenContactId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _ContactHeroSummarySpec implements ContactsCassetteSpec {
  const _ContactHeroSummarySpec({required this.chosenContactId});
  

 final  int chosenContactId;

/// Create a copy of ContactsCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactHeroSummarySpecCopyWith<_ContactHeroSummarySpec> get copyWith => __$ContactHeroSummarySpecCopyWithImpl<_ContactHeroSummarySpec>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactHeroSummarySpec&&(identical(other.chosenContactId, chosenContactId) || other.chosenContactId == chosenContactId));
}


@override
int get hashCode => Object.hash(runtimeType,chosenContactId);

@override
String toString() {
  return 'ContactsCassetteSpec.contactHeroSummary(chosenContactId: $chosenContactId)';
}


}

/// @nodoc
abstract mixin class _$ContactHeroSummarySpecCopyWith<$Res> implements $ContactsCassetteSpecCopyWith<$Res> {
  factory _$ContactHeroSummarySpecCopyWith(_ContactHeroSummarySpec value, $Res Function(_ContactHeroSummarySpec) _then) = __$ContactHeroSummarySpecCopyWithImpl;
@useResult
$Res call({
 int chosenContactId
});




}
/// @nodoc
class __$ContactHeroSummarySpecCopyWithImpl<$Res>
    implements _$ContactHeroSummarySpecCopyWith<$Res> {
  __$ContactHeroSummarySpecCopyWithImpl(this._self, this._then);

  final _ContactHeroSummarySpec _self;
  final $Res Function(_ContactHeroSummarySpec) _then;

/// Create a copy of ContactsCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? chosenContactId = null,}) {
  return _then(_ContactHeroSummarySpec(
chosenContactId: null == chosenContactId ? _self.chosenContactId : chosenContactId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _HandleFilterSpec implements ContactsCassetteSpec {
  const _HandleFilterSpec({required this.contactId, this.selectedHandleId});
  

 final  int contactId;
 final  int? selectedHandleId;

/// Create a copy of ContactsCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HandleFilterSpecCopyWith<_HandleFilterSpec> get copyWith => __$HandleFilterSpecCopyWithImpl<_HandleFilterSpec>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HandleFilterSpec&&(identical(other.contactId, contactId) || other.contactId == contactId)&&(identical(other.selectedHandleId, selectedHandleId) || other.selectedHandleId == selectedHandleId));
}


@override
int get hashCode => Object.hash(runtimeType,contactId,selectedHandleId);

@override
String toString() {
  return 'ContactsCassetteSpec.handleFilter(contactId: $contactId, selectedHandleId: $selectedHandleId)';
}


}

/// @nodoc
abstract mixin class _$HandleFilterSpecCopyWith<$Res> implements $ContactsCassetteSpecCopyWith<$Res> {
  factory _$HandleFilterSpecCopyWith(_HandleFilterSpec value, $Res Function(_HandleFilterSpec) _then) = __$HandleFilterSpecCopyWithImpl;
@useResult
$Res call({
 int contactId, int? selectedHandleId
});




}
/// @nodoc
class __$HandleFilterSpecCopyWithImpl<$Res>
    implements _$HandleFilterSpecCopyWith<$Res> {
  __$HandleFilterSpecCopyWithImpl(this._self, this._then);

  final _HandleFilterSpec _self;
  final $Res Function(_HandleFilterSpec) _then;

/// Create a copy of ContactsCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? contactId = null,Object? selectedHandleId = freezed,}) {
  return _then(_HandleFilterSpec(
contactId: null == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as int,selectedHandleId: freezed == selectedHandleId ? _self.selectedHandleId : selectedHandleId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
