import 'package:freezed_annotation/freezed_annotation.dart';

part 'import_spec.freezed.dart';

@freezed
class ImportSpec with _$ImportSpec {
  const factory ImportSpec.forImport() = _ImportRawData;

  const factory ImportSpec.forMigration() = _MigrateData;
}
