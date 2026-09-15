// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'database_health_audit_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DatabaseHealthAuditOutput {

 String get reportPath; DatabaseHealthReport get report;
/// Create a copy of DatabaseHealthAuditOutput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DatabaseHealthAuditOutputCopyWith<DatabaseHealthAuditOutput> get copyWith => _$DatabaseHealthAuditOutputCopyWithImpl<DatabaseHealthAuditOutput>(this as DatabaseHealthAuditOutput, _$identity);

  /// Serializes this DatabaseHealthAuditOutput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DatabaseHealthAuditOutput&&(identical(other.reportPath, reportPath) || other.reportPath == reportPath)&&(identical(other.report, report) || other.report == report));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reportPath,report);

@override
String toString() {
  return 'DatabaseHealthAuditOutput(reportPath: $reportPath, report: $report)';
}


}

/// @nodoc
abstract mixin class $DatabaseHealthAuditOutputCopyWith<$Res>  {
  factory $DatabaseHealthAuditOutputCopyWith(DatabaseHealthAuditOutput value, $Res Function(DatabaseHealthAuditOutput) _then) = _$DatabaseHealthAuditOutputCopyWithImpl;
@useResult
$Res call({
 String reportPath, DatabaseHealthReport report
});


$DatabaseHealthReportCopyWith<$Res> get report;

}
/// @nodoc
class _$DatabaseHealthAuditOutputCopyWithImpl<$Res>
    implements $DatabaseHealthAuditOutputCopyWith<$Res> {
  _$DatabaseHealthAuditOutputCopyWithImpl(this._self, this._then);

  final DatabaseHealthAuditOutput _self;
  final $Res Function(DatabaseHealthAuditOutput) _then;

/// Create a copy of DatabaseHealthAuditOutput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reportPath = null,Object? report = null,}) {
  return _then(_self.copyWith(
reportPath: null == reportPath ? _self.reportPath : reportPath // ignore: cast_nullable_to_non_nullable
as String,report: null == report ? _self.report : report // ignore: cast_nullable_to_non_nullable
as DatabaseHealthReport,
  ));
}
/// Create a copy of DatabaseHealthAuditOutput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DatabaseHealthReportCopyWith<$Res> get report {
  
  return $DatabaseHealthReportCopyWith<$Res>(_self.report, (value) {
    return _then(_self.copyWith(report: value));
  });
}
}


/// Adds pattern-matching-related methods to [DatabaseHealthAuditOutput].
extension DatabaseHealthAuditOutputPatterns on DatabaseHealthAuditOutput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DatabaseHealthAuditOutput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DatabaseHealthAuditOutput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DatabaseHealthAuditOutput value)  $default,){
final _that = this;
switch (_that) {
case _DatabaseHealthAuditOutput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DatabaseHealthAuditOutput value)?  $default,){
final _that = this;
switch (_that) {
case _DatabaseHealthAuditOutput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String reportPath,  DatabaseHealthReport report)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DatabaseHealthAuditOutput() when $default != null:
return $default(_that.reportPath,_that.report);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String reportPath,  DatabaseHealthReport report)  $default,) {final _that = this;
switch (_that) {
case _DatabaseHealthAuditOutput():
return $default(_that.reportPath,_that.report);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String reportPath,  DatabaseHealthReport report)?  $default,) {final _that = this;
switch (_that) {
case _DatabaseHealthAuditOutput() when $default != null:
return $default(_that.reportPath,_that.report);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class _DatabaseHealthAuditOutput implements DatabaseHealthAuditOutput {
  const _DatabaseHealthAuditOutput({required this.reportPath, required this.report});
  factory _DatabaseHealthAuditOutput.fromJson(Map<String, dynamic> json) => _$DatabaseHealthAuditOutputFromJson(json);

@override final  String reportPath;
@override final  DatabaseHealthReport report;

/// Create a copy of DatabaseHealthAuditOutput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DatabaseHealthAuditOutputCopyWith<_DatabaseHealthAuditOutput> get copyWith => __$DatabaseHealthAuditOutputCopyWithImpl<_DatabaseHealthAuditOutput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DatabaseHealthAuditOutputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DatabaseHealthAuditOutput&&(identical(other.reportPath, reportPath) || other.reportPath == reportPath)&&(identical(other.report, report) || other.report == report));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reportPath,report);

@override
String toString() {
  return 'DatabaseHealthAuditOutput(reportPath: $reportPath, report: $report)';
}


}

/// @nodoc
abstract mixin class _$DatabaseHealthAuditOutputCopyWith<$Res> implements $DatabaseHealthAuditOutputCopyWith<$Res> {
  factory _$DatabaseHealthAuditOutputCopyWith(_DatabaseHealthAuditOutput value, $Res Function(_DatabaseHealthAuditOutput) _then) = __$DatabaseHealthAuditOutputCopyWithImpl;
@override @useResult
$Res call({
 String reportPath, DatabaseHealthReport report
});


@override $DatabaseHealthReportCopyWith<$Res> get report;

}
/// @nodoc
class __$DatabaseHealthAuditOutputCopyWithImpl<$Res>
    implements _$DatabaseHealthAuditOutputCopyWith<$Res> {
  __$DatabaseHealthAuditOutputCopyWithImpl(this._self, this._then);

  final _DatabaseHealthAuditOutput _self;
  final $Res Function(_DatabaseHealthAuditOutput) _then;

/// Create a copy of DatabaseHealthAuditOutput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reportPath = null,Object? report = null,}) {
  return _then(_DatabaseHealthAuditOutput(
reportPath: null == reportPath ? _self.reportPath : reportPath // ignore: cast_nullable_to_non_nullable
as String,report: null == report ? _self.report : report // ignore: cast_nullable_to_non_nullable
as DatabaseHealthReport,
  ));
}

/// Create a copy of DatabaseHealthAuditOutput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DatabaseHealthReportCopyWith<$Res> get report {
  
  return $DatabaseHealthReportCopyWith<$Res>(_self.report, (value) {
    return _then(_self.copyWith(report: value));
  });
}
}


/// @nodoc
mixin _$DatabaseHealthReport {

 String get schemaVersion; String get generatedAt; String get auditVersion; DatabaseHealthAppInfo get app; DatabaseHealthEnvironmentInfo get environment; List<AuditedDatabaseInfo> get databases; List<TableInventoryEntry> get tableInventory; List<RelationshipCheckResult> get relationshipChecks; List<InvariantCheckResult> get invariantChecks; MessageTextEnrichmentHealth? get messageTextEnrichment; HealthReportSummary get summary; List<HealthReportError> get errors;
/// Create a copy of DatabaseHealthReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DatabaseHealthReportCopyWith<DatabaseHealthReport> get copyWith => _$DatabaseHealthReportCopyWithImpl<DatabaseHealthReport>(this as DatabaseHealthReport, _$identity);

  /// Serializes this DatabaseHealthReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DatabaseHealthReport&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.auditVersion, auditVersion) || other.auditVersion == auditVersion)&&(identical(other.app, app) || other.app == app)&&(identical(other.environment, environment) || other.environment == environment)&&const DeepCollectionEquality().equals(other.databases, databases)&&const DeepCollectionEquality().equals(other.tableInventory, tableInventory)&&const DeepCollectionEquality().equals(other.relationshipChecks, relationshipChecks)&&const DeepCollectionEquality().equals(other.invariantChecks, invariantChecks)&&(identical(other.messageTextEnrichment, messageTextEnrichment) || other.messageTextEnrichment == messageTextEnrichment)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.errors, errors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,generatedAt,auditVersion,app,environment,const DeepCollectionEquality().hash(databases),const DeepCollectionEquality().hash(tableInventory),const DeepCollectionEquality().hash(relationshipChecks),const DeepCollectionEquality().hash(invariantChecks),messageTextEnrichment,summary,const DeepCollectionEquality().hash(errors));

@override
String toString() {
  return 'DatabaseHealthReport(schemaVersion: $schemaVersion, generatedAt: $generatedAt, auditVersion: $auditVersion, app: $app, environment: $environment, databases: $databases, tableInventory: $tableInventory, relationshipChecks: $relationshipChecks, invariantChecks: $invariantChecks, messageTextEnrichment: $messageTextEnrichment, summary: $summary, errors: $errors)';
}


}

/// @nodoc
abstract mixin class $DatabaseHealthReportCopyWith<$Res>  {
  factory $DatabaseHealthReportCopyWith(DatabaseHealthReport value, $Res Function(DatabaseHealthReport) _then) = _$DatabaseHealthReportCopyWithImpl;
@useResult
$Res call({
 String schemaVersion, String generatedAt, String auditVersion, DatabaseHealthAppInfo app, DatabaseHealthEnvironmentInfo environment, List<AuditedDatabaseInfo> databases, List<TableInventoryEntry> tableInventory, List<RelationshipCheckResult> relationshipChecks, List<InvariantCheckResult> invariantChecks, MessageTextEnrichmentHealth? messageTextEnrichment, HealthReportSummary summary, List<HealthReportError> errors
});


$DatabaseHealthAppInfoCopyWith<$Res> get app;$DatabaseHealthEnvironmentInfoCopyWith<$Res> get environment;$MessageTextEnrichmentHealthCopyWith<$Res>? get messageTextEnrichment;$HealthReportSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class _$DatabaseHealthReportCopyWithImpl<$Res>
    implements $DatabaseHealthReportCopyWith<$Res> {
  _$DatabaseHealthReportCopyWithImpl(this._self, this._then);

  final DatabaseHealthReport _self;
  final $Res Function(DatabaseHealthReport) _then;

/// Create a copy of DatabaseHealthReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? generatedAt = null,Object? auditVersion = null,Object? app = null,Object? environment = null,Object? databases = null,Object? tableInventory = null,Object? relationshipChecks = null,Object? invariantChecks = null,Object? messageTextEnrichment = freezed,Object? summary = null,Object? errors = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as String,auditVersion: null == auditVersion ? _self.auditVersion : auditVersion // ignore: cast_nullable_to_non_nullable
as String,app: null == app ? _self.app : app // ignore: cast_nullable_to_non_nullable
as DatabaseHealthAppInfo,environment: null == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as DatabaseHealthEnvironmentInfo,databases: null == databases ? _self.databases : databases // ignore: cast_nullable_to_non_nullable
as List<AuditedDatabaseInfo>,tableInventory: null == tableInventory ? _self.tableInventory : tableInventory // ignore: cast_nullable_to_non_nullable
as List<TableInventoryEntry>,relationshipChecks: null == relationshipChecks ? _self.relationshipChecks : relationshipChecks // ignore: cast_nullable_to_non_nullable
as List<RelationshipCheckResult>,invariantChecks: null == invariantChecks ? _self.invariantChecks : invariantChecks // ignore: cast_nullable_to_non_nullable
as List<InvariantCheckResult>,messageTextEnrichment: freezed == messageTextEnrichment ? _self.messageTextEnrichment : messageTextEnrichment // ignore: cast_nullable_to_non_nullable
as MessageTextEnrichmentHealth?,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as HealthReportSummary,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as List<HealthReportError>,
  ));
}
/// Create a copy of DatabaseHealthReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DatabaseHealthAppInfoCopyWith<$Res> get app {
  
  return $DatabaseHealthAppInfoCopyWith<$Res>(_self.app, (value) {
    return _then(_self.copyWith(app: value));
  });
}/// Create a copy of DatabaseHealthReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DatabaseHealthEnvironmentInfoCopyWith<$Res> get environment {
  
  return $DatabaseHealthEnvironmentInfoCopyWith<$Res>(_self.environment, (value) {
    return _then(_self.copyWith(environment: value));
  });
}/// Create a copy of DatabaseHealthReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageTextEnrichmentHealthCopyWith<$Res>? get messageTextEnrichment {
    if (_self.messageTextEnrichment == null) {
    return null;
  }

  return $MessageTextEnrichmentHealthCopyWith<$Res>(_self.messageTextEnrichment!, (value) {
    return _then(_self.copyWith(messageTextEnrichment: value));
  });
}/// Create a copy of DatabaseHealthReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthReportSummaryCopyWith<$Res> get summary {
  
  return $HealthReportSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// Adds pattern-matching-related methods to [DatabaseHealthReport].
extension DatabaseHealthReportPatterns on DatabaseHealthReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DatabaseHealthReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DatabaseHealthReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DatabaseHealthReport value)  $default,){
final _that = this;
switch (_that) {
case _DatabaseHealthReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DatabaseHealthReport value)?  $default,){
final _that = this;
switch (_that) {
case _DatabaseHealthReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String schemaVersion,  String generatedAt,  String auditVersion,  DatabaseHealthAppInfo app,  DatabaseHealthEnvironmentInfo environment,  List<AuditedDatabaseInfo> databases,  List<TableInventoryEntry> tableInventory,  List<RelationshipCheckResult> relationshipChecks,  List<InvariantCheckResult> invariantChecks,  MessageTextEnrichmentHealth? messageTextEnrichment,  HealthReportSummary summary,  List<HealthReportError> errors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DatabaseHealthReport() when $default != null:
return $default(_that.schemaVersion,_that.generatedAt,_that.auditVersion,_that.app,_that.environment,_that.databases,_that.tableInventory,_that.relationshipChecks,_that.invariantChecks,_that.messageTextEnrichment,_that.summary,_that.errors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String schemaVersion,  String generatedAt,  String auditVersion,  DatabaseHealthAppInfo app,  DatabaseHealthEnvironmentInfo environment,  List<AuditedDatabaseInfo> databases,  List<TableInventoryEntry> tableInventory,  List<RelationshipCheckResult> relationshipChecks,  List<InvariantCheckResult> invariantChecks,  MessageTextEnrichmentHealth? messageTextEnrichment,  HealthReportSummary summary,  List<HealthReportError> errors)  $default,) {final _that = this;
switch (_that) {
case _DatabaseHealthReport():
return $default(_that.schemaVersion,_that.generatedAt,_that.auditVersion,_that.app,_that.environment,_that.databases,_that.tableInventory,_that.relationshipChecks,_that.invariantChecks,_that.messageTextEnrichment,_that.summary,_that.errors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String schemaVersion,  String generatedAt,  String auditVersion,  DatabaseHealthAppInfo app,  DatabaseHealthEnvironmentInfo environment,  List<AuditedDatabaseInfo> databases,  List<TableInventoryEntry> tableInventory,  List<RelationshipCheckResult> relationshipChecks,  List<InvariantCheckResult> invariantChecks,  MessageTextEnrichmentHealth? messageTextEnrichment,  HealthReportSummary summary,  List<HealthReportError> errors)?  $default,) {final _that = this;
switch (_that) {
case _DatabaseHealthReport() when $default != null:
return $default(_that.schemaVersion,_that.generatedAt,_that.auditVersion,_that.app,_that.environment,_that.databases,_that.tableInventory,_that.relationshipChecks,_that.invariantChecks,_that.messageTextEnrichment,_that.summary,_that.errors);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake, includeIfNull: false)
class _DatabaseHealthReport implements DatabaseHealthReport {
  const _DatabaseHealthReport({required this.schemaVersion, required this.generatedAt, required this.auditVersion, required this.app, required this.environment, required final  List<AuditedDatabaseInfo> databases, required final  List<TableInventoryEntry> tableInventory, required final  List<RelationshipCheckResult> relationshipChecks, required final  List<InvariantCheckResult> invariantChecks, this.messageTextEnrichment, required this.summary, final  List<HealthReportError> errors = const <HealthReportError>[]}): _databases = databases,_tableInventory = tableInventory,_relationshipChecks = relationshipChecks,_invariantChecks = invariantChecks,_errors = errors;
  factory _DatabaseHealthReport.fromJson(Map<String, dynamic> json) => _$DatabaseHealthReportFromJson(json);

@override final  String schemaVersion;
@override final  String generatedAt;
@override final  String auditVersion;
@override final  DatabaseHealthAppInfo app;
@override final  DatabaseHealthEnvironmentInfo environment;
 final  List<AuditedDatabaseInfo> _databases;
@override List<AuditedDatabaseInfo> get databases {
  if (_databases is EqualUnmodifiableListView) return _databases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_databases);
}

 final  List<TableInventoryEntry> _tableInventory;
@override List<TableInventoryEntry> get tableInventory {
  if (_tableInventory is EqualUnmodifiableListView) return _tableInventory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tableInventory);
}

 final  List<RelationshipCheckResult> _relationshipChecks;
@override List<RelationshipCheckResult> get relationshipChecks {
  if (_relationshipChecks is EqualUnmodifiableListView) return _relationshipChecks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_relationshipChecks);
}

 final  List<InvariantCheckResult> _invariantChecks;
@override List<InvariantCheckResult> get invariantChecks {
  if (_invariantChecks is EqualUnmodifiableListView) return _invariantChecks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_invariantChecks);
}

@override final  MessageTextEnrichmentHealth? messageTextEnrichment;
@override final  HealthReportSummary summary;
 final  List<HealthReportError> _errors;
@override@JsonKey() List<HealthReportError> get errors {
  if (_errors is EqualUnmodifiableListView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_errors);
}


/// Create a copy of DatabaseHealthReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DatabaseHealthReportCopyWith<_DatabaseHealthReport> get copyWith => __$DatabaseHealthReportCopyWithImpl<_DatabaseHealthReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DatabaseHealthReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DatabaseHealthReport&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.auditVersion, auditVersion) || other.auditVersion == auditVersion)&&(identical(other.app, app) || other.app == app)&&(identical(other.environment, environment) || other.environment == environment)&&const DeepCollectionEquality().equals(other._databases, _databases)&&const DeepCollectionEquality().equals(other._tableInventory, _tableInventory)&&const DeepCollectionEquality().equals(other._relationshipChecks, _relationshipChecks)&&const DeepCollectionEquality().equals(other._invariantChecks, _invariantChecks)&&(identical(other.messageTextEnrichment, messageTextEnrichment) || other.messageTextEnrichment == messageTextEnrichment)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._errors, _errors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,generatedAt,auditVersion,app,environment,const DeepCollectionEquality().hash(_databases),const DeepCollectionEquality().hash(_tableInventory),const DeepCollectionEquality().hash(_relationshipChecks),const DeepCollectionEquality().hash(_invariantChecks),messageTextEnrichment,summary,const DeepCollectionEquality().hash(_errors));

@override
String toString() {
  return 'DatabaseHealthReport(schemaVersion: $schemaVersion, generatedAt: $generatedAt, auditVersion: $auditVersion, app: $app, environment: $environment, databases: $databases, tableInventory: $tableInventory, relationshipChecks: $relationshipChecks, invariantChecks: $invariantChecks, messageTextEnrichment: $messageTextEnrichment, summary: $summary, errors: $errors)';
}


}

/// @nodoc
abstract mixin class _$DatabaseHealthReportCopyWith<$Res> implements $DatabaseHealthReportCopyWith<$Res> {
  factory _$DatabaseHealthReportCopyWith(_DatabaseHealthReport value, $Res Function(_DatabaseHealthReport) _then) = __$DatabaseHealthReportCopyWithImpl;
@override @useResult
$Res call({
 String schemaVersion, String generatedAt, String auditVersion, DatabaseHealthAppInfo app, DatabaseHealthEnvironmentInfo environment, List<AuditedDatabaseInfo> databases, List<TableInventoryEntry> tableInventory, List<RelationshipCheckResult> relationshipChecks, List<InvariantCheckResult> invariantChecks, MessageTextEnrichmentHealth? messageTextEnrichment, HealthReportSummary summary, List<HealthReportError> errors
});


@override $DatabaseHealthAppInfoCopyWith<$Res> get app;@override $DatabaseHealthEnvironmentInfoCopyWith<$Res> get environment;@override $MessageTextEnrichmentHealthCopyWith<$Res>? get messageTextEnrichment;@override $HealthReportSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class __$DatabaseHealthReportCopyWithImpl<$Res>
    implements _$DatabaseHealthReportCopyWith<$Res> {
  __$DatabaseHealthReportCopyWithImpl(this._self, this._then);

  final _DatabaseHealthReport _self;
  final $Res Function(_DatabaseHealthReport) _then;

/// Create a copy of DatabaseHealthReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? generatedAt = null,Object? auditVersion = null,Object? app = null,Object? environment = null,Object? databases = null,Object? tableInventory = null,Object? relationshipChecks = null,Object? invariantChecks = null,Object? messageTextEnrichment = freezed,Object? summary = null,Object? errors = null,}) {
  return _then(_DatabaseHealthReport(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as String,auditVersion: null == auditVersion ? _self.auditVersion : auditVersion // ignore: cast_nullable_to_non_nullable
as String,app: null == app ? _self.app : app // ignore: cast_nullable_to_non_nullable
as DatabaseHealthAppInfo,environment: null == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as DatabaseHealthEnvironmentInfo,databases: null == databases ? _self._databases : databases // ignore: cast_nullable_to_non_nullable
as List<AuditedDatabaseInfo>,tableInventory: null == tableInventory ? _self._tableInventory : tableInventory // ignore: cast_nullable_to_non_nullable
as List<TableInventoryEntry>,relationshipChecks: null == relationshipChecks ? _self._relationshipChecks : relationshipChecks // ignore: cast_nullable_to_non_nullable
as List<RelationshipCheckResult>,invariantChecks: null == invariantChecks ? _self._invariantChecks : invariantChecks // ignore: cast_nullable_to_non_nullable
as List<InvariantCheckResult>,messageTextEnrichment: freezed == messageTextEnrichment ? _self.messageTextEnrichment : messageTextEnrichment // ignore: cast_nullable_to_non_nullable
as MessageTextEnrichmentHealth?,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as HealthReportSummary,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as List<HealthReportError>,
  ));
}

/// Create a copy of DatabaseHealthReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DatabaseHealthAppInfoCopyWith<$Res> get app {
  
  return $DatabaseHealthAppInfoCopyWith<$Res>(_self.app, (value) {
    return _then(_self.copyWith(app: value));
  });
}/// Create a copy of DatabaseHealthReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DatabaseHealthEnvironmentInfoCopyWith<$Res> get environment {
  
  return $DatabaseHealthEnvironmentInfoCopyWith<$Res>(_self.environment, (value) {
    return _then(_self.copyWith(environment: value));
  });
}/// Create a copy of DatabaseHealthReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageTextEnrichmentHealthCopyWith<$Res>? get messageTextEnrichment {
    if (_self.messageTextEnrichment == null) {
    return null;
  }

  return $MessageTextEnrichmentHealthCopyWith<$Res>(_self.messageTextEnrichment!, (value) {
    return _then(_self.copyWith(messageTextEnrichment: value));
  });
}/// Create a copy of DatabaseHealthReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthReportSummaryCopyWith<$Res> get summary {
  
  return $HealthReportSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// @nodoc
mixin _$MessageTextEnrichmentHealth {

 int get remainingCandidateCount; int get totalAttributedBodyBytes; int get maximumAttributedBodyBytes;
/// Create a copy of MessageTextEnrichmentHealth
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageTextEnrichmentHealthCopyWith<MessageTextEnrichmentHealth> get copyWith => _$MessageTextEnrichmentHealthCopyWithImpl<MessageTextEnrichmentHealth>(this as MessageTextEnrichmentHealth, _$identity);

  /// Serializes this MessageTextEnrichmentHealth to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageTextEnrichmentHealth&&(identical(other.remainingCandidateCount, remainingCandidateCount) || other.remainingCandidateCount == remainingCandidateCount)&&(identical(other.totalAttributedBodyBytes, totalAttributedBodyBytes) || other.totalAttributedBodyBytes == totalAttributedBodyBytes)&&(identical(other.maximumAttributedBodyBytes, maximumAttributedBodyBytes) || other.maximumAttributedBodyBytes == maximumAttributedBodyBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,remainingCandidateCount,totalAttributedBodyBytes,maximumAttributedBodyBytes);

@override
String toString() {
  return 'MessageTextEnrichmentHealth(remainingCandidateCount: $remainingCandidateCount, totalAttributedBodyBytes: $totalAttributedBodyBytes, maximumAttributedBodyBytes: $maximumAttributedBodyBytes)';
}


}

/// @nodoc
abstract mixin class $MessageTextEnrichmentHealthCopyWith<$Res>  {
  factory $MessageTextEnrichmentHealthCopyWith(MessageTextEnrichmentHealth value, $Res Function(MessageTextEnrichmentHealth) _then) = _$MessageTextEnrichmentHealthCopyWithImpl;
@useResult
$Res call({
 int remainingCandidateCount, int totalAttributedBodyBytes, int maximumAttributedBodyBytes
});




}
/// @nodoc
class _$MessageTextEnrichmentHealthCopyWithImpl<$Res>
    implements $MessageTextEnrichmentHealthCopyWith<$Res> {
  _$MessageTextEnrichmentHealthCopyWithImpl(this._self, this._then);

  final MessageTextEnrichmentHealth _self;
  final $Res Function(MessageTextEnrichmentHealth) _then;

/// Create a copy of MessageTextEnrichmentHealth
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? remainingCandidateCount = null,Object? totalAttributedBodyBytes = null,Object? maximumAttributedBodyBytes = null,}) {
  return _then(_self.copyWith(
remainingCandidateCount: null == remainingCandidateCount ? _self.remainingCandidateCount : remainingCandidateCount // ignore: cast_nullable_to_non_nullable
as int,totalAttributedBodyBytes: null == totalAttributedBodyBytes ? _self.totalAttributedBodyBytes : totalAttributedBodyBytes // ignore: cast_nullable_to_non_nullable
as int,maximumAttributedBodyBytes: null == maximumAttributedBodyBytes ? _self.maximumAttributedBodyBytes : maximumAttributedBodyBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageTextEnrichmentHealth].
extension MessageTextEnrichmentHealthPatterns on MessageTextEnrichmentHealth {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageTextEnrichmentHealth value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageTextEnrichmentHealth() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageTextEnrichmentHealth value)  $default,){
final _that = this;
switch (_that) {
case _MessageTextEnrichmentHealth():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageTextEnrichmentHealth value)?  $default,){
final _that = this;
switch (_that) {
case _MessageTextEnrichmentHealth() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int remainingCandidateCount,  int totalAttributedBodyBytes,  int maximumAttributedBodyBytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageTextEnrichmentHealth() when $default != null:
return $default(_that.remainingCandidateCount,_that.totalAttributedBodyBytes,_that.maximumAttributedBodyBytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int remainingCandidateCount,  int totalAttributedBodyBytes,  int maximumAttributedBodyBytes)  $default,) {final _that = this;
switch (_that) {
case _MessageTextEnrichmentHealth():
return $default(_that.remainingCandidateCount,_that.totalAttributedBodyBytes,_that.maximumAttributedBodyBytes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int remainingCandidateCount,  int totalAttributedBodyBytes,  int maximumAttributedBodyBytes)?  $default,) {final _that = this;
switch (_that) {
case _MessageTextEnrichmentHealth() when $default != null:
return $default(_that.remainingCandidateCount,_that.totalAttributedBodyBytes,_that.maximumAttributedBodyBytes);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MessageTextEnrichmentHealth implements MessageTextEnrichmentHealth {
  const _MessageTextEnrichmentHealth({required this.remainingCandidateCount, required this.totalAttributedBodyBytes, required this.maximumAttributedBodyBytes});
  factory _MessageTextEnrichmentHealth.fromJson(Map<String, dynamic> json) => _$MessageTextEnrichmentHealthFromJson(json);

@override final  int remainingCandidateCount;
@override final  int totalAttributedBodyBytes;
@override final  int maximumAttributedBodyBytes;

/// Create a copy of MessageTextEnrichmentHealth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageTextEnrichmentHealthCopyWith<_MessageTextEnrichmentHealth> get copyWith => __$MessageTextEnrichmentHealthCopyWithImpl<_MessageTextEnrichmentHealth>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageTextEnrichmentHealthToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageTextEnrichmentHealth&&(identical(other.remainingCandidateCount, remainingCandidateCount) || other.remainingCandidateCount == remainingCandidateCount)&&(identical(other.totalAttributedBodyBytes, totalAttributedBodyBytes) || other.totalAttributedBodyBytes == totalAttributedBodyBytes)&&(identical(other.maximumAttributedBodyBytes, maximumAttributedBodyBytes) || other.maximumAttributedBodyBytes == maximumAttributedBodyBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,remainingCandidateCount,totalAttributedBodyBytes,maximumAttributedBodyBytes);

@override
String toString() {
  return 'MessageTextEnrichmentHealth(remainingCandidateCount: $remainingCandidateCount, totalAttributedBodyBytes: $totalAttributedBodyBytes, maximumAttributedBodyBytes: $maximumAttributedBodyBytes)';
}


}

/// @nodoc
abstract mixin class _$MessageTextEnrichmentHealthCopyWith<$Res> implements $MessageTextEnrichmentHealthCopyWith<$Res> {
  factory _$MessageTextEnrichmentHealthCopyWith(_MessageTextEnrichmentHealth value, $Res Function(_MessageTextEnrichmentHealth) _then) = __$MessageTextEnrichmentHealthCopyWithImpl;
@override @useResult
$Res call({
 int remainingCandidateCount, int totalAttributedBodyBytes, int maximumAttributedBodyBytes
});




}
/// @nodoc
class __$MessageTextEnrichmentHealthCopyWithImpl<$Res>
    implements _$MessageTextEnrichmentHealthCopyWith<$Res> {
  __$MessageTextEnrichmentHealthCopyWithImpl(this._self, this._then);

  final _MessageTextEnrichmentHealth _self;
  final $Res Function(_MessageTextEnrichmentHealth) _then;

/// Create a copy of MessageTextEnrichmentHealth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? remainingCandidateCount = null,Object? totalAttributedBodyBytes = null,Object? maximumAttributedBodyBytes = null,}) {
  return _then(_MessageTextEnrichmentHealth(
remainingCandidateCount: null == remainingCandidateCount ? _self.remainingCandidateCount : remainingCandidateCount // ignore: cast_nullable_to_non_nullable
as int,totalAttributedBodyBytes: null == totalAttributedBodyBytes ? _self.totalAttributedBodyBytes : totalAttributedBodyBytes // ignore: cast_nullable_to_non_nullable
as int,maximumAttributedBodyBytes: null == maximumAttributedBodyBytes ? _self.maximumAttributedBodyBytes : maximumAttributedBodyBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$DatabaseHealthAppInfo {

 String get name; String get bundleId; String get version; String? get buildNumber; String? get buildChannel;
/// Create a copy of DatabaseHealthAppInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DatabaseHealthAppInfoCopyWith<DatabaseHealthAppInfo> get copyWith => _$DatabaseHealthAppInfoCopyWithImpl<DatabaseHealthAppInfo>(this as DatabaseHealthAppInfo, _$identity);

  /// Serializes this DatabaseHealthAppInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DatabaseHealthAppInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.bundleId, bundleId) || other.bundleId == bundleId)&&(identical(other.version, version) || other.version == version)&&(identical(other.buildNumber, buildNumber) || other.buildNumber == buildNumber)&&(identical(other.buildChannel, buildChannel) || other.buildChannel == buildChannel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,bundleId,version,buildNumber,buildChannel);

@override
String toString() {
  return 'DatabaseHealthAppInfo(name: $name, bundleId: $bundleId, version: $version, buildNumber: $buildNumber, buildChannel: $buildChannel)';
}


}

/// @nodoc
abstract mixin class $DatabaseHealthAppInfoCopyWith<$Res>  {
  factory $DatabaseHealthAppInfoCopyWith(DatabaseHealthAppInfo value, $Res Function(DatabaseHealthAppInfo) _then) = _$DatabaseHealthAppInfoCopyWithImpl;
@useResult
$Res call({
 String name, String bundleId, String version, String? buildNumber, String? buildChannel
});




}
/// @nodoc
class _$DatabaseHealthAppInfoCopyWithImpl<$Res>
    implements $DatabaseHealthAppInfoCopyWith<$Res> {
  _$DatabaseHealthAppInfoCopyWithImpl(this._self, this._then);

  final DatabaseHealthAppInfo _self;
  final $Res Function(DatabaseHealthAppInfo) _then;

/// Create a copy of DatabaseHealthAppInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? bundleId = null,Object? version = null,Object? buildNumber = freezed,Object? buildChannel = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,bundleId: null == bundleId ? _self.bundleId : bundleId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,buildNumber: freezed == buildNumber ? _self.buildNumber : buildNumber // ignore: cast_nullable_to_non_nullable
as String?,buildChannel: freezed == buildChannel ? _self.buildChannel : buildChannel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DatabaseHealthAppInfo].
extension DatabaseHealthAppInfoPatterns on DatabaseHealthAppInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DatabaseHealthAppInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DatabaseHealthAppInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DatabaseHealthAppInfo value)  $default,){
final _that = this;
switch (_that) {
case _DatabaseHealthAppInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DatabaseHealthAppInfo value)?  $default,){
final _that = this;
switch (_that) {
case _DatabaseHealthAppInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String bundleId,  String version,  String? buildNumber,  String? buildChannel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DatabaseHealthAppInfo() when $default != null:
return $default(_that.name,_that.bundleId,_that.version,_that.buildNumber,_that.buildChannel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String bundleId,  String version,  String? buildNumber,  String? buildChannel)  $default,) {final _that = this;
switch (_that) {
case _DatabaseHealthAppInfo():
return $default(_that.name,_that.bundleId,_that.version,_that.buildNumber,_that.buildChannel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String bundleId,  String version,  String? buildNumber,  String? buildChannel)?  $default,) {final _that = this;
switch (_that) {
case _DatabaseHealthAppInfo() when $default != null:
return $default(_that.name,_that.bundleId,_that.version,_that.buildNumber,_that.buildChannel);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class _DatabaseHealthAppInfo implements DatabaseHealthAppInfo {
  const _DatabaseHealthAppInfo({required this.name, required this.bundleId, required this.version, this.buildNumber, this.buildChannel});
  factory _DatabaseHealthAppInfo.fromJson(Map<String, dynamic> json) => _$DatabaseHealthAppInfoFromJson(json);

@override final  String name;
@override final  String bundleId;
@override final  String version;
@override final  String? buildNumber;
@override final  String? buildChannel;

/// Create a copy of DatabaseHealthAppInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DatabaseHealthAppInfoCopyWith<_DatabaseHealthAppInfo> get copyWith => __$DatabaseHealthAppInfoCopyWithImpl<_DatabaseHealthAppInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DatabaseHealthAppInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DatabaseHealthAppInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.bundleId, bundleId) || other.bundleId == bundleId)&&(identical(other.version, version) || other.version == version)&&(identical(other.buildNumber, buildNumber) || other.buildNumber == buildNumber)&&(identical(other.buildChannel, buildChannel) || other.buildChannel == buildChannel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,bundleId,version,buildNumber,buildChannel);

@override
String toString() {
  return 'DatabaseHealthAppInfo(name: $name, bundleId: $bundleId, version: $version, buildNumber: $buildNumber, buildChannel: $buildChannel)';
}


}

/// @nodoc
abstract mixin class _$DatabaseHealthAppInfoCopyWith<$Res> implements $DatabaseHealthAppInfoCopyWith<$Res> {
  factory _$DatabaseHealthAppInfoCopyWith(_DatabaseHealthAppInfo value, $Res Function(_DatabaseHealthAppInfo) _then) = __$DatabaseHealthAppInfoCopyWithImpl;
@override @useResult
$Res call({
 String name, String bundleId, String version, String? buildNumber, String? buildChannel
});




}
/// @nodoc
class __$DatabaseHealthAppInfoCopyWithImpl<$Res>
    implements _$DatabaseHealthAppInfoCopyWith<$Res> {
  __$DatabaseHealthAppInfoCopyWithImpl(this._self, this._then);

  final _DatabaseHealthAppInfo _self;
  final $Res Function(_DatabaseHealthAppInfo) _then;

/// Create a copy of DatabaseHealthAppInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? bundleId = null,Object? version = null,Object? buildNumber = freezed,Object? buildChannel = freezed,}) {
  return _then(_DatabaseHealthAppInfo(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,bundleId: null == bundleId ? _self.bundleId : bundleId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,buildNumber: freezed == buildNumber ? _self.buildNumber : buildNumber // ignore: cast_nullable_to_non_nullable
as String?,buildChannel: freezed == buildChannel ? _self.buildChannel : buildChannel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DatabaseHealthEnvironmentInfo {

 String get platform; String? get platformVersion; String? get deviceModel; String? get timezone; bool? get hasFullDiskAccess; Map<String, dynamic>? get startupFlags; List<String> get diagnosticNotes;
/// Create a copy of DatabaseHealthEnvironmentInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DatabaseHealthEnvironmentInfoCopyWith<DatabaseHealthEnvironmentInfo> get copyWith => _$DatabaseHealthEnvironmentInfoCopyWithImpl<DatabaseHealthEnvironmentInfo>(this as DatabaseHealthEnvironmentInfo, _$identity);

  /// Serializes this DatabaseHealthEnvironmentInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DatabaseHealthEnvironmentInfo&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.platformVersion, platformVersion) || other.platformVersion == platformVersion)&&(identical(other.deviceModel, deviceModel) || other.deviceModel == deviceModel)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.hasFullDiskAccess, hasFullDiskAccess) || other.hasFullDiskAccess == hasFullDiskAccess)&&const DeepCollectionEquality().equals(other.startupFlags, startupFlags)&&const DeepCollectionEquality().equals(other.diagnosticNotes, diagnosticNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,platformVersion,deviceModel,timezone,hasFullDiskAccess,const DeepCollectionEquality().hash(startupFlags),const DeepCollectionEquality().hash(diagnosticNotes));

@override
String toString() {
  return 'DatabaseHealthEnvironmentInfo(platform: $platform, platformVersion: $platformVersion, deviceModel: $deviceModel, timezone: $timezone, hasFullDiskAccess: $hasFullDiskAccess, startupFlags: $startupFlags, diagnosticNotes: $diagnosticNotes)';
}


}

/// @nodoc
abstract mixin class $DatabaseHealthEnvironmentInfoCopyWith<$Res>  {
  factory $DatabaseHealthEnvironmentInfoCopyWith(DatabaseHealthEnvironmentInfo value, $Res Function(DatabaseHealthEnvironmentInfo) _then) = _$DatabaseHealthEnvironmentInfoCopyWithImpl;
@useResult
$Res call({
 String platform, String? platformVersion, String? deviceModel, String? timezone, bool? hasFullDiskAccess, Map<String, dynamic>? startupFlags, List<String> diagnosticNotes
});




}
/// @nodoc
class _$DatabaseHealthEnvironmentInfoCopyWithImpl<$Res>
    implements $DatabaseHealthEnvironmentInfoCopyWith<$Res> {
  _$DatabaseHealthEnvironmentInfoCopyWithImpl(this._self, this._then);

  final DatabaseHealthEnvironmentInfo _self;
  final $Res Function(DatabaseHealthEnvironmentInfo) _then;

/// Create a copy of DatabaseHealthEnvironmentInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platform = null,Object? platformVersion = freezed,Object? deviceModel = freezed,Object? timezone = freezed,Object? hasFullDiskAccess = freezed,Object? startupFlags = freezed,Object? diagnosticNotes = null,}) {
  return _then(_self.copyWith(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,platformVersion: freezed == platformVersion ? _self.platformVersion : platformVersion // ignore: cast_nullable_to_non_nullable
as String?,deviceModel: freezed == deviceModel ? _self.deviceModel : deviceModel // ignore: cast_nullable_to_non_nullable
as String?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,hasFullDiskAccess: freezed == hasFullDiskAccess ? _self.hasFullDiskAccess : hasFullDiskAccess // ignore: cast_nullable_to_non_nullable
as bool?,startupFlags: freezed == startupFlags ? _self.startupFlags : startupFlags // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,diagnosticNotes: null == diagnosticNotes ? _self.diagnosticNotes : diagnosticNotes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [DatabaseHealthEnvironmentInfo].
extension DatabaseHealthEnvironmentInfoPatterns on DatabaseHealthEnvironmentInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DatabaseHealthEnvironmentInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DatabaseHealthEnvironmentInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DatabaseHealthEnvironmentInfo value)  $default,){
final _that = this;
switch (_that) {
case _DatabaseHealthEnvironmentInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DatabaseHealthEnvironmentInfo value)?  $default,){
final _that = this;
switch (_that) {
case _DatabaseHealthEnvironmentInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String platform,  String? platformVersion,  String? deviceModel,  String? timezone,  bool? hasFullDiskAccess,  Map<String, dynamic>? startupFlags,  List<String> diagnosticNotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DatabaseHealthEnvironmentInfo() when $default != null:
return $default(_that.platform,_that.platformVersion,_that.deviceModel,_that.timezone,_that.hasFullDiskAccess,_that.startupFlags,_that.diagnosticNotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String platform,  String? platformVersion,  String? deviceModel,  String? timezone,  bool? hasFullDiskAccess,  Map<String, dynamic>? startupFlags,  List<String> diagnosticNotes)  $default,) {final _that = this;
switch (_that) {
case _DatabaseHealthEnvironmentInfo():
return $default(_that.platform,_that.platformVersion,_that.deviceModel,_that.timezone,_that.hasFullDiskAccess,_that.startupFlags,_that.diagnosticNotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String platform,  String? platformVersion,  String? deviceModel,  String? timezone,  bool? hasFullDiskAccess,  Map<String, dynamic>? startupFlags,  List<String> diagnosticNotes)?  $default,) {final _that = this;
switch (_that) {
case _DatabaseHealthEnvironmentInfo() when $default != null:
return $default(_that.platform,_that.platformVersion,_that.deviceModel,_that.timezone,_that.hasFullDiskAccess,_that.startupFlags,_that.diagnosticNotes);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake, includeIfNull: false)
class _DatabaseHealthEnvironmentInfo implements DatabaseHealthEnvironmentInfo {
  const _DatabaseHealthEnvironmentInfo({required this.platform, this.platformVersion, this.deviceModel, this.timezone, this.hasFullDiskAccess, final  Map<String, dynamic>? startupFlags, final  List<String> diagnosticNotes = const <String>[]}): _startupFlags = startupFlags,_diagnosticNotes = diagnosticNotes;
  factory _DatabaseHealthEnvironmentInfo.fromJson(Map<String, dynamic> json) => _$DatabaseHealthEnvironmentInfoFromJson(json);

@override final  String platform;
@override final  String? platformVersion;
@override final  String? deviceModel;
@override final  String? timezone;
@override final  bool? hasFullDiskAccess;
 final  Map<String, dynamic>? _startupFlags;
@override Map<String, dynamic>? get startupFlags {
  final value = _startupFlags;
  if (value == null) return null;
  if (_startupFlags is EqualUnmodifiableMapView) return _startupFlags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<String> _diagnosticNotes;
@override@JsonKey() List<String> get diagnosticNotes {
  if (_diagnosticNotes is EqualUnmodifiableListView) return _diagnosticNotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_diagnosticNotes);
}


/// Create a copy of DatabaseHealthEnvironmentInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DatabaseHealthEnvironmentInfoCopyWith<_DatabaseHealthEnvironmentInfo> get copyWith => __$DatabaseHealthEnvironmentInfoCopyWithImpl<_DatabaseHealthEnvironmentInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DatabaseHealthEnvironmentInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DatabaseHealthEnvironmentInfo&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.platformVersion, platformVersion) || other.platformVersion == platformVersion)&&(identical(other.deviceModel, deviceModel) || other.deviceModel == deviceModel)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.hasFullDiskAccess, hasFullDiskAccess) || other.hasFullDiskAccess == hasFullDiskAccess)&&const DeepCollectionEquality().equals(other._startupFlags, _startupFlags)&&const DeepCollectionEquality().equals(other._diagnosticNotes, _diagnosticNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,platformVersion,deviceModel,timezone,hasFullDiskAccess,const DeepCollectionEquality().hash(_startupFlags),const DeepCollectionEquality().hash(_diagnosticNotes));

@override
String toString() {
  return 'DatabaseHealthEnvironmentInfo(platform: $platform, platformVersion: $platformVersion, deviceModel: $deviceModel, timezone: $timezone, hasFullDiskAccess: $hasFullDiskAccess, startupFlags: $startupFlags, diagnosticNotes: $diagnosticNotes)';
}


}

/// @nodoc
abstract mixin class _$DatabaseHealthEnvironmentInfoCopyWith<$Res> implements $DatabaseHealthEnvironmentInfoCopyWith<$Res> {
  factory _$DatabaseHealthEnvironmentInfoCopyWith(_DatabaseHealthEnvironmentInfo value, $Res Function(_DatabaseHealthEnvironmentInfo) _then) = __$DatabaseHealthEnvironmentInfoCopyWithImpl;
@override @useResult
$Res call({
 String platform, String? platformVersion, String? deviceModel, String? timezone, bool? hasFullDiskAccess, Map<String, dynamic>? startupFlags, List<String> diagnosticNotes
});




}
/// @nodoc
class __$DatabaseHealthEnvironmentInfoCopyWithImpl<$Res>
    implements _$DatabaseHealthEnvironmentInfoCopyWith<$Res> {
  __$DatabaseHealthEnvironmentInfoCopyWithImpl(this._self, this._then);

  final _DatabaseHealthEnvironmentInfo _self;
  final $Res Function(_DatabaseHealthEnvironmentInfo) _then;

/// Create a copy of DatabaseHealthEnvironmentInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = null,Object? platformVersion = freezed,Object? deviceModel = freezed,Object? timezone = freezed,Object? hasFullDiskAccess = freezed,Object? startupFlags = freezed,Object? diagnosticNotes = null,}) {
  return _then(_DatabaseHealthEnvironmentInfo(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,platformVersion: freezed == platformVersion ? _self.platformVersion : platformVersion // ignore: cast_nullable_to_non_nullable
as String?,deviceModel: freezed == deviceModel ? _self.deviceModel : deviceModel // ignore: cast_nullable_to_non_nullable
as String?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,hasFullDiskAccess: freezed == hasFullDiskAccess ? _self.hasFullDiskAccess : hasFullDiskAccess // ignore: cast_nullable_to_non_nullable
as bool?,startupFlags: freezed == startupFlags ? _self._startupFlags : startupFlags // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,diagnosticNotes: null == diagnosticNotes ? _self._diagnosticNotes : diagnosticNotes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$AuditedDatabaseInfo {

 String get databaseKey; String get role; bool get accessible; bool get readOnlyOpenSucceeded; int? get schemaUserVersion; Object? get migrationVersion; String? get error;
/// Create a copy of AuditedDatabaseInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditedDatabaseInfoCopyWith<AuditedDatabaseInfo> get copyWith => _$AuditedDatabaseInfoCopyWithImpl<AuditedDatabaseInfo>(this as AuditedDatabaseInfo, _$identity);

  /// Serializes this AuditedDatabaseInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditedDatabaseInfo&&(identical(other.databaseKey, databaseKey) || other.databaseKey == databaseKey)&&(identical(other.role, role) || other.role == role)&&(identical(other.accessible, accessible) || other.accessible == accessible)&&(identical(other.readOnlyOpenSucceeded, readOnlyOpenSucceeded) || other.readOnlyOpenSucceeded == readOnlyOpenSucceeded)&&(identical(other.schemaUserVersion, schemaUserVersion) || other.schemaUserVersion == schemaUserVersion)&&const DeepCollectionEquality().equals(other.migrationVersion, migrationVersion)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,databaseKey,role,accessible,readOnlyOpenSucceeded,schemaUserVersion,const DeepCollectionEquality().hash(migrationVersion),error);

@override
String toString() {
  return 'AuditedDatabaseInfo(databaseKey: $databaseKey, role: $role, accessible: $accessible, readOnlyOpenSucceeded: $readOnlyOpenSucceeded, schemaUserVersion: $schemaUserVersion, migrationVersion: $migrationVersion, error: $error)';
}


}

/// @nodoc
abstract mixin class $AuditedDatabaseInfoCopyWith<$Res>  {
  factory $AuditedDatabaseInfoCopyWith(AuditedDatabaseInfo value, $Res Function(AuditedDatabaseInfo) _then) = _$AuditedDatabaseInfoCopyWithImpl;
@useResult
$Res call({
 String databaseKey, String role, bool accessible, bool readOnlyOpenSucceeded, int? schemaUserVersion, Object? migrationVersion, String? error
});




}
/// @nodoc
class _$AuditedDatabaseInfoCopyWithImpl<$Res>
    implements $AuditedDatabaseInfoCopyWith<$Res> {
  _$AuditedDatabaseInfoCopyWithImpl(this._self, this._then);

  final AuditedDatabaseInfo _self;
  final $Res Function(AuditedDatabaseInfo) _then;

/// Create a copy of AuditedDatabaseInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? databaseKey = null,Object? role = null,Object? accessible = null,Object? readOnlyOpenSucceeded = null,Object? schemaUserVersion = freezed,Object? migrationVersion = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
databaseKey: null == databaseKey ? _self.databaseKey : databaseKey // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,accessible: null == accessible ? _self.accessible : accessible // ignore: cast_nullable_to_non_nullable
as bool,readOnlyOpenSucceeded: null == readOnlyOpenSucceeded ? _self.readOnlyOpenSucceeded : readOnlyOpenSucceeded // ignore: cast_nullable_to_non_nullable
as bool,schemaUserVersion: freezed == schemaUserVersion ? _self.schemaUserVersion : schemaUserVersion // ignore: cast_nullable_to_non_nullable
as int?,migrationVersion: freezed == migrationVersion ? _self.migrationVersion : migrationVersion ,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuditedDatabaseInfo].
extension AuditedDatabaseInfoPatterns on AuditedDatabaseInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditedDatabaseInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditedDatabaseInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditedDatabaseInfo value)  $default,){
final _that = this;
switch (_that) {
case _AuditedDatabaseInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditedDatabaseInfo value)?  $default,){
final _that = this;
switch (_that) {
case _AuditedDatabaseInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String databaseKey,  String role,  bool accessible,  bool readOnlyOpenSucceeded,  int? schemaUserVersion,  Object? migrationVersion,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditedDatabaseInfo() when $default != null:
return $default(_that.databaseKey,_that.role,_that.accessible,_that.readOnlyOpenSucceeded,_that.schemaUserVersion,_that.migrationVersion,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String databaseKey,  String role,  bool accessible,  bool readOnlyOpenSucceeded,  int? schemaUserVersion,  Object? migrationVersion,  String? error)  $default,) {final _that = this;
switch (_that) {
case _AuditedDatabaseInfo():
return $default(_that.databaseKey,_that.role,_that.accessible,_that.readOnlyOpenSucceeded,_that.schemaUserVersion,_that.migrationVersion,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String databaseKey,  String role,  bool accessible,  bool readOnlyOpenSucceeded,  int? schemaUserVersion,  Object? migrationVersion,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _AuditedDatabaseInfo() when $default != null:
return $default(_that.databaseKey,_that.role,_that.accessible,_that.readOnlyOpenSucceeded,_that.schemaUserVersion,_that.migrationVersion,_that.error);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class _AuditedDatabaseInfo implements AuditedDatabaseInfo {
  const _AuditedDatabaseInfo({required this.databaseKey, required this.role, required this.accessible, required this.readOnlyOpenSucceeded, this.schemaUserVersion, this.migrationVersion, this.error});
  factory _AuditedDatabaseInfo.fromJson(Map<String, dynamic> json) => _$AuditedDatabaseInfoFromJson(json);

@override final  String databaseKey;
@override final  String role;
@override final  bool accessible;
@override final  bool readOnlyOpenSucceeded;
@override final  int? schemaUserVersion;
@override final  Object? migrationVersion;
@override final  String? error;

/// Create a copy of AuditedDatabaseInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditedDatabaseInfoCopyWith<_AuditedDatabaseInfo> get copyWith => __$AuditedDatabaseInfoCopyWithImpl<_AuditedDatabaseInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuditedDatabaseInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditedDatabaseInfo&&(identical(other.databaseKey, databaseKey) || other.databaseKey == databaseKey)&&(identical(other.role, role) || other.role == role)&&(identical(other.accessible, accessible) || other.accessible == accessible)&&(identical(other.readOnlyOpenSucceeded, readOnlyOpenSucceeded) || other.readOnlyOpenSucceeded == readOnlyOpenSucceeded)&&(identical(other.schemaUserVersion, schemaUserVersion) || other.schemaUserVersion == schemaUserVersion)&&const DeepCollectionEquality().equals(other.migrationVersion, migrationVersion)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,databaseKey,role,accessible,readOnlyOpenSucceeded,schemaUserVersion,const DeepCollectionEquality().hash(migrationVersion),error);

@override
String toString() {
  return 'AuditedDatabaseInfo(databaseKey: $databaseKey, role: $role, accessible: $accessible, readOnlyOpenSucceeded: $readOnlyOpenSucceeded, schemaUserVersion: $schemaUserVersion, migrationVersion: $migrationVersion, error: $error)';
}


}

/// @nodoc
abstract mixin class _$AuditedDatabaseInfoCopyWith<$Res> implements $AuditedDatabaseInfoCopyWith<$Res> {
  factory _$AuditedDatabaseInfoCopyWith(_AuditedDatabaseInfo value, $Res Function(_AuditedDatabaseInfo) _then) = __$AuditedDatabaseInfoCopyWithImpl;
@override @useResult
$Res call({
 String databaseKey, String role, bool accessible, bool readOnlyOpenSucceeded, int? schemaUserVersion, Object? migrationVersion, String? error
});




}
/// @nodoc
class __$AuditedDatabaseInfoCopyWithImpl<$Res>
    implements _$AuditedDatabaseInfoCopyWith<$Res> {
  __$AuditedDatabaseInfoCopyWithImpl(this._self, this._then);

  final _AuditedDatabaseInfo _self;
  final $Res Function(_AuditedDatabaseInfo) _then;

/// Create a copy of AuditedDatabaseInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? databaseKey = null,Object? role = null,Object? accessible = null,Object? readOnlyOpenSucceeded = null,Object? schemaUserVersion = freezed,Object? migrationVersion = freezed,Object? error = freezed,}) {
  return _then(_AuditedDatabaseInfo(
databaseKey: null == databaseKey ? _self.databaseKey : databaseKey // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,accessible: null == accessible ? _self.accessible : accessible // ignore: cast_nullable_to_non_nullable
as bool,readOnlyOpenSucceeded: null == readOnlyOpenSucceeded ? _self.readOnlyOpenSucceeded : readOnlyOpenSucceeded // ignore: cast_nullable_to_non_nullable
as bool,schemaUserVersion: freezed == schemaUserVersion ? _self.schemaUserVersion : schemaUserVersion // ignore: cast_nullable_to_non_nullable
as int?,migrationVersion: freezed == migrationVersion ? _self.migrationVersion : migrationVersion ,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TableInventoryEntry {

 String get databaseKey; String get tableName; bool get exists; int? get rowCount; DatabaseHealthPrimaryKeyInfo? get primaryKey; List<DatabaseHealthImportantColumnSummary> get importantColumns; List<String> get notes; String? get error;
/// Create a copy of TableInventoryEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TableInventoryEntryCopyWith<TableInventoryEntry> get copyWith => _$TableInventoryEntryCopyWithImpl<TableInventoryEntry>(this as TableInventoryEntry, _$identity);

  /// Serializes this TableInventoryEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TableInventoryEntry&&(identical(other.databaseKey, databaseKey) || other.databaseKey == databaseKey)&&(identical(other.tableName, tableName) || other.tableName == tableName)&&(identical(other.exists, exists) || other.exists == exists)&&(identical(other.rowCount, rowCount) || other.rowCount == rowCount)&&(identical(other.primaryKey, primaryKey) || other.primaryKey == primaryKey)&&const DeepCollectionEquality().equals(other.importantColumns, importantColumns)&&const DeepCollectionEquality().equals(other.notes, notes)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,databaseKey,tableName,exists,rowCount,primaryKey,const DeepCollectionEquality().hash(importantColumns),const DeepCollectionEquality().hash(notes),error);

@override
String toString() {
  return 'TableInventoryEntry(databaseKey: $databaseKey, tableName: $tableName, exists: $exists, rowCount: $rowCount, primaryKey: $primaryKey, importantColumns: $importantColumns, notes: $notes, error: $error)';
}


}

/// @nodoc
abstract mixin class $TableInventoryEntryCopyWith<$Res>  {
  factory $TableInventoryEntryCopyWith(TableInventoryEntry value, $Res Function(TableInventoryEntry) _then) = _$TableInventoryEntryCopyWithImpl;
@useResult
$Res call({
 String databaseKey, String tableName, bool exists, int? rowCount, DatabaseHealthPrimaryKeyInfo? primaryKey, List<DatabaseHealthImportantColumnSummary> importantColumns, List<String> notes, String? error
});


$DatabaseHealthPrimaryKeyInfoCopyWith<$Res>? get primaryKey;

}
/// @nodoc
class _$TableInventoryEntryCopyWithImpl<$Res>
    implements $TableInventoryEntryCopyWith<$Res> {
  _$TableInventoryEntryCopyWithImpl(this._self, this._then);

  final TableInventoryEntry _self;
  final $Res Function(TableInventoryEntry) _then;

/// Create a copy of TableInventoryEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? databaseKey = null,Object? tableName = null,Object? exists = null,Object? rowCount = freezed,Object? primaryKey = freezed,Object? importantColumns = null,Object? notes = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
databaseKey: null == databaseKey ? _self.databaseKey : databaseKey // ignore: cast_nullable_to_non_nullable
as String,tableName: null == tableName ? _self.tableName : tableName // ignore: cast_nullable_to_non_nullable
as String,exists: null == exists ? _self.exists : exists // ignore: cast_nullable_to_non_nullable
as bool,rowCount: freezed == rowCount ? _self.rowCount : rowCount // ignore: cast_nullable_to_non_nullable
as int?,primaryKey: freezed == primaryKey ? _self.primaryKey : primaryKey // ignore: cast_nullable_to_non_nullable
as DatabaseHealthPrimaryKeyInfo?,importantColumns: null == importantColumns ? _self.importantColumns : importantColumns // ignore: cast_nullable_to_non_nullable
as List<DatabaseHealthImportantColumnSummary>,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as List<String>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of TableInventoryEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DatabaseHealthPrimaryKeyInfoCopyWith<$Res>? get primaryKey {
    if (_self.primaryKey == null) {
    return null;
  }

  return $DatabaseHealthPrimaryKeyInfoCopyWith<$Res>(_self.primaryKey!, (value) {
    return _then(_self.copyWith(primaryKey: value));
  });
}
}


/// Adds pattern-matching-related methods to [TableInventoryEntry].
extension TableInventoryEntryPatterns on TableInventoryEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TableInventoryEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TableInventoryEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TableInventoryEntry value)  $default,){
final _that = this;
switch (_that) {
case _TableInventoryEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TableInventoryEntry value)?  $default,){
final _that = this;
switch (_that) {
case _TableInventoryEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String databaseKey,  String tableName,  bool exists,  int? rowCount,  DatabaseHealthPrimaryKeyInfo? primaryKey,  List<DatabaseHealthImportantColumnSummary> importantColumns,  List<String> notes,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TableInventoryEntry() when $default != null:
return $default(_that.databaseKey,_that.tableName,_that.exists,_that.rowCount,_that.primaryKey,_that.importantColumns,_that.notes,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String databaseKey,  String tableName,  bool exists,  int? rowCount,  DatabaseHealthPrimaryKeyInfo? primaryKey,  List<DatabaseHealthImportantColumnSummary> importantColumns,  List<String> notes,  String? error)  $default,) {final _that = this;
switch (_that) {
case _TableInventoryEntry():
return $default(_that.databaseKey,_that.tableName,_that.exists,_that.rowCount,_that.primaryKey,_that.importantColumns,_that.notes,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String databaseKey,  String tableName,  bool exists,  int? rowCount,  DatabaseHealthPrimaryKeyInfo? primaryKey,  List<DatabaseHealthImportantColumnSummary> importantColumns,  List<String> notes,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _TableInventoryEntry() when $default != null:
return $default(_that.databaseKey,_that.tableName,_that.exists,_that.rowCount,_that.primaryKey,_that.importantColumns,_that.notes,_that.error);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake, includeIfNull: false)
class _TableInventoryEntry implements TableInventoryEntry {
  const _TableInventoryEntry({required this.databaseKey, required this.tableName, required this.exists, this.rowCount, this.primaryKey, final  List<DatabaseHealthImportantColumnSummary> importantColumns = const <DatabaseHealthImportantColumnSummary>[], final  List<String> notes = const <String>[], this.error}): _importantColumns = importantColumns,_notes = notes;
  factory _TableInventoryEntry.fromJson(Map<String, dynamic> json) => _$TableInventoryEntryFromJson(json);

@override final  String databaseKey;
@override final  String tableName;
@override final  bool exists;
@override final  int? rowCount;
@override final  DatabaseHealthPrimaryKeyInfo? primaryKey;
 final  List<DatabaseHealthImportantColumnSummary> _importantColumns;
@override@JsonKey() List<DatabaseHealthImportantColumnSummary> get importantColumns {
  if (_importantColumns is EqualUnmodifiableListView) return _importantColumns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_importantColumns);
}

 final  List<String> _notes;
@override@JsonKey() List<String> get notes {
  if (_notes is EqualUnmodifiableListView) return _notes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notes);
}

@override final  String? error;

/// Create a copy of TableInventoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TableInventoryEntryCopyWith<_TableInventoryEntry> get copyWith => __$TableInventoryEntryCopyWithImpl<_TableInventoryEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TableInventoryEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TableInventoryEntry&&(identical(other.databaseKey, databaseKey) || other.databaseKey == databaseKey)&&(identical(other.tableName, tableName) || other.tableName == tableName)&&(identical(other.exists, exists) || other.exists == exists)&&(identical(other.rowCount, rowCount) || other.rowCount == rowCount)&&(identical(other.primaryKey, primaryKey) || other.primaryKey == primaryKey)&&const DeepCollectionEquality().equals(other._importantColumns, _importantColumns)&&const DeepCollectionEquality().equals(other._notes, _notes)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,databaseKey,tableName,exists,rowCount,primaryKey,const DeepCollectionEquality().hash(_importantColumns),const DeepCollectionEquality().hash(_notes),error);

@override
String toString() {
  return 'TableInventoryEntry(databaseKey: $databaseKey, tableName: $tableName, exists: $exists, rowCount: $rowCount, primaryKey: $primaryKey, importantColumns: $importantColumns, notes: $notes, error: $error)';
}


}

/// @nodoc
abstract mixin class _$TableInventoryEntryCopyWith<$Res> implements $TableInventoryEntryCopyWith<$Res> {
  factory _$TableInventoryEntryCopyWith(_TableInventoryEntry value, $Res Function(_TableInventoryEntry) _then) = __$TableInventoryEntryCopyWithImpl;
@override @useResult
$Res call({
 String databaseKey, String tableName, bool exists, int? rowCount, DatabaseHealthPrimaryKeyInfo? primaryKey, List<DatabaseHealthImportantColumnSummary> importantColumns, List<String> notes, String? error
});


@override $DatabaseHealthPrimaryKeyInfoCopyWith<$Res>? get primaryKey;

}
/// @nodoc
class __$TableInventoryEntryCopyWithImpl<$Res>
    implements _$TableInventoryEntryCopyWith<$Res> {
  __$TableInventoryEntryCopyWithImpl(this._self, this._then);

  final _TableInventoryEntry _self;
  final $Res Function(_TableInventoryEntry) _then;

/// Create a copy of TableInventoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? databaseKey = null,Object? tableName = null,Object? exists = null,Object? rowCount = freezed,Object? primaryKey = freezed,Object? importantColumns = null,Object? notes = null,Object? error = freezed,}) {
  return _then(_TableInventoryEntry(
databaseKey: null == databaseKey ? _self.databaseKey : databaseKey // ignore: cast_nullable_to_non_nullable
as String,tableName: null == tableName ? _self.tableName : tableName // ignore: cast_nullable_to_non_nullable
as String,exists: null == exists ? _self.exists : exists // ignore: cast_nullable_to_non_nullable
as bool,rowCount: freezed == rowCount ? _self.rowCount : rowCount // ignore: cast_nullable_to_non_nullable
as int?,primaryKey: freezed == primaryKey ? _self.primaryKey : primaryKey // ignore: cast_nullable_to_non_nullable
as DatabaseHealthPrimaryKeyInfo?,importantColumns: null == importantColumns ? _self._importantColumns : importantColumns // ignore: cast_nullable_to_non_nullable
as List<DatabaseHealthImportantColumnSummary>,notes: null == notes ? _self._notes : notes // ignore: cast_nullable_to_non_nullable
as List<String>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of TableInventoryEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DatabaseHealthPrimaryKeyInfoCopyWith<$Res>? get primaryKey {
    if (_self.primaryKey == null) {
    return null;
  }

  return $DatabaseHealthPrimaryKeyInfoCopyWith<$Res>(_self.primaryKey!, (value) {
    return _then(_self.copyWith(primaryKey: value));
  });
}
}


/// @nodoc
mixin _$DatabaseHealthPrimaryKeyInfo {

 String get columnName; int? get minValue; int? get maxValue;
/// Create a copy of DatabaseHealthPrimaryKeyInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DatabaseHealthPrimaryKeyInfoCopyWith<DatabaseHealthPrimaryKeyInfo> get copyWith => _$DatabaseHealthPrimaryKeyInfoCopyWithImpl<DatabaseHealthPrimaryKeyInfo>(this as DatabaseHealthPrimaryKeyInfo, _$identity);

  /// Serializes this DatabaseHealthPrimaryKeyInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DatabaseHealthPrimaryKeyInfo&&(identical(other.columnName, columnName) || other.columnName == columnName)&&(identical(other.minValue, minValue) || other.minValue == minValue)&&(identical(other.maxValue, maxValue) || other.maxValue == maxValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,columnName,minValue,maxValue);

@override
String toString() {
  return 'DatabaseHealthPrimaryKeyInfo(columnName: $columnName, minValue: $minValue, maxValue: $maxValue)';
}


}

/// @nodoc
abstract mixin class $DatabaseHealthPrimaryKeyInfoCopyWith<$Res>  {
  factory $DatabaseHealthPrimaryKeyInfoCopyWith(DatabaseHealthPrimaryKeyInfo value, $Res Function(DatabaseHealthPrimaryKeyInfo) _then) = _$DatabaseHealthPrimaryKeyInfoCopyWithImpl;
@useResult
$Res call({
 String columnName, int? minValue, int? maxValue
});




}
/// @nodoc
class _$DatabaseHealthPrimaryKeyInfoCopyWithImpl<$Res>
    implements $DatabaseHealthPrimaryKeyInfoCopyWith<$Res> {
  _$DatabaseHealthPrimaryKeyInfoCopyWithImpl(this._self, this._then);

  final DatabaseHealthPrimaryKeyInfo _self;
  final $Res Function(DatabaseHealthPrimaryKeyInfo) _then;

/// Create a copy of DatabaseHealthPrimaryKeyInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? columnName = null,Object? minValue = freezed,Object? maxValue = freezed,}) {
  return _then(_self.copyWith(
columnName: null == columnName ? _self.columnName : columnName // ignore: cast_nullable_to_non_nullable
as String,minValue: freezed == minValue ? _self.minValue : minValue // ignore: cast_nullable_to_non_nullable
as int?,maxValue: freezed == maxValue ? _self.maxValue : maxValue // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [DatabaseHealthPrimaryKeyInfo].
extension DatabaseHealthPrimaryKeyInfoPatterns on DatabaseHealthPrimaryKeyInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DatabaseHealthPrimaryKeyInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DatabaseHealthPrimaryKeyInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DatabaseHealthPrimaryKeyInfo value)  $default,){
final _that = this;
switch (_that) {
case _DatabaseHealthPrimaryKeyInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DatabaseHealthPrimaryKeyInfo value)?  $default,){
final _that = this;
switch (_that) {
case _DatabaseHealthPrimaryKeyInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String columnName,  int? minValue,  int? maxValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DatabaseHealthPrimaryKeyInfo() when $default != null:
return $default(_that.columnName,_that.minValue,_that.maxValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String columnName,  int? minValue,  int? maxValue)  $default,) {final _that = this;
switch (_that) {
case _DatabaseHealthPrimaryKeyInfo():
return $default(_that.columnName,_that.minValue,_that.maxValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String columnName,  int? minValue,  int? maxValue)?  $default,) {final _that = this;
switch (_that) {
case _DatabaseHealthPrimaryKeyInfo() when $default != null:
return $default(_that.columnName,_that.minValue,_that.maxValue);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class _DatabaseHealthPrimaryKeyInfo implements DatabaseHealthPrimaryKeyInfo {
  const _DatabaseHealthPrimaryKeyInfo({required this.columnName, this.minValue, this.maxValue});
  factory _DatabaseHealthPrimaryKeyInfo.fromJson(Map<String, dynamic> json) => _$DatabaseHealthPrimaryKeyInfoFromJson(json);

@override final  String columnName;
@override final  int? minValue;
@override final  int? maxValue;

/// Create a copy of DatabaseHealthPrimaryKeyInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DatabaseHealthPrimaryKeyInfoCopyWith<_DatabaseHealthPrimaryKeyInfo> get copyWith => __$DatabaseHealthPrimaryKeyInfoCopyWithImpl<_DatabaseHealthPrimaryKeyInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DatabaseHealthPrimaryKeyInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DatabaseHealthPrimaryKeyInfo&&(identical(other.columnName, columnName) || other.columnName == columnName)&&(identical(other.minValue, minValue) || other.minValue == minValue)&&(identical(other.maxValue, maxValue) || other.maxValue == maxValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,columnName,minValue,maxValue);

@override
String toString() {
  return 'DatabaseHealthPrimaryKeyInfo(columnName: $columnName, minValue: $minValue, maxValue: $maxValue)';
}


}

/// @nodoc
abstract mixin class _$DatabaseHealthPrimaryKeyInfoCopyWith<$Res> implements $DatabaseHealthPrimaryKeyInfoCopyWith<$Res> {
  factory _$DatabaseHealthPrimaryKeyInfoCopyWith(_DatabaseHealthPrimaryKeyInfo value, $Res Function(_DatabaseHealthPrimaryKeyInfo) _then) = __$DatabaseHealthPrimaryKeyInfoCopyWithImpl;
@override @useResult
$Res call({
 String columnName, int? minValue, int? maxValue
});




}
/// @nodoc
class __$DatabaseHealthPrimaryKeyInfoCopyWithImpl<$Res>
    implements _$DatabaseHealthPrimaryKeyInfoCopyWith<$Res> {
  __$DatabaseHealthPrimaryKeyInfoCopyWithImpl(this._self, this._then);

  final _DatabaseHealthPrimaryKeyInfo _self;
  final $Res Function(_DatabaseHealthPrimaryKeyInfo) _then;

/// Create a copy of DatabaseHealthPrimaryKeyInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? columnName = null,Object? minValue = freezed,Object? maxValue = freezed,}) {
  return _then(_DatabaseHealthPrimaryKeyInfo(
columnName: null == columnName ? _self.columnName : columnName // ignore: cast_nullable_to_non_nullable
as String,minValue: freezed == minValue ? _self.minValue : minValue // ignore: cast_nullable_to_non_nullable
as int?,maxValue: freezed == maxValue ? _self.maxValue : maxValue // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$DatabaseHealthImportantColumnSummary {

 String get columnName; int? get nullCount; int? get nonNullCount; int? get distinctCount; bool? get omittedForPrivacy; List<String> get notes;
/// Create a copy of DatabaseHealthImportantColumnSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DatabaseHealthImportantColumnSummaryCopyWith<DatabaseHealthImportantColumnSummary> get copyWith => _$DatabaseHealthImportantColumnSummaryCopyWithImpl<DatabaseHealthImportantColumnSummary>(this as DatabaseHealthImportantColumnSummary, _$identity);

  /// Serializes this DatabaseHealthImportantColumnSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DatabaseHealthImportantColumnSummary&&(identical(other.columnName, columnName) || other.columnName == columnName)&&(identical(other.nullCount, nullCount) || other.nullCount == nullCount)&&(identical(other.nonNullCount, nonNullCount) || other.nonNullCount == nonNullCount)&&(identical(other.distinctCount, distinctCount) || other.distinctCount == distinctCount)&&(identical(other.omittedForPrivacy, omittedForPrivacy) || other.omittedForPrivacy == omittedForPrivacy)&&const DeepCollectionEquality().equals(other.notes, notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,columnName,nullCount,nonNullCount,distinctCount,omittedForPrivacy,const DeepCollectionEquality().hash(notes));

@override
String toString() {
  return 'DatabaseHealthImportantColumnSummary(columnName: $columnName, nullCount: $nullCount, nonNullCount: $nonNullCount, distinctCount: $distinctCount, omittedForPrivacy: $omittedForPrivacy, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $DatabaseHealthImportantColumnSummaryCopyWith<$Res>  {
  factory $DatabaseHealthImportantColumnSummaryCopyWith(DatabaseHealthImportantColumnSummary value, $Res Function(DatabaseHealthImportantColumnSummary) _then) = _$DatabaseHealthImportantColumnSummaryCopyWithImpl;
@useResult
$Res call({
 String columnName, int? nullCount, int? nonNullCount, int? distinctCount, bool? omittedForPrivacy, List<String> notes
});




}
/// @nodoc
class _$DatabaseHealthImportantColumnSummaryCopyWithImpl<$Res>
    implements $DatabaseHealthImportantColumnSummaryCopyWith<$Res> {
  _$DatabaseHealthImportantColumnSummaryCopyWithImpl(this._self, this._then);

  final DatabaseHealthImportantColumnSummary _self;
  final $Res Function(DatabaseHealthImportantColumnSummary) _then;

/// Create a copy of DatabaseHealthImportantColumnSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? columnName = null,Object? nullCount = freezed,Object? nonNullCount = freezed,Object? distinctCount = freezed,Object? omittedForPrivacy = freezed,Object? notes = null,}) {
  return _then(_self.copyWith(
columnName: null == columnName ? _self.columnName : columnName // ignore: cast_nullable_to_non_nullable
as String,nullCount: freezed == nullCount ? _self.nullCount : nullCount // ignore: cast_nullable_to_non_nullable
as int?,nonNullCount: freezed == nonNullCount ? _self.nonNullCount : nonNullCount // ignore: cast_nullable_to_non_nullable
as int?,distinctCount: freezed == distinctCount ? _self.distinctCount : distinctCount // ignore: cast_nullable_to_non_nullable
as int?,omittedForPrivacy: freezed == omittedForPrivacy ? _self.omittedForPrivacy : omittedForPrivacy // ignore: cast_nullable_to_non_nullable
as bool?,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [DatabaseHealthImportantColumnSummary].
extension DatabaseHealthImportantColumnSummaryPatterns on DatabaseHealthImportantColumnSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DatabaseHealthImportantColumnSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DatabaseHealthImportantColumnSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DatabaseHealthImportantColumnSummary value)  $default,){
final _that = this;
switch (_that) {
case _DatabaseHealthImportantColumnSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DatabaseHealthImportantColumnSummary value)?  $default,){
final _that = this;
switch (_that) {
case _DatabaseHealthImportantColumnSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String columnName,  int? nullCount,  int? nonNullCount,  int? distinctCount,  bool? omittedForPrivacy,  List<String> notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DatabaseHealthImportantColumnSummary() when $default != null:
return $default(_that.columnName,_that.nullCount,_that.nonNullCount,_that.distinctCount,_that.omittedForPrivacy,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String columnName,  int? nullCount,  int? nonNullCount,  int? distinctCount,  bool? omittedForPrivacy,  List<String> notes)  $default,) {final _that = this;
switch (_that) {
case _DatabaseHealthImportantColumnSummary():
return $default(_that.columnName,_that.nullCount,_that.nonNullCount,_that.distinctCount,_that.omittedForPrivacy,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String columnName,  int? nullCount,  int? nonNullCount,  int? distinctCount,  bool? omittedForPrivacy,  List<String> notes)?  $default,) {final _that = this;
switch (_that) {
case _DatabaseHealthImportantColumnSummary() when $default != null:
return $default(_that.columnName,_that.nullCount,_that.nonNullCount,_that.distinctCount,_that.omittedForPrivacy,_that.notes);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class _DatabaseHealthImportantColumnSummary implements DatabaseHealthImportantColumnSummary {
  const _DatabaseHealthImportantColumnSummary({required this.columnName, this.nullCount, this.nonNullCount, this.distinctCount, this.omittedForPrivacy, final  List<String> notes = const <String>[]}): _notes = notes;
  factory _DatabaseHealthImportantColumnSummary.fromJson(Map<String, dynamic> json) => _$DatabaseHealthImportantColumnSummaryFromJson(json);

@override final  String columnName;
@override final  int? nullCount;
@override final  int? nonNullCount;
@override final  int? distinctCount;
@override final  bool? omittedForPrivacy;
 final  List<String> _notes;
@override@JsonKey() List<String> get notes {
  if (_notes is EqualUnmodifiableListView) return _notes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notes);
}


/// Create a copy of DatabaseHealthImportantColumnSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DatabaseHealthImportantColumnSummaryCopyWith<_DatabaseHealthImportantColumnSummary> get copyWith => __$DatabaseHealthImportantColumnSummaryCopyWithImpl<_DatabaseHealthImportantColumnSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DatabaseHealthImportantColumnSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DatabaseHealthImportantColumnSummary&&(identical(other.columnName, columnName) || other.columnName == columnName)&&(identical(other.nullCount, nullCount) || other.nullCount == nullCount)&&(identical(other.nonNullCount, nonNullCount) || other.nonNullCount == nonNullCount)&&(identical(other.distinctCount, distinctCount) || other.distinctCount == distinctCount)&&(identical(other.omittedForPrivacy, omittedForPrivacy) || other.omittedForPrivacy == omittedForPrivacy)&&const DeepCollectionEquality().equals(other._notes, _notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,columnName,nullCount,nonNullCount,distinctCount,omittedForPrivacy,const DeepCollectionEquality().hash(_notes));

@override
String toString() {
  return 'DatabaseHealthImportantColumnSummary(columnName: $columnName, nullCount: $nullCount, nonNullCount: $nonNullCount, distinctCount: $distinctCount, omittedForPrivacy: $omittedForPrivacy, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$DatabaseHealthImportantColumnSummaryCopyWith<$Res> implements $DatabaseHealthImportantColumnSummaryCopyWith<$Res> {
  factory _$DatabaseHealthImportantColumnSummaryCopyWith(_DatabaseHealthImportantColumnSummary value, $Res Function(_DatabaseHealthImportantColumnSummary) _then) = __$DatabaseHealthImportantColumnSummaryCopyWithImpl;
@override @useResult
$Res call({
 String columnName, int? nullCount, int? nonNullCount, int? distinctCount, bool? omittedForPrivacy, List<String> notes
});




}
/// @nodoc
class __$DatabaseHealthImportantColumnSummaryCopyWithImpl<$Res>
    implements _$DatabaseHealthImportantColumnSummaryCopyWith<$Res> {
  __$DatabaseHealthImportantColumnSummaryCopyWithImpl(this._self, this._then);

  final _DatabaseHealthImportantColumnSummary _self;
  final $Res Function(_DatabaseHealthImportantColumnSummary) _then;

/// Create a copy of DatabaseHealthImportantColumnSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? columnName = null,Object? nullCount = freezed,Object? nonNullCount = freezed,Object? distinctCount = freezed,Object? omittedForPrivacy = freezed,Object? notes = null,}) {
  return _then(_DatabaseHealthImportantColumnSummary(
columnName: null == columnName ? _self.columnName : columnName // ignore: cast_nullable_to_non_nullable
as String,nullCount: freezed == nullCount ? _self.nullCount : nullCount // ignore: cast_nullable_to_non_nullable
as int?,nonNullCount: freezed == nonNullCount ? _self.nonNullCount : nonNullCount // ignore: cast_nullable_to_non_nullable
as int?,distinctCount: freezed == distinctCount ? _self.distinctCount : distinctCount // ignore: cast_nullable_to_non_nullable
as int?,omittedForPrivacy: freezed == omittedForPrivacy ? _self.omittedForPrivacy : omittedForPrivacy // ignore: cast_nullable_to_non_nullable
as bool?,notes: null == notes ? _self._notes : notes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$RelationshipCheckResult {

 String get checkKey; String get databaseKey; DatabaseHealthRelationshipType get relationshipType; String get parentTable; String? get childTable; String get joinExpressionDescription; int? get parentRowCount; int? get childRowCount; int? get matchedRowCount; int? get unmatchedParentRowCount; int? get unmatchedChildRowCount; double? get matchedPercentage; double? get unmatchedParentPercentage; double? get unmatchedChildPercentage; DatabaseHealthStatus get status; List<String> get notes; String? get error;
/// Create a copy of RelationshipCheckResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RelationshipCheckResultCopyWith<RelationshipCheckResult> get copyWith => _$RelationshipCheckResultCopyWithImpl<RelationshipCheckResult>(this as RelationshipCheckResult, _$identity);

  /// Serializes this RelationshipCheckResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RelationshipCheckResult&&(identical(other.checkKey, checkKey) || other.checkKey == checkKey)&&(identical(other.databaseKey, databaseKey) || other.databaseKey == databaseKey)&&(identical(other.relationshipType, relationshipType) || other.relationshipType == relationshipType)&&(identical(other.parentTable, parentTable) || other.parentTable == parentTable)&&(identical(other.childTable, childTable) || other.childTable == childTable)&&(identical(other.joinExpressionDescription, joinExpressionDescription) || other.joinExpressionDescription == joinExpressionDescription)&&(identical(other.parentRowCount, parentRowCount) || other.parentRowCount == parentRowCount)&&(identical(other.childRowCount, childRowCount) || other.childRowCount == childRowCount)&&(identical(other.matchedRowCount, matchedRowCount) || other.matchedRowCount == matchedRowCount)&&(identical(other.unmatchedParentRowCount, unmatchedParentRowCount) || other.unmatchedParentRowCount == unmatchedParentRowCount)&&(identical(other.unmatchedChildRowCount, unmatchedChildRowCount) || other.unmatchedChildRowCount == unmatchedChildRowCount)&&(identical(other.matchedPercentage, matchedPercentage) || other.matchedPercentage == matchedPercentage)&&(identical(other.unmatchedParentPercentage, unmatchedParentPercentage) || other.unmatchedParentPercentage == unmatchedParentPercentage)&&(identical(other.unmatchedChildPercentage, unmatchedChildPercentage) || other.unmatchedChildPercentage == unmatchedChildPercentage)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.notes, notes)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,checkKey,databaseKey,relationshipType,parentTable,childTable,joinExpressionDescription,parentRowCount,childRowCount,matchedRowCount,unmatchedParentRowCount,unmatchedChildRowCount,matchedPercentage,unmatchedParentPercentage,unmatchedChildPercentage,status,const DeepCollectionEquality().hash(notes),error);

@override
String toString() {
  return 'RelationshipCheckResult(checkKey: $checkKey, databaseKey: $databaseKey, relationshipType: $relationshipType, parentTable: $parentTable, childTable: $childTable, joinExpressionDescription: $joinExpressionDescription, parentRowCount: $parentRowCount, childRowCount: $childRowCount, matchedRowCount: $matchedRowCount, unmatchedParentRowCount: $unmatchedParentRowCount, unmatchedChildRowCount: $unmatchedChildRowCount, matchedPercentage: $matchedPercentage, unmatchedParentPercentage: $unmatchedParentPercentage, unmatchedChildPercentage: $unmatchedChildPercentage, status: $status, notes: $notes, error: $error)';
}


}

/// @nodoc
abstract mixin class $RelationshipCheckResultCopyWith<$Res>  {
  factory $RelationshipCheckResultCopyWith(RelationshipCheckResult value, $Res Function(RelationshipCheckResult) _then) = _$RelationshipCheckResultCopyWithImpl;
@useResult
$Res call({
 String checkKey, String databaseKey, DatabaseHealthRelationshipType relationshipType, String parentTable, String? childTable, String joinExpressionDescription, int? parentRowCount, int? childRowCount, int? matchedRowCount, int? unmatchedParentRowCount, int? unmatchedChildRowCount, double? matchedPercentage, double? unmatchedParentPercentage, double? unmatchedChildPercentage, DatabaseHealthStatus status, List<String> notes, String? error
});




}
/// @nodoc
class _$RelationshipCheckResultCopyWithImpl<$Res>
    implements $RelationshipCheckResultCopyWith<$Res> {
  _$RelationshipCheckResultCopyWithImpl(this._self, this._then);

  final RelationshipCheckResult _self;
  final $Res Function(RelationshipCheckResult) _then;

/// Create a copy of RelationshipCheckResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? checkKey = null,Object? databaseKey = null,Object? relationshipType = null,Object? parentTable = null,Object? childTable = freezed,Object? joinExpressionDescription = null,Object? parentRowCount = freezed,Object? childRowCount = freezed,Object? matchedRowCount = freezed,Object? unmatchedParentRowCount = freezed,Object? unmatchedChildRowCount = freezed,Object? matchedPercentage = freezed,Object? unmatchedParentPercentage = freezed,Object? unmatchedChildPercentage = freezed,Object? status = null,Object? notes = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
checkKey: null == checkKey ? _self.checkKey : checkKey // ignore: cast_nullable_to_non_nullable
as String,databaseKey: null == databaseKey ? _self.databaseKey : databaseKey // ignore: cast_nullable_to_non_nullable
as String,relationshipType: null == relationshipType ? _self.relationshipType : relationshipType // ignore: cast_nullable_to_non_nullable
as DatabaseHealthRelationshipType,parentTable: null == parentTable ? _self.parentTable : parentTable // ignore: cast_nullable_to_non_nullable
as String,childTable: freezed == childTable ? _self.childTable : childTable // ignore: cast_nullable_to_non_nullable
as String?,joinExpressionDescription: null == joinExpressionDescription ? _self.joinExpressionDescription : joinExpressionDescription // ignore: cast_nullable_to_non_nullable
as String,parentRowCount: freezed == parentRowCount ? _self.parentRowCount : parentRowCount // ignore: cast_nullable_to_non_nullable
as int?,childRowCount: freezed == childRowCount ? _self.childRowCount : childRowCount // ignore: cast_nullable_to_non_nullable
as int?,matchedRowCount: freezed == matchedRowCount ? _self.matchedRowCount : matchedRowCount // ignore: cast_nullable_to_non_nullable
as int?,unmatchedParentRowCount: freezed == unmatchedParentRowCount ? _self.unmatchedParentRowCount : unmatchedParentRowCount // ignore: cast_nullable_to_non_nullable
as int?,unmatchedChildRowCount: freezed == unmatchedChildRowCount ? _self.unmatchedChildRowCount : unmatchedChildRowCount // ignore: cast_nullable_to_non_nullable
as int?,matchedPercentage: freezed == matchedPercentage ? _self.matchedPercentage : matchedPercentage // ignore: cast_nullable_to_non_nullable
as double?,unmatchedParentPercentage: freezed == unmatchedParentPercentage ? _self.unmatchedParentPercentage : unmatchedParentPercentage // ignore: cast_nullable_to_non_nullable
as double?,unmatchedChildPercentage: freezed == unmatchedChildPercentage ? _self.unmatchedChildPercentage : unmatchedChildPercentage // ignore: cast_nullable_to_non_nullable
as double?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DatabaseHealthStatus,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as List<String>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RelationshipCheckResult].
extension RelationshipCheckResultPatterns on RelationshipCheckResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RelationshipCheckResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RelationshipCheckResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RelationshipCheckResult value)  $default,){
final _that = this;
switch (_that) {
case _RelationshipCheckResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RelationshipCheckResult value)?  $default,){
final _that = this;
switch (_that) {
case _RelationshipCheckResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String checkKey,  String databaseKey,  DatabaseHealthRelationshipType relationshipType,  String parentTable,  String? childTable,  String joinExpressionDescription,  int? parentRowCount,  int? childRowCount,  int? matchedRowCount,  int? unmatchedParentRowCount,  int? unmatchedChildRowCount,  double? matchedPercentage,  double? unmatchedParentPercentage,  double? unmatchedChildPercentage,  DatabaseHealthStatus status,  List<String> notes,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RelationshipCheckResult() when $default != null:
return $default(_that.checkKey,_that.databaseKey,_that.relationshipType,_that.parentTable,_that.childTable,_that.joinExpressionDescription,_that.parentRowCount,_that.childRowCount,_that.matchedRowCount,_that.unmatchedParentRowCount,_that.unmatchedChildRowCount,_that.matchedPercentage,_that.unmatchedParentPercentage,_that.unmatchedChildPercentage,_that.status,_that.notes,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String checkKey,  String databaseKey,  DatabaseHealthRelationshipType relationshipType,  String parentTable,  String? childTable,  String joinExpressionDescription,  int? parentRowCount,  int? childRowCount,  int? matchedRowCount,  int? unmatchedParentRowCount,  int? unmatchedChildRowCount,  double? matchedPercentage,  double? unmatchedParentPercentage,  double? unmatchedChildPercentage,  DatabaseHealthStatus status,  List<String> notes,  String? error)  $default,) {final _that = this;
switch (_that) {
case _RelationshipCheckResult():
return $default(_that.checkKey,_that.databaseKey,_that.relationshipType,_that.parentTable,_that.childTable,_that.joinExpressionDescription,_that.parentRowCount,_that.childRowCount,_that.matchedRowCount,_that.unmatchedParentRowCount,_that.unmatchedChildRowCount,_that.matchedPercentage,_that.unmatchedParentPercentage,_that.unmatchedChildPercentage,_that.status,_that.notes,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String checkKey,  String databaseKey,  DatabaseHealthRelationshipType relationshipType,  String parentTable,  String? childTable,  String joinExpressionDescription,  int? parentRowCount,  int? childRowCount,  int? matchedRowCount,  int? unmatchedParentRowCount,  int? unmatchedChildRowCount,  double? matchedPercentage,  double? unmatchedParentPercentage,  double? unmatchedChildPercentage,  DatabaseHealthStatus status,  List<String> notes,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _RelationshipCheckResult() when $default != null:
return $default(_that.checkKey,_that.databaseKey,_that.relationshipType,_that.parentTable,_that.childTable,_that.joinExpressionDescription,_that.parentRowCount,_that.childRowCount,_that.matchedRowCount,_that.unmatchedParentRowCount,_that.unmatchedChildRowCount,_that.matchedPercentage,_that.unmatchedParentPercentage,_that.unmatchedChildPercentage,_that.status,_that.notes,_that.error);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class _RelationshipCheckResult implements RelationshipCheckResult {
  const _RelationshipCheckResult({required this.checkKey, required this.databaseKey, required this.relationshipType, required this.parentTable, this.childTable, required this.joinExpressionDescription, this.parentRowCount, this.childRowCount, this.matchedRowCount, this.unmatchedParentRowCount, this.unmatchedChildRowCount, this.matchedPercentage, this.unmatchedParentPercentage, this.unmatchedChildPercentage, required this.status, final  List<String> notes = const <String>[], this.error}): _notes = notes;
  factory _RelationshipCheckResult.fromJson(Map<String, dynamic> json) => _$RelationshipCheckResultFromJson(json);

@override final  String checkKey;
@override final  String databaseKey;
@override final  DatabaseHealthRelationshipType relationshipType;
@override final  String parentTable;
@override final  String? childTable;
@override final  String joinExpressionDescription;
@override final  int? parentRowCount;
@override final  int? childRowCount;
@override final  int? matchedRowCount;
@override final  int? unmatchedParentRowCount;
@override final  int? unmatchedChildRowCount;
@override final  double? matchedPercentage;
@override final  double? unmatchedParentPercentage;
@override final  double? unmatchedChildPercentage;
@override final  DatabaseHealthStatus status;
 final  List<String> _notes;
@override@JsonKey() List<String> get notes {
  if (_notes is EqualUnmodifiableListView) return _notes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notes);
}

@override final  String? error;

/// Create a copy of RelationshipCheckResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RelationshipCheckResultCopyWith<_RelationshipCheckResult> get copyWith => __$RelationshipCheckResultCopyWithImpl<_RelationshipCheckResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RelationshipCheckResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RelationshipCheckResult&&(identical(other.checkKey, checkKey) || other.checkKey == checkKey)&&(identical(other.databaseKey, databaseKey) || other.databaseKey == databaseKey)&&(identical(other.relationshipType, relationshipType) || other.relationshipType == relationshipType)&&(identical(other.parentTable, parentTable) || other.parentTable == parentTable)&&(identical(other.childTable, childTable) || other.childTable == childTable)&&(identical(other.joinExpressionDescription, joinExpressionDescription) || other.joinExpressionDescription == joinExpressionDescription)&&(identical(other.parentRowCount, parentRowCount) || other.parentRowCount == parentRowCount)&&(identical(other.childRowCount, childRowCount) || other.childRowCount == childRowCount)&&(identical(other.matchedRowCount, matchedRowCount) || other.matchedRowCount == matchedRowCount)&&(identical(other.unmatchedParentRowCount, unmatchedParentRowCount) || other.unmatchedParentRowCount == unmatchedParentRowCount)&&(identical(other.unmatchedChildRowCount, unmatchedChildRowCount) || other.unmatchedChildRowCount == unmatchedChildRowCount)&&(identical(other.matchedPercentage, matchedPercentage) || other.matchedPercentage == matchedPercentage)&&(identical(other.unmatchedParentPercentage, unmatchedParentPercentage) || other.unmatchedParentPercentage == unmatchedParentPercentage)&&(identical(other.unmatchedChildPercentage, unmatchedChildPercentage) || other.unmatchedChildPercentage == unmatchedChildPercentage)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._notes, _notes)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,checkKey,databaseKey,relationshipType,parentTable,childTable,joinExpressionDescription,parentRowCount,childRowCount,matchedRowCount,unmatchedParentRowCount,unmatchedChildRowCount,matchedPercentage,unmatchedParentPercentage,unmatchedChildPercentage,status,const DeepCollectionEquality().hash(_notes),error);

@override
String toString() {
  return 'RelationshipCheckResult(checkKey: $checkKey, databaseKey: $databaseKey, relationshipType: $relationshipType, parentTable: $parentTable, childTable: $childTable, joinExpressionDescription: $joinExpressionDescription, parentRowCount: $parentRowCount, childRowCount: $childRowCount, matchedRowCount: $matchedRowCount, unmatchedParentRowCount: $unmatchedParentRowCount, unmatchedChildRowCount: $unmatchedChildRowCount, matchedPercentage: $matchedPercentage, unmatchedParentPercentage: $unmatchedParentPercentage, unmatchedChildPercentage: $unmatchedChildPercentage, status: $status, notes: $notes, error: $error)';
}


}

/// @nodoc
abstract mixin class _$RelationshipCheckResultCopyWith<$Res> implements $RelationshipCheckResultCopyWith<$Res> {
  factory _$RelationshipCheckResultCopyWith(_RelationshipCheckResult value, $Res Function(_RelationshipCheckResult) _then) = __$RelationshipCheckResultCopyWithImpl;
@override @useResult
$Res call({
 String checkKey, String databaseKey, DatabaseHealthRelationshipType relationshipType, String parentTable, String? childTable, String joinExpressionDescription, int? parentRowCount, int? childRowCount, int? matchedRowCount, int? unmatchedParentRowCount, int? unmatchedChildRowCount, double? matchedPercentage, double? unmatchedParentPercentage, double? unmatchedChildPercentage, DatabaseHealthStatus status, List<String> notes, String? error
});




}
/// @nodoc
class __$RelationshipCheckResultCopyWithImpl<$Res>
    implements _$RelationshipCheckResultCopyWith<$Res> {
  __$RelationshipCheckResultCopyWithImpl(this._self, this._then);

  final _RelationshipCheckResult _self;
  final $Res Function(_RelationshipCheckResult) _then;

/// Create a copy of RelationshipCheckResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? checkKey = null,Object? databaseKey = null,Object? relationshipType = null,Object? parentTable = null,Object? childTable = freezed,Object? joinExpressionDescription = null,Object? parentRowCount = freezed,Object? childRowCount = freezed,Object? matchedRowCount = freezed,Object? unmatchedParentRowCount = freezed,Object? unmatchedChildRowCount = freezed,Object? matchedPercentage = freezed,Object? unmatchedParentPercentage = freezed,Object? unmatchedChildPercentage = freezed,Object? status = null,Object? notes = null,Object? error = freezed,}) {
  return _then(_RelationshipCheckResult(
checkKey: null == checkKey ? _self.checkKey : checkKey // ignore: cast_nullable_to_non_nullable
as String,databaseKey: null == databaseKey ? _self.databaseKey : databaseKey // ignore: cast_nullable_to_non_nullable
as String,relationshipType: null == relationshipType ? _self.relationshipType : relationshipType // ignore: cast_nullable_to_non_nullable
as DatabaseHealthRelationshipType,parentTable: null == parentTable ? _self.parentTable : parentTable // ignore: cast_nullable_to_non_nullable
as String,childTable: freezed == childTable ? _self.childTable : childTable // ignore: cast_nullable_to_non_nullable
as String?,joinExpressionDescription: null == joinExpressionDescription ? _self.joinExpressionDescription : joinExpressionDescription // ignore: cast_nullable_to_non_nullable
as String,parentRowCount: freezed == parentRowCount ? _self.parentRowCount : parentRowCount // ignore: cast_nullable_to_non_nullable
as int?,childRowCount: freezed == childRowCount ? _self.childRowCount : childRowCount // ignore: cast_nullable_to_non_nullable
as int?,matchedRowCount: freezed == matchedRowCount ? _self.matchedRowCount : matchedRowCount // ignore: cast_nullable_to_non_nullable
as int?,unmatchedParentRowCount: freezed == unmatchedParentRowCount ? _self.unmatchedParentRowCount : unmatchedParentRowCount // ignore: cast_nullable_to_non_nullable
as int?,unmatchedChildRowCount: freezed == unmatchedChildRowCount ? _self.unmatchedChildRowCount : unmatchedChildRowCount // ignore: cast_nullable_to_non_nullable
as int?,matchedPercentage: freezed == matchedPercentage ? _self.matchedPercentage : matchedPercentage // ignore: cast_nullable_to_non_nullable
as double?,unmatchedParentPercentage: freezed == unmatchedParentPercentage ? _self.unmatchedParentPercentage : unmatchedParentPercentage // ignore: cast_nullable_to_non_nullable
as double?,unmatchedChildPercentage: freezed == unmatchedChildPercentage ? _self.unmatchedChildPercentage : unmatchedChildPercentage // ignore: cast_nullable_to_non_nullable
as double?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DatabaseHealthStatus,notes: null == notes ? _self._notes : notes // ignore: cast_nullable_to_non_nullable
as List<String>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$InvariantCheckResult {

 String get checkKey; DatabaseHealthSeverity get severity; String get description; DatabaseHealthStatus get status; int? get violationCount; int? get evaluatedRowCount; List<String> get notes; String? get error;
/// Create a copy of InvariantCheckResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvariantCheckResultCopyWith<InvariantCheckResult> get copyWith => _$InvariantCheckResultCopyWithImpl<InvariantCheckResult>(this as InvariantCheckResult, _$identity);

  /// Serializes this InvariantCheckResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvariantCheckResult&&(identical(other.checkKey, checkKey) || other.checkKey == checkKey)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.violationCount, violationCount) || other.violationCount == violationCount)&&(identical(other.evaluatedRowCount, evaluatedRowCount) || other.evaluatedRowCount == evaluatedRowCount)&&const DeepCollectionEquality().equals(other.notes, notes)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,checkKey,severity,description,status,violationCount,evaluatedRowCount,const DeepCollectionEquality().hash(notes),error);

@override
String toString() {
  return 'InvariantCheckResult(checkKey: $checkKey, severity: $severity, description: $description, status: $status, violationCount: $violationCount, evaluatedRowCount: $evaluatedRowCount, notes: $notes, error: $error)';
}


}

/// @nodoc
abstract mixin class $InvariantCheckResultCopyWith<$Res>  {
  factory $InvariantCheckResultCopyWith(InvariantCheckResult value, $Res Function(InvariantCheckResult) _then) = _$InvariantCheckResultCopyWithImpl;
@useResult
$Res call({
 String checkKey, DatabaseHealthSeverity severity, String description, DatabaseHealthStatus status, int? violationCount, int? evaluatedRowCount, List<String> notes, String? error
});




}
/// @nodoc
class _$InvariantCheckResultCopyWithImpl<$Res>
    implements $InvariantCheckResultCopyWith<$Res> {
  _$InvariantCheckResultCopyWithImpl(this._self, this._then);

  final InvariantCheckResult _self;
  final $Res Function(InvariantCheckResult) _then;

/// Create a copy of InvariantCheckResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? checkKey = null,Object? severity = null,Object? description = null,Object? status = null,Object? violationCount = freezed,Object? evaluatedRowCount = freezed,Object? notes = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
checkKey: null == checkKey ? _self.checkKey : checkKey // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as DatabaseHealthSeverity,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DatabaseHealthStatus,violationCount: freezed == violationCount ? _self.violationCount : violationCount // ignore: cast_nullable_to_non_nullable
as int?,evaluatedRowCount: freezed == evaluatedRowCount ? _self.evaluatedRowCount : evaluatedRowCount // ignore: cast_nullable_to_non_nullable
as int?,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as List<String>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InvariantCheckResult].
extension InvariantCheckResultPatterns on InvariantCheckResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvariantCheckResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvariantCheckResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvariantCheckResult value)  $default,){
final _that = this;
switch (_that) {
case _InvariantCheckResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvariantCheckResult value)?  $default,){
final _that = this;
switch (_that) {
case _InvariantCheckResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String checkKey,  DatabaseHealthSeverity severity,  String description,  DatabaseHealthStatus status,  int? violationCount,  int? evaluatedRowCount,  List<String> notes,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvariantCheckResult() when $default != null:
return $default(_that.checkKey,_that.severity,_that.description,_that.status,_that.violationCount,_that.evaluatedRowCount,_that.notes,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String checkKey,  DatabaseHealthSeverity severity,  String description,  DatabaseHealthStatus status,  int? violationCount,  int? evaluatedRowCount,  List<String> notes,  String? error)  $default,) {final _that = this;
switch (_that) {
case _InvariantCheckResult():
return $default(_that.checkKey,_that.severity,_that.description,_that.status,_that.violationCount,_that.evaluatedRowCount,_that.notes,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String checkKey,  DatabaseHealthSeverity severity,  String description,  DatabaseHealthStatus status,  int? violationCount,  int? evaluatedRowCount,  List<String> notes,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _InvariantCheckResult() when $default != null:
return $default(_that.checkKey,_that.severity,_that.description,_that.status,_that.violationCount,_that.evaluatedRowCount,_that.notes,_that.error);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class _InvariantCheckResult implements InvariantCheckResult {
  const _InvariantCheckResult({required this.checkKey, required this.severity, required this.description, required this.status, this.violationCount, this.evaluatedRowCount, final  List<String> notes = const <String>[], this.error}): _notes = notes;
  factory _InvariantCheckResult.fromJson(Map<String, dynamic> json) => _$InvariantCheckResultFromJson(json);

@override final  String checkKey;
@override final  DatabaseHealthSeverity severity;
@override final  String description;
@override final  DatabaseHealthStatus status;
@override final  int? violationCount;
@override final  int? evaluatedRowCount;
 final  List<String> _notes;
@override@JsonKey() List<String> get notes {
  if (_notes is EqualUnmodifiableListView) return _notes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notes);
}

@override final  String? error;

/// Create a copy of InvariantCheckResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvariantCheckResultCopyWith<_InvariantCheckResult> get copyWith => __$InvariantCheckResultCopyWithImpl<_InvariantCheckResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvariantCheckResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvariantCheckResult&&(identical(other.checkKey, checkKey) || other.checkKey == checkKey)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.violationCount, violationCount) || other.violationCount == violationCount)&&(identical(other.evaluatedRowCount, evaluatedRowCount) || other.evaluatedRowCount == evaluatedRowCount)&&const DeepCollectionEquality().equals(other._notes, _notes)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,checkKey,severity,description,status,violationCount,evaluatedRowCount,const DeepCollectionEquality().hash(_notes),error);

@override
String toString() {
  return 'InvariantCheckResult(checkKey: $checkKey, severity: $severity, description: $description, status: $status, violationCount: $violationCount, evaluatedRowCount: $evaluatedRowCount, notes: $notes, error: $error)';
}


}

/// @nodoc
abstract mixin class _$InvariantCheckResultCopyWith<$Res> implements $InvariantCheckResultCopyWith<$Res> {
  factory _$InvariantCheckResultCopyWith(_InvariantCheckResult value, $Res Function(_InvariantCheckResult) _then) = __$InvariantCheckResultCopyWithImpl;
@override @useResult
$Res call({
 String checkKey, DatabaseHealthSeverity severity, String description, DatabaseHealthStatus status, int? violationCount, int? evaluatedRowCount, List<String> notes, String? error
});




}
/// @nodoc
class __$InvariantCheckResultCopyWithImpl<$Res>
    implements _$InvariantCheckResultCopyWith<$Res> {
  __$InvariantCheckResultCopyWithImpl(this._self, this._then);

  final _InvariantCheckResult _self;
  final $Res Function(_InvariantCheckResult) _then;

/// Create a copy of InvariantCheckResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? checkKey = null,Object? severity = null,Object? description = null,Object? status = null,Object? violationCount = freezed,Object? evaluatedRowCount = freezed,Object? notes = null,Object? error = freezed,}) {
  return _then(_InvariantCheckResult(
checkKey: null == checkKey ? _self.checkKey : checkKey // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as DatabaseHealthSeverity,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DatabaseHealthStatus,violationCount: freezed == violationCount ? _self.violationCount : violationCount // ignore: cast_nullable_to_non_nullable
as int?,evaluatedRowCount: freezed == evaluatedRowCount ? _self.evaluatedRowCount : evaluatedRowCount // ignore: cast_nullable_to_non_nullable
as int?,notes: null == notes ? _self._notes : notes // ignore: cast_nullable_to_non_nullable
as List<String>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$HealthReportSummary {

 DatabaseHealthStatus get overallStatus;/// Count of active app-health tables only. Retired cleanup tables may appear
/// in detailed inventory but must not inflate the top-level health summary.
 int get tableCount; int get relationshipCheckCount; int get invariantCheckCount; int get passCount; int get warningCount; int get failCount; int get errorCount; List<String> get headlineFindings;
/// Create a copy of HealthReportSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthReportSummaryCopyWith<HealthReportSummary> get copyWith => _$HealthReportSummaryCopyWithImpl<HealthReportSummary>(this as HealthReportSummary, _$identity);

  /// Serializes this HealthReportSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthReportSummary&&(identical(other.overallStatus, overallStatus) || other.overallStatus == overallStatus)&&(identical(other.tableCount, tableCount) || other.tableCount == tableCount)&&(identical(other.relationshipCheckCount, relationshipCheckCount) || other.relationshipCheckCount == relationshipCheckCount)&&(identical(other.invariantCheckCount, invariantCheckCount) || other.invariantCheckCount == invariantCheckCount)&&(identical(other.passCount, passCount) || other.passCount == passCount)&&(identical(other.warningCount, warningCount) || other.warningCount == warningCount)&&(identical(other.failCount, failCount) || other.failCount == failCount)&&(identical(other.errorCount, errorCount) || other.errorCount == errorCount)&&const DeepCollectionEquality().equals(other.headlineFindings, headlineFindings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,overallStatus,tableCount,relationshipCheckCount,invariantCheckCount,passCount,warningCount,failCount,errorCount,const DeepCollectionEquality().hash(headlineFindings));

@override
String toString() {
  return 'HealthReportSummary(overallStatus: $overallStatus, tableCount: $tableCount, relationshipCheckCount: $relationshipCheckCount, invariantCheckCount: $invariantCheckCount, passCount: $passCount, warningCount: $warningCount, failCount: $failCount, errorCount: $errorCount, headlineFindings: $headlineFindings)';
}


}

/// @nodoc
abstract mixin class $HealthReportSummaryCopyWith<$Res>  {
  factory $HealthReportSummaryCopyWith(HealthReportSummary value, $Res Function(HealthReportSummary) _then) = _$HealthReportSummaryCopyWithImpl;
@useResult
$Res call({
 DatabaseHealthStatus overallStatus, int tableCount, int relationshipCheckCount, int invariantCheckCount, int passCount, int warningCount, int failCount, int errorCount, List<String> headlineFindings
});




}
/// @nodoc
class _$HealthReportSummaryCopyWithImpl<$Res>
    implements $HealthReportSummaryCopyWith<$Res> {
  _$HealthReportSummaryCopyWithImpl(this._self, this._then);

  final HealthReportSummary _self;
  final $Res Function(HealthReportSummary) _then;

/// Create a copy of HealthReportSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? overallStatus = null,Object? tableCount = null,Object? relationshipCheckCount = null,Object? invariantCheckCount = null,Object? passCount = null,Object? warningCount = null,Object? failCount = null,Object? errorCount = null,Object? headlineFindings = null,}) {
  return _then(_self.copyWith(
overallStatus: null == overallStatus ? _self.overallStatus : overallStatus // ignore: cast_nullable_to_non_nullable
as DatabaseHealthStatus,tableCount: null == tableCount ? _self.tableCount : tableCount // ignore: cast_nullable_to_non_nullable
as int,relationshipCheckCount: null == relationshipCheckCount ? _self.relationshipCheckCount : relationshipCheckCount // ignore: cast_nullable_to_non_nullable
as int,invariantCheckCount: null == invariantCheckCount ? _self.invariantCheckCount : invariantCheckCount // ignore: cast_nullable_to_non_nullable
as int,passCount: null == passCount ? _self.passCount : passCount // ignore: cast_nullable_to_non_nullable
as int,warningCount: null == warningCount ? _self.warningCount : warningCount // ignore: cast_nullable_to_non_nullable
as int,failCount: null == failCount ? _self.failCount : failCount // ignore: cast_nullable_to_non_nullable
as int,errorCount: null == errorCount ? _self.errorCount : errorCount // ignore: cast_nullable_to_non_nullable
as int,headlineFindings: null == headlineFindings ? _self.headlineFindings : headlineFindings // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthReportSummary].
extension HealthReportSummaryPatterns on HealthReportSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthReportSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthReportSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthReportSummary value)  $default,){
final _that = this;
switch (_that) {
case _HealthReportSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthReportSummary value)?  $default,){
final _that = this;
switch (_that) {
case _HealthReportSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DatabaseHealthStatus overallStatus,  int tableCount,  int relationshipCheckCount,  int invariantCheckCount,  int passCount,  int warningCount,  int failCount,  int errorCount,  List<String> headlineFindings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthReportSummary() when $default != null:
return $default(_that.overallStatus,_that.tableCount,_that.relationshipCheckCount,_that.invariantCheckCount,_that.passCount,_that.warningCount,_that.failCount,_that.errorCount,_that.headlineFindings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DatabaseHealthStatus overallStatus,  int tableCount,  int relationshipCheckCount,  int invariantCheckCount,  int passCount,  int warningCount,  int failCount,  int errorCount,  List<String> headlineFindings)  $default,) {final _that = this;
switch (_that) {
case _HealthReportSummary():
return $default(_that.overallStatus,_that.tableCount,_that.relationshipCheckCount,_that.invariantCheckCount,_that.passCount,_that.warningCount,_that.failCount,_that.errorCount,_that.headlineFindings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DatabaseHealthStatus overallStatus,  int tableCount,  int relationshipCheckCount,  int invariantCheckCount,  int passCount,  int warningCount,  int failCount,  int errorCount,  List<String> headlineFindings)?  $default,) {final _that = this;
switch (_that) {
case _HealthReportSummary() when $default != null:
return $default(_that.overallStatus,_that.tableCount,_that.relationshipCheckCount,_that.invariantCheckCount,_that.passCount,_that.warningCount,_that.failCount,_that.errorCount,_that.headlineFindings);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class _HealthReportSummary implements HealthReportSummary {
  const _HealthReportSummary({required this.overallStatus, required this.tableCount, required this.relationshipCheckCount, required this.invariantCheckCount, required this.passCount, required this.warningCount, required this.failCount, required this.errorCount, final  List<String> headlineFindings = const <String>[]}): _headlineFindings = headlineFindings;
  factory _HealthReportSummary.fromJson(Map<String, dynamic> json) => _$HealthReportSummaryFromJson(json);

@override final  DatabaseHealthStatus overallStatus;
/// Count of active app-health tables only. Retired cleanup tables may appear
/// in detailed inventory but must not inflate the top-level health summary.
@override final  int tableCount;
@override final  int relationshipCheckCount;
@override final  int invariantCheckCount;
@override final  int passCount;
@override final  int warningCount;
@override final  int failCount;
@override final  int errorCount;
 final  List<String> _headlineFindings;
@override@JsonKey() List<String> get headlineFindings {
  if (_headlineFindings is EqualUnmodifiableListView) return _headlineFindings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_headlineFindings);
}


/// Create a copy of HealthReportSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthReportSummaryCopyWith<_HealthReportSummary> get copyWith => __$HealthReportSummaryCopyWithImpl<_HealthReportSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthReportSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthReportSummary&&(identical(other.overallStatus, overallStatus) || other.overallStatus == overallStatus)&&(identical(other.tableCount, tableCount) || other.tableCount == tableCount)&&(identical(other.relationshipCheckCount, relationshipCheckCount) || other.relationshipCheckCount == relationshipCheckCount)&&(identical(other.invariantCheckCount, invariantCheckCount) || other.invariantCheckCount == invariantCheckCount)&&(identical(other.passCount, passCount) || other.passCount == passCount)&&(identical(other.warningCount, warningCount) || other.warningCount == warningCount)&&(identical(other.failCount, failCount) || other.failCount == failCount)&&(identical(other.errorCount, errorCount) || other.errorCount == errorCount)&&const DeepCollectionEquality().equals(other._headlineFindings, _headlineFindings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,overallStatus,tableCount,relationshipCheckCount,invariantCheckCount,passCount,warningCount,failCount,errorCount,const DeepCollectionEquality().hash(_headlineFindings));

@override
String toString() {
  return 'HealthReportSummary(overallStatus: $overallStatus, tableCount: $tableCount, relationshipCheckCount: $relationshipCheckCount, invariantCheckCount: $invariantCheckCount, passCount: $passCount, warningCount: $warningCount, failCount: $failCount, errorCount: $errorCount, headlineFindings: $headlineFindings)';
}


}

/// @nodoc
abstract mixin class _$HealthReportSummaryCopyWith<$Res> implements $HealthReportSummaryCopyWith<$Res> {
  factory _$HealthReportSummaryCopyWith(_HealthReportSummary value, $Res Function(_HealthReportSummary) _then) = __$HealthReportSummaryCopyWithImpl;
@override @useResult
$Res call({
 DatabaseHealthStatus overallStatus, int tableCount, int relationshipCheckCount, int invariantCheckCount, int passCount, int warningCount, int failCount, int errorCount, List<String> headlineFindings
});




}
/// @nodoc
class __$HealthReportSummaryCopyWithImpl<$Res>
    implements _$HealthReportSummaryCopyWith<$Res> {
  __$HealthReportSummaryCopyWithImpl(this._self, this._then);

  final _HealthReportSummary _self;
  final $Res Function(_HealthReportSummary) _then;

/// Create a copy of HealthReportSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? overallStatus = null,Object? tableCount = null,Object? relationshipCheckCount = null,Object? invariantCheckCount = null,Object? passCount = null,Object? warningCount = null,Object? failCount = null,Object? errorCount = null,Object? headlineFindings = null,}) {
  return _then(_HealthReportSummary(
overallStatus: null == overallStatus ? _self.overallStatus : overallStatus // ignore: cast_nullable_to_non_nullable
as DatabaseHealthStatus,tableCount: null == tableCount ? _self.tableCount : tableCount // ignore: cast_nullable_to_non_nullable
as int,relationshipCheckCount: null == relationshipCheckCount ? _self.relationshipCheckCount : relationshipCheckCount // ignore: cast_nullable_to_non_nullable
as int,invariantCheckCount: null == invariantCheckCount ? _self.invariantCheckCount : invariantCheckCount // ignore: cast_nullable_to_non_nullable
as int,passCount: null == passCount ? _self.passCount : passCount // ignore: cast_nullable_to_non_nullable
as int,warningCount: null == warningCount ? _self.warningCount : warningCount // ignore: cast_nullable_to_non_nullable
as int,failCount: null == failCount ? _self.failCount : failCount // ignore: cast_nullable_to_non_nullable
as int,errorCount: null == errorCount ? _self.errorCount : errorCount // ignore: cast_nullable_to_non_nullable
as int,headlineFindings: null == headlineFindings ? _self._headlineFindings : headlineFindings // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$HealthReportError {

 DatabaseHealthErrorScope get scope; String? get databaseKey; String? get tableName; String? get checkKey; String get message;
/// Create a copy of HealthReportError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthReportErrorCopyWith<HealthReportError> get copyWith => _$HealthReportErrorCopyWithImpl<HealthReportError>(this as HealthReportError, _$identity);

  /// Serializes this HealthReportError to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthReportError&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.databaseKey, databaseKey) || other.databaseKey == databaseKey)&&(identical(other.tableName, tableName) || other.tableName == tableName)&&(identical(other.checkKey, checkKey) || other.checkKey == checkKey)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,scope,databaseKey,tableName,checkKey,message);

@override
String toString() {
  return 'HealthReportError(scope: $scope, databaseKey: $databaseKey, tableName: $tableName, checkKey: $checkKey, message: $message)';
}


}

/// @nodoc
abstract mixin class $HealthReportErrorCopyWith<$Res>  {
  factory $HealthReportErrorCopyWith(HealthReportError value, $Res Function(HealthReportError) _then) = _$HealthReportErrorCopyWithImpl;
@useResult
$Res call({
 DatabaseHealthErrorScope scope, String? databaseKey, String? tableName, String? checkKey, String message
});




}
/// @nodoc
class _$HealthReportErrorCopyWithImpl<$Res>
    implements $HealthReportErrorCopyWith<$Res> {
  _$HealthReportErrorCopyWithImpl(this._self, this._then);

  final HealthReportError _self;
  final $Res Function(HealthReportError) _then;

/// Create a copy of HealthReportError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? scope = null,Object? databaseKey = freezed,Object? tableName = freezed,Object? checkKey = freezed,Object? message = null,}) {
  return _then(_self.copyWith(
scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as DatabaseHealthErrorScope,databaseKey: freezed == databaseKey ? _self.databaseKey : databaseKey // ignore: cast_nullable_to_non_nullable
as String?,tableName: freezed == tableName ? _self.tableName : tableName // ignore: cast_nullable_to_non_nullable
as String?,checkKey: freezed == checkKey ? _self.checkKey : checkKey // ignore: cast_nullable_to_non_nullable
as String?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthReportError].
extension HealthReportErrorPatterns on HealthReportError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthReportError value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthReportError() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthReportError value)  $default,){
final _that = this;
switch (_that) {
case _HealthReportError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthReportError value)?  $default,){
final _that = this;
switch (_that) {
case _HealthReportError() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DatabaseHealthErrorScope scope,  String? databaseKey,  String? tableName,  String? checkKey,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthReportError() when $default != null:
return $default(_that.scope,_that.databaseKey,_that.tableName,_that.checkKey,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DatabaseHealthErrorScope scope,  String? databaseKey,  String? tableName,  String? checkKey,  String message)  $default,) {final _that = this;
switch (_that) {
case _HealthReportError():
return $default(_that.scope,_that.databaseKey,_that.tableName,_that.checkKey,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DatabaseHealthErrorScope scope,  String? databaseKey,  String? tableName,  String? checkKey,  String message)?  $default,) {final _that = this;
switch (_that) {
case _HealthReportError() when $default != null:
return $default(_that.scope,_that.databaseKey,_that.tableName,_that.checkKey,_that.message);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class _HealthReportError implements HealthReportError {
  const _HealthReportError({required this.scope, this.databaseKey, this.tableName, this.checkKey, required this.message});
  factory _HealthReportError.fromJson(Map<String, dynamic> json) => _$HealthReportErrorFromJson(json);

@override final  DatabaseHealthErrorScope scope;
@override final  String? databaseKey;
@override final  String? tableName;
@override final  String? checkKey;
@override final  String message;

/// Create a copy of HealthReportError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthReportErrorCopyWith<_HealthReportError> get copyWith => __$HealthReportErrorCopyWithImpl<_HealthReportError>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthReportErrorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthReportError&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.databaseKey, databaseKey) || other.databaseKey == databaseKey)&&(identical(other.tableName, tableName) || other.tableName == tableName)&&(identical(other.checkKey, checkKey) || other.checkKey == checkKey)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,scope,databaseKey,tableName,checkKey,message);

@override
String toString() {
  return 'HealthReportError(scope: $scope, databaseKey: $databaseKey, tableName: $tableName, checkKey: $checkKey, message: $message)';
}


}

/// @nodoc
abstract mixin class _$HealthReportErrorCopyWith<$Res> implements $HealthReportErrorCopyWith<$Res> {
  factory _$HealthReportErrorCopyWith(_HealthReportError value, $Res Function(_HealthReportError) _then) = __$HealthReportErrorCopyWithImpl;
@override @useResult
$Res call({
 DatabaseHealthErrorScope scope, String? databaseKey, String? tableName, String? checkKey, String message
});




}
/// @nodoc
class __$HealthReportErrorCopyWithImpl<$Res>
    implements _$HealthReportErrorCopyWith<$Res> {
  __$HealthReportErrorCopyWithImpl(this._self, this._then);

  final _HealthReportError _self;
  final $Res Function(_HealthReportError) _then;

/// Create a copy of HealthReportError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? scope = null,Object? databaseKey = freezed,Object? tableName = freezed,Object? checkKey = freezed,Object? message = null,}) {
  return _then(_HealthReportError(
scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as DatabaseHealthErrorScope,databaseKey: freezed == databaseKey ? _self.databaseKey : databaseKey // ignore: cast_nullable_to_non_nullable
as String?,tableName: freezed == tableName ? _self.tableName : tableName // ignore: cast_nullable_to_non_nullable
as String?,checkKey: freezed == checkKey ? _self.checkKey : checkKey // ignore: cast_nullable_to_non_nullable
as String?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
