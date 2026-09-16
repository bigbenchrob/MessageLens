// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resolved_attachment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ResolvedAttachment {

 AttachmentInfo get attachmentInfo; ResolvedAttachmentAvailability get availability; AttachmentProvenance? get provenance; String? get resolvedFilePath; AttachmentRecoveryMetadata? get recoveryMetadata; AttachmentArchivePayloadStatus? get archivePayloadStatus; AttachmentArchiveLocationAvailability? get archiveRootAvailability; int? get archiveLocationGeneration; String? get archiveRootIssue;
/// Create a copy of ResolvedAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedAttachmentCopyWith<ResolvedAttachment> get copyWith => _$ResolvedAttachmentCopyWithImpl<ResolvedAttachment>(this as ResolvedAttachment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedAttachment&&(identical(other.attachmentInfo, attachmentInfo) || other.attachmentInfo == attachmentInfo)&&(identical(other.availability, availability) || other.availability == availability)&&(identical(other.provenance, provenance) || other.provenance == provenance)&&(identical(other.resolvedFilePath, resolvedFilePath) || other.resolvedFilePath == resolvedFilePath)&&(identical(other.recoveryMetadata, recoveryMetadata) || other.recoveryMetadata == recoveryMetadata)&&(identical(other.archivePayloadStatus, archivePayloadStatus) || other.archivePayloadStatus == archivePayloadStatus)&&(identical(other.archiveRootAvailability, archiveRootAvailability) || other.archiveRootAvailability == archiveRootAvailability)&&(identical(other.archiveLocationGeneration, archiveLocationGeneration) || other.archiveLocationGeneration == archiveLocationGeneration)&&(identical(other.archiveRootIssue, archiveRootIssue) || other.archiveRootIssue == archiveRootIssue));
}


@override
int get hashCode => Object.hash(runtimeType,attachmentInfo,availability,provenance,resolvedFilePath,recoveryMetadata,archivePayloadStatus,archiveRootAvailability,archiveLocationGeneration,archiveRootIssue);

@override
String toString() {
  return 'ResolvedAttachment(attachmentInfo: $attachmentInfo, availability: $availability, provenance: $provenance, resolvedFilePath: $resolvedFilePath, recoveryMetadata: $recoveryMetadata, archivePayloadStatus: $archivePayloadStatus, archiveRootAvailability: $archiveRootAvailability, archiveLocationGeneration: $archiveLocationGeneration, archiveRootIssue: $archiveRootIssue)';
}


}

/// @nodoc
abstract mixin class $ResolvedAttachmentCopyWith<$Res>  {
  factory $ResolvedAttachmentCopyWith(ResolvedAttachment value, $Res Function(ResolvedAttachment) _then) = _$ResolvedAttachmentCopyWithImpl;
@useResult
$Res call({
 AttachmentInfo attachmentInfo, ResolvedAttachmentAvailability availability, AttachmentProvenance? provenance, String? resolvedFilePath, AttachmentRecoveryMetadata? recoveryMetadata, AttachmentArchivePayloadStatus? archivePayloadStatus, AttachmentArchiveLocationAvailability? archiveRootAvailability, int? archiveLocationGeneration, String? archiveRootIssue
});




}
/// @nodoc
class _$ResolvedAttachmentCopyWithImpl<$Res>
    implements $ResolvedAttachmentCopyWith<$Res> {
  _$ResolvedAttachmentCopyWithImpl(this._self, this._then);

  final ResolvedAttachment _self;
  final $Res Function(ResolvedAttachment) _then;

/// Create a copy of ResolvedAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? attachmentInfo = null,Object? availability = null,Object? provenance = freezed,Object? resolvedFilePath = freezed,Object? recoveryMetadata = freezed,Object? archivePayloadStatus = freezed,Object? archiveRootAvailability = freezed,Object? archiveLocationGeneration = freezed,Object? archiveRootIssue = freezed,}) {
  return _then(_self.copyWith(
attachmentInfo: null == attachmentInfo ? _self.attachmentInfo : attachmentInfo // ignore: cast_nullable_to_non_nullable
as AttachmentInfo,availability: null == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as ResolvedAttachmentAvailability,provenance: freezed == provenance ? _self.provenance : provenance // ignore: cast_nullable_to_non_nullable
as AttachmentProvenance?,resolvedFilePath: freezed == resolvedFilePath ? _self.resolvedFilePath : resolvedFilePath // ignore: cast_nullable_to_non_nullable
as String?,recoveryMetadata: freezed == recoveryMetadata ? _self.recoveryMetadata : recoveryMetadata // ignore: cast_nullable_to_non_nullable
as AttachmentRecoveryMetadata?,archivePayloadStatus: freezed == archivePayloadStatus ? _self.archivePayloadStatus : archivePayloadStatus // ignore: cast_nullable_to_non_nullable
as AttachmentArchivePayloadStatus?,archiveRootAvailability: freezed == archiveRootAvailability ? _self.archiveRootAvailability : archiveRootAvailability // ignore: cast_nullable_to_non_nullable
as AttachmentArchiveLocationAvailability?,archiveLocationGeneration: freezed == archiveLocationGeneration ? _self.archiveLocationGeneration : archiveLocationGeneration // ignore: cast_nullable_to_non_nullable
as int?,archiveRootIssue: freezed == archiveRootIssue ? _self.archiveRootIssue : archiveRootIssue // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ResolvedAttachment].
extension ResolvedAttachmentPatterns on ResolvedAttachment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResolvedAttachment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResolvedAttachment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResolvedAttachment value)  $default,){
final _that = this;
switch (_that) {
case _ResolvedAttachment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResolvedAttachment value)?  $default,){
final _that = this;
switch (_that) {
case _ResolvedAttachment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AttachmentInfo attachmentInfo,  ResolvedAttachmentAvailability availability,  AttachmentProvenance? provenance,  String? resolvedFilePath,  AttachmentRecoveryMetadata? recoveryMetadata,  AttachmentArchivePayloadStatus? archivePayloadStatus,  AttachmentArchiveLocationAvailability? archiveRootAvailability,  int? archiveLocationGeneration,  String? archiveRootIssue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResolvedAttachment() when $default != null:
return $default(_that.attachmentInfo,_that.availability,_that.provenance,_that.resolvedFilePath,_that.recoveryMetadata,_that.archivePayloadStatus,_that.archiveRootAvailability,_that.archiveLocationGeneration,_that.archiveRootIssue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AttachmentInfo attachmentInfo,  ResolvedAttachmentAvailability availability,  AttachmentProvenance? provenance,  String? resolvedFilePath,  AttachmentRecoveryMetadata? recoveryMetadata,  AttachmentArchivePayloadStatus? archivePayloadStatus,  AttachmentArchiveLocationAvailability? archiveRootAvailability,  int? archiveLocationGeneration,  String? archiveRootIssue)  $default,) {final _that = this;
switch (_that) {
case _ResolvedAttachment():
return $default(_that.attachmentInfo,_that.availability,_that.provenance,_that.resolvedFilePath,_that.recoveryMetadata,_that.archivePayloadStatus,_that.archiveRootAvailability,_that.archiveLocationGeneration,_that.archiveRootIssue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AttachmentInfo attachmentInfo,  ResolvedAttachmentAvailability availability,  AttachmentProvenance? provenance,  String? resolvedFilePath,  AttachmentRecoveryMetadata? recoveryMetadata,  AttachmentArchivePayloadStatus? archivePayloadStatus,  AttachmentArchiveLocationAvailability? archiveRootAvailability,  int? archiveLocationGeneration,  String? archiveRootIssue)?  $default,) {final _that = this;
switch (_that) {
case _ResolvedAttachment() when $default != null:
return $default(_that.attachmentInfo,_that.availability,_that.provenance,_that.resolvedFilePath,_that.recoveryMetadata,_that.archivePayloadStatus,_that.archiveRootAvailability,_that.archiveLocationGeneration,_that.archiveRootIssue);case _:
  return null;

}
}

}

/// @nodoc


class _ResolvedAttachment extends ResolvedAttachment {
  const _ResolvedAttachment({required this.attachmentInfo, required this.availability, this.provenance, this.resolvedFilePath, this.recoveryMetadata, this.archivePayloadStatus, this.archiveRootAvailability, this.archiveLocationGeneration, this.archiveRootIssue}): super._();
  

@override final  AttachmentInfo attachmentInfo;
@override final  ResolvedAttachmentAvailability availability;
@override final  AttachmentProvenance? provenance;
@override final  String? resolvedFilePath;
@override final  AttachmentRecoveryMetadata? recoveryMetadata;
@override final  AttachmentArchivePayloadStatus? archivePayloadStatus;
@override final  AttachmentArchiveLocationAvailability? archiveRootAvailability;
@override final  int? archiveLocationGeneration;
@override final  String? archiveRootIssue;

/// Create a copy of ResolvedAttachment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResolvedAttachmentCopyWith<_ResolvedAttachment> get copyWith => __$ResolvedAttachmentCopyWithImpl<_ResolvedAttachment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResolvedAttachment&&(identical(other.attachmentInfo, attachmentInfo) || other.attachmentInfo == attachmentInfo)&&(identical(other.availability, availability) || other.availability == availability)&&(identical(other.provenance, provenance) || other.provenance == provenance)&&(identical(other.resolvedFilePath, resolvedFilePath) || other.resolvedFilePath == resolvedFilePath)&&(identical(other.recoveryMetadata, recoveryMetadata) || other.recoveryMetadata == recoveryMetadata)&&(identical(other.archivePayloadStatus, archivePayloadStatus) || other.archivePayloadStatus == archivePayloadStatus)&&(identical(other.archiveRootAvailability, archiveRootAvailability) || other.archiveRootAvailability == archiveRootAvailability)&&(identical(other.archiveLocationGeneration, archiveLocationGeneration) || other.archiveLocationGeneration == archiveLocationGeneration)&&(identical(other.archiveRootIssue, archiveRootIssue) || other.archiveRootIssue == archiveRootIssue));
}


@override
int get hashCode => Object.hash(runtimeType,attachmentInfo,availability,provenance,resolvedFilePath,recoveryMetadata,archivePayloadStatus,archiveRootAvailability,archiveLocationGeneration,archiveRootIssue);

@override
String toString() {
  return 'ResolvedAttachment(attachmentInfo: $attachmentInfo, availability: $availability, provenance: $provenance, resolvedFilePath: $resolvedFilePath, recoveryMetadata: $recoveryMetadata, archivePayloadStatus: $archivePayloadStatus, archiveRootAvailability: $archiveRootAvailability, archiveLocationGeneration: $archiveLocationGeneration, archiveRootIssue: $archiveRootIssue)';
}


}

/// @nodoc
abstract mixin class _$ResolvedAttachmentCopyWith<$Res> implements $ResolvedAttachmentCopyWith<$Res> {
  factory _$ResolvedAttachmentCopyWith(_ResolvedAttachment value, $Res Function(_ResolvedAttachment) _then) = __$ResolvedAttachmentCopyWithImpl;
@override @useResult
$Res call({
 AttachmentInfo attachmentInfo, ResolvedAttachmentAvailability availability, AttachmentProvenance? provenance, String? resolvedFilePath, AttachmentRecoveryMetadata? recoveryMetadata, AttachmentArchivePayloadStatus? archivePayloadStatus, AttachmentArchiveLocationAvailability? archiveRootAvailability, int? archiveLocationGeneration, String? archiveRootIssue
});




}
/// @nodoc
class __$ResolvedAttachmentCopyWithImpl<$Res>
    implements _$ResolvedAttachmentCopyWith<$Res> {
  __$ResolvedAttachmentCopyWithImpl(this._self, this._then);

  final _ResolvedAttachment _self;
  final $Res Function(_ResolvedAttachment) _then;

/// Create a copy of ResolvedAttachment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? attachmentInfo = null,Object? availability = null,Object? provenance = freezed,Object? resolvedFilePath = freezed,Object? recoveryMetadata = freezed,Object? archivePayloadStatus = freezed,Object? archiveRootAvailability = freezed,Object? archiveLocationGeneration = freezed,Object? archiveRootIssue = freezed,}) {
  return _then(_ResolvedAttachment(
attachmentInfo: null == attachmentInfo ? _self.attachmentInfo : attachmentInfo // ignore: cast_nullable_to_non_nullable
as AttachmentInfo,availability: null == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as ResolvedAttachmentAvailability,provenance: freezed == provenance ? _self.provenance : provenance // ignore: cast_nullable_to_non_nullable
as AttachmentProvenance?,resolvedFilePath: freezed == resolvedFilePath ? _self.resolvedFilePath : resolvedFilePath // ignore: cast_nullable_to_non_nullable
as String?,recoveryMetadata: freezed == recoveryMetadata ? _self.recoveryMetadata : recoveryMetadata // ignore: cast_nullable_to_non_nullable
as AttachmentRecoveryMetadata?,archivePayloadStatus: freezed == archivePayloadStatus ? _self.archivePayloadStatus : archivePayloadStatus // ignore: cast_nullable_to_non_nullable
as AttachmentArchivePayloadStatus?,archiveRootAvailability: freezed == archiveRootAvailability ? _self.archiveRootAvailability : archiveRootAvailability // ignore: cast_nullable_to_non_nullable
as AttachmentArchiveLocationAvailability?,archiveLocationGeneration: freezed == archiveLocationGeneration ? _self.archiveLocationGeneration : archiveLocationGeneration // ignore: cast_nullable_to_non_nullable
as int?,archiveRootIssue: freezed == archiveRootIssue ? _self.archiveRootIssue : archiveRootIssue // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
