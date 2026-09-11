// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_evidence_spine_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageEvidenceTimelineSkeletonHash() =>
    r'3f767a11267f6d4de53139627dbea24e8e22fdcc';

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

/// See also [messageEvidenceTimelineSkeleton].
@ProviderFor(messageEvidenceTimelineSkeleton)
const messageEvidenceTimelineSkeletonProvider =
    MessageEvidenceTimelineSkeletonFamily();

/// See also [messageEvidenceTimelineSkeleton].
class MessageEvidenceTimelineSkeletonFamily
    extends Family<AsyncValue<MessageEvidenceTimelineSkeleton>> {
  /// See also [messageEvidenceTimelineSkeleton].
  const MessageEvidenceTimelineSkeletonFamily();

  /// See also [messageEvidenceTimelineSkeleton].
  MessageEvidenceTimelineSkeletonProvider call({
    required MessageEvidenceScope scope,
  }) {
    return MessageEvidenceTimelineSkeletonProvider(scope: scope);
  }

  @override
  MessageEvidenceTimelineSkeletonProvider getProviderOverride(
    covariant MessageEvidenceTimelineSkeletonProvider provider,
  ) {
    return call(scope: provider.scope);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageEvidenceTimelineSkeletonProvider';
}

/// See also [messageEvidenceTimelineSkeleton].
class MessageEvidenceTimelineSkeletonProvider
    extends AutoDisposeFutureProvider<MessageEvidenceTimelineSkeleton> {
  /// See also [messageEvidenceTimelineSkeleton].
  MessageEvidenceTimelineSkeletonProvider({required MessageEvidenceScope scope})
    : this._internal(
        (ref) => messageEvidenceTimelineSkeleton(
          ref as MessageEvidenceTimelineSkeletonRef,
          scope: scope,
        ),
        from: messageEvidenceTimelineSkeletonProvider,
        name: r'messageEvidenceTimelineSkeletonProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messageEvidenceTimelineSkeletonHash,
        dependencies: MessageEvidenceTimelineSkeletonFamily._dependencies,
        allTransitiveDependencies:
            MessageEvidenceTimelineSkeletonFamily._allTransitiveDependencies,
        scope: scope,
      );

  MessageEvidenceTimelineSkeletonProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scope,
  }) : super.internal();

  final MessageEvidenceScope scope;

  @override
  Override overrideWith(
    FutureOr<MessageEvidenceTimelineSkeleton> Function(
      MessageEvidenceTimelineSkeletonRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageEvidenceTimelineSkeletonProvider._internal(
        (ref) => create(ref as MessageEvidenceTimelineSkeletonRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scope: scope,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MessageEvidenceTimelineSkeleton>
  createElement() {
    return _MessageEvidenceTimelineSkeletonProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageEvidenceTimelineSkeletonProvider &&
        other.scope == scope;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scope.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageEvidenceTimelineSkeletonRef
    on AutoDisposeFutureProviderRef<MessageEvidenceTimelineSkeleton> {
  /// The parameter `scope` of this provider.
  MessageEvidenceScope get scope;
}

class _MessageEvidenceTimelineSkeletonProviderElement
    extends AutoDisposeFutureProviderElement<MessageEvidenceTimelineSkeleton>
    with MessageEvidenceTimelineSkeletonRef {
  _MessageEvidenceTimelineSkeletonProviderElement(super.provider);

  @override
  MessageEvidenceScope get scope =>
      (origin as MessageEvidenceTimelineSkeletonProvider).scope;
}

String _$messageEvidenceRowHash() =>
    r'4e4012bca66e84b36c03ab479e5759b5a8b446f2';

/// See also [messageEvidenceRow].
@ProviderFor(messageEvidenceRow)
const messageEvidenceRowProvider = MessageEvidenceRowFamily();

/// See also [messageEvidenceRow].
class MessageEvidenceRowFamily
    extends Family<AsyncValue<MessageEvidenceRowData?>> {
  /// See also [messageEvidenceRow].
  const MessageEvidenceRowFamily();

  /// See also [messageEvidenceRow].
  MessageEvidenceRowProvider call({
    required MessageEvidenceScope scope,
    required int messageId,
  }) {
    return MessageEvidenceRowProvider(scope: scope, messageId: messageId);
  }

  @override
  MessageEvidenceRowProvider getProviderOverride(
    covariant MessageEvidenceRowProvider provider,
  ) {
    return call(scope: provider.scope, messageId: provider.messageId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageEvidenceRowProvider';
}

/// See also [messageEvidenceRow].
class MessageEvidenceRowProvider
    extends AutoDisposeFutureProvider<MessageEvidenceRowData?> {
  /// See also [messageEvidenceRow].
  MessageEvidenceRowProvider({
    required MessageEvidenceScope scope,
    required int messageId,
  }) : this._internal(
         (ref) => messageEvidenceRow(
           ref as MessageEvidenceRowRef,
           scope: scope,
           messageId: messageId,
         ),
         from: messageEvidenceRowProvider,
         name: r'messageEvidenceRowProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$messageEvidenceRowHash,
         dependencies: MessageEvidenceRowFamily._dependencies,
         allTransitiveDependencies:
             MessageEvidenceRowFamily._allTransitiveDependencies,
         scope: scope,
         messageId: messageId,
       );

  MessageEvidenceRowProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scope,
    required this.messageId,
  }) : super.internal();

  final MessageEvidenceScope scope;
  final int messageId;

  @override
  Override overrideWith(
    FutureOr<MessageEvidenceRowData?> Function(MessageEvidenceRowRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageEvidenceRowProvider._internal(
        (ref) => create(ref as MessageEvidenceRowRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scope: scope,
        messageId: messageId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MessageEvidenceRowData?> createElement() {
    return _MessageEvidenceRowProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageEvidenceRowProvider &&
        other.scope == scope &&
        other.messageId == messageId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scope.hashCode);
    hash = _SystemHash.combine(hash, messageId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageEvidenceRowRef
    on AutoDisposeFutureProviderRef<MessageEvidenceRowData?> {
  /// The parameter `scope` of this provider.
  MessageEvidenceScope get scope;

  /// The parameter `messageId` of this provider.
  int get messageId;
}

class _MessageEvidenceRowProviderElement
    extends AutoDisposeFutureProviderElement<MessageEvidenceRowData?>
    with MessageEvidenceRowRef {
  _MessageEvidenceRowProviderElement(super.provider);

  @override
  MessageEvidenceScope get scope =>
      (origin as MessageEvidenceRowProvider).scope;
  @override
  int get messageId => (origin as MessageEvidenceRowProvider).messageId;
}

String _$messageEvidenceAttachmentsHash() =>
    r'38651f5c43eb11aec171e58b0d34032b3f1769da';

/// See also [messageEvidenceAttachments].
@ProviderFor(messageEvidenceAttachments)
const messageEvidenceAttachmentsProvider = MessageEvidenceAttachmentsFamily();

/// See also [messageEvidenceAttachments].
class MessageEvidenceAttachmentsFamily
    extends Family<AsyncValue<List<MessageAttachmentEvidence>>> {
  /// See also [messageEvidenceAttachments].
  const MessageEvidenceAttachmentsFamily();

  /// See also [messageEvidenceAttachments].
  MessageEvidenceAttachmentsProvider call({
    required MessageEvidenceScope scope,
    required int messageId,
  }) {
    return MessageEvidenceAttachmentsProvider(
      scope: scope,
      messageId: messageId,
    );
  }

  @override
  MessageEvidenceAttachmentsProvider getProviderOverride(
    covariant MessageEvidenceAttachmentsProvider provider,
  ) {
    return call(scope: provider.scope, messageId: provider.messageId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageEvidenceAttachmentsProvider';
}

/// See also [messageEvidenceAttachments].
class MessageEvidenceAttachmentsProvider
    extends AutoDisposeFutureProvider<List<MessageAttachmentEvidence>> {
  /// See also [messageEvidenceAttachments].
  MessageEvidenceAttachmentsProvider({
    required MessageEvidenceScope scope,
    required int messageId,
  }) : this._internal(
         (ref) => messageEvidenceAttachments(
           ref as MessageEvidenceAttachmentsRef,
           scope: scope,
           messageId: messageId,
         ),
         from: messageEvidenceAttachmentsProvider,
         name: r'messageEvidenceAttachmentsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$messageEvidenceAttachmentsHash,
         dependencies: MessageEvidenceAttachmentsFamily._dependencies,
         allTransitiveDependencies:
             MessageEvidenceAttachmentsFamily._allTransitiveDependencies,
         scope: scope,
         messageId: messageId,
       );

  MessageEvidenceAttachmentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scope,
    required this.messageId,
  }) : super.internal();

  final MessageEvidenceScope scope;
  final int messageId;

  @override
  Override overrideWith(
    FutureOr<List<MessageAttachmentEvidence>> Function(
      MessageEvidenceAttachmentsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageEvidenceAttachmentsProvider._internal(
        (ref) => create(ref as MessageEvidenceAttachmentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scope: scope,
        messageId: messageId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MessageAttachmentEvidence>>
  createElement() {
    return _MessageEvidenceAttachmentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageEvidenceAttachmentsProvider &&
        other.scope == scope &&
        other.messageId == messageId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scope.hashCode);
    hash = _SystemHash.combine(hash, messageId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageEvidenceAttachmentsRef
    on AutoDisposeFutureProviderRef<List<MessageAttachmentEvidence>> {
  /// The parameter `scope` of this provider.
  MessageEvidenceScope get scope;

  /// The parameter `messageId` of this provider.
  int get messageId;
}

class _MessageEvidenceAttachmentsProviderElement
    extends AutoDisposeFutureProviderElement<List<MessageAttachmentEvidence>>
    with MessageEvidenceAttachmentsRef {
  _MessageEvidenceAttachmentsProviderElement(super.provider);

  @override
  MessageEvidenceScope get scope =>
      (origin as MessageEvidenceAttachmentsProvider).scope;
  @override
  int get messageId => (origin as MessageEvidenceAttachmentsProvider).messageId;
}

String _$messageEvidenceInitialRowsHash() =>
    r'4761d2523194f8ee1548449d55c945e64b916f68';

/// See also [messageEvidenceInitialRows].
@ProviderFor(messageEvidenceInitialRows)
const messageEvidenceInitialRowsProvider = MessageEvidenceInitialRowsFamily();

/// See also [messageEvidenceInitialRows].
class MessageEvidenceInitialRowsFamily
    extends Family<AsyncValue<Map<int, MessageEvidenceRowData>>> {
  /// See also [messageEvidenceInitialRows].
  const MessageEvidenceInitialRowsFamily();

  /// See also [messageEvidenceInitialRows].
  MessageEvidenceInitialRowsProvider call({
    required MessageEvidenceScope scope,
    DateTime? monthAnchor,
    int hydrationLimit = 80,
  }) {
    return MessageEvidenceInitialRowsProvider(
      scope: scope,
      monthAnchor: monthAnchor,
      hydrationLimit: hydrationLimit,
    );
  }

  @override
  MessageEvidenceInitialRowsProvider getProviderOverride(
    covariant MessageEvidenceInitialRowsProvider provider,
  ) {
    return call(
      scope: provider.scope,
      monthAnchor: provider.monthAnchor,
      hydrationLimit: provider.hydrationLimit,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageEvidenceInitialRowsProvider';
}

/// See also [messageEvidenceInitialRows].
class MessageEvidenceInitialRowsProvider
    extends AutoDisposeFutureProvider<Map<int, MessageEvidenceRowData>> {
  /// See also [messageEvidenceInitialRows].
  MessageEvidenceInitialRowsProvider({
    required MessageEvidenceScope scope,
    DateTime? monthAnchor,
    int hydrationLimit = 80,
  }) : this._internal(
         (ref) => messageEvidenceInitialRows(
           ref as MessageEvidenceInitialRowsRef,
           scope: scope,
           monthAnchor: monthAnchor,
           hydrationLimit: hydrationLimit,
         ),
         from: messageEvidenceInitialRowsProvider,
         name: r'messageEvidenceInitialRowsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$messageEvidenceInitialRowsHash,
         dependencies: MessageEvidenceInitialRowsFamily._dependencies,
         allTransitiveDependencies:
             MessageEvidenceInitialRowsFamily._allTransitiveDependencies,
         scope: scope,
         monthAnchor: monthAnchor,
         hydrationLimit: hydrationLimit,
       );

  MessageEvidenceInitialRowsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scope,
    required this.monthAnchor,
    required this.hydrationLimit,
  }) : super.internal();

  final MessageEvidenceScope scope;
  final DateTime? monthAnchor;
  final int hydrationLimit;

  @override
  Override overrideWith(
    FutureOr<Map<int, MessageEvidenceRowData>> Function(
      MessageEvidenceInitialRowsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageEvidenceInitialRowsProvider._internal(
        (ref) => create(ref as MessageEvidenceInitialRowsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scope: scope,
        monthAnchor: monthAnchor,
        hydrationLimit: hydrationLimit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<int, MessageEvidenceRowData>>
  createElement() {
    return _MessageEvidenceInitialRowsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageEvidenceInitialRowsProvider &&
        other.scope == scope &&
        other.monthAnchor == monthAnchor &&
        other.hydrationLimit == hydrationLimit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scope.hashCode);
    hash = _SystemHash.combine(hash, monthAnchor.hashCode);
    hash = _SystemHash.combine(hash, hydrationLimit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageEvidenceInitialRowsRef
    on AutoDisposeFutureProviderRef<Map<int, MessageEvidenceRowData>> {
  /// The parameter `scope` of this provider.
  MessageEvidenceScope get scope;

  /// The parameter `monthAnchor` of this provider.
  DateTime? get monthAnchor;

  /// The parameter `hydrationLimit` of this provider.
  int get hydrationLimit;
}

class _MessageEvidenceInitialRowsProviderElement
    extends AutoDisposeFutureProviderElement<Map<int, MessageEvidenceRowData>>
    with MessageEvidenceInitialRowsRef {
  _MessageEvidenceInitialRowsProviderElement(super.provider);

  @override
  MessageEvidenceScope get scope =>
      (origin as MessageEvidenceInitialRowsProvider).scope;
  @override
  DateTime? get monthAnchor =>
      (origin as MessageEvidenceInitialRowsProvider).monthAnchor;
  @override
  int get hydrationLimit =>
      (origin as MessageEvidenceInitialRowsProvider).hydrationLimit;
}

String _$messageEvidenceTextMatchIdsHash() =>
    r'3f01307dea12b0e508929251cb2033ceaad43779';

/// See also [messageEvidenceTextMatchIds].
@ProviderFor(messageEvidenceTextMatchIds)
const messageEvidenceTextMatchIdsProvider = MessageEvidenceTextMatchIdsFamily();

/// See also [messageEvidenceTextMatchIds].
class MessageEvidenceTextMatchIdsFamily extends Family<AsyncValue<List<int>>> {
  /// See also [messageEvidenceTextMatchIds].
  const MessageEvidenceTextMatchIdsFamily();

  /// See also [messageEvidenceTextMatchIds].
  MessageEvidenceTextMatchIdsProvider call({
    required MessageEvidenceScope scope,
    required MessageTextSearchExecutionIntent searchIntent,
    MessageEvidenceSearchMode mode = MessageEvidenceSearchMode.allTerms,
  }) {
    return MessageEvidenceTextMatchIdsProvider(
      scope: scope,
      searchIntent: searchIntent,
      mode: mode,
    );
  }

  @override
  MessageEvidenceTextMatchIdsProvider getProviderOverride(
    covariant MessageEvidenceTextMatchIdsProvider provider,
  ) {
    return call(
      scope: provider.scope,
      searchIntent: provider.searchIntent,
      mode: provider.mode,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageEvidenceTextMatchIdsProvider';
}

/// See also [messageEvidenceTextMatchIds].
class MessageEvidenceTextMatchIdsProvider
    extends AutoDisposeFutureProvider<List<int>> {
  /// See also [messageEvidenceTextMatchIds].
  MessageEvidenceTextMatchIdsProvider({
    required MessageEvidenceScope scope,
    required MessageTextSearchExecutionIntent searchIntent,
    MessageEvidenceSearchMode mode = MessageEvidenceSearchMode.allTerms,
  }) : this._internal(
         (ref) => messageEvidenceTextMatchIds(
           ref as MessageEvidenceTextMatchIdsRef,
           scope: scope,
           searchIntent: searchIntent,
           mode: mode,
         ),
         from: messageEvidenceTextMatchIdsProvider,
         name: r'messageEvidenceTextMatchIdsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$messageEvidenceTextMatchIdsHash,
         dependencies: MessageEvidenceTextMatchIdsFamily._dependencies,
         allTransitiveDependencies:
             MessageEvidenceTextMatchIdsFamily._allTransitiveDependencies,
         scope: scope,
         searchIntent: searchIntent,
         mode: mode,
       );

  MessageEvidenceTextMatchIdsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scope,
    required this.searchIntent,
    required this.mode,
  }) : super.internal();

  final MessageEvidenceScope scope;
  final MessageTextSearchExecutionIntent searchIntent;
  final MessageEvidenceSearchMode mode;

  @override
  Override overrideWith(
    FutureOr<List<int>> Function(MessageEvidenceTextMatchIdsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageEvidenceTextMatchIdsProvider._internal(
        (ref) => create(ref as MessageEvidenceTextMatchIdsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scope: scope,
        searchIntent: searchIntent,
        mode: mode,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<int>> createElement() {
    return _MessageEvidenceTextMatchIdsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageEvidenceTextMatchIdsProvider &&
        other.scope == scope &&
        other.searchIntent == searchIntent &&
        other.mode == mode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scope.hashCode);
    hash = _SystemHash.combine(hash, searchIntent.hashCode);
    hash = _SystemHash.combine(hash, mode.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageEvidenceTextMatchIdsRef
    on AutoDisposeFutureProviderRef<List<int>> {
  /// The parameter `scope` of this provider.
  MessageEvidenceScope get scope;

  /// The parameter `searchIntent` of this provider.
  MessageTextSearchExecutionIntent get searchIntent;

  /// The parameter `mode` of this provider.
  MessageEvidenceSearchMode get mode;
}

class _MessageEvidenceTextMatchIdsProviderElement
    extends AutoDisposeFutureProviderElement<List<int>>
    with MessageEvidenceTextMatchIdsRef {
  _MessageEvidenceTextMatchIdsProviderElement(super.provider);

  @override
  MessageEvidenceScope get scope =>
      (origin as MessageEvidenceTextMatchIdsProvider).scope;
  @override
  MessageTextSearchExecutionIntent get searchIntent =>
      (origin as MessageEvidenceTextMatchIdsProvider).searchIntent;
  @override
  MessageEvidenceSearchMode get mode =>
      (origin as MessageEvidenceTextMatchIdsProvider).mode;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
