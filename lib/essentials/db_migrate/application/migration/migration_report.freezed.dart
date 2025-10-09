// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'migration_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MigrationReport {

 DateTime get startedAt; DateTime get endedAt; List<TableReport> get tables;// per-table stats
 List<String> get warnings;
/// Create a copy of MigrationReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MigrationReportCopyWith<MigrationReport> get copyWith => _$MigrationReportCopyWithImpl<MigrationReport>(this as MigrationReport, _$identity);

  /// Serializes this MigrationReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MigrationReport&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&const DeepCollectionEquality().equals(other.tables, tables)&&const DeepCollectionEquality().equals(other.warnings, warnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startedAt,endedAt,const DeepCollectionEquality().hash(tables),const DeepCollectionEquality().hash(warnings));

@override
String toString() {
  return 'MigrationReport(startedAt: $startedAt, endedAt: $endedAt, tables: $tables, warnings: $warnings)';
}


}

/// @nodoc
abstract mixin class $MigrationReportCopyWith<$Res>  {
  factory $MigrationReportCopyWith(MigrationReport value, $Res Function(MigrationReport) _then) = _$MigrationReportCopyWithImpl;
@useResult
$Res call({
 DateTime startedAt, DateTime endedAt, List<TableReport> tables, List<String> warnings
});




}
/// @nodoc
class _$MigrationReportCopyWithImpl<$Res>
    implements $MigrationReportCopyWith<$Res> {
  _$MigrationReportCopyWithImpl(this._self, this._then);

  final MigrationReport _self;
  final $Res Function(MigrationReport) _then;

/// Create a copy of MigrationReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startedAt = null,Object? endedAt = null,Object? tables = null,Object? warnings = null,}) {
  return _then(_self.copyWith(
startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: null == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime,tables: null == tables ? _self.tables : tables // ignore: cast_nullable_to_non_nullable
as List<TableReport>,warnings: null == warnings ? _self.warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [MigrationReport].
extension MigrationReportPatterns on MigrationReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MigrationReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MigrationReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MigrationReport value)  $default,){
final _that = this;
switch (_that) {
case _MigrationReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MigrationReport value)?  $default,){
final _that = this;
switch (_that) {
case _MigrationReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime startedAt,  DateTime endedAt,  List<TableReport> tables,  List<String> warnings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MigrationReport() when $default != null:
return $default(_that.startedAt,_that.endedAt,_that.tables,_that.warnings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime startedAt,  DateTime endedAt,  List<TableReport> tables,  List<String> warnings)  $default,) {final _that = this;
switch (_that) {
case _MigrationReport():
return $default(_that.startedAt,_that.endedAt,_that.tables,_that.warnings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime startedAt,  DateTime endedAt,  List<TableReport> tables,  List<String> warnings)?  $default,) {final _that = this;
switch (_that) {
case _MigrationReport() when $default != null:
return $default(_that.startedAt,_that.endedAt,_that.tables,_that.warnings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MigrationReport extends MigrationReport {
  const _MigrationReport({required this.startedAt, required this.endedAt, required final  List<TableReport> tables, final  List<String> warnings = const []}): _tables = tables,_warnings = warnings,super._();
  factory _MigrationReport.fromJson(Map<String, dynamic> json) => _$MigrationReportFromJson(json);

@override final  DateTime startedAt;
@override final  DateTime endedAt;
 final  List<TableReport> _tables;
@override List<TableReport> get tables {
  if (_tables is EqualUnmodifiableListView) return _tables;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tables);
}

// per-table stats
 final  List<String> _warnings;
// per-table stats
@override@JsonKey() List<String> get warnings {
  if (_warnings is EqualUnmodifiableListView) return _warnings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_warnings);
}


/// Create a copy of MigrationReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MigrationReportCopyWith<_MigrationReport> get copyWith => __$MigrationReportCopyWithImpl<_MigrationReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MigrationReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MigrationReport&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&const DeepCollectionEquality().equals(other._tables, _tables)&&const DeepCollectionEquality().equals(other._warnings, _warnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startedAt,endedAt,const DeepCollectionEquality().hash(_tables),const DeepCollectionEquality().hash(_warnings));

@override
String toString() {
  return 'MigrationReport(startedAt: $startedAt, endedAt: $endedAt, tables: $tables, warnings: $warnings)';
}


}

/// @nodoc
abstract mixin class _$MigrationReportCopyWith<$Res> implements $MigrationReportCopyWith<$Res> {
  factory _$MigrationReportCopyWith(_MigrationReport value, $Res Function(_MigrationReport) _then) = __$MigrationReportCopyWithImpl;
@override @useResult
$Res call({
 DateTime startedAt, DateTime endedAt, List<TableReport> tables, List<String> warnings
});




}
/// @nodoc
class __$MigrationReportCopyWithImpl<$Res>
    implements _$MigrationReportCopyWith<$Res> {
  __$MigrationReportCopyWithImpl(this._self, this._then);

  final _MigrationReport _self;
  final $Res Function(_MigrationReport) _then;

/// Create a copy of MigrationReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startedAt = null,Object? endedAt = null,Object? tables = null,Object? warnings = null,}) {
  return _then(_MigrationReport(
startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: null == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime,tables: null == tables ? _self._tables : tables // ignore: cast_nullable_to_non_nullable
as List<TableReport>,warnings: null == warnings ? _self._warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$TableReport {

 String get table; int get rowsCopied; int get rowsUpdated; int get rowsSkipped; List<String> get notes;
/// Create a copy of TableReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TableReportCopyWith<TableReport> get copyWith => _$TableReportCopyWithImpl<TableReport>(this as TableReport, _$identity);

  /// Serializes this TableReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TableReport&&(identical(other.table, table) || other.table == table)&&(identical(other.rowsCopied, rowsCopied) || other.rowsCopied == rowsCopied)&&(identical(other.rowsUpdated, rowsUpdated) || other.rowsUpdated == rowsUpdated)&&(identical(other.rowsSkipped, rowsSkipped) || other.rowsSkipped == rowsSkipped)&&const DeepCollectionEquality().equals(other.notes, notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,table,rowsCopied,rowsUpdated,rowsSkipped,const DeepCollectionEquality().hash(notes));

@override
String toString() {
  return 'TableReport(table: $table, rowsCopied: $rowsCopied, rowsUpdated: $rowsUpdated, rowsSkipped: $rowsSkipped, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $TableReportCopyWith<$Res>  {
  factory $TableReportCopyWith(TableReport value, $Res Function(TableReport) _then) = _$TableReportCopyWithImpl;
@useResult
$Res call({
 String table, int rowsCopied, int rowsUpdated, int rowsSkipped, List<String> notes
});




}
/// @nodoc
class _$TableReportCopyWithImpl<$Res>
    implements $TableReportCopyWith<$Res> {
  _$TableReportCopyWithImpl(this._self, this._then);

  final TableReport _self;
  final $Res Function(TableReport) _then;

/// Create a copy of TableReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? table = null,Object? rowsCopied = null,Object? rowsUpdated = null,Object? rowsSkipped = null,Object? notes = null,}) {
  return _then(_self.copyWith(
table: null == table ? _self.table : table // ignore: cast_nullable_to_non_nullable
as String,rowsCopied: null == rowsCopied ? _self.rowsCopied : rowsCopied // ignore: cast_nullable_to_non_nullable
as int,rowsUpdated: null == rowsUpdated ? _self.rowsUpdated : rowsUpdated // ignore: cast_nullable_to_non_nullable
as int,rowsSkipped: null == rowsSkipped ? _self.rowsSkipped : rowsSkipped // ignore: cast_nullable_to_non_nullable
as int,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [TableReport].
extension TableReportPatterns on TableReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TableReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TableReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TableReport value)  $default,){
final _that = this;
switch (_that) {
case _TableReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TableReport value)?  $default,){
final _that = this;
switch (_that) {
case _TableReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String table,  int rowsCopied,  int rowsUpdated,  int rowsSkipped,  List<String> notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TableReport() when $default != null:
return $default(_that.table,_that.rowsCopied,_that.rowsUpdated,_that.rowsSkipped,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String table,  int rowsCopied,  int rowsUpdated,  int rowsSkipped,  List<String> notes)  $default,) {final _that = this;
switch (_that) {
case _TableReport():
return $default(_that.table,_that.rowsCopied,_that.rowsUpdated,_that.rowsSkipped,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String table,  int rowsCopied,  int rowsUpdated,  int rowsSkipped,  List<String> notes)?  $default,) {final _that = this;
switch (_that) {
case _TableReport() when $default != null:
return $default(_that.table,_that.rowsCopied,_that.rowsUpdated,_that.rowsSkipped,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TableReport implements TableReport {
  const _TableReport({required this.table, required this.rowsCopied, this.rowsUpdated = 0, this.rowsSkipped = 0, final  List<String> notes = const []}): _notes = notes;
  factory _TableReport.fromJson(Map<String, dynamic> json) => _$TableReportFromJson(json);

@override final  String table;
@override final  int rowsCopied;
@override@JsonKey() final  int rowsUpdated;
@override@JsonKey() final  int rowsSkipped;
 final  List<String> _notes;
@override@JsonKey() List<String> get notes {
  if (_notes is EqualUnmodifiableListView) return _notes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notes);
}


/// Create a copy of TableReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TableReportCopyWith<_TableReport> get copyWith => __$TableReportCopyWithImpl<_TableReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TableReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TableReport&&(identical(other.table, table) || other.table == table)&&(identical(other.rowsCopied, rowsCopied) || other.rowsCopied == rowsCopied)&&(identical(other.rowsUpdated, rowsUpdated) || other.rowsUpdated == rowsUpdated)&&(identical(other.rowsSkipped, rowsSkipped) || other.rowsSkipped == rowsSkipped)&&const DeepCollectionEquality().equals(other._notes, _notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,table,rowsCopied,rowsUpdated,rowsSkipped,const DeepCollectionEquality().hash(_notes));

@override
String toString() {
  return 'TableReport(table: $table, rowsCopied: $rowsCopied, rowsUpdated: $rowsUpdated, rowsSkipped: $rowsSkipped, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$TableReportCopyWith<$Res> implements $TableReportCopyWith<$Res> {
  factory _$TableReportCopyWith(_TableReport value, $Res Function(_TableReport) _then) = __$TableReportCopyWithImpl;
@override @useResult
$Res call({
 String table, int rowsCopied, int rowsUpdated, int rowsSkipped, List<String> notes
});




}
/// @nodoc
class __$TableReportCopyWithImpl<$Res>
    implements _$TableReportCopyWith<$Res> {
  __$TableReportCopyWithImpl(this._self, this._then);

  final _TableReport _self;
  final $Res Function(_TableReport) _then;

/// Create a copy of TableReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? table = null,Object? rowsCopied = null,Object? rowsUpdated = null,Object? rowsSkipped = null,Object? notes = null,}) {
  return _then(_TableReport(
table: null == table ? _self.table : table // ignore: cast_nullable_to_non_nullable
as String,rowsCopied: null == rowsCopied ? _self.rowsCopied : rowsCopied // ignore: cast_nullable_to_non_nullable
as int,rowsUpdated: null == rowsUpdated ? _self.rowsUpdated : rowsUpdated // ignore: cast_nullable_to_non_nullable
as int,rowsSkipped: null == rowsSkipped ? _self.rowsSkipped : rowsSkipped // ignore: cast_nullable_to_non_nullable
as int,notes: null == notes ? _self._notes : notes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
