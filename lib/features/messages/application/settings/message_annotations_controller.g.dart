// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_annotations_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$starredMessagesHash() => r'c4432826512e122fb24a35b2ccb5e2ca5d27f269';

/// Provider for getting all starred messages
///
/// Copied from [starredMessages].
@ProviderFor(starredMessages)
final starredMessagesProvider =
    AutoDisposeFutureProvider<List<MessageAnnotation>>.internal(
      starredMessages,
      name: r'starredMessagesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$starredMessagesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StarredMessagesRef =
    AutoDisposeFutureProviderRef<List<MessageAnnotation>>;
String _$messagesByTagHash() => r'6d032faef6c28c75ebaea863ce61cb0a57724aa9';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for getting messages with a specific tag
///
/// Copied from [messagesByTag].
@ProviderFor(messagesByTag)
const messagesByTagProvider = MessagesByTagFamily();

/// Provider for getting messages with a specific tag
///
/// Copied from [messagesByTag].
class MessagesByTagFamily extends Family<AsyncValue<List<MessageAnnotation>>> {
  /// Provider for getting messages with a specific tag
  ///
  /// Copied from [messagesByTag].
  const MessagesByTagFamily();

  /// Provider for getting messages with a specific tag
  ///
  /// Copied from [messagesByTag].
  MessagesByTagProvider call(String tag) {
    return MessagesByTagProvider(tag);
  }

  @override
  MessagesByTagProvider getProviderOverride(
    covariant MessagesByTagProvider provider,
  ) {
    return call(provider.tag);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messagesByTagProvider';
}

/// Provider for getting messages with a specific tag
///
/// Copied from [messagesByTag].
class MessagesByTagProvider
    extends AutoDisposeFutureProvider<List<MessageAnnotation>> {
  /// Provider for getting messages with a specific tag
  ///
  /// Copied from [messagesByTag].
  MessagesByTagProvider(String tag)
    : this._internal(
        (ref) => messagesByTag(ref as MessagesByTagRef, tag),
        from: messagesByTagProvider,
        name: r'messagesByTagProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messagesByTagHash,
        dependencies: MessagesByTagFamily._dependencies,
        allTransitiveDependencies:
            MessagesByTagFamily._allTransitiveDependencies,
        tag: tag,
      );

  MessagesByTagProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tag,
  }) : super.internal();

  final String tag;

  @override
  Override overrideWith(
    FutureOr<List<MessageAnnotation>> Function(MessagesByTagRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessagesByTagProvider._internal(
        (ref) => create(ref as MessagesByTagRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tag: tag,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MessageAnnotation>> createElement() {
    return _MessagesByTagProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesByTagProvider && other.tag == tag;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tag.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessagesByTagRef
    on AutoDisposeFutureProviderRef<List<MessageAnnotation>> {
  /// The parameter `tag` of this provider.
  String get tag;
}

class _MessagesByTagProviderElement
    extends AutoDisposeFutureProviderElement<List<MessageAnnotation>>
    with MessagesByTagRef {
  _MessagesByTagProviderElement(super.provider);

  @override
  String get tag => (origin as MessagesByTagProvider).tag;
}

String _$highPriorityMessagesHash() =>
    r'1756b73a0c828b8a59bce05aa4056ff56aa89454';

/// Provider for getting high priority messages
///
/// Copied from [highPriorityMessages].
@ProviderFor(highPriorityMessages)
final highPriorityMessagesProvider =
    AutoDisposeFutureProvider<List<MessageAnnotation>>.internal(
      highPriorityMessages,
      name: r'highPriorityMessagesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$highPriorityMessagesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HighPriorityMessagesRef =
    AutoDisposeFutureProviderRef<List<MessageAnnotation>>;
String _$messagesDueForReminderHash() =>
    r'876fa5e3240cf867a6d6d698af828d287603ba3e';

/// Provider for getting messages due for reminder
///
/// Copied from [messagesDueForReminder].
@ProviderFor(messagesDueForReminder)
const messagesDueForReminderProvider = MessagesDueForReminderFamily();

/// Provider for getting messages due for reminder
///
/// Copied from [messagesDueForReminder].
class MessagesDueForReminderFamily
    extends Family<AsyncValue<List<MessageAnnotation>>> {
  /// Provider for getting messages due for reminder
  ///
  /// Copied from [messagesDueForReminder].
  const MessagesDueForReminderFamily();

  /// Provider for getting messages due for reminder
  ///
  /// Copied from [messagesDueForReminder].
  MessagesDueForReminderProvider call(DateTime before) {
    return MessagesDueForReminderProvider(before);
  }

  @override
  MessagesDueForReminderProvider getProviderOverride(
    covariant MessagesDueForReminderProvider provider,
  ) {
    return call(provider.before);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messagesDueForReminderProvider';
}

/// Provider for getting messages due for reminder
///
/// Copied from [messagesDueForReminder].
class MessagesDueForReminderProvider
    extends AutoDisposeFutureProvider<List<MessageAnnotation>> {
  /// Provider for getting messages due for reminder
  ///
  /// Copied from [messagesDueForReminder].
  MessagesDueForReminderProvider(DateTime before)
    : this._internal(
        (ref) =>
            messagesDueForReminder(ref as MessagesDueForReminderRef, before),
        from: messagesDueForReminderProvider,
        name: r'messagesDueForReminderProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messagesDueForReminderHash,
        dependencies: MessagesDueForReminderFamily._dependencies,
        allTransitiveDependencies:
            MessagesDueForReminderFamily._allTransitiveDependencies,
        before: before,
      );

  MessagesDueForReminderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.before,
  }) : super.internal();

  final DateTime before;

  @override
  Override overrideWith(
    FutureOr<List<MessageAnnotation>> Function(
      MessagesDueForReminderRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessagesDueForReminderProvider._internal(
        (ref) => create(ref as MessagesDueForReminderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        before: before,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MessageAnnotation>> createElement() {
    return _MessagesDueForReminderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesDueForReminderProvider && other.before == before;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, before.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessagesDueForReminderRef
    on AutoDisposeFutureProviderRef<List<MessageAnnotation>> {
  /// The parameter `before` of this provider.
  DateTime get before;
}

class _MessagesDueForReminderProviderElement
    extends AutoDisposeFutureProviderElement<List<MessageAnnotation>>
    with MessagesDueForReminderRef {
  _MessagesDueForReminderProviderElement(super.provider);

  @override
  DateTime get before => (origin as MessagesDueForReminderProvider).before;
}

String _$messageAnnotationsHash() =>
    r'7723ce1756c9b376a80086ba5a1e356d0d9b85c9';

abstract class _$MessageAnnotations
    extends BuildlessAutoDisposeAsyncNotifier<MessageAnnotation?> {
  late final int messageId;

  FutureOr<MessageAnnotation?> build(int messageId);
}

/// Controller for managing message annotations (tags, starred, notes, etc.)
///
/// Copied from [MessageAnnotations].
@ProviderFor(MessageAnnotations)
const messageAnnotationsProvider = MessageAnnotationsFamily();

/// Controller for managing message annotations (tags, starred, notes, etc.)
///
/// Copied from [MessageAnnotations].
class MessageAnnotationsFamily extends Family<AsyncValue<MessageAnnotation?>> {
  /// Controller for managing message annotations (tags, starred, notes, etc.)
  ///
  /// Copied from [MessageAnnotations].
  const MessageAnnotationsFamily();

  /// Controller for managing message annotations (tags, starred, notes, etc.)
  ///
  /// Copied from [MessageAnnotations].
  MessageAnnotationsProvider call(int messageId) {
    return MessageAnnotationsProvider(messageId);
  }

  @override
  MessageAnnotationsProvider getProviderOverride(
    covariant MessageAnnotationsProvider provider,
  ) {
    return call(provider.messageId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageAnnotationsProvider';
}

/// Controller for managing message annotations (tags, starred, notes, etc.)
///
/// Copied from [MessageAnnotations].
class MessageAnnotationsProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          MessageAnnotations,
          MessageAnnotation?
        > {
  /// Controller for managing message annotations (tags, starred, notes, etc.)
  ///
  /// Copied from [MessageAnnotations].
  MessageAnnotationsProvider(int messageId)
    : this._internal(
        () => MessageAnnotations()..messageId = messageId,
        from: messageAnnotationsProvider,
        name: r'messageAnnotationsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messageAnnotationsHash,
        dependencies: MessageAnnotationsFamily._dependencies,
        allTransitiveDependencies:
            MessageAnnotationsFamily._allTransitiveDependencies,
        messageId: messageId,
      );

  MessageAnnotationsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.messageId,
  }) : super.internal();

  final int messageId;

  @override
  FutureOr<MessageAnnotation?> runNotifierBuild(
    covariant MessageAnnotations notifier,
  ) {
    return notifier.build(messageId);
  }

  @override
  Override overrideWith(MessageAnnotations Function() create) {
    return ProviderOverride(
      origin: this,
      override: MessageAnnotationsProvider._internal(
        () => create()..messageId = messageId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        messageId: messageId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    MessageAnnotations,
    MessageAnnotation?
  >
  createElement() {
    return _MessageAnnotationsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageAnnotationsProvider && other.messageId == messageId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, messageId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageAnnotationsRef
    on AutoDisposeAsyncNotifierProviderRef<MessageAnnotation?> {
  /// The parameter `messageId` of this provider.
  int get messageId;
}

class _MessageAnnotationsProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          MessageAnnotations,
          MessageAnnotation?
        >
    with MessageAnnotationsRef {
  _MessageAnnotationsProviderElement(super.provider);

  @override
  int get messageId => (origin as MessageAnnotationsProvider).messageId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
