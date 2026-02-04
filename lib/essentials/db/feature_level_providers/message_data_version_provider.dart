import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'message_data_version_provider.g.dart';

/// A signal provider that message-related providers can watch to know when
/// new data has been imported/migrated.
///
/// ## Purpose
///
/// Drift's reactive streams (`watch()`) automatically update when data changes,
/// but many message providers use one-time queries (`get()`) for performance.
/// Those providers need an external signal to know when to re-query.
///
/// ## How it works
///
/// 1. Message providers (e.g., `contactMessagesOrdinalProvider`) watch this
/// 2. After migration completes, `ChatDbChangeMonitor` invalidates this provider
/// 3. The invalidation cascades to all watching providers, triggering rebuilds
///
/// ## Usage
///
/// In a provider that needs to refresh when new messages arrive:
/// ```dart
/// @riverpod
/// Future<SomeState> myProvider(MyProviderRef ref) async {
///   // Watch the signal - rebuilds when invalidated
///   ref.watch(messageDataVersionProvider);
///
///   // ... fetch data from database
/// }
/// ```
///
/// To trigger a refresh (in ChatDbChangeMonitor):
/// ```dart
/// ref.invalidate(messageDataVersionProvider);
/// ```
@Riverpod(keepAlive: true)
class MessageDataVersion extends _$MessageDataVersion {
  @override
  int build() => 0;

  /// Increment to signal that message data has changed.
  /// This causes all watching providers to rebuild.
  void bump() {
    state = state + 1;
  }
}
