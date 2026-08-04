import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// Converts a Firestore `Timestamp` to/from `DateTime` for freezed/
/// json_serializable models — Firestore's own SDK type isn't JSON-native.
class TimestampConverter implements JsonConverter<DateTime, Object?> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object? json) {
    if (json is Timestamp) return json.toDate();
    if (json is DateTime) return json;
    throw ArgumentError('Expected a Firestore Timestamp, got $json');
  }

  @override
  Object toJson(DateTime object) => Timestamp.fromDate(object);
}

/// Same as [TimestampConverter], but for fields written via
/// `FieldValue.serverTimestamp()` that can briefly read back as null from
/// local cache before the server round-trip resolves.
class NullableTimestampConverter implements JsonConverter<DateTime?, Object?> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is DateTime) return json;
    throw ArgumentError('Expected a Firestore Timestamp, got $json');
  }

  @override
  Object? toJson(DateTime? object) =>
      object == null ? null : Timestamp.fromDate(object);
}
