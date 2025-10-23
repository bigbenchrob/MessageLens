// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contacts_list_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ContactsListSpec {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactsListSpec);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ContactsListSpec()';
}


}

/// @nodoc
class $ContactsListSpecCopyWith<$Res>  {
$ContactsListSpecCopyWith(ContactsListSpec _, $Res Function(ContactsListSpec) __);
}


/// Adds pattern-matching-related methods to [ContactsListSpec].
extension ContactsListSpecPatterns on ContactsListSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ContactsListSpecAll value)?  all,TResult Function( ContactsListSpecAlphabetical value)?  alphabetical,TResult Function( ContactsListSpecFavorites value)?  favorites,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ContactsListSpecAll() when all != null:
return all(_that);case ContactsListSpecAlphabetical() when alphabetical != null:
return alphabetical(_that);case ContactsListSpecFavorites() when favorites != null:
return favorites(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ContactsListSpecAll value)  all,required TResult Function( ContactsListSpecAlphabetical value)  alphabetical,required TResult Function( ContactsListSpecFavorites value)  favorites,}){
final _that = this;
switch (_that) {
case ContactsListSpecAll():
return all(_that);case ContactsListSpecAlphabetical():
return alphabetical(_that);case ContactsListSpecFavorites():
return favorites(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ContactsListSpecAll value)?  all,TResult? Function( ContactsListSpecAlphabetical value)?  alphabetical,TResult? Function( ContactsListSpecFavorites value)?  favorites,}){
final _that = this;
switch (_that) {
case ContactsListSpecAll() when all != null:
return all(_that);case ContactsListSpecAlphabetical() when alphabetical != null:
return alphabetical(_that);case ContactsListSpecFavorites() when favorites != null:
return favorites(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  all,TResult Function()?  alphabetical,TResult Function()?  favorites,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ContactsListSpecAll() when all != null:
return all();case ContactsListSpecAlphabetical() when alphabetical != null:
return alphabetical();case ContactsListSpecFavorites() when favorites != null:
return favorites();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  all,required TResult Function()  alphabetical,required TResult Function()  favorites,}) {final _that = this;
switch (_that) {
case ContactsListSpecAll():
return all();case ContactsListSpecAlphabetical():
return alphabetical();case ContactsListSpecFavorites():
return favorites();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  all,TResult? Function()?  alphabetical,TResult? Function()?  favorites,}) {final _that = this;
switch (_that) {
case ContactsListSpecAll() when all != null:
return all();case ContactsListSpecAlphabetical() when alphabetical != null:
return alphabetical();case ContactsListSpecFavorites() when favorites != null:
return favorites();case _:
  return null;

}
}

}

/// @nodoc


class ContactsListSpecAll implements ContactsListSpec {
  const ContactsListSpecAll();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactsListSpecAll);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ContactsListSpec.all()';
}


}




/// @nodoc


class ContactsListSpecAlphabetical implements ContactsListSpec {
  const ContactsListSpecAlphabetical();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactsListSpecAlphabetical);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ContactsListSpec.alphabetical()';
}


}




/// @nodoc


class ContactsListSpecFavorites implements ContactsListSpec {
  const ContactsListSpecFavorites();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactsListSpecFavorites);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ContactsListSpec.favorites()';
}


}




// dart format on
