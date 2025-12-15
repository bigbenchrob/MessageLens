import 'package:freezed_annotation/freezed_annotation.dart';

import '../cassette_spec.dart';

part 'presentation_cassette_spec.freezed.dart';

@freezed
abstract class PresentationCassetteSpec with _$PresentationCassetteSpec {
  const factory PresentationCassetteSpec.themePlayground() =
      _PresentationCassetteSpecThemePlayground;

  const PresentationCassetteSpec._();
}

extension PresentationCassetteSpecX on PresentationCassetteSpec {
  /// Presentation cassettes currently have no children.
  CassetteSpec? childSpec() {
    return null;
  }
}
