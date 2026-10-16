import 'package:cloud_functions/cloud_functions.dart';

/// What the public website forms tell the visitor when a submission fails.
/// A visitor who has sent several requests in the last hour hits the
/// per-visitor limit on the Cloud Function (`resource-exhausted`); everything
/// else gets the generic retry message.
String requestErrorMessage(Object? error) {
  if (error is FirebaseFunctionsException &&
      error.code == 'resource-exhausted') {
    return 'Too many requests from this device. Please try again in a little while.';
  }
  return "Couldn't send your request. Please try again.";
}
