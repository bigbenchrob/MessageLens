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
 int chosenContactId
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
@pragma('vm:prefer-inline') @override $Res call({Object? chosenContactId = null,}) {
  return _then(_self.copyWith(
chosenContactId: null == chosenContactId ? _self.chosenContactId! : chosenContactId // ignore: cast_nullable_to_non_nullable
as int,
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _RecentContactsSpec value)?  recentContacts,TResult Function( _ContactChooserSpec value)?  contactChooser,TResult Function( _ContactHeroSummarySpec value)?  contactHeroSummary,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecentContactsSpec() when recentContacts != null:
return recentContacts(_that);case _ContactChooserSpec() when contactChooser != null:
return contactChooser(_that);case _ContactHeroSummarySpec() when contactHeroSummary != null:
return contactHeroSummary(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _RecentContactsSpec value)  recentContacts,required TResult Function( _ContactChooserSpec value)  contactChooser,required TResult Function( _ContactHeroSummarySpec value)  contactHeroSummary,}){
final _that = this;
switch (_that) {
case _RecentContactsSpec():
return recentContacts(_that);case _ContactChooserSpec():
return contactChooser(_that);case _ContactHeroSummarySpec():
return contactHeroSummary(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _RecentContactsSpec value)?  recentContacts,TResult? Function( _ContactChooserSpec value)?  contactChooser,TResult? Function( _ContactHeroSummarySpec value)?  contactHeroSummary,}){
final _that = this;
switch (_that) {
case _RecentContactsSpec() when recentContacts != null:
return recentContacts(_that);case _ContactChooserSpec() when contactChooser != null:
return contactChooser(_that);case _ContactHeroSummarySpec() when contactHeroSummary != null:
return contactHeroSummary(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int? chosenContactId)?  recentContacts,TResult Function( int? chosenContactId)?  contactChooser,TResult Function( int chosenContactId)?  contactHeroSummary,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecentContactsSpec() when recentContacts != null:
return recentContacts(_that.chosenContactId);case _ContactChooserSpec() when contactChooser != null:
return contactChooser(_that.chosenContactId);case _ContactHeroSummarySpec() when contactHeroSummary != null:
return contactHeroSummary(_that.chosenContactId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int? chosenContactId)  recentContacts,required TResult Function( int? chosenContactId)  contactChooser,required TResult Function( int chosenContactId)  contactHeroSummary,}) {final _that = this;
switch (_that) {
case _RecentContactsSpec():
return recentContacts(_that.chosenContactId);case _ContactChooserSpec():
return contactChooser(_that.chosenContactId);case _ContactHeroSummarySpec():
return contactHeroSummary(_that.chosenContactId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int? chosenContactId)?  recentContacts,TResult? Function( int? chosenContactId)?  contactChooser,TResult? Function( int chosenContactId)?  contactHeroSummary,}) {final _that = this;
switch (_that) {
case _RecentContactsSpec() when recentContacts != null:
return recentContacts(_that.chosenContactId);case _ContactChooserSpec() when contactChooser != null:
return contactChooser(_that.chosenContactId);case _ContactHeroSummarySpec() when contactHeroSummary != null:
return contactHeroSummary(_that.chosenContactId);case _:
  return null;

}
}

}

/// @nodoc


class _RecentContactsSpec implements ContactsCassetteSpec {
  const _RecentContactsSpec({this.chosenContactId});
  

@override final  int? chosenContactId;

/// Create a copy of ContactsCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecentContactsSpecCopyWith<_RecentContactsSpec> get copyWith => __$RecentContactsSpecCopyWithImpl<_RecentContactsSpec>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecentContactsSpec&&(identical(other.chosenContactId, chosenContactId) || other.chosenContactId == chosenContactId));
}


@override
int get hashCode => Object.hash(runtimeType,chosenContactId);

@override
String toString() {
  return 'ContactsCassetteSpec.recentContacts(chosenContactId: $chosenContactId)';
}


}

/// @nodoc
abstract mixin class _$RecentContactsSpecCopyWith<$Res> implements $ContactsCassetteSpecCopyWith<$Res> {
  factory _$RecentContactsSpecCopyWith(_RecentContactsSpec value, $Res Function(_RecentContactsSpec) _then) = __$RecentContactsSpecCopyWithImpl;
@override @useResult
$Res call({
 int? chosenContactId
});




}
/// @nodoc
class __$RecentContactsSpecCopyWithImpl<$Res>
    implements _$RecentContactsSpecCopyWith<$Res> {
  __$RecentContactsSpecCopyWithImpl(this._self, this._then);

  final _RecentContactsSpec _self;
  final $Res Function(_RecentContactsSpec) _then;

/// Create a copy of ContactsCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chosenContactId = freezed,}) {
  return _then(_RecentContactsSpec(
chosenContactId: freezed == chosenContactId ? _self.chosenContactId : chosenContactId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class _ContactChooserSpec implements ContactsCassetteSpec {
  const _ContactChooserSpec({this.chosenContactId});
  

@override final  int? chosenContactId;

/// Create a copy of ContactsCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
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
@override @useResult
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
@override @pragma('vm:prefer-inline') $Res call({Object? chosenContactId = freezed,}) {
  return _then(_ContactChooserSpec(
chosenContactId: freezed == chosenContactId ? _self.chosenContactId : chosenContactId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class _ContactHeroSummarySpec implements ContactsCassetteSpec {
  const _ContactHeroSummarySpec({required this.chosenContactId});
  

@override final  int chosenContactId;

/// Create a copy of ContactsCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
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
@override @useResult
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
@override @pragma('vm:prefer-inline') $Res call({Object? chosenContactId = null,}) {
  return _then(_ContactHeroSummarySpec(
chosenContactId: null == chosenContactId ? _self.chosenContactId : chosenContactId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
