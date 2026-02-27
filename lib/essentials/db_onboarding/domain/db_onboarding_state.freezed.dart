// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'db_onboarding_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DbOnboardingState {

/// The current phase being displayed in the stepper.
 DbOnboardingPhase get currentPhase;/// Whether Full Disk Access has been granted.
 bool get fdaGranted;/// Whether the Messages database (chat.db) was found.
 bool get messagesDbFound;/// Whether the Contacts database (AddressBook) was found.
 bool get contactsDbFound;/// Whether the import process has completed successfully.
 bool get importComplete;/// Whether onboarding is running in developer mode.
///
/// When true, the fullscreen overlay is suppressed and progress
/// is shown inline in the developer tools panel.
 bool get devMode;/// Minimum duration (milliseconds) each onboarding phase should be visible.
///
/// This is primarily exposed for developer tools UX tuning.
 int get phaseMinDurationMs;/// Whether the onboarding flow has been explicitly started.
///
/// Used by UI to differentiate a true virgin/reset state from an
/// active permission-check phase.
 bool get onboardingStarted;/// Optional error message if the current phase is [DbOnboardingPhase.error].
 String? get errorMessage;/// Optional progress percentage for the current phase (0.0 to 1.0).
 double? get progressPercent;/// Current count for import progress (e.g., messages imported so far).
 int? get importCurrent;/// Total count for import progress (e.g., total messages to import).
 int? get importTotal;/// Human-readable description of current import activity.
 String? get importStatusMessage;/// List of import sub-stages with their individual progress.
///
/// These are the granular steps within a main phase (e.g., "Importing Messages"
/// contains sub-stages like "Importing handles", "Importing chats", etc.)
 List<ImportSubStage> get importSubStages;/// True while migration is running after import has completed.
///
/// This lets the onboarding UI show a clearer "finalizing" label instead
/// of implying contacts import is still active.
 bool get migrationInProgress;
/// Create a copy of DbOnboardingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DbOnboardingStateCopyWith<DbOnboardingState> get copyWith => _$DbOnboardingStateCopyWithImpl<DbOnboardingState>(this as DbOnboardingState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DbOnboardingState&&(identical(other.currentPhase, currentPhase) || other.currentPhase == currentPhase)&&(identical(other.fdaGranted, fdaGranted) || other.fdaGranted == fdaGranted)&&(identical(other.messagesDbFound, messagesDbFound) || other.messagesDbFound == messagesDbFound)&&(identical(other.contactsDbFound, contactsDbFound) || other.contactsDbFound == contactsDbFound)&&(identical(other.importComplete, importComplete) || other.importComplete == importComplete)&&(identical(other.devMode, devMode) || other.devMode == devMode)&&(identical(other.phaseMinDurationMs, phaseMinDurationMs) || other.phaseMinDurationMs == phaseMinDurationMs)&&(identical(other.onboardingStarted, onboardingStarted) || other.onboardingStarted == onboardingStarted)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.progressPercent, progressPercent) || other.progressPercent == progressPercent)&&(identical(other.importCurrent, importCurrent) || other.importCurrent == importCurrent)&&(identical(other.importTotal, importTotal) || other.importTotal == importTotal)&&(identical(other.importStatusMessage, importStatusMessage) || other.importStatusMessage == importStatusMessage)&&const DeepCollectionEquality().equals(other.importSubStages, importSubStages)&&(identical(other.migrationInProgress, migrationInProgress) || other.migrationInProgress == migrationInProgress));
}


@override
int get hashCode => Object.hash(runtimeType,currentPhase,fdaGranted,messagesDbFound,contactsDbFound,importComplete,devMode,phaseMinDurationMs,onboardingStarted,errorMessage,progressPercent,importCurrent,importTotal,importStatusMessage,const DeepCollectionEquality().hash(importSubStages),migrationInProgress);

@override
String toString() {
  return 'DbOnboardingState(currentPhase: $currentPhase, fdaGranted: $fdaGranted, messagesDbFound: $messagesDbFound, contactsDbFound: $contactsDbFound, importComplete: $importComplete, devMode: $devMode, phaseMinDurationMs: $phaseMinDurationMs, onboardingStarted: $onboardingStarted, errorMessage: $errorMessage, progressPercent: $progressPercent, importCurrent: $importCurrent, importTotal: $importTotal, importStatusMessage: $importStatusMessage, importSubStages: $importSubStages, migrationInProgress: $migrationInProgress)';
}


}

/// @nodoc
abstract mixin class $DbOnboardingStateCopyWith<$Res>  {
  factory $DbOnboardingStateCopyWith(DbOnboardingState value, $Res Function(DbOnboardingState) _then) = _$DbOnboardingStateCopyWithImpl;
@useResult
$Res call({
 DbOnboardingPhase currentPhase, bool fdaGranted, bool messagesDbFound, bool contactsDbFound, bool importComplete, bool devMode, int phaseMinDurationMs, bool onboardingStarted, String? errorMessage, double? progressPercent, int? importCurrent, int? importTotal, String? importStatusMessage, List<ImportSubStage> importSubStages, bool migrationInProgress
});




}
/// @nodoc
class _$DbOnboardingStateCopyWithImpl<$Res>
    implements $DbOnboardingStateCopyWith<$Res> {
  _$DbOnboardingStateCopyWithImpl(this._self, this._then);

  final DbOnboardingState _self;
  final $Res Function(DbOnboardingState) _then;

/// Create a copy of DbOnboardingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentPhase = null,Object? fdaGranted = null,Object? messagesDbFound = null,Object? contactsDbFound = null,Object? importComplete = null,Object? devMode = null,Object? phaseMinDurationMs = null,Object? onboardingStarted = null,Object? errorMessage = freezed,Object? progressPercent = freezed,Object? importCurrent = freezed,Object? importTotal = freezed,Object? importStatusMessage = freezed,Object? importSubStages = null,Object? migrationInProgress = null,}) {
  return _then(_self.copyWith(
currentPhase: null == currentPhase ? _self.currentPhase : currentPhase // ignore: cast_nullable_to_non_nullable
as DbOnboardingPhase,fdaGranted: null == fdaGranted ? _self.fdaGranted : fdaGranted // ignore: cast_nullable_to_non_nullable
as bool,messagesDbFound: null == messagesDbFound ? _self.messagesDbFound : messagesDbFound // ignore: cast_nullable_to_non_nullable
as bool,contactsDbFound: null == contactsDbFound ? _self.contactsDbFound : contactsDbFound // ignore: cast_nullable_to_non_nullable
as bool,importComplete: null == importComplete ? _self.importComplete : importComplete // ignore: cast_nullable_to_non_nullable
as bool,devMode: null == devMode ? _self.devMode : devMode // ignore: cast_nullable_to_non_nullable
as bool,phaseMinDurationMs: null == phaseMinDurationMs ? _self.phaseMinDurationMs : phaseMinDurationMs // ignore: cast_nullable_to_non_nullable
as int,onboardingStarted: null == onboardingStarted ? _self.onboardingStarted : onboardingStarted // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,progressPercent: freezed == progressPercent ? _self.progressPercent : progressPercent // ignore: cast_nullable_to_non_nullable
as double?,importCurrent: freezed == importCurrent ? _self.importCurrent : importCurrent // ignore: cast_nullable_to_non_nullable
as int?,importTotal: freezed == importTotal ? _self.importTotal : importTotal // ignore: cast_nullable_to_non_nullable
as int?,importStatusMessage: freezed == importStatusMessage ? _self.importStatusMessage : importStatusMessage // ignore: cast_nullable_to_non_nullable
as String?,importSubStages: null == importSubStages ? _self.importSubStages : importSubStages // ignore: cast_nullable_to_non_nullable
as List<ImportSubStage>,migrationInProgress: null == migrationInProgress ? _self.migrationInProgress : migrationInProgress // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DbOnboardingState].
extension DbOnboardingStatePatterns on DbOnboardingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DbOnboardingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DbOnboardingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DbOnboardingState value)  $default,){
final _that = this;
switch (_that) {
case _DbOnboardingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DbOnboardingState value)?  $default,){
final _that = this;
switch (_that) {
case _DbOnboardingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DbOnboardingPhase currentPhase,  bool fdaGranted,  bool messagesDbFound,  bool contactsDbFound,  bool importComplete,  bool devMode,  int phaseMinDurationMs,  bool onboardingStarted,  String? errorMessage,  double? progressPercent,  int? importCurrent,  int? importTotal,  String? importStatusMessage,  List<ImportSubStage> importSubStages,  bool migrationInProgress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DbOnboardingState() when $default != null:
return $default(_that.currentPhase,_that.fdaGranted,_that.messagesDbFound,_that.contactsDbFound,_that.importComplete,_that.devMode,_that.phaseMinDurationMs,_that.onboardingStarted,_that.errorMessage,_that.progressPercent,_that.importCurrent,_that.importTotal,_that.importStatusMessage,_that.importSubStages,_that.migrationInProgress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DbOnboardingPhase currentPhase,  bool fdaGranted,  bool messagesDbFound,  bool contactsDbFound,  bool importComplete,  bool devMode,  int phaseMinDurationMs,  bool onboardingStarted,  String? errorMessage,  double? progressPercent,  int? importCurrent,  int? importTotal,  String? importStatusMessage,  List<ImportSubStage> importSubStages,  bool migrationInProgress)  $default,) {final _that = this;
switch (_that) {
case _DbOnboardingState():
return $default(_that.currentPhase,_that.fdaGranted,_that.messagesDbFound,_that.contactsDbFound,_that.importComplete,_that.devMode,_that.phaseMinDurationMs,_that.onboardingStarted,_that.errorMessage,_that.progressPercent,_that.importCurrent,_that.importTotal,_that.importStatusMessage,_that.importSubStages,_that.migrationInProgress);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DbOnboardingPhase currentPhase,  bool fdaGranted,  bool messagesDbFound,  bool contactsDbFound,  bool importComplete,  bool devMode,  int phaseMinDurationMs,  bool onboardingStarted,  String? errorMessage,  double? progressPercent,  int? importCurrent,  int? importTotal,  String? importStatusMessage,  List<ImportSubStage> importSubStages,  bool migrationInProgress)?  $default,) {final _that = this;
switch (_that) {
case _DbOnboardingState() when $default != null:
return $default(_that.currentPhase,_that.fdaGranted,_that.messagesDbFound,_that.contactsDbFound,_that.importComplete,_that.devMode,_that.phaseMinDurationMs,_that.onboardingStarted,_that.errorMessage,_that.progressPercent,_that.importCurrent,_that.importTotal,_that.importStatusMessage,_that.importSubStages,_that.migrationInProgress);case _:
  return null;

}
}

}

/// @nodoc


class _DbOnboardingState implements DbOnboardingState {
  const _DbOnboardingState({required this.currentPhase, required this.fdaGranted, required this.messagesDbFound, required this.contactsDbFound, required this.importComplete, this.devMode = false, this.phaseMinDurationMs = 1000, this.onboardingStarted = false, this.errorMessage, this.progressPercent, this.importCurrent, this.importTotal, this.importStatusMessage, final  List<ImportSubStage> importSubStages = const <ImportSubStage>[], this.migrationInProgress = false}): _importSubStages = importSubStages;
  

/// The current phase being displayed in the stepper.
@override final  DbOnboardingPhase currentPhase;
/// Whether Full Disk Access has been granted.
@override final  bool fdaGranted;
/// Whether the Messages database (chat.db) was found.
@override final  bool messagesDbFound;
/// Whether the Contacts database (AddressBook) was found.
@override final  bool contactsDbFound;
/// Whether the import process has completed successfully.
@override final  bool importComplete;
/// Whether onboarding is running in developer mode.
///
/// When true, the fullscreen overlay is suppressed and progress
/// is shown inline in the developer tools panel.
@override@JsonKey() final  bool devMode;
/// Minimum duration (milliseconds) each onboarding phase should be visible.
///
/// This is primarily exposed for developer tools UX tuning.
@override@JsonKey() final  int phaseMinDurationMs;
/// Whether the onboarding flow has been explicitly started.
///
/// Used by UI to differentiate a true virgin/reset state from an
/// active permission-check phase.
@override@JsonKey() final  bool onboardingStarted;
/// Optional error message if the current phase is [DbOnboardingPhase.error].
@override final  String? errorMessage;
/// Optional progress percentage for the current phase (0.0 to 1.0).
@override final  double? progressPercent;
/// Current count for import progress (e.g., messages imported so far).
@override final  int? importCurrent;
/// Total count for import progress (e.g., total messages to import).
@override final  int? importTotal;
/// Human-readable description of current import activity.
@override final  String? importStatusMessage;
/// List of import sub-stages with their individual progress.
///
/// These are the granular steps within a main phase (e.g., "Importing Messages"
/// contains sub-stages like "Importing handles", "Importing chats", etc.)
 final  List<ImportSubStage> _importSubStages;
/// List of import sub-stages with their individual progress.
///
/// These are the granular steps within a main phase (e.g., "Importing Messages"
/// contains sub-stages like "Importing handles", "Importing chats", etc.)
@override@JsonKey() List<ImportSubStage> get importSubStages {
  if (_importSubStages is EqualUnmodifiableListView) return _importSubStages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_importSubStages);
}

/// True while migration is running after import has completed.
///
/// This lets the onboarding UI show a clearer "finalizing" label instead
/// of implying contacts import is still active.
@override@JsonKey() final  bool migrationInProgress;

/// Create a copy of DbOnboardingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DbOnboardingStateCopyWith<_DbOnboardingState> get copyWith => __$DbOnboardingStateCopyWithImpl<_DbOnboardingState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DbOnboardingState&&(identical(other.currentPhase, currentPhase) || other.currentPhase == currentPhase)&&(identical(other.fdaGranted, fdaGranted) || other.fdaGranted == fdaGranted)&&(identical(other.messagesDbFound, messagesDbFound) || other.messagesDbFound == messagesDbFound)&&(identical(other.contactsDbFound, contactsDbFound) || other.contactsDbFound == contactsDbFound)&&(identical(other.importComplete, importComplete) || other.importComplete == importComplete)&&(identical(other.devMode, devMode) || other.devMode == devMode)&&(identical(other.phaseMinDurationMs, phaseMinDurationMs) || other.phaseMinDurationMs == phaseMinDurationMs)&&(identical(other.onboardingStarted, onboardingStarted) || other.onboardingStarted == onboardingStarted)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.progressPercent, progressPercent) || other.progressPercent == progressPercent)&&(identical(other.importCurrent, importCurrent) || other.importCurrent == importCurrent)&&(identical(other.importTotal, importTotal) || other.importTotal == importTotal)&&(identical(other.importStatusMessage, importStatusMessage) || other.importStatusMessage == importStatusMessage)&&const DeepCollectionEquality().equals(other._importSubStages, _importSubStages)&&(identical(other.migrationInProgress, migrationInProgress) || other.migrationInProgress == migrationInProgress));
}


@override
int get hashCode => Object.hash(runtimeType,currentPhase,fdaGranted,messagesDbFound,contactsDbFound,importComplete,devMode,phaseMinDurationMs,onboardingStarted,errorMessage,progressPercent,importCurrent,importTotal,importStatusMessage,const DeepCollectionEquality().hash(_importSubStages),migrationInProgress);

@override
String toString() {
  return 'DbOnboardingState(currentPhase: $currentPhase, fdaGranted: $fdaGranted, messagesDbFound: $messagesDbFound, contactsDbFound: $contactsDbFound, importComplete: $importComplete, devMode: $devMode, phaseMinDurationMs: $phaseMinDurationMs, onboardingStarted: $onboardingStarted, errorMessage: $errorMessage, progressPercent: $progressPercent, importCurrent: $importCurrent, importTotal: $importTotal, importStatusMessage: $importStatusMessage, importSubStages: $importSubStages, migrationInProgress: $migrationInProgress)';
}


}

/// @nodoc
abstract mixin class _$DbOnboardingStateCopyWith<$Res> implements $DbOnboardingStateCopyWith<$Res> {
  factory _$DbOnboardingStateCopyWith(_DbOnboardingState value, $Res Function(_DbOnboardingState) _then) = __$DbOnboardingStateCopyWithImpl;
@override @useResult
$Res call({
 DbOnboardingPhase currentPhase, bool fdaGranted, bool messagesDbFound, bool contactsDbFound, bool importComplete, bool devMode, int phaseMinDurationMs, bool onboardingStarted, String? errorMessage, double? progressPercent, int? importCurrent, int? importTotal, String? importStatusMessage, List<ImportSubStage> importSubStages, bool migrationInProgress
});




}
/// @nodoc
class __$DbOnboardingStateCopyWithImpl<$Res>
    implements _$DbOnboardingStateCopyWith<$Res> {
  __$DbOnboardingStateCopyWithImpl(this._self, this._then);

  final _DbOnboardingState _self;
  final $Res Function(_DbOnboardingState) _then;

/// Create a copy of DbOnboardingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentPhase = null,Object? fdaGranted = null,Object? messagesDbFound = null,Object? contactsDbFound = null,Object? importComplete = null,Object? devMode = null,Object? phaseMinDurationMs = null,Object? onboardingStarted = null,Object? errorMessage = freezed,Object? progressPercent = freezed,Object? importCurrent = freezed,Object? importTotal = freezed,Object? importStatusMessage = freezed,Object? importSubStages = null,Object? migrationInProgress = null,}) {
  return _then(_DbOnboardingState(
currentPhase: null == currentPhase ? _self.currentPhase : currentPhase // ignore: cast_nullable_to_non_nullable
as DbOnboardingPhase,fdaGranted: null == fdaGranted ? _self.fdaGranted : fdaGranted // ignore: cast_nullable_to_non_nullable
as bool,messagesDbFound: null == messagesDbFound ? _self.messagesDbFound : messagesDbFound // ignore: cast_nullable_to_non_nullable
as bool,contactsDbFound: null == contactsDbFound ? _self.contactsDbFound : contactsDbFound // ignore: cast_nullable_to_non_nullable
as bool,importComplete: null == importComplete ? _self.importComplete : importComplete // ignore: cast_nullable_to_non_nullable
as bool,devMode: null == devMode ? _self.devMode : devMode // ignore: cast_nullable_to_non_nullable
as bool,phaseMinDurationMs: null == phaseMinDurationMs ? _self.phaseMinDurationMs : phaseMinDurationMs // ignore: cast_nullable_to_non_nullable
as int,onboardingStarted: null == onboardingStarted ? _self.onboardingStarted : onboardingStarted // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,progressPercent: freezed == progressPercent ? _self.progressPercent : progressPercent // ignore: cast_nullable_to_non_nullable
as double?,importCurrent: freezed == importCurrent ? _self.importCurrent : importCurrent // ignore: cast_nullable_to_non_nullable
as int?,importTotal: freezed == importTotal ? _self.importTotal : importTotal // ignore: cast_nullable_to_non_nullable
as int?,importStatusMessage: freezed == importStatusMessage ? _self.importStatusMessage : importStatusMessage // ignore: cast_nullable_to_non_nullable
as String?,importSubStages: null == importSubStages ? _self._importSubStages : importSubStages // ignore: cast_nullable_to_non_nullable
as List<ImportSubStage>,migrationInProgress: null == migrationInProgress ? _self.migrationInProgress : migrationInProgress // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
