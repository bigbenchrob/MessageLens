import 'package:characters/characters.dart';

/// Returns the alphabetical group key for a contact display name.
///
/// - Returns `'A'..'Z'` for alphabetic first characters (case-insensitive).
/// - Returns `'#'` for digits, symbols, emoji, or empty/whitespace-only names.
String deriveContactGroupKey(String displayName) {
  final trimmed = displayName.trim();
  if (trimmed.isEmpty) {
    return '#';
  }

  final iterator = trimmed.characters.iterator;
  if (!iterator.moveNext()) {
    return '#';
  }

  final first = iterator.current.toUpperCase();
  if (_latinLetterRegExp.hasMatch(first)) {
    return first;
  }

  return '#';
}

final _latinLetterRegExp = RegExp(r'^[A-Z]$');
