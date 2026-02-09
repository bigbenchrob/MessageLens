// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'handles_cassette_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HandlesCassetteSpec {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HandlesCassetteSpec);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HandlesCassetteSpec()';
}


}

/// @nodoc
class $HandlesCassetteSpecCopyWith<$Res>  {
$HandlesCassetteSpecCopyWith(HandlesCassetteSpec _, $Res Function(HandlesCassetteSpec) __);
}


/// Adds pattern-matching-related methods to [HandlesCassetteSpec].
extension HandlesCassetteSpecPatterns on HandlesCassetteSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _HandlesListUnmatchedSpec value)?  unmatchedHandlesList,TResult Function( _HandlesStrayPhoneNumbersSpec value)?  strayPhoneNumbers,TResult Function( _HandlesStrayEmailsSpec value)?  strayEmails,TResult Function( _HandlesStrayReviewSpec value)?  strayHandlesReview,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HandlesListUnmatchedSpec() when unmatchedHandlesList != null:
return unmatchedHandlesList(_that);case _HandlesStrayPhoneNumbersSpec() when strayPhoneNumbers != null:
return strayPhoneNumbers(_that);case _HandlesStrayEmailsSpec() when strayEmails != null:
return strayEmails(_that);case _HandlesStrayReviewSpec() when strayHandlesReview != null:
return strayHandlesReview(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _HandlesListUnmatchedSpec value)  unmatchedHandlesList,required TResult Function( _HandlesStrayPhoneNumbersSpec value)  strayPhoneNumbers,required TResult Function( _HandlesStrayEmailsSpec value)  strayEmails,required TResult Function( _HandlesStrayReviewSpec value)  strayHandlesReview,}){
final _that = this;
switch (_that) {
case _HandlesListUnmatchedSpec():
return unmatchedHandlesList(_that);case _HandlesStrayPhoneNumbersSpec():
return strayPhoneNumbers(_that);case _HandlesStrayEmailsSpec():
return strayEmails(_that);case _HandlesStrayReviewSpec():
return strayHandlesReview(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _HandlesListUnmatchedSpec value)?  unmatchedHandlesList,TResult? Function( _HandlesStrayPhoneNumbersSpec value)?  strayPhoneNumbers,TResult? Function( _HandlesStrayEmailsSpec value)?  strayEmails,TResult? Function( _HandlesStrayReviewSpec value)?  strayHandlesReview,}){
final _that = this;
switch (_that) {
case _HandlesListUnmatchedSpec() when unmatchedHandlesList != null:
return unmatchedHandlesList(_that);case _HandlesStrayPhoneNumbersSpec() when strayPhoneNumbers != null:
return strayPhoneNumbers(_that);case _HandlesStrayEmailsSpec() when strayEmails != null:
return strayEmails(_that);case _HandlesStrayReviewSpec() when strayHandlesReview != null:
return strayHandlesReview(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int? chosenContactId)?  unmatchedHandlesList,TResult Function()?  strayPhoneNumbers,TResult Function()?  strayEmails,TResult Function( StrayHandleFilter filter)?  strayHandlesReview,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HandlesListUnmatchedSpec() when unmatchedHandlesList != null:
return unmatchedHandlesList(_that.chosenContactId);case _HandlesStrayPhoneNumbersSpec() when strayPhoneNumbers != null:
return strayPhoneNumbers();case _HandlesStrayEmailsSpec() when strayEmails != null:
return strayEmails();case _HandlesStrayReviewSpec() when strayHandlesReview != null:
return strayHandlesReview(_that.filter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int? chosenContactId)  unmatchedHandlesList,required TResult Function()  strayPhoneNumbers,required TResult Function()  strayEmails,required TResult Function( StrayHandleFilter filter)  strayHandlesReview,}) {final _that = this;
switch (_that) {
case _HandlesListUnmatchedSpec():
return unmatchedHandlesList(_that.chosenContactId);case _HandlesStrayPhoneNumbersSpec():
return strayPhoneNumbers();case _HandlesStrayEmailsSpec():
return strayEmails();case _HandlesStrayReviewSpec():
return strayHandlesReview(_that.filter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int? chosenContactId)?  unmatchedHandlesList,TResult? Function()?  strayPhoneNumbers,TResult? Function()?  strayEmails,TResult? Function( StrayHandleFilter filter)?  strayHandlesReview,}) {final _that = this;
switch (_that) {
case _HandlesListUnmatchedSpec() when unmatchedHandlesList != null:
return unmatchedHandlesList(_that.chosenContactId);case _HandlesStrayPhoneNumbersSpec() when strayPhoneNumbers != null:
return strayPhoneNumbers();case _HandlesStrayEmailsSpec() when strayEmails != null:
return strayEmails();case _HandlesStrayReviewSpec() when strayHandlesReview != null:
return strayHandlesReview(_that.filter);case _:
  return null;

}
}

}

/// @nodoc


class _HandlesListUnmatchedSpec implements HandlesCassetteSpec {
  const _HandlesListUnmatchedSpec({this.chosenContactId});
  

 final  int? chosenContactId;

/// Create a copy of HandlesCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HandlesListUnmatchedSpecCopyWith<_HandlesListUnmatchedSpec> get copyWith => __$HandlesListUnmatchedSpecCopyWithImpl<_HandlesListUnmatchedSpec>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HandlesListUnmatchedSpec&&(identical(other.chosenContactId, chosenContactId) || other.chosenContactId == chosenContactId));
}


@override
int get hashCode => Object.hash(runtimeType,chosenContactId);

@override
String toString() {
  return 'HandlesCassetteSpec.unmatchedHandlesList(chosenContactId: $chosenContactId)';
}


}

/// @nodoc
abstract mixin class _$HandlesListUnmatchedSpecCopyWith<$Res> implements $HandlesCassetteSpecCopyWith<$Res> {
  factory _$HandlesListUnmatchedSpecCopyWith(_HandlesListUnmatchedSpec value, $Res Function(_HandlesListUnmatchedSpec) _then) = __$HandlesListUnmatchedSpecCopyWithImpl;
@useResult
$Res call({
 int? chosenContactId
});




}
/// @nodoc
class __$HandlesListUnmatchedSpecCopyWithImpl<$Res>
    implements _$HandlesListUnmatchedSpecCopyWith<$Res> {
  __$HandlesListUnmatchedSpecCopyWithImpl(this._self, this._then);

  final _HandlesListUnmatchedSpec _self;
  final $Res Function(_HandlesListUnmatchedSpec) _then;

/// Create a copy of HandlesCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? chosenContactId = freezed,}) {
  return _then(_HandlesListUnmatchedSpec(
chosenContactId: freezed == chosenContactId ? _self.chosenContactId : chosenContactId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class _HandlesStrayPhoneNumbersSpec implements HandlesCassetteSpec {
  const _HandlesStrayPhoneNumbersSpec();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HandlesStrayPhoneNumbersSpec);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HandlesCassetteSpec.strayPhoneNumbers()';
}


}




/// @nodoc


class _HandlesStrayEmailsSpec implements HandlesCassetteSpec {
  const _HandlesStrayEmailsSpec();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HandlesStrayEmailsSpec);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HandlesCassetteSpec.strayEmails()';
}


}




/// @nodoc


class _HandlesStrayReviewSpec implements HandlesCassetteSpec {
  const _HandlesStrayReviewSpec({required this.filter});
  

 final  StrayHandleFilter filter;

/// Create a copy of HandlesCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HandlesStrayReviewSpecCopyWith<_HandlesStrayReviewSpec> get copyWith => __$HandlesStrayReviewSpecCopyWithImpl<_HandlesStrayReviewSpec>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HandlesStrayReviewSpec&&(identical(other.filter, filter) || other.filter == filter));
}


@override
int get hashCode => Object.hash(runtimeType,filter);

@override
String toString() {
  return 'HandlesCassetteSpec.strayHandlesReview(filter: $filter)';
}


}

/// @nodoc
abstract mixin class _$HandlesStrayReviewSpecCopyWith<$Res> implements $HandlesCassetteSpecCopyWith<$Res> {
  factory _$HandlesStrayReviewSpecCopyWith(_HandlesStrayReviewSpec value, $Res Function(_HandlesStrayReviewSpec) _then) = __$HandlesStrayReviewSpecCopyWithImpl;
@useResult
$Res call({
 StrayHandleFilter filter
});




}
/// @nodoc
class __$HandlesStrayReviewSpecCopyWithImpl<$Res>
    implements _$HandlesStrayReviewSpecCopyWith<$Res> {
  __$HandlesStrayReviewSpecCopyWithImpl(this._self, this._then);

  final _HandlesStrayReviewSpec _self;
  final $Res Function(_HandlesStrayReviewSpec) _then;

/// Create a copy of HandlesCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? filter = null,}) {
  return _then(_HandlesStrayReviewSpec(
filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as StrayHandleFilter,
  ));
}


}

// dart format on
