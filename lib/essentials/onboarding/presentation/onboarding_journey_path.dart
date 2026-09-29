import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../../config/theme/theme_typography.dart';
import '../domain/onboarding_journey_state.dart';

enum OnboardingJourneyPathNode {
  messages,
  history,
  contacts,
  ready,
  import,
  start,
}

enum OnboardingJourneyPathNodeState { completed, current, future }

final class OnboardingJourneyPathProjection {
  OnboardingJourneyPathProjection({
    required this.currentNode,
    required Map<OnboardingJourneyPathNode, OnboardingJourneyPathNodeState>
    nodeStates,
  }) : nodeStates =
           Map<
             OnboardingJourneyPathNode,
             OnboardingJourneyPathNodeState
           >.unmodifiable(nodeStates);

  final OnboardingJourneyPathNode currentNode;
  final Map<OnboardingJourneyPathNode, OnboardingJourneyPathNodeState>
  nodeStates;

  String get semanticLabel {
    final completedLabels = OnboardingJourneyPathNode.values
        .where(
          (node) =>
              nodeStates[node] == OnboardingJourneyPathNodeState.completed,
        )
        .map(_semanticLabelFor)
        .toList(growable: false);
    final completed = completedLabels.isEmpty
        ? ''
        : ' ${_joinLabels(completedLabels)} '
              '${completedLabels.length == 1 ? 'is' : 'are'} complete.';
    return 'Current setup step: ${_semanticLabelFor(currentNode)}.$completed';
  }
}

OnboardingJourneyPathProjection? projectOnboardingJourneyPath(
  OnboardingJourneyState journey,
) {
  if (!journey.ownsFirstRunPresentation) {
    return null;
  }

  final currentNode = switch (journey) {
    OnboardingCheckingPrerequisites() ||
    OnboardingNeedsMessagesAccess() => OnboardingJourneyPathNode.messages,
    OnboardingNeedsLocalHistoryConfirmation() =>
      OnboardingJourneyPathNode.history,
    OnboardingNeedsContactsAccess() => OnboardingJourneyPathNode.contacts,
    OnboardingReadyToImport() => OnboardingJourneyPathNode.ready,
    OnboardingRecoveringDerivedData() ||
    OnboardingPreparingImport() ||
    OnboardingBuildingLocalData() ||
    OnboardingOperationInterrupted() ||
    OnboardingOperationFailed() => OnboardingJourneyPathNode.import,
    // Durable verification is a mandatory internal gate, not another human
    // obligation. Import remains current until its proof makes Start truthful.
    OnboardingVerifyingDurableReadiness() => OnboardingJourneyPathNode.import,
    OnboardingReadyToStart() => OnboardingJourneyPathNode.start,
    OnboardingNormalApplication() ||
    OnboardingReimporting() ||
    OnboardingReimportReady() => throw StateError(
      'Non-Onboarding Journey cannot be projected onto the first-run path.',
    ),
  };
  final currentIndex = OnboardingJourneyPathNode.values.indexOf(currentNode);
  return OnboardingJourneyPathProjection(
    currentNode: currentNode,
    nodeStates: <OnboardingJourneyPathNode, OnboardingJourneyPathNodeState>{
      for (final (index, node) in OnboardingJourneyPathNode.values.indexed)
        node: index < currentIndex
            ? OnboardingJourneyPathNodeState.completed
            : index == currentIndex
            ? OnboardingJourneyPathNodeState.current
            : OnboardingJourneyPathNodeState.future,
    },
  );
}

class OnboardingJourneyPath extends ConsumerWidget {
  const OnboardingJourneyPath({required this.journey, super.key});

  final OnboardingJourneyState journey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projection = projectOnboardingJourneyPath(journey);
    if (projection == null) {
      return const SizedBox.shrink();
    }

    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Semantics(
      key: const Key('onboarding-journey-path'),
      container: true,
      label: projection.semanticLabel,
      child: ExcludeSemantics(
        child: SizedBox(
          height: 74,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final (index, node)
                  in OnboardingJourneyPathNode.values.indexed)
                Expanded(
                  child: _JourneyPathNode(
                    node: node,
                    state: projection.nodeStates[node]!,
                    isFirst: index == 0,
                    isLast:
                        index == OnboardingJourneyPathNode.values.length - 1,
                    leftConnectorSettled:
                        index <=
                        OnboardingJourneyPathNode.values.indexOf(
                          projection.currentNode,
                        ),
                    rightConnectorSettled:
                        index <
                        OnboardingJourneyPathNode.values.indexOf(
                          projection.currentNode,
                        ),
                    animationDuration: disableAnimations
                        ? Duration.zero
                        : const Duration(milliseconds: 180),
                    colors: colors,
                    typography: typography,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JourneyPathNode extends StatelessWidget {
  const _JourneyPathNode({
    required this.node,
    required this.state,
    required this.isFirst,
    required this.isLast,
    required this.leftConnectorSettled,
    required this.rightConnectorSettled,
    required this.animationDuration,
    required this.colors,
    required this.typography,
  });

  final OnboardingJourneyPathNode node;
  final OnboardingJourneyPathNodeState state;
  final bool isFirst;
  final bool isLast;
  final bool leftConnectorSettled;
  final bool rightConnectorSettled;
  final Duration animationDuration;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 22,
          child: Row(
            children: <Widget>[
              Expanded(
                child: _JourneyConnector(
                  visible: !isFirst,
                  settled: leftConnectorSettled,
                  colors: colors,
                  animationDuration: animationDuration,
                ),
              ),
              _JourneyNodeMarker(
                key: ValueKey<String>(
                  'onboarding-journey-node-${node.name}-${state.name}',
                ),
                state: state,
                colors: colors,
                animationDuration: animationDuration,
              ),
              Expanded(
                child: _JourneyConnector(
                  visible: !isLast,
                  settled: rightConnectorSettled,
                  colors: colors,
                  animationDuration: animationDuration,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        Text(
          _visibleLabelFor(node),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: typography.caption.copyWith(
            color: state == OnboardingJourneyPathNodeState.current
                ? colors.content.textPrimary
                : state == OnboardingJourneyPathNodeState.completed
                ? colors.content.textSecondary
                : colors.content.textTertiary,
            fontWeight: state == OnboardingJourneyPathNodeState.current
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _JourneyNodeMarker extends StatelessWidget {
  const _JourneyNodeMarker({
    required this.state,
    required this.colors,
    required this.animationDuration,
    super.key,
  });

  final OnboardingJourneyPathNodeState state;
  final ThemeColors colors;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final isCurrent = state == OnboardingJourneyPathNodeState.current;
    final isCompleted = state == OnboardingJourneyPathNodeState.completed;
    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeOut,
      width: isCurrent ? 18 : 14,
      height: isCurrent ? 18 : 14,
      decoration: BoxDecoration(
        color: isCompleted ? colors.accents.primary : colors.surfaces.canvas,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCurrent
              ? colors.accents.primary
              : isCompleted
              ? colors.accents.primary
              : colors.lines.borderStrong,
          width: isCurrent ? 2.5 : 1.0,
        ),
      ),
      alignment: Alignment.center,
      child: isCompleted
          ? Icon(
              Icons.check_rounded,
              size: 10,
              color: colors.buttons.primaryForeground,
            )
          : isCurrent
          ? AnimatedContainer(
              duration: animationDuration,
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: colors.accents.primary,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}

class _JourneyConnector extends StatelessWidget {
  const _JourneyConnector({
    required this.visible,
    required this.settled,
    required this.colors,
    required this.animationDuration,
  });

  final bool visible;
  final bool settled;
  final ThemeColors colors;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeOut,
      height: 1,
      color: visible
          ? settled
                ? colors.accents.primary.withValues(alpha: 0.58)
                : colors.lines.dividerQuiet
          : colors.lines.dividerQuiet.withValues(alpha: 0),
    );
  }
}

String _visibleLabelFor(OnboardingJourneyPathNode node) {
  return switch (node) {
    OnboardingJourneyPathNode.messages => 'Messages',
    OnboardingJourneyPathNode.history => 'History',
    OnboardingJourneyPathNode.contacts => 'Contacts',
    OnboardingJourneyPathNode.ready => 'Ready',
    OnboardingJourneyPathNode.import => 'Import',
    OnboardingJourneyPathNode.start => 'Start',
  };
}

String _semanticLabelFor(OnboardingJourneyPathNode node) {
  return switch (node) {
    OnboardingJourneyPathNode.messages => 'Messages access',
    OnboardingJourneyPathNode.history => 'Message history',
    OnboardingJourneyPathNode.contacts => 'Contacts',
    OnboardingJourneyPathNode.ready => 'Ready to import',
    OnboardingJourneyPathNode.import => 'Importing',
    OnboardingJourneyPathNode.start => 'Start',
  };
}

String _joinLabels(List<String> labels) {
  if (labels.length == 1) {
    return labels.single;
  }
  if (labels.length == 2) {
    return '${labels.first} and ${labels.last}';
  }
  return '${labels.take(labels.length - 1).join(', ')}, and ${labels.last}';
}
