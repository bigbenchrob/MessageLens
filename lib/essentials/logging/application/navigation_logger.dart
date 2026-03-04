import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../navigation/domain/entities/features/chats_spec.dart';
import '../../navigation/domain/entities/features/import_spec.dart';
import '../../navigation/domain/entities/features/onboarding_spec.dart';
import '../../navigation/domain/entities/features/settings_spec.dart';
import '../../navigation/domain/entities/features/workbench_spec.dart';
import '../../navigation/domain/entities/view_spec.dart';
import '../../navigation/domain/navigation_constants.dart';
import '../../navigation/feature_level_providers.dart';
import 'message_logger.dart';

part 'navigation_logger.g.dart';

/// Specialized log entry for navigation events
class NavigationLogEntry {
  final String id;
  final DateTime timestamp;
  final String
  action; // 'toolbar_click', 'menu_select', 'keyboard_shortcut', etc.
  final String trigger; // 'Messages Button', 'Contacts List Item', etc.
  final WindowPanel targetPanel;
  final ViewSpec viewSpec;
  final Map<String, dynamic> context;

  const NavigationLogEntry({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.trigger,
    required this.targetPanel,
    required this.viewSpec,
    this.context = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'action': action,
    'trigger': trigger,
    'targetPanel': targetPanel.name,
    'viewSpec': _viewSpecToJson(viewSpec),
    'context': context,
  };

  Map<String, dynamic> _viewSpecToJson(ViewSpec spec) {
    return spec.when(
      messages: (messagesSpec) => {
        'type': 'messages',
        'spec': messagesSpec.when(
          forChat: (chatId) => {'variant': 'forChat', 'chatId': chatId},
          forContact: (contactId, scrollToDate) => {
            'variant': 'forContact',
            'contactId': contactId,
            if (scrollToDate != null)
              'scrollToDate': scrollToDate.toIso8601String(),
          },
          globalTimeline: (scrollToDate) => {
            'variant': 'globalTimeline',
            if (scrollToDate != null)
              'scrollToDate': scrollToDate.toIso8601String(),
          },
          forHandle: (handleId) => {
            'variant': 'forHandle',
            'handleId': handleId,
          },
          forChatInDateRange: (chatId, startDate, endDate) => {
            'variant': 'forChatInDateRange',
            'chatId': chatId,
            'startDate': startDate.toIso8601String(),
            'endDate': endDate.toIso8601String(),
          },
          handleLens: (handleId) => {
            'variant': 'handleLens',
            'handleId': handleId,
          },
        ),
      },
      chats: (chatsSpec) => {
        'type': 'chats',
        'spec': chatsSpec.when(
          list: () => {'variant': 'list'},
          forContact: (contactId) => {
            'variant': 'forContact',
            'contactId': contactId,
          },
          recent: (limit) => {'variant': 'recent', 'limit': limit},
          byAgeOldest: (limit) => {'variant': 'byAgeOldest', 'limit': limit},
          byAgeNewest: (limit) => {'variant': 'byAgeNewest', 'limit': limit},
          unmatched: (limit) => {'variant': 'unmatched', 'limit': limit},
          forParticipant: (participantId) => {
            'variant': 'forParticipant',
            'participantId': participantId,
          },
        ),
      },
      import: (importSpec) => {
        'type': 'import',
        'spec': importSpec.when(
          forImport: () => {'variant': 'forImport'},
          forMigration: () => {'variant': 'forMigration'},
        ),
      },
      settings: (settingsSpec) => {
        'type': 'settings',
        'spec': settingsSpec.when(
          contactDisplayNameInfo: () => {'variant': 'contactDisplayNameInfo'},
        ),
      },
      workbench: (workbenchSpec) => {
        'type': 'workbench',
        'spec': workbenchSpec.when(panel: () => {'variant': 'panel'}),
      },
      onboarding: (onboardingSpec) => {
        'type': 'onboarding',
        'spec': onboardingSpec.when(devPanel: () => {'variant': 'devPanel'}),
      },
    );
  }
}

@Riverpod(keepAlive: true)
class NavigationLogger extends _$NavigationLogger {
  final List<NavigationLogEntry> _navigationLogs = [];

  @override
  List<NavigationLogEntry> build() {
    return _navigationLogs;
  }

  /// Log a navigation event
  void logNavigation({
    required String action,
    required String trigger,
    required WindowPanel targetPanel,
    required ViewSpec viewSpec,
    Map<String, dynamic> context = const {},
  }) {
    final entry = NavigationLogEntry(
      id: 'nav_${DateTime.now().millisecondsSinceEpoch}_${_navigationLogs.length}',
      timestamp: DateTime.now(),
      action: action,
      trigger: trigger,
      targetPanel: targetPanel,
      viewSpec: viewSpec,
      context: context,
    );

    _navigationLogs.add(entry);
    state = List.of(_navigationLogs);

    // Also log to the general message logger for unified logging
    ref
        .read(messageLoggerProvider.notifier)
        .info(
          'Navigation: $action via $trigger to ${targetPanel.name} panel',
          source: 'NavigationLogger',
          context: {
            'navigationId': entry.id,
            'targetPanel': targetPanel.name,
            'viewSpecType': entry._viewSpecToJson(viewSpec)['type'],
          },
        );
  }

  /// Log a toolbar button click
  void logToolbarClick({
    required String buttonLabel,
    required WindowPanel targetPanel,
    required ViewSpec viewSpec,
  }) {
    logNavigation(
      action: 'toolbar_click',
      trigger: '$buttonLabel Button',
      targetPanel: targetPanel,
      viewSpec: viewSpec,
      context: {
        'buttonLabel': buttonLabel,
        'timestamp_human': DateTime.now().toString(),
      },
    );
  }

  /// Get usage statistics
  Map<String, dynamic> getUsageStats() {
    if (_navigationLogs.isEmpty) {
      return {'totalEvents': 0, 'message': 'No navigation events recorded yet'};
    }

    final actionCounts = <String, int>{};
    final buttonCounts = <String, int>{};
    final panelCounts = <String, int>{};

    for (final log in _navigationLogs) {
      actionCounts[log.action] = (actionCounts[log.action] ?? 0) + 1;
      panelCounts[log.targetPanel.name] =
          (panelCounts[log.targetPanel.name] ?? 0) + 1;

      if (log.context['buttonLabel'] != null) {
        final button = log.context['buttonLabel'] as String;
        buttonCounts[button] = (buttonCounts[button] ?? 0) + 1;
      }
    }

    return {
      'totalEvents': _navigationLogs.length,
      'actionBreakdown': actionCounts,
      'buttonBreakdown': buttonCounts,
      'panelBreakdown': panelCounts,
      'firstEvent': _navigationLogs.first.timestamp.toIso8601String(),
      'lastEvent': _navigationLogs.last.timestamp.toIso8601String(),
    };
  }

  /// Export logs as JSON string
  String exportLogsAsJson() {
    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'totalLogs': _navigationLogs.length,
      'usageStats': getUsageStats(),
      'logs': _navigationLogs.map((log) => log.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Debug method to print current logs to console
  void debugPrintLogs() {
    final messageLogger = ref.read(messageLoggerProvider.notifier);

    if (_navigationLogs.isEmpty) {
      messageLogger.info('NavigationLogger: No logs recorded yet');
      return;
    }

    messageLogger.info(
      'NavigationLogger: ${_navigationLogs.length} events recorded',
    );
    messageLogger.info('Usage Stats: ${getUsageStats()}');

    for (var i = 0; i < _navigationLogs.length && i < 5; i++) {
      final log = _navigationLogs[i];
      messageLogger.info(
        'Event ${i + 1}: ${log.action} -> ${log.targetPanel.name} at ${log.timestamp}',
      );
    }

    if (_navigationLogs.length > 5) {
      messageLogger.info('... and ${_navigationLogs.length - 5} more events');
    }
  }

  /// Clear navigation logs
  void clear() {
    _navigationLogs.clear();
    state = [];
  }

  /// Export navigation logs as JSON
  String exportJson() =>
      jsonEncode(_navigationLogs.map((e) => e.toJson()).toList());
}
