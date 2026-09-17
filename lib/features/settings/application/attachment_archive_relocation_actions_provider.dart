import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/logging/feature_level_providers.dart'
    show appLoggerProvider;
import '../../attachments/feature_level_providers.dart'
    show
        attachmentArchiveRelocationExecutionEnabledProvider,
        attachmentArchiveRelocationWorkflowProvider;

part 'attachment_archive_relocation_actions_provider.g.dart';

@riverpod
class AttachmentArchiveRelocationActions
    extends _$AttachmentArchiveRelocationActions {
  @override
  FutureOr<void> build() {}

  Future<void> chooseDestination() {
    return _runEnabledAction(
      label: 'choose destination',
      action: () async {
        await ref
            .read(attachmentArchiveRelocationWorkflowProvider.notifier)
            .chooseDestinationAndPrepare();
      },
    );
  }

  Future<void> chooseAnotherLocation(String operationId) {
    return _runEnabledAction(
      label: 'choose another destination',
      action: () async {
        final workflow = ref.read(
          attachmentArchiveRelocationWorkflowProvider.notifier,
        );
        final destinationParentPath = await workflow.chooseDestinationParent();
        if (destinationParentPath == null) {
          return;
        }
        await workflow.cancel(operationId);
        final selected = await workflow.selectDestination(
          destinationParentPath,
        );
        await workflow.prepareForReview(selected.operationId);
      },
    );
  }

  Future<void> retryPreflight(String operationId) {
    return _runEnabledAction(
      label: 'retry preflight',
      action: () async {
        await ref
            .read(attachmentArchiveRelocationWorkflowProvider.notifier)
            .prepareForReview(operationId);
      },
    );
  }

  Future<void> begin(String operationId) {
    return _runEnabledAction(
      label: 'begin relocation',
      action: () async {
        await ref
            .read(attachmentArchiveRelocationWorkflowProvider.notifier)
            .run(operationId);
      },
    );
  }

  Future<void> pause(String operationId) {
    return _runEnabledAction(
      label: 'pause relocation',
      action: () async {
        ref
            .read(attachmentArchiveRelocationWorkflowProvider.notifier)
            .requestPause(operationId);
      },
    );
  }

  Future<void> resume(String operationId) {
    return _runEnabledAction(
      label: 'resume relocation',
      action: () async {
        await ref
            .read(attachmentArchiveRelocationWorkflowProvider.notifier)
            .run(operationId);
      },
    );
  }

  Future<void> cancel(String operationId) {
    return _runEnabledAction(
      label: 'cancel relocation',
      action: () async {
        await ref
            .read(attachmentArchiveRelocationWorkflowProvider.notifier)
            .cancel(operationId);
      },
    );
  }

  Future<void> _runEnabledAction({
    required String label,
    required Future<void> Function() action,
  }) async {
    if (!ref.read(attachmentArchiveRelocationExecutionEnabledProvider)) {
      throw StateError(
        'Attachment archive relocation is awaiting explicit '
        'authorization.',
      );
    }
    try {
      await action();
    } on Object catch (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Attachment archive relocation could not $label',
            source: 'AttachmentArchiveRelocationActions',
            context: <String, Object?>{
              'error': error.toString(),
              'stackTrace': stackTrace.toString(),
            },
          );
      await ref
          .read(attachmentArchiveRelocationWorkflowProvider.notifier)
          .refreshFromJournal();
    }
  }
}
