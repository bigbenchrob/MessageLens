// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_for_chat_view_builder_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messagesForChatViewBuilderHash() =>
    r'c601251dfa46d6c7bcffb5e730560a208d1f7a77';

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

/// Resolves the widget used to display messages for a specific chat.
///
/// Copied from [messagesForChatViewBuilder].
@ProviderFor(messagesForChatViewBuilder)
const messagesForChatViewBuilderProvider = MessagesForChatViewBuilderFamily();

/// Resolves the widget used to display messages for a specific chat.
///
/// Copied from [messagesForChatViewBuilder].
class MessagesForChatViewBuilderFamily extends Family<Widget> {
  /// Resolves the widget used to display messages for a specific chat.
  ///
  /// Copied from [messagesForChatViewBuilder].
  const MessagesForChatViewBuilderFamily();

  /// Resolves the widget used to display messages for a specific chat.
  ///
  /// Copied from [messagesForChatViewBuilder].
  MessagesForChatViewBuilderProvider call(
    int chatId, {
    DateTime? scrollToDate,
  }) {
    return MessagesForChatViewBuilderProvider(
      chatId,
      scrollToDate: scrollToDate,
    );
  }

  @override
  MessagesForChatViewBuilderProvider getProviderOverride(
    covariant MessagesForChatViewBuilderProvider provider,
  ) {
    return call(provider.chatId, scrollToDate: provider.scrollToDate);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messagesForChatViewBuilderProvider';
}

/// Resolves the widget used to display messages for a specific chat.
///
/// Copied from [messagesForChatViewBuilder].
class MessagesForChatViewBuilderProvider extends AutoDisposeProvider<Widget> {
  /// Resolves the widget used to display messages for a specific chat.
  ///
  /// Copied from [messagesForChatViewBuilder].
  MessagesForChatViewBuilderProvider(int chatId, {DateTime? scrollToDate})
    : this._internal(
        (ref) => messagesForChatViewBuilder(
          ref as MessagesForChatViewBuilderRef,
          chatId,
          scrollToDate: scrollToDate,
        ),
        from: messagesForChatViewBuilderProvider,
        name: r'messagesForChatViewBuilderProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messagesForChatViewBuilderHash,
        dependencies: MessagesForChatViewBuilderFamily._dependencies,
        allTransitiveDependencies:
            MessagesForChatViewBuilderFamily._allTransitiveDependencies,
        chatId: chatId,
        scrollToDate: scrollToDate,
      );

  MessagesForChatViewBuilderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chatId,
    required this.scrollToDate,
  }) : super.internal();

  final int chatId;
  final DateTime? scrollToDate;

  @override
  Override overrideWith(
    Widget Function(MessagesForChatViewBuilderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessagesForChatViewBuilderProvider._internal(
        (ref) => create(ref as MessagesForChatViewBuilderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chatId: chatId,
        scrollToDate: scrollToDate,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<Widget> createElement() {
    return _MessagesForChatViewBuilderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesForChatViewBuilderProvider &&
        other.chatId == chatId &&
        other.scrollToDate == scrollToDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chatId.hashCode);
    hash = _SystemHash.combine(hash, scrollToDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessagesForChatViewBuilderRef on AutoDisposeProviderRef<Widget> {
  /// The parameter `chatId` of this provider.
  int get chatId;

  /// The parameter `scrollToDate` of this provider.
  DateTime? get scrollToDate;
}

class _MessagesForChatViewBuilderProviderElement
    extends AutoDisposeProviderElement<Widget>
    with MessagesForChatViewBuilderRef {
  _MessagesForChatViewBuilderProviderElement(super.provider);

  @override
  int get chatId => (origin as MessagesForChatViewBuilderProvider).chatId;
  @override
  DateTime? get scrollToDate =>
      (origin as MessagesForChatViewBuilderProvider).scrollToDate;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
