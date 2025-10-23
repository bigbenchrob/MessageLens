import 'package:freezed_annotation/freezed_annotation.dart';

part 'contacts_list_spec.freezed.dart';

@freezed
abstract class ContactsListSpec with _$ContactsListSpec {
  const factory ContactsListSpec.all() = ContactsListSpecAll;

  const factory ContactsListSpec.alphabetical() = ContactsListSpecAlphabetical;

  const factory ContactsListSpec.favorites() = ContactsListSpecFavorites;
}
