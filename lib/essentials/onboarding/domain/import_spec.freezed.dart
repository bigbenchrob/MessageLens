// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ImportSpec {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportSpec);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ImportSpec()';
}


}

/// @nodoc
class $ImportSpecCopyWith<$Res>  {
$ImportSpecCopyWith(ImportSpec _, $Res Function(ImportSpec) __);
}


/// Adds pattern-matching-related methods to [ImportSpec].
extension ImportSpecPatterns on ImportSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ImportRawData value)?  forImport,TResult Function( _MigrateData value)?  forMigration,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImportRawData() when forImport != null:
return forImport(_that);case _MigrateData() when forMigration != null:
return forMigration(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ImportRawData value)  forImport,required TResult Function( _MigrateData value)  forMigration,}){
final _that = this;
switch (_that) {
case _ImportRawData():
return forImport(_that);case _MigrateData():
return forMigration(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ImportRawData value)?  forImport,TResult? Function( _MigrateData value)?  forMigration,}){
final _that = this;
switch (_that) {
case _ImportRawData() when forImport != null:
return forImport(_that);case _MigrateData() when forMigration != null:
return forMigration(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  forImport,TResult Function()?  forMigration,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImportRawData() when forImport != null:
return forImport();case _MigrateData() when forMigration != null:
return forMigration();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  forImport,required TResult Function()  forMigration,}) {final _that = this;
switch (_that) {
case _ImportRawData():
return forImport();case _MigrateData():
return forMigration();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  forImport,TResult? Function()?  forMigration,}) {final _that = this;
switch (_that) {
case _ImportRawData() when forImport != null:
return forImport();case _MigrateData() when forMigration != null:
return forMigration();case _:
  return null;

}
}

}

/// @nodoc


class _ImportRawData implements ImportSpec {
  const _ImportRawData();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImportRawData);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ImportSpec.forImport()';
}


}




/// @nodoc


class _MigrateData implements ImportSpec {
  const _MigrateData();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MigrateData);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ImportSpec.forMigration()';
}


}




// dart format on
