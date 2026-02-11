part of '../cassette_spec.dart';

CassetteSpec? resolveMessagesChild(MessagesCassetteSpec spec) {
  return spec.when(heatMap: (_) => null);
}

extension MessagesCassetteSpecX on MessagesCassetteSpec {
  /// Handles cassettes currently have no children.
  CassetteSpec? childSpec() {
    return resolveMessagesChild(this);
  }
}
