// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Result<S,F> {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Result<S, F>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Result<$S, $F>()';
}


}

/// @nodoc
class $ResultCopyWith<S,F,$Res>  {
$ResultCopyWith(Result<S, F> _, $Res Function(Result<S, F>) __);
}


/// Adds pattern-matching-related methods to [Result].
extension ResultPatterns<S,F> on Result<S, F> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Success<S, F> value)?  success,TResult Function( Failure<S, F> value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Success() when success != null:
return success(_that);case Failure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Success<S, F> value)  success,required TResult Function( Failure<S, F> value)  failure,}){
final _that = this;
switch (_that) {
case Success():
return success(_that);case Failure():
return failure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Success<S, F> value)?  success,TResult? Function( Failure<S, F> value)?  failure,}){
final _that = this;
switch (_that) {
case Success() when success != null:
return success(_that);case Failure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( S value)?  success,TResult Function( F error)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Success() when success != null:
return success(_that.value);case Failure() when failure != null:
return failure(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( S value)  success,required TResult Function( F error)  failure,}) {final _that = this;
switch (_that) {
case Success():
return success(_that.value);case Failure():
return failure(_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( S value)?  success,TResult? Function( F error)?  failure,}) {final _that = this;
switch (_that) {
case Success() when success != null:
return success(_that.value);case Failure() when failure != null:
return failure(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class Success<S,F> implements Result<S, F> {
  const Success(this.value);
  

 final  S value;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuccessCopyWith<S, F, Success<S, F>> get copyWith => _$SuccessCopyWithImpl<S, F, Success<S, F>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Success<S, F>&&const DeepCollectionEquality().equals(other.value, value));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'Result<$S, $F>.success(value: $value)';
}


}

/// @nodoc
abstract mixin class $SuccessCopyWith<S,F,$Res> implements $ResultCopyWith<S, F, $Res> {
  factory $SuccessCopyWith(Success<S, F> value, $Res Function(Success<S, F>) _then) = _$SuccessCopyWithImpl;
@useResult
$Res call({
 S value
});




}
/// @nodoc
class _$SuccessCopyWithImpl<S,F,$Res>
    implements $SuccessCopyWith<S, F, $Res> {
  _$SuccessCopyWithImpl(this._self, this._then);

  final Success<S, F> _self;
  final $Res Function(Success<S, F>) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = freezed,}) {
  return _then(Success<S, F>(
freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as S,
  ));
}


}

/// @nodoc


class Failure<S,F> implements Result<S, F> {
  const Failure(this.error);
  

 final  F error;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FailureCopyWith<S, F, Failure<S, F>> get copyWith => _$FailureCopyWithImpl<S, F, Failure<S, F>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Failure<S, F>&&const DeepCollectionEquality().equals(other.error, error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(error));

@override
String toString() {
  return 'Result<$S, $F>.failure(error: $error)';
}


}

/// @nodoc
abstract mixin class $FailureCopyWith<S,F,$Res> implements $ResultCopyWith<S, F, $Res> {
  factory $FailureCopyWith(Failure<S, F> value, $Res Function(Failure<S, F>) _then) = _$FailureCopyWithImpl;
@useResult
$Res call({
 F error
});




}
/// @nodoc
class _$FailureCopyWithImpl<S,F,$Res>
    implements $FailureCopyWith<S, F, $Res> {
  _$FailureCopyWithImpl(this._self, this._then);

  final Failure<S, F> _self;
  final $Res Function(Failure<S, F>) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = freezed,}) {
  return _then(Failure<S, F>(
freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as F,
  ));
}


}

// dart format on
