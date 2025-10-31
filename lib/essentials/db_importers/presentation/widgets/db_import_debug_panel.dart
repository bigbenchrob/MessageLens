import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/debug_settings_provider.dart';

class DbImportDebugPanel extends ConsumerWidget {
  const DbImportDebugPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debugSettings = ref.watch(importDebugSettingsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Debug Settings',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Database Logging'),
              subtitle: const Text('Log database open/close operations'),
              value: debugSettings.enableDatabaseLogging,
              onChanged: (value) {
                ref
                    .read(importDebugSettingsProvider.notifier)
                    .updateDatabaseLogging(enabled: value ?? false);
              },
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              title: const Text('Progress Logging'),
              subtitle: const Text('Log import progress updates'),
              value: debugSettings.enableProgressLogging,
              onChanged: (value) {
                ref
                    .read(importDebugSettingsProvider.notifier)
                    .updateProgressLogging(enabled: value ?? false);
              },
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              title: const Text('Error Details'),
              subtitle: const Text('Log detailed error information'),
              value: debugSettings.enableErrorDetailsLogging,
              onChanged: (value) {
                ref
                    .read(importDebugSettingsProvider.notifier)
                    .updateErrorLogging(enabled: value ?? false);
              },
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(importDebugSettingsProvider.notifier)
                        .enableAllDebugging();
                  },
                  icon: const Icon(Icons.bug_report, size: 16),
                  label: const Text('Enable All'),
                  style: ElevatedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    ref
                        .read(importDebugSettingsProvider.notifier)
                        .disableAllDebugging();
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Disable All'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
