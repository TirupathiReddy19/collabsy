// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserReport {

 String get id; String get reporterId; UserRole get reporterRole; String get reportedId; UserRole get reportedRole; String? get reportedName; ReportReason get reason; String? get details; String? get chatId; String get status;@NullableTimestampConverter() DateTime? get createdAt;
/// Create a copy of UserReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserReportCopyWith<UserReport> get copyWith => _$UserReportCopyWithImpl<UserReport>(this as UserReport, _$identity);

  /// Serializes this UserReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserReport&&(identical(other.id, id) || other.id == id)&&(identical(other.reporterId, reporterId) || other.reporterId == reporterId)&&(identical(other.reporterRole, reporterRole) || other.reporterRole == reporterRole)&&(identical(other.reportedId, reportedId) || other.reportedId == reportedId)&&(identical(other.reportedRole, reportedRole) || other.reportedRole == reportedRole)&&(identical(other.reportedName, reportedName) || other.reportedName == reportedName)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.details, details) || other.details == details)&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reporterId,reporterRole,reportedId,reportedRole,reportedName,reason,details,chatId,status,createdAt);

@override
String toString() {
  return 'UserReport(id: $id, reporterId: $reporterId, reporterRole: $reporterRole, reportedId: $reportedId, reportedRole: $reportedRole, reportedName: $reportedName, reason: $reason, details: $details, chatId: $chatId, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $UserReportCopyWith<$Res>  {
  factory $UserReportCopyWith(UserReport value, $Res Function(UserReport) _then) = _$UserReportCopyWithImpl;
@useResult
$Res call({
 String id, String reporterId, UserRole reporterRole, String reportedId, UserRole reportedRole, String? reportedName, ReportReason reason, String? details, String? chatId, String status,@NullableTimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class _$UserReportCopyWithImpl<$Res>
    implements $UserReportCopyWith<$Res> {
  _$UserReportCopyWithImpl(this._self, this._then);

  final UserReport _self;
  final $Res Function(UserReport) _then;

/// Create a copy of UserReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reporterId = null,Object? reporterRole = null,Object? reportedId = null,Object? reportedRole = null,Object? reportedName = freezed,Object? reason = null,Object? details = freezed,Object? chatId = freezed,Object? status = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reporterId: null == reporterId ? _self.reporterId : reporterId // ignore: cast_nullable_to_non_nullable
as String,reporterRole: null == reporterRole ? _self.reporterRole : reporterRole // ignore: cast_nullable_to_non_nullable
as UserRole,reportedId: null == reportedId ? _self.reportedId : reportedId // ignore: cast_nullable_to_non_nullable
as String,reportedRole: null == reportedRole ? _self.reportedRole : reportedRole // ignore: cast_nullable_to_non_nullable
as UserRole,reportedName: freezed == reportedName ? _self.reportedName : reportedName // ignore: cast_nullable_to_non_nullable
as String?,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ReportReason,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String?,chatId: freezed == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserReport].
extension UserReportPatterns on UserReport {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserReport() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserReport value)  $default,){
final _that = this;
switch (_that) {
case _UserReport():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserReport value)?  $default,){
final _that = this;
switch (_that) {
case _UserReport() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String reporterId,  UserRole reporterRole,  String reportedId,  UserRole reportedRole,  String? reportedName,  ReportReason reason,  String? details,  String? chatId,  String status, @NullableTimestampConverter()  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserReport() when $default != null:
return $default(_that.id,_that.reporterId,_that.reporterRole,_that.reportedId,_that.reportedRole,_that.reportedName,_that.reason,_that.details,_that.chatId,_that.status,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String reporterId,  UserRole reporterRole,  String reportedId,  UserRole reportedRole,  String? reportedName,  ReportReason reason,  String? details,  String? chatId,  String status, @NullableTimestampConverter()  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _UserReport():
return $default(_that.id,_that.reporterId,_that.reporterRole,_that.reportedId,_that.reportedRole,_that.reportedName,_that.reason,_that.details,_that.chatId,_that.status,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String reporterId,  UserRole reporterRole,  String reportedId,  UserRole reportedRole,  String? reportedName,  ReportReason reason,  String? details,  String? chatId,  String status, @NullableTimestampConverter()  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _UserReport() when $default != null:
return $default(_that.id,_that.reporterId,_that.reporterRole,_that.reportedId,_that.reportedRole,_that.reportedName,_that.reason,_that.details,_that.chatId,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserReport implements UserReport {
  const _UserReport({required this.id, required this.reporterId, required this.reporterRole, required this.reportedId, required this.reportedRole, this.reportedName, required this.reason, this.details, this.chatId, this.status = 'open', @NullableTimestampConverter() this.createdAt});
  factory _UserReport.fromJson(Map<String, dynamic> json) => _$UserReportFromJson(json);

@override final  String id;
@override final  String reporterId;
@override final  UserRole reporterRole;
@override final  String reportedId;
@override final  UserRole reportedRole;
@override final  String? reportedName;
@override final  ReportReason reason;
@override final  String? details;
@override final  String? chatId;
@override@JsonKey() final  String status;
@override@NullableTimestampConverter() final  DateTime? createdAt;

/// Create a copy of UserReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserReportCopyWith<_UserReport> get copyWith => __$UserReportCopyWithImpl<_UserReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserReport&&(identical(other.id, id) || other.id == id)&&(identical(other.reporterId, reporterId) || other.reporterId == reporterId)&&(identical(other.reporterRole, reporterRole) || other.reporterRole == reporterRole)&&(identical(other.reportedId, reportedId) || other.reportedId == reportedId)&&(identical(other.reportedRole, reportedRole) || other.reportedRole == reportedRole)&&(identical(other.reportedName, reportedName) || other.reportedName == reportedName)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.details, details) || other.details == details)&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reporterId,reporterRole,reportedId,reportedRole,reportedName,reason,details,chatId,status,createdAt);

@override
String toString() {
  return 'UserReport(id: $id, reporterId: $reporterId, reporterRole: $reporterRole, reportedId: $reportedId, reportedRole: $reportedRole, reportedName: $reportedName, reason: $reason, details: $details, chatId: $chatId, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$UserReportCopyWith<$Res> implements $UserReportCopyWith<$Res> {
  factory _$UserReportCopyWith(_UserReport value, $Res Function(_UserReport) _then) = __$UserReportCopyWithImpl;
@override @useResult
$Res call({
 String id, String reporterId, UserRole reporterRole, String reportedId, UserRole reportedRole, String? reportedName, ReportReason reason, String? details, String? chatId, String status,@NullableTimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class __$UserReportCopyWithImpl<$Res>
    implements _$UserReportCopyWith<$Res> {
  __$UserReportCopyWithImpl(this._self, this._then);

  final _UserReport _self;
  final $Res Function(_UserReport) _then;

/// Create a copy of UserReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reporterId = null,Object? reporterRole = null,Object? reportedId = null,Object? reportedRole = null,Object? reportedName = freezed,Object? reason = null,Object? details = freezed,Object? chatId = freezed,Object? status = null,Object? createdAt = freezed,}) {
  return _then(_UserReport(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reporterId: null == reporterId ? _self.reporterId : reporterId // ignore: cast_nullable_to_non_nullable
as String,reporterRole: null == reporterRole ? _self.reporterRole : reporterRole // ignore: cast_nullable_to_non_nullable
as UserRole,reportedId: null == reportedId ? _self.reportedId : reportedId // ignore: cast_nullable_to_non_nullable
as String,reportedRole: null == reportedRole ? _self.reportedRole : reportedRole // ignore: cast_nullable_to_non_nullable
as UserRole,reportedName: freezed == reportedName ? _self.reportedName : reportedName // ignore: cast_nullable_to_non_nullable
as String?,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ReportReason,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String?,chatId: freezed == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
