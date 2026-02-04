// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tooltip_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TooltipSpec {

 ContactsTooltipSpec get spec;
/// Create a copy of TooltipSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TooltipSpecCopyWith<TooltipSpec> get copyWith => _$TooltipSpecCopyWithImpl<TooltipSpec>(this as TooltipSpec, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TooltipSpec&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'TooltipSpec(spec: $spec)';
}


}

/// @nodoc
abstract mixin class $TooltipSpecCopyWith<$Res>  {
  factory $TooltipSpecCopyWith(TooltipSpec value, $Res Function(TooltipSpec) _then) = _$TooltipSpecCopyWithImpl;
@useResult
$Res call({
 ContactsTooltipSpec spec
});


$ContactsTooltipSpecCopyWith<$Res> get spec;

}
/// @nodoc
class _$TooltipSpecCopyWithImpl<$Res>
    implements $TooltipSpecCopyWith<$Res> {
  _$TooltipSpecCopyWithImpl(this._self, this._then);

  final TooltipSpec _self;
  final $Res Function(TooltipSpec) _then;

/// Create a copy of TooltipSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? spec = null,}) {
  return _then(_self.copyWith(
spec: null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as ContactsTooltipSpec,
  ));
}
/// Create a copy of TooltipSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactsTooltipSpecCopyWith<$Res> get spec {
  
  return $ContactsTooltipSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}


/// Adds pattern-matching-related methods to [TooltipSpec].
extension TooltipSpecPatterns on TooltipSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ContactsTooltip value)?  contacts,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ContactsTooltip() when contacts != null:
return contacts(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ContactsTooltip value)  contacts,}){
final _that = this;
switch (_that) {
case ContactsTooltip():
return contacts(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ContactsTooltip value)?  contacts,}){
final _that = this;
switch (_that) {
case ContactsTooltip() when contacts != null:
return contacts(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( ContactsTooltipSpec spec)?  contacts,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ContactsTooltip() when contacts != null:
return contacts(_that.spec);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( ContactsTooltipSpec spec)  contacts,}) {final _that = this;
switch (_that) {
case ContactsTooltip():
return contacts(_that.spec);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( ContactsTooltipSpec spec)?  contacts,}) {final _that = this;
switch (_that) {
case ContactsTooltip() when contacts != null:
return contacts(_that.spec);case _:
  return null;

}
}

}

/// @nodoc


class ContactsTooltip extends TooltipSpec {
  const ContactsTooltip(this.spec): super._();
  

@override final  ContactsTooltipSpec spec;

/// Create a copy of TooltipSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactsTooltipCopyWith<ContactsTooltip> get copyWith => _$ContactsTooltipCopyWithImpl<ContactsTooltip>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactsTooltip&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'TooltipSpec.contacts(spec: $spec)';
}


}

/// @nodoc
abstract mixin class $ContactsTooltipCopyWith<$Res> implements $TooltipSpecCopyWith<$Res> {
  factory $ContactsTooltipCopyWith(ContactsTooltip value, $Res Function(ContactsTooltip) _then) = _$ContactsTooltipCopyWithImpl;
@override @useResult
$Res call({
 ContactsTooltipSpec spec
});


@override $ContactsTooltipSpecCopyWith<$Res> get spec;

}
/// @nodoc
class _$ContactsTooltipCopyWithImpl<$Res>
    implements $ContactsTooltipCopyWith<$Res> {
  _$ContactsTooltipCopyWithImpl(this._self, this._then);

  final ContactsTooltip _self;
  final $Res Function(ContactsTooltip) _then;

/// Create a copy of TooltipSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(ContactsTooltip(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as ContactsTooltipSpec,
  ));
}

/// Create a copy of TooltipSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactsTooltipSpecCopyWith<$Res> get spec {
  
  return $ContactsTooltipSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

// dart format on
