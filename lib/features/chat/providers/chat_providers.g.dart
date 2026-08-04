// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(chatRepository)
final chatRepositoryProvider = ChatRepositoryProvider._();

final class ChatRepositoryProvider
    extends $FunctionalProvider<ChatRepository, ChatRepository, ChatRepository>
    with $Provider<ChatRepository> {
  ChatRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChatRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChatRepository create(Ref ref) {
    return chatRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatRepository>(value),
    );
  }
}

String _$chatRepositoryHash() => r'adedc4ab186f1b05b76aabcfbc139226866fd856';

@ProviderFor(PendingChatDraft)
final pendingChatDraftProvider = PendingChatDraftProvider._();

final class PendingChatDraftProvider
    extends $NotifierProvider<PendingChatDraft, ChatDraft?> {
  PendingChatDraftProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingChatDraftProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingChatDraftHash();

  @$internal
  @override
  PendingChatDraft create() => PendingChatDraft();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatDraft? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatDraft?>(value),
    );
  }
}

String _$pendingChatDraftHash() => r'f431049fd29274d2d3e9ef17766a3cbaf4551894';

abstract class _$PendingChatDraft extends $Notifier<ChatDraft?> {
  ChatDraft? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ChatDraft?, ChatDraft?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatDraft?, ChatDraft?>,
              ChatDraft?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The signed-in user's chat threads — whichever side of the pair they are.

@ProviderFor(myChats)
final myChatsProvider = MyChatsProvider._();

/// The signed-in user's chat threads — whichever side of the pair they are.

final class MyChatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Chat>>,
          List<Chat>,
          Stream<List<Chat>>
        >
    with $FutureModifier<List<Chat>>, $StreamProvider<List<Chat>> {
  /// The signed-in user's chat threads — whichever side of the pair they are.
  MyChatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myChatsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myChatsHash();

  @$internal
  @override
  $StreamProviderElement<List<Chat>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Chat>> create(Ref ref) {
    return myChats(ref);
  }
}

String _$myChatsHash() => r'd82efad4a4cd5b84e180e8cdf81324a2d7e18863';

@ProviderFor(chatById)
final chatByIdProvider = ChatByIdFamily._();

final class ChatByIdProvider
    extends $FunctionalProvider<AsyncValue<Chat?>, Chat?, FutureOr<Chat?>>
    with $FutureModifier<Chat?>, $FutureProvider<Chat?> {
  ChatByIdProvider._({
    required ChatByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chatByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatByIdHash();

  @override
  String toString() {
    return r'chatByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Chat?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Chat?> create(Ref ref) {
    final argument = this.argument as String;
    return chatById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatByIdHash() => r'59ac0714840886339e3d2c9a3048ceeb7bf400c6';

final class ChatByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Chat?>, String> {
  ChatByIdFamily._()
    : super(
        retry: null,
        name: r'chatByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatByIdProvider call(String chatId) =>
      ChatByIdProvider._(argument: chatId, from: this);

  @override
  String toString() => r'chatByIdProvider';
}

@ProviderFor(chatMessages)
final chatMessagesProvider = ChatMessagesFamily._();

final class ChatMessagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ChatMessage>>,
          List<ChatMessage>,
          Stream<List<ChatMessage>>
        >
    with
        $FutureModifier<List<ChatMessage>>,
        $StreamProvider<List<ChatMessage>> {
  ChatMessagesProvider._({
    required ChatMessagesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chatMessagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatMessagesHash();

  @override
  String toString() {
    return r'chatMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ChatMessage>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ChatMessage>> create(Ref ref) {
    final argument = this.argument as String;
    return chatMessages(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatMessagesHash() => r'915d36c6e538b28b79bc0cd93ddddbfc0c12b765';

final class ChatMessagesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ChatMessage>>, String> {
  ChatMessagesFamily._()
    : super(
        retry: null,
        name: r'chatMessagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatMessagesProvider call(String chatId) =>
      ChatMessagesProvider._(argument: chatId, from: this);

  @override
  String toString() => r'chatMessagesProvider';
}

/// Drives sending messages and marking a thread read.

@ProviderFor(ChatController)
final chatControllerProvider = ChatControllerProvider._();

/// Drives sending messages and marking a thread read.
final class ChatControllerProvider
    extends $AsyncNotifierProvider<ChatController, void> {
  /// Drives sending messages and marking a thread read.
  ChatControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatControllerHash();

  @$internal
  @override
  ChatController create() => ChatController();
}

String _$chatControllerHash() => r'ea6da838f6bc7d96cc638936a022881b39433096';

/// Drives sending messages and marking a thread read.

abstract class _$ChatController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
