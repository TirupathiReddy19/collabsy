import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/instagram_account.dart';

/// Thrown for the specific, user-actionable failure modes the UI needs to
/// tell apart (as opposed to a generic "something went wrong").
class InstagramApiException implements Exception {
  const InstagramApiException(this.kind, this.message);

  final InstagramApiErrorKind kind;
  final String message;

  @override
  String toString() => 'InstagramApiException($kind: $message)';
}

enum InstagramApiErrorKind {
  tokenExpired,
  permissionsRevoked,
  network,
  refreshFailed,
  unknown,
}

/// Talks to Firestore (read-only — the account/media documents are
/// server-written, see `firestore.rules`) and to the Cloud Functions that
/// own the actual Instagram token exchange/refresh/fetch logic. Nothing in
/// this class or its callers ever sees an App Secret or a raw access token;
/// those stay in `instagram_accounts/{userId}/private/tokens`, which only
/// the Admin SDK can read.
class InstagramRepository {
  InstagramRepository(this._firestore, this._functions);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  DocumentReference<Map<String, dynamic>> _accountDoc(String userId) =>
      _firestore.collection('instagram_accounts').doc(userId);

  Stream<InstagramAccount?> watchAccount(String userId) {
    return _accountDoc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return InstagramAccount.fromJson({...doc.data()!, 'id': doc.id});
    });
  }

  /// Every connected Instagram account, unfiltered — for the Admin
  /// Creators list, which shows the handle next to (or instead of) a
  /// possibly-missing display name.
  Stream<List<InstagramAccount>> watchAllAccounts() {
    return _firestore
        .collection('instagram_accounts')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    InstagramAccount.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  /// Sends the OAuth [code] to the `exchangeInstagramCode` Cloud Function,
  /// which does the actual token exchange (short-lived -> long-lived) and
  /// the initial profile/media sync server-side.
  Future<void> connect(String code) async {
    try {
      await _functions.httpsCallable('exchangeInstagramCode').call({
        'code': code,
      });
    } on FirebaseFunctionsException catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> disconnect() async {
    try {
      await _functions.httpsCallable('disconnectInstagram').call();
    } on FirebaseFunctionsException catch (e) {
      throw _mapException(e);
    }
  }

  /// Re-fetches profile stats (name, bio, follower/media counts) for the
  /// already-connected account (e.g. a manual "Refresh" tap), refreshing
  /// the stored token first if needed. The same sync also runs on its own
  /// every 2 hours server-side, so this is just for "I want it now."
  Future<void> refresh() async {
    try {
      await _functions.httpsCallable('refreshInstagramProfile').call();
    } on FirebaseFunctionsException catch (e) {
      throw _mapException(e);
    }
  }

  InstagramApiException _mapException(FirebaseFunctionsException e) {
    // Meta's Graph API reports an expired token and a revoked one with the
    // same generic OAuthException shape — there's no reliable signal to
    // tell them apart without guessing at undocumented error subcodes, so
    // both surface identically here as "needs reconnect".
    switch (e.code) {
      case 'failed-precondition':
        final reason = e.details is Map ? e.details['reason'] : null;
        if (reason == 'refresh-failed') {
          return InstagramApiException(
            InstagramApiErrorKind.refreshFailed,
            "Couldn't refresh your Instagram connection. Please reconnect.",
          );
        }
        return InstagramApiException(
          InstagramApiErrorKind.tokenExpired,
          'Your Instagram connection has expired. Please reconnect.',
        );
      case 'unavailable':
      case 'deadline-exceeded':
        return const InstagramApiException(
          InstagramApiErrorKind.network,
          'Network error. Please try again.',
        );
      default:
        return InstagramApiException(
          InstagramApiErrorKind.unknown,
          e.message ?? 'Something went wrong. Please try again.',
        );
    }
  }
}
