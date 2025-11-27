// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sidebar_root_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SidebarRootSpec {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SidebarRootSpec);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SidebarRootSpec()';
}


}

/// @nodoc
class $SidebarRootSpecCopyWith<$Res>  {
$SidebarRootSpecCopyWith(SidebarRootSpec _, $Res Function(SidebarRootSpec) __);
}


/// Adds pattern-matching-related methods to [SidebarRootSpec].
extension SidebarRootSpecPatterns on SidebarRootSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ContactsRoot value)?  contacts,TResult Function( _UnmatchedRoot value)?  unmatched,TResult Function( _AllMessagesRoot value)?  allMessages,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactsRoot() when contacts != null:
return contacts(_that);case _UnmatchedRoot() when unmatched != null:
return unmatched(_that);case _AllMessagesRoot() when allMessages != null:
return allMessages(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ContactsRoot value)  contacts,required TResult Function( _UnmatchedRoot value)  unmatched,required TResult Function( _AllMessagesRoot value)  allMessages,}){
final _that = this;
switch (_that) {
case _ContactsRoot():
return contacts(_that);case _UnmatchedRoot():
return unmatched(_that);case _AllMessagesRoot():
return allMessages(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ContactsRoot value)?  contacts,TResult? Function( _UnmatchedRoot value)?  unmatched,TResult? Function( _AllMessagesRoot value)?  allMessages,}){
final _that = this;
switch (_that) {
case _ContactsRoot() when contacts != null:
return contacts(_that);case _UnmatchedRoot() when unmatched != null:
return unmatched(_that);case _AllMessagesRoot() when allMessages != null:
return allMessages(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  contacts,TResult Function()?  unmatched,TResult Function()?  allMessages,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactsRoot() when contacts != null:
return contacts();case _UnmatchedRoot() when unmatched != null:
return unmatched();case _AllMessagesRoot() when allMessages != null:
return allMessages();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  contacts,required TResult Function()  unmatched,required TResult Function()  allMessages,}) {final _that = this;
switch (_that) {
case _ContactsRoot():
return contacts();case _UnmatchedRoot():
return unmatched();case _AllMessagesRoot():
return allMessages();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  contacts,TResult? Function()?  unmatched,TResult? Function()?  allMessages,}) {final _that = this;
switch (_that) {
case _ContactsRoot() when contacts != null:
return contacts();case _UnmatchedRoot() when unmatched != null:
return unmatched();case _AllMessagesRoot() when allMessages != null:
return allMessages();case _:
  return null;

}
}

}

/// @nodoc


class _ContactsRoot implements SidebarRootSpec {
  const _ContactsRoot();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactsRoot);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SidebarRootSpec.contacts()';
}


}




/// @nodoc


class _UnmatchedRoot implements SidebarRootSpec {
  const _UnmatchedRoot();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnmatchedRoot);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SidebarRootSpec.unmatched()';
}


}




/// @nodoc


class _AllMessagesRoot implements SidebarRootSpec {
  const _AllMessagesRoot();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AllMessagesRoot);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SidebarRootSpec.allMessages()';
}


}




// dart format on
