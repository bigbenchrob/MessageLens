import 'package:freezed_annotation/freezed_annotation.dart';

part 'messages_cassette_spec.freezed.dart';

/// Specification for the contacts-related cassette types.
///
/// This file resides in the `features` folder to align with the directory
/// structure described in the essentials/sidebar domain. It mirrors the
/// existing `contacts_cassette_spec.dart` at the root but places it where
/// `cassette_spec.dart` expects to find it. The generated `.freezed.dart`
/// will live alongside this file after running build_runner.
@freezed
abstract class MessagesCassetteSpec with _$MessagesCassetteSpec {
  /// Heat map cassette for messages. When [contactId] is provided the heatmap
  /// is scoped to that contact; otherwise it visualises the entire archive.
  const factory MessagesCassetteSpec.heatMap({int? contactId}) =
      _MessagesHeatMapSpec;
}
