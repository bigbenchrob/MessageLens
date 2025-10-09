import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

@freezed
sealed class Result<S, F> with _$Result<S, F> {
  const factory Result.success(S value) = Success<S, F>;
  const factory Result.failure(F error) = Failure<S, F>;

  // Centralized fold (nice ergonomics, no casts)
  T fold<T>(T Function(F failure) onFailure, T Function(S success) onSuccess) =>
      when(success: (v) => onSuccess(v), failure: (e) => onFailure(e));
}
