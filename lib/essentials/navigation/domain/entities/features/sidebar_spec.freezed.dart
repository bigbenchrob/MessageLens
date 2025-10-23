// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sidebar_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SidebarSpec {

 Object get listMode;



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SidebarSpec&&const DeepCollectionEquality().equals(other.listMode, listMode));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(listMode));

@override
String toString() {
  return 'SidebarSpec(listMode: $listMode)';
}


}

/// @nodoc
class $SidebarSpecCopyWith<$Res>  {
$SidebarSpecCopyWith(SidebarSpec _, $Res Function(SidebarSpec) __);
}


/// Adds pattern-matching-related methods to [SidebarSpec].
extension SidebarSpecPatterns on SidebarSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SidebarSpecContacts value)?  contacts,TResult Function( SidebarSpecUnmatchedHandles value)?  unmatchedHandles,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SidebarSpecContacts() when contacts != null:
return contacts(_that);case SidebarSpecUnmatchedHandles() when unmatchedHandles != null:
return unmatchedHandles(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SidebarSpecContacts value)  contacts,required TResult Function( SidebarSpecUnmatchedHandles value)  unmatchedHandles,}){
final _that = this;
switch (_that) {
case SidebarSpecContacts():
return contacts(_that);case SidebarSpecUnmatchedHandles():
return unmatchedHandles(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SidebarSpecContacts value)?  contacts,TResult? Function( SidebarSpecUnmatchedHandles value)?  unmatchedHandles,}){
final _that = this;
switch (_that) {
case SidebarSpecContacts() when contacts != null:
return contacts(_that);case SidebarSpecUnmatchedHandles() when unmatchedHandles != null:
return unmatchedHandles(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( ContactsListSpec listMode,  int? selectedParticipantId,  ChatViewMode chatViewMode)?  contacts,TResult Function( HandlesListSpec listMode)?  unmatchedHandles,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SidebarSpecContacts() when contacts != null:
return contacts(_that.listMode,_that.selectedParticipantId,_that.chatViewMode);case SidebarSpecUnmatchedHandles() when unmatchedHandles != null:
return unmatchedHandles(_that.listMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( ContactsListSpec listMode,  int? selectedParticipantId,  ChatViewMode chatViewMode)  contacts,required TResult Function( HandlesListSpec listMode)  unmatchedHandles,}) {final _that = this;
switch (_that) {
case SidebarSpecContacts():
return contacts(_that.listMode,_that.selectedParticipantId,_that.chatViewMode);case SidebarSpecUnmatchedHandles():
return unmatchedHandles(_that.listMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( ContactsListSpec listMode,  int? selectedParticipantId,  ChatViewMode chatViewMode)?  contacts,TResult? Function( HandlesListSpec listMode)?  unmatchedHandles,}) {final _that = this;
switch (_that) {
case SidebarSpecContacts() when contacts != null:
return contacts(_that.listMode,_that.selectedParticipantId,_that.chatViewMode);case SidebarSpecUnmatchedHandles() when unmatchedHandles != null:
return unmatchedHandles(_that.listMode);case _:
  return null;

}
}

}

/// @nodoc


class SidebarSpecContacts implements SidebarSpec {
  const SidebarSpecContacts({required this.listMode, this.selectedParticipantId, this.chatViewMode = ChatViewMode.recentActivity});
  

@override final  ContactsListSpec listMode;
 final  int? selectedParticipantId;
@JsonKey() final  ChatViewMode chatViewMode;

/// Create a copy of SidebarSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SidebarSpecContactsCopyWith<SidebarSpecContacts> get copyWith => _$SidebarSpecContactsCopyWithImpl<SidebarSpecContacts>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SidebarSpecContacts&&(identical(other.listMode, listMode) || other.listMode == listMode)&&(identical(other.selectedParticipantId, selectedParticipantId) || other.selectedParticipantId == selectedParticipantId)&&(identical(other.chatViewMode, chatViewMode) || other.chatViewMode == chatViewMode));
}


@override
int get hashCode => Object.hash(runtimeType,listMode,selectedParticipantId,chatViewMode);

@override
String toString() {
  return 'SidebarSpec.contacts(listMode: $listMode, selectedParticipantId: $selectedParticipantId, chatViewMode: $chatViewMode)';
}


}

/// @nodoc
abstract mixin class $SidebarSpecContactsCopyWith<$Res> implements $SidebarSpecCopyWith<$Res> {
  factory $SidebarSpecContactsCopyWith(SidebarSpecContacts value, $Res Function(SidebarSpecContacts) _then) = _$SidebarSpecContactsCopyWithImpl;
@useResult
$Res call({
 ContactsListSpec listMode, int? selectedParticipantId, ChatViewMode chatViewMode
});


$ContactsListSpecCopyWith<$Res> get listMode;

}
/// @nodoc
class _$SidebarSpecContactsCopyWithImpl<$Res>
    implements $SidebarSpecContactsCopyWith<$Res> {
  _$SidebarSpecContactsCopyWithImpl(this._self, this._then);

  final SidebarSpecContacts _self;
  final $Res Function(SidebarSpecContacts) _then;

/// Create a copy of SidebarSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? listMode = null,Object? selectedParticipantId = freezed,Object? chatViewMode = null,}) {
  return _then(SidebarSpecContacts(
listMode: null == listMode ? _self.listMode : listMode // ignore: cast_nullable_to_non_nullable
as ContactsListSpec,selectedParticipantId: freezed == selectedParticipantId ? _self.selectedParticipantId : selectedParticipantId // ignore: cast_nullable_to_non_nullable
as int?,chatViewMode: null == chatViewMode ? _self.chatViewMode : chatViewMode // ignore: cast_nullable_to_non_nullable
as ChatViewMode,
  ));
}

/// Create a copy of SidebarSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactsListSpecCopyWith<$Res> get listMode {
  
  return $ContactsListSpecCopyWith<$Res>(_self.listMode, (value) {
    return _then(_self.copyWith(listMode: value));
  });
}
}

/// @nodoc


class SidebarSpecUnmatchedHandles implements SidebarSpec {
  const SidebarSpecUnmatchedHandles({required this.listMode});
  

@override final  HandlesListSpec listMode;

/// Create a copy of SidebarSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SidebarSpecUnmatchedHandlesCopyWith<SidebarSpecUnmatchedHandles> get copyWith => _$SidebarSpecUnmatchedHandlesCopyWithImpl<SidebarSpecUnmatchedHandles>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SidebarSpecUnmatchedHandles&&(identical(other.listMode, listMode) || other.listMode == listMode));
}


@override
int get hashCode => Object.hash(runtimeType,listMode);

@override
String toString() {
  return 'SidebarSpec.unmatchedHandles(listMode: $listMode)';
}


}

/// @nodoc
abstract mixin class $SidebarSpecUnmatchedHandlesCopyWith<$Res> implements $SidebarSpecCopyWith<$Res> {
  factory $SidebarSpecUnmatchedHandlesCopyWith(SidebarSpecUnmatchedHandles value, $Res Function(SidebarSpecUnmatchedHandles) _then) = _$SidebarSpecUnmatchedHandlesCopyWithImpl;
@useResult
$Res call({
 HandlesListSpec listMode
});


$HandlesListSpecCopyWith<$Res> get listMode;

}
/// @nodoc
class _$SidebarSpecUnmatchedHandlesCopyWithImpl<$Res>
    implements $SidebarSpecUnmatchedHandlesCopyWith<$Res> {
  _$SidebarSpecUnmatchedHandlesCopyWithImpl(this._self, this._then);

  final SidebarSpecUnmatchedHandles _self;
  final $Res Function(SidebarSpecUnmatchedHandles) _then;

/// Create a copy of SidebarSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? listMode = null,}) {
  return _then(SidebarSpecUnmatchedHandles(
listMode: null == listMode ? _self.listMode : listMode // ignore: cast_nullable_to_non_nullable
as HandlesListSpec,
  ));
}

/// Create a copy of SidebarSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HandlesListSpecCopyWith<$Res> get listMode {
  
  return $HandlesListSpecCopyWith<$Res>(_self.listMode, (value) {
    return _then(_self.copyWith(listMode: value));
  });
}
}

// dart format on
