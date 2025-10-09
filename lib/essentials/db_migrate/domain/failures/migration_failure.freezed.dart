// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'migration_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MigrationFailure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MigrationFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MigrationFailure()';
}


}

/// @nodoc
class $MigrationFailureCopyWith<$Res>  {
$MigrationFailureCopyWith(MigrationFailure _, $Res Function(MigrationFailure) __);
}


/// Adds pattern-matching-related methods to [MigrationFailure].
extension MigrationFailurePatterns on MigrationFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ForeignKeyViolation value)?  foreignKeyViolation,TResult Function( _Validation value)?  validation,TResult Function( _Database value)?  database,TResult Function( _Unknown value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ForeignKeyViolation() when foreignKeyViolation != null:
return foreignKeyViolation(_that);case _Validation() when validation != null:
return validation(_that);case _Database() when database != null:
return database(_that);case _Unknown() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ForeignKeyViolation value)  foreignKeyViolation,required TResult Function( _Validation value)  validation,required TResult Function( _Database value)  database,required TResult Function( _Unknown value)  unknown,}){
final _that = this;
switch (_that) {
case _ForeignKeyViolation():
return foreignKeyViolation(_that);case _Validation():
return validation(_that);case _Database():
return database(_that);case _Unknown():
return unknown(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ForeignKeyViolation value)?  foreignKeyViolation,TResult? Function( _Validation value)?  validation,TResult? Function( _Database value)?  database,TResult? Function( _Unknown value)?  unknown,}){
final _that = this;
switch (_that) {
case _ForeignKeyViolation() when foreignKeyViolation != null:
return foreignKeyViolation(_that);case _Validation() when validation != null:
return validation(_that);case _Database() when database != null:
return database(_that);case _Unknown() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String table,  String details)?  foreignKeyViolation,TResult Function( String table,  String details)?  validation,TResult Function( String message)?  database,TResult Function( String message)?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ForeignKeyViolation() when foreignKeyViolation != null:
return foreignKeyViolation(_that.table,_that.details);case _Validation() when validation != null:
return validation(_that.table,_that.details);case _Database() when database != null:
return database(_that.message);case _Unknown() when unknown != null:
return unknown(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String table,  String details)  foreignKeyViolation,required TResult Function( String table,  String details)  validation,required TResult Function( String message)  database,required TResult Function( String message)  unknown,}) {final _that = this;
switch (_that) {
case _ForeignKeyViolation():
return foreignKeyViolation(_that.table,_that.details);case _Validation():
return validation(_that.table,_that.details);case _Database():
return database(_that.message);case _Unknown():
return unknown(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String table,  String details)?  foreignKeyViolation,TResult? Function( String table,  String details)?  validation,TResult? Function( String message)?  database,TResult? Function( String message)?  unknown,}) {final _that = this;
switch (_that) {
case _ForeignKeyViolation() when foreignKeyViolation != null:
return foreignKeyViolation(_that.table,_that.details);case _Validation() when validation != null:
return validation(_that.table,_that.details);case _Database() when database != null:
return database(_that.message);case _Unknown() when unknown != null:
return unknown(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _ForeignKeyViolation implements MigrationFailure {
  const _ForeignKeyViolation({required this.table, required this.details});
  

 final  String table;
 final  String details;

/// Create a copy of MigrationFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ForeignKeyViolationCopyWith<_ForeignKeyViolation> get copyWith => __$ForeignKeyViolationCopyWithImpl<_ForeignKeyViolation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ForeignKeyViolation&&(identical(other.table, table) || other.table == table)&&(identical(other.details, details) || other.details == details));
}


@override
int get hashCode => Object.hash(runtimeType,table,details);

@override
String toString() {
  return 'MigrationFailure.foreignKeyViolation(table: $table, details: $details)';
}


}

/// @nodoc
abstract mixin class _$ForeignKeyViolationCopyWith<$Res> implements $MigrationFailureCopyWith<$Res> {
  factory _$ForeignKeyViolationCopyWith(_ForeignKeyViolation value, $Res Function(_ForeignKeyViolation) _then) = __$ForeignKeyViolationCopyWithImpl;
@useResult
$Res call({
 String table, String details
});




}
/// @nodoc
class __$ForeignKeyViolationCopyWithImpl<$Res>
    implements _$ForeignKeyViolationCopyWith<$Res> {
  __$ForeignKeyViolationCopyWithImpl(this._self, this._then);

  final _ForeignKeyViolation _self;
  final $Res Function(_ForeignKeyViolation) _then;

/// Create a copy of MigrationFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? table = null,Object? details = null,}) {
  return _then(_ForeignKeyViolation(
table: null == table ? _self.table : table // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Validation implements MigrationFailure {
  const _Validation({required this.table, required this.details});
  

 final  String table;
 final  String details;

/// Create a copy of MigrationFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ValidationCopyWith<_Validation> get copyWith => __$ValidationCopyWithImpl<_Validation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Validation&&(identical(other.table, table) || other.table == table)&&(identical(other.details, details) || other.details == details));
}


@override
int get hashCode => Object.hash(runtimeType,table,details);

@override
String toString() {
  return 'MigrationFailure.validation(table: $table, details: $details)';
}


}

/// @nodoc
abstract mixin class _$ValidationCopyWith<$Res> implements $MigrationFailureCopyWith<$Res> {
  factory _$ValidationCopyWith(_Validation value, $Res Function(_Validation) _then) = __$ValidationCopyWithImpl;
@useResult
$Res call({
 String table, String details
});




}
/// @nodoc
class __$ValidationCopyWithImpl<$Res>
    implements _$ValidationCopyWith<$Res> {
  __$ValidationCopyWithImpl(this._self, this._then);

  final _Validation _self;
  final $Res Function(_Validation) _then;

/// Create a copy of MigrationFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? table = null,Object? details = null,}) {
  return _then(_Validation(
table: null == table ? _self.table : table // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Database implements MigrationFailure {
  const _Database({required this.message});
  

 final  String message;

/// Create a copy of MigrationFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DatabaseCopyWith<_Database> get copyWith => __$DatabaseCopyWithImpl<_Database>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Database&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'MigrationFailure.database(message: $message)';
}


}

/// @nodoc
abstract mixin class _$DatabaseCopyWith<$Res> implements $MigrationFailureCopyWith<$Res> {
  factory _$DatabaseCopyWith(_Database value, $Res Function(_Database) _then) = __$DatabaseCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$DatabaseCopyWithImpl<$Res>
    implements _$DatabaseCopyWith<$Res> {
  __$DatabaseCopyWithImpl(this._self, this._then);

  final _Database _self;
  final $Res Function(_Database) _then;

/// Create a copy of MigrationFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Database(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Unknown implements MigrationFailure {
  const _Unknown({required this.message});
  

 final  String message;

/// Create a copy of MigrationFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnknownCopyWith<_Unknown> get copyWith => __$UnknownCopyWithImpl<_Unknown>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Unknown&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'MigrationFailure.unknown(message: $message)';
}


}

/// @nodoc
abstract mixin class _$UnknownCopyWith<$Res> implements $MigrationFailureCopyWith<$Res> {
  factory _$UnknownCopyWith(_Unknown value, $Res Function(_Unknown) _then) = __$UnknownCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$UnknownCopyWithImpl<$Res>
    implements _$UnknownCopyWith<$Res> {
  __$UnknownCopyWithImpl(this._self, this._then);

  final _Unknown _self;
  final $Res Function(_Unknown) _then;

/// Create a copy of MigrationFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Unknown(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
