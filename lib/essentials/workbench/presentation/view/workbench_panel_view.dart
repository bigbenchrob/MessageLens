import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../domain/entities/workbench_view_state.dart';
import '../view_model/workbench_view_model.dart';

class WorkbenchPanelView extends HookConsumerWidget {
  const WorkbenchPanelView({super.key});

  static const List<Color> _badgePalette = <Color>[
    Color(0xFFB5E2FA), // soft blue
    Color(0xFFF7E2AF), // warm tan
    Color(0xFFF9C6D3), // blush pink
    Color(0xFFD5F5E3), // mint green
    Color(0xFFFCF3CF), // pastel yellow
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(workbenchViewModelProvider);
    final notifier = ref.watch(workbenchViewModelProvider.notifier);

    final theme = MacosTheme.of(context);

    return ColoredBox(
      color: theme.brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : const Color(0xFFF5F5F8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WorkbenchFormSection(viewState: viewState, notifier: notifier),
            const SizedBox(height: 16),
            _WorkbenchActionRow(viewState: viewState, notifier: notifier),
            const SizedBox(height: 16),
            Expanded(
              child: _WorkbenchResultsSection(
                viewState: viewState,
                palette: _badgePalette,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkbenchFormSection extends HookConsumerWidget {
  const _WorkbenchFormSection({
    required this.viewState,
    required this.notifier,
  });

  final WorkbenchViewState viewState;
  final WorkbenchViewModel notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final definitions = notifier.fieldDefinitions;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: definitions.map<Widget>((definition) {
        final initialValue = viewState.fields[definition.key] ?? '';
        final controller = useTextEditingController(text: initialValue);

        useEffect(() {
          final currentValue = viewState.fields[definition.key] ?? '';
          if (controller.text != currentValue) {
            controller.text = currentValue;
          }
          return null;
        }, [viewState.fields[definition.key]]);

        return SizedBox(
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                definition.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              MacosTextField(
                controller: controller,
                placeholder: definition.placeholder,
                keyboardType: definition.isNumeric
                    ? TextInputType.number
                    : TextInputType.text,
                onChanged: (value) {
                  notifier.updateField(definition.key, value);
                },
              ),
              if (definition.helperText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    definition.helperText!,
                    style: TextStyle(
                      fontSize: 11,
                      color: MacosTheme.brightnessOf(context).resolve(
                        const Color(0xFF5C5C5C),
                        const Color(0xFFCCCCCC),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _WorkbenchActionRow extends ConsumerWidget {
  const _WorkbenchActionRow({required this.viewState, required this.notifier});

  final WorkbenchViewState viewState;
  final WorkbenchViewModel notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = viewState.isLoading;

    return Row(
      children: [
        Wrap(
          spacing: 12,
          children: notifier.actions.map<Widget>((action) {
            final isPending = viewState.pendingKind == action.kind && isLoading;
            return PushButton(
              controlSize: ControlSize.regular,
              onPressed: isLoading
                  ? null
                  : () => notifier.runQuery(action.kind),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPending) ...[
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2.0),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(action.label),
                ],
              ),
            );
          }).toList(),
        ),
        const Spacer(),
        if (viewState.lastResult != null)
          PushButton(
            secondary: true,
            controlSize: ControlSize.regular,
            onPressed: notifier.clearResults,
            child: const Text('Clear'),
          ),
      ],
    );
  }
}

class _WorkbenchResultsSection extends StatelessWidget {
  const _WorkbenchResultsSection({
    required this.viewState,
    required this.palette,
  });

  final WorkbenchViewState viewState;
  final List<Color> palette;

  @override
  Widget build(BuildContext context) {
    if (viewState.isLoading && viewState.lastResult == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewState.errorMessage != null) {
      return Center(
        child: Text(
          viewState.errorMessage!,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    final result = viewState.lastResult;
    if (result == null || result.rows.isEmpty) {
      return const Center(
        child: Text(
          'No results yet. Enter parameters and choose a query.',
          style: TextStyle(fontSize: 13, color: Color(0xFF777777)),
        ),
      );
    }

    final headers = result.rows.first.cells.map((cell) => cell.label).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${result.rows.length} rows retrieved (showing up to ${result.request.limit})',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
        const SizedBox(height: 8),
        _BadgeRow(labels: headers, palette: palette, isHeader: true),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: result.rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final row = result.rows[index];
              final cells = row.cells.map((cell) => cell.displayValue).toList();
              return _BadgeRow(labels: cells, palette: palette);
            },
          ),
        ),
      ],
    );
  }
}

class _BadgeRow extends StatelessWidget {
  const _BadgeRow({
    required this.labels,
    required this.palette,
    this.isHeader = false,
  });

  final List<String> labels;
  final List<Color> palette;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < labels.length; i += 1)
          DecoratedBox(
            decoration: BoxDecoration(
              color: palette[i % palette.length],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
