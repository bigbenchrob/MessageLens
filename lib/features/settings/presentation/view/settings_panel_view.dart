import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../application/contact_short_names/contact_short_name_candidates_provider.dart';
import '../../application/contact_short_names/contact_short_names_controller.dart';

const double _settingsContentMaxWidth = 500;

class SettingsPanelView extends ConsumerWidget {
  const SettingsPanelView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactShortNameCandidatesProvider);
    final shortNamesAsync = ref.watch(contactShortNamesProvider);

    if (contactsAsync.hasError) {
      return _SettingsError(message: '${contactsAsync.error}');
    }

    if (shortNamesAsync.hasError) {
      return _SettingsError(message: '${shortNamesAsync.error}');
    }

    if (contactsAsync.isLoading || shortNamesAsync.isLoading) {
      return const _SettingsLoading();
    }

    final contacts = contactsAsync.value ?? <SettingsContactEntry>[];
    final shortNames = shortNamesAsync.value ?? <String, String>{};

    return _SettingsScaffold(
      maxContentWidth: _settingsContentMaxWidth,
      child: _ContactShortNameSection(
        contacts: contacts,
        shortNames: shortNames,
      ),
    );
  }
}

class _SettingsScaffold extends StatelessWidget {
  const _SettingsScaffold({required this.child, this.maxContentWidth});

  final Widget child;
  final double? maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final typography = theme.typography;

    final constrainedContent = maxContentWidth == null
        ? child
        : Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth!),
              child: child,
            ),
          );

    return ColoredBox(
      color: theme.canvasColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: typography.largeTitle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(child: constrainedContent),
          ],
        ),
      ),
    );
  }
}

class _ContactShortNameSection extends HookWidget {
  const _ContactShortNameSection({
    required this.contacts,
    required this.shortNames,
  });

  final List<SettingsContactEntry> contacts;
  final Map<String, String> shortNames;

  @override
  Widget build(BuildContext context) {
    final typography = MacosTheme.of(context).typography;
    final scrollController = useScrollController();

    if (contacts.isEmpty) {
      return Center(
        child: Text(
          'No contacts available yet. Import messages to begin assigning short names.',
          style: typography.title3.copyWith(color: const Color(0xFF767680)),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact short names',
          style: typography.title1.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Define concise labels that will appear in chat lists and other views. '
          'Short names override imported contact names without modifying the source data.',
          style: typography.caption1.copyWith(color: const Color(0xFF6B6B70)),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: MacosScrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: ListView.separated(
              controller: scrollController,
              itemCount: contacts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final entry = contacts[index];
                final shortName = shortNames[entry.contactKey];
                return _ContactShortNameRow(
                  entry: entry,
                  initialShortName: shortName,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactShortNameRow extends HookConsumerWidget {
  const _ContactShortNameRow({
    required this.entry,
    required this.initialShortName,
  });

  final SettingsContactEntry entry;
  final String? initialShortName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController(text: initialShortName ?? '');

    useEffect(() {
      final desired = initialShortName ?? '';
      if (controller.text != desired) {
        controller.value = TextEditingValue(
          text: desired,
          selection: TextSelection.collapsed(offset: desired.length),
        );
      }
      return null;
    }, [initialShortName]);

    final editingValue = useValueListenable(controller);
    final trimmedValue = editingValue.text.trim();
    final originalValue = (initialShortName ?? '').trim();
    final hasChanges = trimmedValue != originalValue;
    final canSave = hasChanges && trimmedValue.isNotEmpty;
    final canClear = originalValue.isNotEmpty;

    final typography = MacosTheme.of(context).typography;

    final handles = entry.identities
        .map((identity) {
          final address = identity.normalizedAddress?.trim();
          if (address != null && address.isNotEmpty) {
            final service = identity.service?.trim();
            if (service == null || service.toLowerCase() == 'unknown') {
              return address;
            }
            return '$address • $service';
          }
          return identity.displayName?.trim();
        })
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toList();

    Future<void> handleSave() async {
      await ref
          .read(contactShortNamesProvider.notifier)
          .setShortName(contactKey: entry.contactKey, shortName: trimmedValue);
    }

    Future<void> handleClear() async {
      await ref
          .read(contactShortNamesProvider.notifier)
          .setShortName(contactKey: entry.contactKey, shortName: null);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: MacosTheme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2C2C33)
            : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E2EA)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.displayName,
                        style: typography.title2.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (handles.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          handles.join('\n'),
                          style: typography.caption1.copyWith(
                            color: const Color(0xFF6B6B70),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                SizedBox(
                  width: 220,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MacosTextField(
                        controller: controller,
                        placeholder: 'Short name',
                        onSubmitted: (_) async {
                          if (canSave) {
                            await handleSave();
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          PushButton(
                            controlSize: ControlSize.small,
                            onPressed: canSave ? handleSave : null,
                            child: const Text('Save'),
                          ),
                          const SizedBox(width: 8),
                          PushButton(
                            controlSize: ControlSize.small,
                            secondary: true,
                            onPressed: canClear ? handleClear : null,
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ],
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

class _SettingsLoading extends StatelessWidget {
  const _SettingsLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: ProgressCircle(radius: 12));
  }
}

class _SettingsError extends StatelessWidget {
  const _SettingsError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Unable to load settings. $message',
        style: MacosTheme.of(
          context,
        ).typography.title3.copyWith(color: const Color(0xFFD14343)),
        textAlign: TextAlign.center,
      ),
    );
  }
}
