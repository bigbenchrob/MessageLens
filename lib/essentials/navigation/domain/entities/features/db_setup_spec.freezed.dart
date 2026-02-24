// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'db_setup_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DbSetupSpec {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DbSetupSpec);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DbSetupSpec()';
}


}

/// @nodoc
class $DbSetupSpecCopyWith<$Res>  {
$DbSetupSpecCopyWith(DbSetupSpec _, $Res Function(DbSetupSpec) __);
}


/// Adds pattern-matching-related methods to [DbSetupSpec].
extension DbSetupSpecPatterns on DbSetupSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _DbSetupFirstRun value)?  firstRun,TResult Function( _DbSetupRerunImport value)?  rerunImport,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DbSetupFirstRun() when firstRun != null:
return firstRun(_that);case _DbSetupRerunImport() when rerunImport != null:
return rerunImport(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _DbSetupFirstRun value)  firstRun,required TResult Function( _DbSetupRerunImport value)  rerunImport,}){
final _that = this;
switch (_that) {
case _DbSetupFirstRun():
return firstRun(_that);case _DbSetupRerunImport():
return rerunImport(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _DbSetupFirstRun value)?  firstRun,TResult? Function( _DbSetupRerunImport value)?  rerunImport,}){
final _that = this;
switch (_that) {
case _DbSetupFirstRun() when firstRun != null:
return firstRun(_that);case _DbSetupRerunImport() when rerunImport != null:
return rerunImport(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  firstRun,TResult Function()?  rerunImport,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DbSetupFirstRun() when firstRun != null:
return firstRun();case _DbSetupRerunImport() when rerunImport != null:
return rerunImport();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  firstRun,required TResult Function()  rerunImport,}) {final _that = this;
switch (_that) {
case _DbSetupFirstRun():
return firstRun();case _DbSetupRerunImport():
return rerunImport();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  firstRun,TResult? Function()?  rerunImport,}) {final _that = this;
switch (_that) {
case _DbSetupFirstRun() when firstRun != null:
return firstRun();case _DbSetupRerunImport() when rerunImport != null:
return rerunImport();case _:
  return null;

}
}

}

/// @nodoc


class _DbSetupFirstRun implements DbSetupSpec {
  const _DbSetupFirstRun();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DbSetupFirstRun);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DbSetupSpec.firstRun()';
}


}




/// @nodoc


class _DbSetupRerunImport implements DbSetupSpec {
  const _DbSetupRerunImport();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DbSetupRerunImport);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DbSetupSpec.rerunImport()';
}


}




// dart format on
