import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../../config/theme/theme_typography.dart';

Future<bool> showStartFreshAuthorizationDialog(
  BuildContext context, {
  required Color barrierColor,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: barrierColor,
    builder: (_) {
      return const StartFreshAuthorizationDialog();
    },
  );
  return result ?? false;
}

class StartFreshAuthorizationDialog extends ConsumerStatefulWidget {
  const StartFreshAuthorizationDialog({super.key});

  @override
  ConsumerState<StartFreshAuthorizationDialog> createState() =>
      _StartFreshAuthorizationDialogState();
}

class _StartFreshAuthorizationDialogState
    extends ConsumerState<StartFreshAuthorizationDialog> {
  bool _submissionClaimed = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return AlertDialog(
      title: const Text('Start with a clean MessageLens setup?'),
      content: Text(
        'MessageLens will remove its rebuildable imported-message and '
        'conversation-index data, then restart Onboarding.\n\n'
        'Your Apple Messages and Contacts will not be changed. Your '
        'preferences, MessageLens customizations, setup history, archived '
        'attachment payloads, diagnostics, and archive identity will be '
        'preserved. Historical Archive source folders and recovery donors '
        'will not be changed.',
        style: typography.body.copyWith(color: colors.content.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: _submissionClaimed ? null : _cancel,
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submissionClaimed ? null : _accept,
          child: Text(_submissionClaimed ? 'Starting…' : 'Start Fresh'),
        ),
      ],
    );
  }

  void _cancel() {
    if (_submissionClaimed) {
      return;
    }
    Navigator.of(context).pop(false);
  }

  void _accept() {
    if (_submissionClaimed) {
      return;
    }
    setState(() {
      _submissionClaimed = true;
    });
    Navigator.of(context).pop(true);
  }
}
