// Legacy shim re-exporting the generated provider that now lives under
// `db_importers`. This file remains so older imports of the generated output
// keep compiling until the `db_import` folder is fully removed.

export '../../db_importers/application/debug_settings_provider.g.dart';
