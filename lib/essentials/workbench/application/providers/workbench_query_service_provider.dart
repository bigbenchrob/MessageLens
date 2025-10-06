import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../feature_level_providers.dart';
import '../services/workbench_query_service.dart';

part 'workbench_query_service_provider.g.dart';

@riverpod
Future<WorkbenchQueryService> workbenchQueryService(Ref ref) async {
  final repository = await ref.watch(workbenchQueryRepositoryProvider.future);
  return WorkbenchQueryService(repository: repository);
}
