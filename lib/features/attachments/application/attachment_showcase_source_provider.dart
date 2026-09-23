import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'attachment_showcase.dart';

part 'attachment_showcase_source_provider.g.dart';

/// Bounded, presentation-only sampling source for Attachment Showcase.
///
/// Producers never await this source. The currently displayed item plus at
/// most one latest pending item are retained; intermediate rapid events are
/// deliberately coalesced. No event is persisted or sent off-device.
@Riverpod(keepAlive: true)
class AttachmentShowcaseSource extends _$AttachmentShowcaseSource {
  static const samplingCadence = Duration(milliseconds: 750);

  Timer? _samplingTimer;
  AttachmentShowcaseItem? _pendingLatest;
  bool _acceptingEvents = false;

  @override
  AttachmentShowcaseItem? build() {
    ref.onDispose(() {
      _samplingTimer?.cancel();
      _samplingTimer = null;
      _pendingLatest = null;
      _acceptingEvents = false;
    });
    return null;
  }

  void begin() {
    _samplingTimer?.cancel();
    _samplingTimer = null;
    _pendingLatest = null;
    _acceptingEvents = true;
    state = null;
  }

  void offer(AttachmentShowcaseItem item) {
    if (!_acceptingEvents) {
      return;
    }
    if (_samplingTimer == null) {
      state = item;
      _scheduleNextSample();
      return;
    }
    _pendingLatest = item;
  }

  /// Stops operation-progress updates without discarding the last visual.
  void stop() {
    _acceptingEvents = false;
    _pendingLatest = null;
    _samplingTimer?.cancel();
    _samplingTimer = null;
  }

  void clear() {
    stop();
    state = null;
  }

  int get retainedItemCount {
    return (state == null ? 0 : 1) + (_pendingLatest == null ? 0 : 1);
  }

  void _scheduleNextSample() {
    _samplingTimer = Timer(samplingCadence, () {
      _samplingTimer = null;
      if (!_acceptingEvents) {
        _pendingLatest = null;
        return;
      }
      final next = _pendingLatest;
      _pendingLatest = null;
      if (next == null) {
        return;
      }
      state = next;
      _scheduleNextSample();
    });
  }
}
