// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'instagram_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InstagramAccount {

 String get id; InstagramConnectionStatus get status; String? get instagramUserId; String? get username; String? get name; String? get profilePictureUrl; String? get biography; String? get website; int get followersCount; int get followsCount; int get mediaCount;@NullableTimestampConverter() DateTime? get connectedAt;@NullableTimestampConverter() DateTime? get lastSyncedAt;
/// Create a copy of InstagramAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InstagramAccountCopyWith<InstagramAccount> get copyWith => _$InstagramAccountCopyWithImpl<InstagramAccount>(this as InstagramAccount, _$identity);

  /// Serializes this InstagramAccount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InstagramAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.instagramUserId, instagramUserId) || other.instagramUserId == instagramUserId)&&(identical(other.username, username) || other.username == username)&&(identical(other.name, name) || other.name == name)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl)&&(identical(other.biography, biography) || other.biography == biography)&&(identical(other.website, website) || other.website == website)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followsCount, followsCount) || other.followsCount == followsCount)&&(identical(other.mediaCount, mediaCount) || other.mediaCount == mediaCount)&&(identical(other.connectedAt, connectedAt) || other.connectedAt == connectedAt)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,instagramUserId,username,name,profilePictureUrl,biography,website,followersCount,followsCount,mediaCount,connectedAt,lastSyncedAt);

@override
String toString() {
  return 'InstagramAccount(id: $id, status: $status, instagramUserId: $instagramUserId, username: $username, name: $name, profilePictureUrl: $profilePictureUrl, biography: $biography, website: $website, followersCount: $followersCount, followsCount: $followsCount, mediaCount: $mediaCount, connectedAt: $connectedAt, lastSyncedAt: $lastSyncedAt)';
}


}

/// @nodoc
abstract mixin class $InstagramAccountCopyWith<$Res>  {
  factory $InstagramAccountCopyWith(InstagramAccount value, $Res Function(InstagramAccount) _then) = _$InstagramAccountCopyWithImpl;
@useResult
$Res call({
 String id, InstagramConnectionStatus status, String? instagramUserId, String? username, String? name, String? profilePictureUrl, String? biography, String? website, int followersCount, int followsCount, int mediaCount,@NullableTimestampConverter() DateTime? connectedAt,@NullableTimestampConverter() DateTime? lastSyncedAt
});




}
/// @nodoc
class _$InstagramAccountCopyWithImpl<$Res>
    implements $InstagramAccountCopyWith<$Res> {
  _$InstagramAccountCopyWithImpl(this._self, this._then);

  final InstagramAccount _self;
  final $Res Function(InstagramAccount) _then;

/// Create a copy of InstagramAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? instagramUserId = freezed,Object? username = freezed,Object? name = freezed,Object? profilePictureUrl = freezed,Object? biography = freezed,Object? website = freezed,Object? followersCount = null,Object? followsCount = null,Object? mediaCount = null,Object? connectedAt = freezed,Object? lastSyncedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InstagramConnectionStatus,instagramUserId: freezed == instagramUserId ? _self.instagramUserId : instagramUserId // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,profilePictureUrl: freezed == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String?,biography: freezed == biography ? _self.biography : biography // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followsCount: null == followsCount ? _self.followsCount : followsCount // ignore: cast_nullable_to_non_nullable
as int,mediaCount: null == mediaCount ? _self.mediaCount : mediaCount // ignore: cast_nullable_to_non_nullable
as int,connectedAt: freezed == connectedAt ? _self.connectedAt : connectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [InstagramAccount].
extension InstagramAccountPatterns on InstagramAccount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InstagramAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InstagramAccount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InstagramAccount value)  $default,){
final _that = this;
switch (_that) {
case _InstagramAccount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InstagramAccount value)?  $default,){
final _that = this;
switch (_that) {
case _InstagramAccount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  InstagramConnectionStatus status,  String? instagramUserId,  String? username,  String? name,  String? profilePictureUrl,  String? biography,  String? website,  int followersCount,  int followsCount,  int mediaCount, @NullableTimestampConverter()  DateTime? connectedAt, @NullableTimestampConverter()  DateTime? lastSyncedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InstagramAccount() when $default != null:
return $default(_that.id,_that.status,_that.instagramUserId,_that.username,_that.name,_that.profilePictureUrl,_that.biography,_that.website,_that.followersCount,_that.followsCount,_that.mediaCount,_that.connectedAt,_that.lastSyncedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  InstagramConnectionStatus status,  String? instagramUserId,  String? username,  String? name,  String? profilePictureUrl,  String? biography,  String? website,  int followersCount,  int followsCount,  int mediaCount, @NullableTimestampConverter()  DateTime? connectedAt, @NullableTimestampConverter()  DateTime? lastSyncedAt)  $default,) {final _that = this;
switch (_that) {
case _InstagramAccount():
return $default(_that.id,_that.status,_that.instagramUserId,_that.username,_that.name,_that.profilePictureUrl,_that.biography,_that.website,_that.followersCount,_that.followsCount,_that.mediaCount,_that.connectedAt,_that.lastSyncedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  InstagramConnectionStatus status,  String? instagramUserId,  String? username,  String? name,  String? profilePictureUrl,  String? biography,  String? website,  int followersCount,  int followsCount,  int mediaCount, @NullableTimestampConverter()  DateTime? connectedAt, @NullableTimestampConverter()  DateTime? lastSyncedAt)?  $default,) {final _that = this;
switch (_that) {
case _InstagramAccount() when $default != null:
return $default(_that.id,_that.status,_that.instagramUserId,_that.username,_that.name,_that.profilePictureUrl,_that.biography,_that.website,_that.followersCount,_that.followsCount,_that.mediaCount,_that.connectedAt,_that.lastSyncedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InstagramAccount implements InstagramAccount {
  const _InstagramAccount({required this.id, this.status = InstagramConnectionStatus.disconnected, this.instagramUserId, this.username, this.name, this.profilePictureUrl, this.biography, this.website, this.followersCount = 0, this.followsCount = 0, this.mediaCount = 0, @NullableTimestampConverter() this.connectedAt, @NullableTimestampConverter() this.lastSyncedAt});
  factory _InstagramAccount.fromJson(Map<String, dynamic> json) => _$InstagramAccountFromJson(json);

@override final  String id;
@override@JsonKey() final  InstagramConnectionStatus status;
@override final  String? instagramUserId;
@override final  String? username;
@override final  String? name;
@override final  String? profilePictureUrl;
@override final  String? biography;
@override final  String? website;
@override@JsonKey() final  int followersCount;
@override@JsonKey() final  int followsCount;
@override@JsonKey() final  int mediaCount;
@override@NullableTimestampConverter() final  DateTime? connectedAt;
@override@NullableTimestampConverter() final  DateTime? lastSyncedAt;

/// Create a copy of InstagramAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InstagramAccountCopyWith<_InstagramAccount> get copyWith => __$InstagramAccountCopyWithImpl<_InstagramAccount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InstagramAccountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InstagramAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.instagramUserId, instagramUserId) || other.instagramUserId == instagramUserId)&&(identical(other.username, username) || other.username == username)&&(identical(other.name, name) || other.name == name)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl)&&(identical(other.biography, biography) || other.biography == biography)&&(identical(other.website, website) || other.website == website)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followsCount, followsCount) || other.followsCount == followsCount)&&(identical(other.mediaCount, mediaCount) || other.mediaCount == mediaCount)&&(identical(other.connectedAt, connectedAt) || other.connectedAt == connectedAt)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,instagramUserId,username,name,profilePictureUrl,biography,website,followersCount,followsCount,mediaCount,connectedAt,lastSyncedAt);

@override
String toString() {
  return 'InstagramAccount(id: $id, status: $status, instagramUserId: $instagramUserId, username: $username, name: $name, profilePictureUrl: $profilePictureUrl, biography: $biography, website: $website, followersCount: $followersCount, followsCount: $followsCount, mediaCount: $mediaCount, connectedAt: $connectedAt, lastSyncedAt: $lastSyncedAt)';
}


}

/// @nodoc
abstract mixin class _$InstagramAccountCopyWith<$Res> implements $InstagramAccountCopyWith<$Res> {
  factory _$InstagramAccountCopyWith(_InstagramAccount value, $Res Function(_InstagramAccount) _then) = __$InstagramAccountCopyWithImpl;
@override @useResult
$Res call({
 String id, InstagramConnectionStatus status, String? instagramUserId, String? username, String? name, String? profilePictureUrl, String? biography, String? website, int followersCount, int followsCount, int mediaCount,@NullableTimestampConverter() DateTime? connectedAt,@NullableTimestampConverter() DateTime? lastSyncedAt
});




}
/// @nodoc
class __$InstagramAccountCopyWithImpl<$Res>
    implements _$InstagramAccountCopyWith<$Res> {
  __$InstagramAccountCopyWithImpl(this._self, this._then);

  final _InstagramAccount _self;
  final $Res Function(_InstagramAccount) _then;

/// Create a copy of InstagramAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? instagramUserId = freezed,Object? username = freezed,Object? name = freezed,Object? profilePictureUrl = freezed,Object? biography = freezed,Object? website = freezed,Object? followersCount = null,Object? followsCount = null,Object? mediaCount = null,Object? connectedAt = freezed,Object? lastSyncedAt = freezed,}) {
  return _then(_InstagramAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InstagramConnectionStatus,instagramUserId: freezed == instagramUserId ? _self.instagramUserId : instagramUserId // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,profilePictureUrl: freezed == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String?,biography: freezed == biography ? _self.biography : biography // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followsCount: null == followsCount ? _self.followsCount : followsCount // ignore: cast_nullable_to_non_nullable
as int,mediaCount: null == mediaCount ? _self.mediaCount : mediaCount // ignore: cast_nullable_to_non_nullable
as int,connectedAt: freezed == connectedAt ? _self.connectedAt : connectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
