import 'package:freezed_annotation/freezed_annotation.dart';

part 'contacts_cassette_spec.freezed.dart';

@freezed
abstract class ContactsCassetteSpec with _$ContactsCassetteSpec {
  const factory ContactsCassetteSpec.contactPicker({int? chosenContactId}) =
      _ContactPickerSpec;
}
