// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppUserProfile {

 String get id; UserRole? get role; String? get displayName; String? get email; String? get phone; String? get avatarUrl; String? get bio; bool get onboardingCompleted; bool get pushNotificationsEnabled; String? get fcmToken;
/// Create a copy of AppUserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUserProfileCopyWith<AppUserProfile> get copyWith => _$AppUserProfileCopyWithImpl<AppUserProfile>(this as AppUserProfile, _$identity);

  /// Serializes this AppUserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.role, role) || other.role == role)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.onboardingCompleted, onboardingCompleted) || other.onboardingCompleted == onboardingCompleted)&&(identical(other.pushNotificationsEnabled, pushNotificationsEnabled) || other.pushNotificationsEnabled == pushNotificationsEnabled)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,role,displayName,email,phone,avatarUrl,bio,onboardingCompleted,pushNotificationsEnabled,fcmToken);

@override
String toString() {
  return 'AppUserProfile(id: $id, role: $role, displayName: $displayName, email: $email, phone: $phone, avatarUrl: $avatarUrl, bio: $bio, onboardingCompleted: $onboardingCompleted, pushNotificationsEnabled: $pushNotificationsEnabled, fcmToken: $fcmToken)';
}


}

/// @nodoc
abstract mixin class $AppUserProfileCopyWith<$Res>  {
  factory $AppUserProfileCopyWith(AppUserProfile value, $Res Function(AppUserProfile) _then) = _$AppUserProfileCopyWithImpl;
@useResult
$Res call({
 String id, UserRole? role, String? displayName, String? email, String? phone, String? avatarUrl, String? bio, bool onboardingCompleted, bool pushNotificationsEnabled, String? fcmToken
});




}
/// @nodoc
class _$AppUserProfileCopyWithImpl<$Res>
    implements $AppUserProfileCopyWith<$Res> {
  _$AppUserProfileCopyWithImpl(this._self, this._then);

  final AppUserProfile _self;
  final $Res Function(AppUserProfile) _then;

/// Create a copy of AppUserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? role = freezed,Object? displayName = freezed,Object? email = freezed,Object? phone = freezed,Object? avatarUrl = freezed,Object? bio = freezed,Object? onboardingCompleted = null,Object? pushNotificationsEnabled = null,Object? fcmToken = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,onboardingCompleted: null == onboardingCompleted ? _self.onboardingCompleted : onboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool,pushNotificationsEnabled: null == pushNotificationsEnabled ? _self.pushNotificationsEnabled : pushNotificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUserProfile].
extension AppUserProfilePatterns on AppUserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUserProfile value)  $default,){
final _that = this;
switch (_that) {
case _AppUserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _AppUserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  UserRole? role,  String? displayName,  String? email,  String? phone,  String? avatarUrl,  String? bio,  bool onboardingCompleted,  bool pushNotificationsEnabled,  String? fcmToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUserProfile() when $default != null:
return $default(_that.id,_that.role,_that.displayName,_that.email,_that.phone,_that.avatarUrl,_that.bio,_that.onboardingCompleted,_that.pushNotificationsEnabled,_that.fcmToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  UserRole? role,  String? displayName,  String? email,  String? phone,  String? avatarUrl,  String? bio,  bool onboardingCompleted,  bool pushNotificationsEnabled,  String? fcmToken)  $default,) {final _that = this;
switch (_that) {
case _AppUserProfile():
return $default(_that.id,_that.role,_that.displayName,_that.email,_that.phone,_that.avatarUrl,_that.bio,_that.onboardingCompleted,_that.pushNotificationsEnabled,_that.fcmToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  UserRole? role,  String? displayName,  String? email,  String? phone,  String? avatarUrl,  String? bio,  bool onboardingCompleted,  bool pushNotificationsEnabled,  String? fcmToken)?  $default,) {final _that = this;
switch (_that) {
case _AppUserProfile() when $default != null:
return $default(_that.id,_that.role,_that.displayName,_that.email,_that.phone,_that.avatarUrl,_that.bio,_that.onboardingCompleted,_that.pushNotificationsEnabled,_that.fcmToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUserProfile implements AppUserProfile {
  const _AppUserProfile({required this.id, this.role, this.displayName, this.email, this.phone, this.avatarUrl, this.bio, this.onboardingCompleted = false, this.pushNotificationsEnabled = true, this.fcmToken});
  factory _AppUserProfile.fromJson(Map<String, dynamic> json) => _$AppUserProfileFromJson(json);

@override final  String id;
@override final  UserRole? role;
@override final  String? displayName;
@override final  String? email;
@override final  String? phone;
@override final  String? avatarUrl;
@override final  String? bio;
@override@JsonKey() final  bool onboardingCompleted;
@override@JsonKey() final  bool pushNotificationsEnabled;
@override final  String? fcmToken;

/// Create a copy of AppUserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUserProfileCopyWith<_AppUserProfile> get copyWith => __$AppUserProfileCopyWithImpl<_AppUserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.role, role) || other.role == role)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.onboardingCompleted, onboardingCompleted) || other.onboardingCompleted == onboardingCompleted)&&(identical(other.pushNotificationsEnabled, pushNotificationsEnabled) || other.pushNotificationsEnabled == pushNotificationsEnabled)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,role,displayName,email,phone,avatarUrl,bio,onboardingCompleted,pushNotificationsEnabled,fcmToken);

@override
String toString() {
  return 'AppUserProfile(id: $id, role: $role, displayName: $displayName, email: $email, phone: $phone, avatarUrl: $avatarUrl, bio: $bio, onboardingCompleted: $onboardingCompleted, pushNotificationsEnabled: $pushNotificationsEnabled, fcmToken: $fcmToken)';
}


}

/// @nodoc
abstract mixin class _$AppUserProfileCopyWith<$Res> implements $AppUserProfileCopyWith<$Res> {
  factory _$AppUserProfileCopyWith(_AppUserProfile value, $Res Function(_AppUserProfile) _then) = __$AppUserProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, UserRole? role, String? displayName, String? email, String? phone, String? avatarUrl, String? bio, bool onboardingCompleted, bool pushNotificationsEnabled, String? fcmToken
});




}
/// @nodoc
class __$AppUserProfileCopyWithImpl<$Res>
    implements _$AppUserProfileCopyWith<$Res> {
  __$AppUserProfileCopyWithImpl(this._self, this._then);

  final _AppUserProfile _self;
  final $Res Function(_AppUserProfile) _then;

/// Create a copy of AppUserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? role = freezed,Object? displayName = freezed,Object? email = freezed,Object? phone = freezed,Object? avatarUrl = freezed,Object? bio = freezed,Object? onboardingCompleted = null,Object? pushNotificationsEnabled = null,Object? fcmToken = freezed,}) {
  return _then(_AppUserProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,onboardingCompleted: null == onboardingCompleted ? _self.onboardingCompleted : onboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool,pushNotificationsEnabled: null == pushNotificationsEnabled ? _self.pushNotificationsEnabled : pushNotificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
