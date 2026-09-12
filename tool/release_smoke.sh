#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

run_flutter_tests() {
  for test_path in "$@"; do
    echo "-- $test_path"
    flutter test --reporter compact "$test_path"
  done
}

echo "== MessageLens release smoke: analyzer =="
flutter analyze

echo "== MessageLens release smoke: readiness and onboarding =="
run_flutter_tests \
  test/essentials/onboarding/domain/onboarding_environment_report_test.dart \
  test/essentials/onboarding/application/onboarding_environment_report_provider_test.dart \
  test/essentials/onboarding/application/onboarding_gate_provider_test.dart \
  test/features/environment_readiness/application/view_spec/resolver_tools/environment_readiness_surface_provider_test.dart

echo "== MessageLens release smoke: graph lifecycle and health =="
run_flutter_tests \
  test/essentials/conversation_graph/application/conversation_graph_build_controller_provider_test.dart \
  test/essentials/conversation_graph/application/conversation_graph_build_service_provider_test.dart \
  test/essentials/conversation_graph/application/health/graph_health_reader_test.dart \
  test/essentials/conversation_graph/application/monitor/chat_db_change_monitor_provider_test.dart

echo "== MessageLens release smoke: message evidence and attachments =="
run_flutter_tests \
  test/features/attachments/infrastructure/repositories/overlay_archive_compatibility_lookup_test.dart \
  test/features/attachments/infrastructure/repositories/sqlite_graph_attachment_archive_candidate_reader_test.dart \
  test/essentials/conversation_graph/application/chat_summaries/chat_summary_reader_test.dart \
  test/features/messages/application/message_evidence/message_evidence_spine_provider_test.dart \
  test/features/messages/application/message_evidence/message_attachment_evidence_test.dart \
  test/features/messages/presentation/widgets/message_evidence/message_evidence_header_test.dart \
  test/features/messages/presentation/widgets/message_evidence/message_evidence_timeline_view_test.dart \
  test/features/messages/presentation/widgets/message_evidence/media_tile_attachment_test.dart \
  test/features/messages/presentation/view/contact_messages_evidence_view_test.dart \
  test/features/conversations/presentation/view/conversation_messages_view_test.dart

echo "== MessageLens release smoke: historical archives =="
run_flutter_tests \
  test/essentials/conversation_graph/application/archives/source_scoped_archive_graph_import_service_test.dart \
  test/essentials/source_scoped_import/application/archives/historical_messages_archive_source_registrar_test.dart \
  test/features/settings/application/historical_archives_workflow_panel_model_provider_test.dart \
  test/features/settings/presentation/view/historical_archives_panel_test.dart

echo "== MessageLens release smoke: architecture tripwire =="
run_flutter_tests test/architecture/forbidden_imports_test.dart

echo "== MessageLens release smoke: complete =="
