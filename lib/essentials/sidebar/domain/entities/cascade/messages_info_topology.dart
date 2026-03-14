part of '../cassette_spec.dart';

CassetteSpec? resolveMessagesInfoChild(MessagesInfoCassetteSpec spec) {
  return spec.when(
    infoCard: (key) => null,
  );
}

extension MessagesInfoCassetteSpecX on MessagesInfoCassetteSpec {
  /// Messages info cassettes currently have no children.
  CassetteSpec? childSpec() {
    return resolveMessagesInfoChild(this);
  }
}