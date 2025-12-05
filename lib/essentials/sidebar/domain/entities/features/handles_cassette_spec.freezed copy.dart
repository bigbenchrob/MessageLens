// // GENERATED CODE - DO NOT MODIFY BY HAND
// // coverage:ignore-file
// // ignore_for_file: type=lint
// // ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

// part of 'handles_cassette_spec.dart';

// // **************************************************************************
// // FreezedGenerator
// // **************************************************************************

// // dart format off
// T _$identity<T>(T value) => value;
// /// @nodoc
// mixin _$HandlesCassetteSpec {

//  int? get chosenContactId;
// /// Create a copy of HandlesCassetteSpec
// /// with the given fields replaced by the non-null parameter values.
// @JsonKey(includeFromJson: false, includeToJson: false)
// @pragma('vm:prefer-inline')
// $HandlesCassetteSpecCopyWith<HandlesCassetteSpec> get copyWith => _$HandlesCassetteSpecCopyWithImpl<HandlesCassetteSpec>(this as HandlesCassetteSpec, _$identity);



// @override
// bool operator ==(Object other) {
//   return identical(this, other) || (other.runtimeType == runtimeType&&other is HandlesCassetteSpec&&(identical(other.chosenContactId, chosenContactId) || other.chosenContactId == chosenContactId));
// }


// @override
// int get hashCode => Object.hash(runtimeType,chosenContactId);

// @override
// String toString() {
//   return 'HandlesCassetteSpec(chosenContactId: $chosenContactId)';
// }


// }

// /// @nodoc
// abstract mixin class $HandlesCassetteSpecCopyWith<$Res>  {
//   factory $HandlesCassetteSpecCopyWith(HandlesCassetteSpec value, $Res Function(HandlesCassetteSpec) _then) = _$HandlesCassetteSpecCopyWithImpl;
// @useResult
// $Res call({
//  int? chosenContactId
// });




// }
// /// @nodoc
// class _$HandlesCassetteSpecCopyWithImpl<$Res>
//     implements $HandlesCassetteSpecCopyWith<$Res> {
//   _$HandlesCassetteSpecCopyWithImpl(this._self, this._then);

//   final HandlesCassetteSpec _self;
//   final $Res Function(HandlesCassetteSpec) _then;

// /// Create a copy of HandlesCassetteSpec
// /// with the given fields replaced by the non-null parameter values.
// @pragma('vm:prefer-inline') @override $Res call({Object? chosenContactId = freezed,}) {
//   return _then(_self.copyWith(
// chosenContactId: freezed == chosenContactId ? _self.chosenContactId : chosenContactId // ignore: cast_nullable_to_non_nullable
// as int?,
//   ));
// }

// }


// /// Adds pattern-matching-related methods to [HandlesCassetteSpec].
// extension HandlesCassetteSpecPatterns on HandlesCassetteSpec {
// /// A variant of `map` that fallback to returning `orElse`.
// ///
// /// It is equivalent to doing:
// /// ```dart
// /// switch (sealedClass) {
// ///   case final Subclass value:
// ///     return ...;
// ///   case _:
// ///     return orElse();
// /// }
// /// ```

// @optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _HandlesListUnmatchedSpec value)?  unmatchedHandlesList,required TResult orElse(),}){
// final _that = this;
// switch (_that) {
// case _HandlesListUnmatchedSpec() when unmatchedHandlesList != null:
// return unmatchedHandlesList(_that);case _:
//   return orElse();

// }
// }
// /// A `switch`-like method, using callbacks.
// ///
// /// Callbacks receives the raw object, upcasted.
// /// It is equivalent to doing:
// /// ```dart
// /// switch (sealedClass) {
// ///   case final Subclass value:
// ///     return ...;
// ///   case final Subclass2 value:
// ///     return ...;
// /// }
// /// ```

// @optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _HandlesListUnmatchedSpec value)  unmatchedHandlesList,}){
// final _that = this;
// switch (_that) {
// case _HandlesListUnmatchedSpec():
// return unmatchedHandlesList(_that);case _:
//   throw StateError('Unexpected subclass');

// }
// }
// /// A variant of `map` that fallback to returning `null`.
// ///
// /// It is equivalent to doing:
// /// ```dart
// /// switch (sealedClass) {
// ///   case final Subclass value:
// ///     return ...;
// ///   case _:
// ///     return null;
// /// }
// /// ```

// @optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _HandlesListUnmatchedSpec value)?  unmatchedHandlesList,}){
// final _that = this;
// switch (_that) {
// case _HandlesListUnmatchedSpec() when unmatchedHandlesList != null:
// return unmatchedHandlesList(_that);case _:
//   return null;

// }
// }
// /// A variant of `when` that fallback to an `orElse` callback.
// ///
// /// It is equivalent to doing:
// /// ```dart
// /// switch (sealedClass) {
// ///   case Subclass(:final field):
// ///     return ...;
// ///   case _:
// ///     return orElse();
// /// }
// /// ```

// @optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int? chosenContactId)?  unmatchedHandlesList,required TResult orElse(),}) {final _that = this;
// switch (_that) {
// case _HandlesListUnmatchedSpec() when unmatchedHandlesList != null:
// return unmatchedHandlesList(_that.chosenContactId);case _:
//   return orElse();

// }
// }
// /// A `switch`-like method, using callbacks.
// ///
// /// As opposed to `map`, this offers destructuring.
// /// It is equivalent to doing:
// /// ```dart
// /// switch (sealedClass) {
// ///   case Subclass(:final field):
// ///     return ...;
// ///   case Subclass2(:final field2):
// ///     return ...;
// /// }
// /// ```

// @optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int? chosenContactId)  unmatchedHandlesList,}) {final _that = this;
// switch (_that) {
// case _HandlesListUnmatchedSpec():
// return unmatchedHandlesList(_that.chosenContactId);case _:
//   throw StateError('Unexpected subclass');

// }
// }
// /// A variant of `when` that fallback to returning `null`
// ///
// /// It is equivalent to doing:
// /// ```dart
// /// switch (sealedClass) {
// ///   case Subclass(:final field):
// ///     return ...;
// ///   case _:
// ///     return null;
// /// }
// /// ```

// @optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int? chosenContactId)?  unmatchedHandlesList,}) {final _that = this;
// switch (_that) {
// case _HandlesListUnmatchedSpec() when unmatchedHandlesList != null:
// return unmatchedHandlesList(_that.chosenContactId);case _:
//   return null;

// }
// }

// }

// /// @nodoc


// class _HandlesListUnmatchedSpec implements HandlesCassetteSpec {
//   const _HandlesListUnmatchedSpec({this.chosenContactId});
  

// @override final  int? chosenContactId;

// /// Create a copy of HandlesCassetteSpec
// /// with the given fields replaced by the non-null parameter values.
// @override @JsonKey(includeFromJson: false, includeToJson: false)
// @pragma('vm:prefer-inline')
// _$HandlesListUnmatchedSpecCopyWith<_HandlesListUnmatchedSpec> get copyWith => __$HandlesListUnmatchedSpecCopyWithImpl<_HandlesListUnmatchedSpec>(this, _$identity);



// @override
// bool operator ==(Object other) {
//   return identical(this, other) || (other.runtimeType == runtimeType&&other is _HandlesListUnmatchedSpec&&(identical(other.chosenContactId, chosenContactId) || other.chosenContactId == chosenContactId));
// }


// @override
// int get hashCode => Object.hash(runtimeType,chosenContactId);

// @override
// String toString() {
//   return 'HandlesCassetteSpec.unmatchedHandlesList(chosenContactId: $chosenContactId)';
// }


// }

// /// @nodoc
// abstract mixin class _$HandlesListUnmatchedSpecCopyWith<$Res> implements $HandlesCassetteSpecCopyWith<$Res> {
//   factory _$HandlesListUnmatchedSpecCopyWith(_HandlesListUnmatchedSpec value, $Res Function(_HandlesListUnmatchedSpec) _then) = __$HandlesListUnmatchedSpecCopyWithImpl;
// @override @useResult
// $Res call({
//  int? chosenContactId
// });




// }
// /// @nodoc
// class __$HandlesListUnmatchedSpecCopyWithImpl<$Res>
//     implements _$HandlesListUnmatchedSpecCopyWith<$Res> {
//   __$HandlesListUnmatchedSpecCopyWithImpl(this._self, this._then);

//   final _HandlesListUnmatchedSpec _self;
//   final $Res Function(_HandlesListUnmatchedSpec) _then;

// /// Create a copy of HandlesCassetteSpec
// /// with the given fields replaced by the non-null parameter values.
// @override @pragma('vm:prefer-inline') $Res call({Object? chosenContactId = freezed,}) {
//   return _then(_HandlesListUnmatchedSpec(
// chosenContactId: freezed == chosenContactId ? _self.chosenContactId : chosenContactId // ignore: cast_nullable_to_non_nullable
// as int?,
//   ));
// }


// }

// // dart format on
