// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'handles_list_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HandlesListSpec {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HandlesListSpec);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HandlesListSpec()';
}


}

/// @nodoc
class $HandlesListSpecCopyWith<$Res>  {
$HandlesListSpecCopyWith(HandlesListSpec _, $Res Function(HandlesListSpec) __);
}


/// Adds pattern-matching-related methods to [HandlesListSpec].
extension HandlesListSpecPatterns on HandlesListSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( HandlesListSpecPhones value)?  phones,TResult Function( HandlesListSpecEmails value)?  emails,required TResult orElse(),}){
final _that = this;
switch (_that) {
case HandlesListSpecPhones() when phones != null:
return phones(_that);case HandlesListSpecEmails() when emails != null:
return emails(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( HandlesListSpecPhones value)  phones,required TResult Function( HandlesListSpecEmails value)  emails,}){
final _that = this;
switch (_that) {
case HandlesListSpecPhones():
return phones(_that);case HandlesListSpecEmails():
return emails(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( HandlesListSpecPhones value)?  phones,TResult? Function( HandlesListSpecEmails value)?  emails,}){
final _that = this;
switch (_that) {
case HandlesListSpecPhones() when phones != null:
return phones(_that);case HandlesListSpecEmails() when emails != null:
return emails(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( PhoneFilterMode filterMode)?  phones,TResult Function()?  emails,required TResult orElse(),}) {final _that = this;
switch (_that) {
case HandlesListSpecPhones() when phones != null:
return phones(_that.filterMode);case HandlesListSpecEmails() when emails != null:
return emails();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( PhoneFilterMode filterMode)  phones,required TResult Function()  emails,}) {final _that = this;
switch (_that) {
case HandlesListSpecPhones():
return phones(_that.filterMode);case HandlesListSpecEmails():
return emails();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( PhoneFilterMode filterMode)?  phones,TResult? Function()?  emails,}) {final _that = this;
switch (_that) {
case HandlesListSpecPhones() when phones != null:
return phones(_that.filterMode);case HandlesListSpecEmails() when emails != null:
return emails();case _:
  return null;

}
}

}

/// @nodoc


class HandlesListSpecPhones implements HandlesListSpec {
  const HandlesListSpecPhones({required this.filterMode});
  

 final  PhoneFilterMode filterMode;

/// Create a copy of HandlesListSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HandlesListSpecPhonesCopyWith<HandlesListSpecPhones> get copyWith => _$HandlesListSpecPhonesCopyWithImpl<HandlesListSpecPhones>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HandlesListSpecPhones&&(identical(other.filterMode, filterMode) || other.filterMode == filterMode));
}


@override
int get hashCode => Object.hash(runtimeType,filterMode);

@override
String toString() {
  return 'HandlesListSpec.phones(filterMode: $filterMode)';
}


}

/// @nodoc
abstract mixin class $HandlesListSpecPhonesCopyWith<$Res> implements $HandlesListSpecCopyWith<$Res> {
  factory $HandlesListSpecPhonesCopyWith(HandlesListSpecPhones value, $Res Function(HandlesListSpecPhones) _then) = _$HandlesListSpecPhonesCopyWithImpl;
@useResult
$Res call({
 PhoneFilterMode filterMode
});




}
/// @nodoc
class _$HandlesListSpecPhonesCopyWithImpl<$Res>
    implements $HandlesListSpecPhonesCopyWith<$Res> {
  _$HandlesListSpecPhonesCopyWithImpl(this._self, this._then);

  final HandlesListSpecPhones _self;
  final $Res Function(HandlesListSpecPhones) _then;

/// Create a copy of HandlesListSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? filterMode = null,}) {
  return _then(HandlesListSpecPhones(
filterMode: null == filterMode ? _self.filterMode : filterMode // ignore: cast_nullable_to_non_nullable
as PhoneFilterMode,
  ));
}


}

/// @nodoc


class HandlesListSpecEmails implements HandlesListSpec {
  const HandlesListSpecEmails();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HandlesListSpecEmails);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HandlesListSpec.emails()';
}


}




// dart format on
