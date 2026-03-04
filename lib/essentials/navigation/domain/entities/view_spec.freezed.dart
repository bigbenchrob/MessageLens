// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'view_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ViewSpec {

 Object get spec;



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ViewSpec&&const DeepCollectionEquality().equals(other.spec, spec));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(spec));

@override
String toString() {
  return 'ViewSpec(spec: $spec)';
}


}

/// @nodoc
class $ViewSpecCopyWith<$Res>  {
$ViewSpecCopyWith(ViewSpec _, $Res Function(ViewSpec) __);
}


/// Adds pattern-matching-related methods to [ViewSpec].
extension ViewSpecPatterns on ViewSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ViewMessages value)?  messages,TResult Function( _ViewImport value)?  import,TResult Function( _ViewOnboarding value)?  onboarding,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ViewMessages() when messages != null:
return messages(_that);case _ViewImport() when import != null:
return import(_that);case _ViewOnboarding() when onboarding != null:
return onboarding(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ViewMessages value)  messages,required TResult Function( _ViewImport value)  import,required TResult Function( _ViewOnboarding value)  onboarding,}){
final _that = this;
switch (_that) {
case _ViewMessages():
return messages(_that);case _ViewImport():
return import(_that);case _ViewOnboarding():
return onboarding(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ViewMessages value)?  messages,TResult? Function( _ViewImport value)?  import,TResult? Function( _ViewOnboarding value)?  onboarding,}){
final _that = this;
switch (_that) {
case _ViewMessages() when messages != null:
return messages(_that);case _ViewImport() when import != null:
return import(_that);case _ViewOnboarding() when onboarding != null:
return onboarding(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( MessagesSpec spec)?  messages,TResult Function( ImportSpec spec)?  import,TResult Function( OnboardingSpec spec)?  onboarding,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ViewMessages() when messages != null:
return messages(_that.spec);case _ViewImport() when import != null:
return import(_that.spec);case _ViewOnboarding() when onboarding != null:
return onboarding(_that.spec);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( MessagesSpec spec)  messages,required TResult Function( ImportSpec spec)  import,required TResult Function( OnboardingSpec spec)  onboarding,}) {final _that = this;
switch (_that) {
case _ViewMessages():
return messages(_that.spec);case _ViewImport():
return import(_that.spec);case _ViewOnboarding():
return onboarding(_that.spec);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( MessagesSpec spec)?  messages,TResult? Function( ImportSpec spec)?  import,TResult? Function( OnboardingSpec spec)?  onboarding,}) {final _that = this;
switch (_that) {
case _ViewMessages() when messages != null:
return messages(_that.spec);case _ViewImport() when import != null:
return import(_that.spec);case _ViewOnboarding() when onboarding != null:
return onboarding(_that.spec);case _:
  return null;

}
}

}

/// @nodoc


class _ViewMessages implements ViewSpec {
  const _ViewMessages(this.spec);
  

@override final  MessagesSpec spec;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ViewMessagesCopyWith<_ViewMessages> get copyWith => __$ViewMessagesCopyWithImpl<_ViewMessages>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewMessages&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'ViewSpec.messages(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$ViewMessagesCopyWith<$Res> implements $ViewSpecCopyWith<$Res> {
  factory _$ViewMessagesCopyWith(_ViewMessages value, $Res Function(_ViewMessages) _then) = __$ViewMessagesCopyWithImpl;
@useResult
$Res call({
 MessagesSpec spec
});


$MessagesSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$ViewMessagesCopyWithImpl<$Res>
    implements _$ViewMessagesCopyWith<$Res> {
  __$ViewMessagesCopyWithImpl(this._self, this._then);

  final _ViewMessages _self;
  final $Res Function(_ViewMessages) _then;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_ViewMessages(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as MessagesSpec,
  ));
}

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessagesSpecCopyWith<$Res> get spec {
  
  return $MessagesSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

/// @nodoc


class _ViewImport implements ViewSpec {
  const _ViewImport(this.spec);
  

@override final  ImportSpec spec;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ViewImportCopyWith<_ViewImport> get copyWith => __$ViewImportCopyWithImpl<_ViewImport>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewImport&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'ViewSpec.import(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$ViewImportCopyWith<$Res> implements $ViewSpecCopyWith<$Res> {
  factory _$ViewImportCopyWith(_ViewImport value, $Res Function(_ViewImport) _then) = __$ViewImportCopyWithImpl;
@useResult
$Res call({
 ImportSpec spec
});


$ImportSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$ViewImportCopyWithImpl<$Res>
    implements _$ViewImportCopyWith<$Res> {
  __$ViewImportCopyWithImpl(this._self, this._then);

  final _ViewImport _self;
  final $Res Function(_ViewImport) _then;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_ViewImport(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as ImportSpec,
  ));
}

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImportSpecCopyWith<$Res> get spec {
  
  return $ImportSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

/// @nodoc


class _ViewOnboarding implements ViewSpec {
  const _ViewOnboarding(this.spec);
  

@override final  OnboardingSpec spec;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ViewOnboardingCopyWith<_ViewOnboarding> get copyWith => __$ViewOnboardingCopyWithImpl<_ViewOnboarding>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewOnboarding&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'ViewSpec.onboarding(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$ViewOnboardingCopyWith<$Res> implements $ViewSpecCopyWith<$Res> {
  factory _$ViewOnboardingCopyWith(_ViewOnboarding value, $Res Function(_ViewOnboarding) _then) = __$ViewOnboardingCopyWithImpl;
@useResult
$Res call({
 OnboardingSpec spec
});


$OnboardingSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$ViewOnboardingCopyWithImpl<$Res>
    implements _$ViewOnboardingCopyWith<$Res> {
  __$ViewOnboardingCopyWithImpl(this._self, this._then);

  final _ViewOnboarding _self;
  final $Res Function(_ViewOnboarding) _then;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_ViewOnboarding(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as OnboardingSpec,
  ));
}

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OnboardingSpecCopyWith<$Res> get spec {
  
  return $OnboardingSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

// dart format on
