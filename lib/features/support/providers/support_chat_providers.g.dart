// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(supportChatRepository)
final supportChatRepositoryProvider = SupportChatRepositoryProvider._();

final class SupportChatRepositoryProvider
    extends
        $FunctionalProvider<
          SupportChatRepository,
          SupportChatRepository,
          SupportChatRepository
        >
    with $Provider<SupportChatRepository> {
  SupportChatRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supportChatRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supportChatRepositoryHash();

  @$internal
  @override
  $ProviderElement<SupportChatRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SupportChatRepository create(Ref ref) {
    return supportChatRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupportChatRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupportChatRepository>(value),
    );
  }
}

String _$supportChatRepositoryHash() =>
    r'958af0c9e0cf0ef649d02f01f930fd4fdd5d657d';

/// A specific ticket, by id — shared by the mobile chat screen (its own
/// ticket) and the Admin's Support Ticket detail screen (any ticket).

@ProviderFor(supportTicket)
final supportTicketProvider = SupportTicketFamily._();

/// A specific ticket, by id — shared by the mobile chat screen (its own
/// ticket) and the Admin's Support Ticket detail screen (any ticket).

final class SupportTicketProvider
    extends
        $FunctionalProvider<
          AsyncValue<SupportChat?>,
          SupportChat?,
          Stream<SupportChat?>
        >
    with $FutureModifier<SupportChat?>, $StreamProvider<SupportChat?> {
  /// A specific ticket, by id — shared by the mobile chat screen (its own
  /// ticket) and the Admin's Support Ticket detail screen (any ticket).
  SupportTicketProvider._({
    required SupportTicketFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'supportTicketProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$supportTicketHash();

  @override
  String toString() {
    return r'supportTicketProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<SupportChat?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SupportChat?> create(Ref ref) {
    final argument = this.argument as String;
    return supportTicket(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SupportTicketProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$supportTicketHash() => r'542f698b517e7e4dddae7905089f96b673090db2';

/// A specific ticket, by id — shared by the mobile chat screen (its own
/// ticket) and the Admin's Support Ticket detail screen (any ticket).

final class SupportTicketFamily extends $Family
    with $FunctionalFamilyOverride<Stream<SupportChat?>, String> {
  SupportTicketFamily._()
    : super(
        retry: null,
        name: r'supportTicketProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A specific ticket, by id — shared by the mobile chat screen (its own
  /// ticket) and the Admin's Support Ticket detail screen (any ticket).

  SupportTicketProvider call(String ticketId) =>
      SupportTicketProvider._(argument: ticketId, from: this);

  @override
  String toString() => r'supportTicketProvider';
}

@ProviderFor(supportTicketMessages)
final supportTicketMessagesProvider = SupportTicketMessagesFamily._();

final class SupportTicketMessagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SupportMessage>>,
          List<SupportMessage>,
          Stream<List<SupportMessage>>
        >
    with
        $FutureModifier<List<SupportMessage>>,
        $StreamProvider<List<SupportMessage>> {
  SupportTicketMessagesProvider._({
    required SupportTicketMessagesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'supportTicketMessagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$supportTicketMessagesHash();

  @override
  String toString() {
    return r'supportTicketMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<SupportMessage>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SupportMessage>> create(Ref ref) {
    final argument = this.argument as String;
    return supportTicketMessages(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SupportTicketMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$supportTicketMessagesHash() =>
    r'126e2db0eb38415a4386af02617664d3240983a7';

final class SupportTicketMessagesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<SupportMessage>>, String> {
  SupportTicketMessagesFamily._()
    : super(
        retry: null,
        name: r'supportTicketMessagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SupportTicketMessagesProvider call(String ticketId) =>
      SupportTicketMessagesProvider._(argument: ticketId, from: this);

  @override
  String toString() => r'supportTicketMessagesProvider';
}

/// Every ticket belonging to the signed-in user, newest first — the
/// mobile-side ticket history screen.

@ProviderFor(userTickets)
final userTicketsProvider = UserTicketsFamily._();

/// Every ticket belonging to the signed-in user, newest first — the
/// mobile-side ticket history screen.

final class UserTicketsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SupportChat>>,
          List<SupportChat>,
          Stream<List<SupportChat>>
        >
    with
        $FutureModifier<List<SupportChat>>,
        $StreamProvider<List<SupportChat>> {
  /// Every ticket belonging to the signed-in user, newest first — the
  /// mobile-side ticket history screen.
  UserTicketsProvider._({
    required UserTicketsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userTicketsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userTicketsHash();

  @override
  String toString() {
    return r'userTicketsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<SupportChat>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SupportChat>> create(Ref ref) {
    final argument = this.argument as String;
    return userTickets(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserTicketsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userTicketsHash() => r'ecba517e0103336693fc2a7428190a3936930fdb';

/// Every ticket belonging to the signed-in user, newest first — the
/// mobile-side ticket history screen.

final class UserTicketsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<SupportChat>>, String> {
  UserTicketsFamily._()
    : super(
        retry: null,
        name: r'userTicketsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Every ticket belonging to the signed-in user, newest first — the
  /// mobile-side ticket history screen.

  UserTicketsProvider call(String userId) =>
      UserTicketsProvider._(argument: userId, from: this);

  @override
  String toString() => r'userTicketsProvider';
}

/// Every ticket across every user — for the Admin's Support Tickets list.

@ProviderFor(allSupportChats)
final allSupportChatsProvider = AllSupportChatsProvider._();

/// Every ticket across every user — for the Admin's Support Tickets list.

final class AllSupportChatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SupportChat>>,
          List<SupportChat>,
          Stream<List<SupportChat>>
        >
    with
        $FutureModifier<List<SupportChat>>,
        $StreamProvider<List<SupportChat>> {
  /// Every ticket across every user — for the Admin's Support Tickets list.
  AllSupportChatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allSupportChatsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allSupportChatsHash();

  @$internal
  @override
  $StreamProviderElement<List<SupportChat>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SupportChat>> create(Ref ref) {
    return allSupportChats(ref);
  }
}

String _$allSupportChatsHash() => r'c0facf7ddde08a3e9ca28aba52e85e6075fa934a';

/// Drives the user-facing Help/chat screens: resolving which ticket to open
/// and sending messages as themselves.

@ProviderFor(SupportChatController)
final supportChatControllerProvider = SupportChatControllerProvider._();

/// Drives the user-facing Help/chat screens: resolving which ticket to open
/// and sending messages as themselves.
final class SupportChatControllerProvider
    extends $AsyncNotifierProvider<SupportChatController, void> {
  /// Drives the user-facing Help/chat screens: resolving which ticket to open
  /// and sending messages as themselves.
  SupportChatControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supportChatControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supportChatControllerHash();

  @$internal
  @override
  SupportChatController create() => SupportChatController();
}

String _$supportChatControllerHash() =>
    r'0a172336038dc1f570a63bb797234eca74732447';

/// Drives the user-facing Help/chat screens: resolving which ticket to open
/// and sending messages as themselves.

abstract class _$SupportChatController extends $AsyncNotifier<void> {
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
