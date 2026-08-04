// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'creator_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreatorProfile {

 String get id; String? get displayName; String? get bio; List<String> get categories; List<String> get languages; String get country; String? get state; String? get city; VerificationStatus get verificationStatus;
/// Create a copy of CreatorProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatorProfileCopyWith<CreatorProfile> get copyWith => _$CreatorProfileCopyWithImpl<CreatorProfile>(this as CreatorProfile, _$identity);

  /// Serializes this CreatorProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatorProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.languages, languages)&&(identical(other.country, country) || other.country == country)&&(identical(other.state, state) || other.state == state)&&(identical(other.city, city) || other.city == city)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,bio,const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(languages),country,state,city,verificationStatus);

@override
String toString() {
  return 'CreatorProfile(id: $id, displayName: $displayName, bio: $bio, categories: $categories, languages: $languages, country: $country, state: $state, city: $city, verificationStatus: $verificationStatus)';
}


}

/// @nodoc
abstract mixin class $CreatorProfileCopyWith<$Res>  {
  factory $CreatorProfileCopyWith(CreatorProfile value, $Res Function(CreatorProfile) _then) = _$CreatorProfileCopyWithImpl;
@useResult
$Res call({
 String id, String? displayName, String? bio, List<String> categories, List<String> languages, String country, String? state, String? city, VerificationStatus verificationStatus
});




}
/// @nodoc
class _$CreatorProfileCopyWithImpl<$Res>
    implements $CreatorProfileCopyWith<$Res> {
  _$CreatorProfileCopyWithImpl(this._self, this._then);

  final CreatorProfile _self;
  final $Res Function(CreatorProfile) _then;

/// Create a copy of CreatorProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = freezed,Object? bio = freezed,Object? categories = null,Object? languages = null,Object? country = null,Object? state = freezed,Object? city = freezed,Object? verificationStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,languages: null == languages ? _self.languages : languages // ignore: cast_nullable_to_non_nullable
as List<String>,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VerificationStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [CreatorProfile].
extension CreatorProfilePatterns on CreatorProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatorProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatorProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatorProfile value)  $default,){
final _that = this;
switch (_that) {
case _CreatorProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatorProfile value)?  $default,){
final _that = this;
switch (_that) {
case _CreatorProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? displayName,  String? bio,  List<String> categories,  List<String> languages,  String country,  String? state,  String? city,  VerificationStatus verificationStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatorProfile() when $default != null:
return $default(_that.id,_that.displayName,_that.bio,_that.categories,_that.languages,_that.country,_that.state,_that.city,_that.verificationStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? displayName,  String? bio,  List<String> categories,  List<String> languages,  String country,  String? state,  String? city,  VerificationStatus verificationStatus)  $default,) {final _that = this;
switch (_that) {
case _CreatorProfile():
return $default(_that.id,_that.displayName,_that.bio,_that.categories,_that.languages,_that.country,_that.state,_that.city,_that.verificationStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? displayName,  String? bio,  List<String> categories,  List<String> languages,  String country,  String? state,  String? city,  VerificationStatus verificationStatus)?  $default,) {final _that = this;
switch (_that) {
case _CreatorProfile() when $default != null:
return $default(_that.id,_that.displayName,_that.bio,_that.categories,_that.languages,_that.country,_that.state,_that.city,_that.verificationStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreatorProfile implements CreatorProfile {
  const _CreatorProfile({required this.id, this.displayName, this.bio, final  List<String> categories = const [], final  List<String> languages = const [], this.country = 'India', this.state, this.city, this.verificationStatus = VerificationStatus.pending}): _categories = categories,_languages = languages;
  factory _CreatorProfile.fromJson(Map<String, dynamic> json) => _$CreatorProfileFromJson(json);

@override final  String id;
@override final  String? displayName;
@override final  String? bio;
 final  List<String> _categories;
@override@JsonKey() List<String> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  List<String> _languages;
@override@JsonKey() List<String> get languages {
  if (_languages is EqualUnmodifiableListView) return _languages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_languages);
}

@override@JsonKey() final  String country;
@override final  String? state;
@override final  String? city;
@override@JsonKey() final  VerificationStatus verificationStatus;

/// Create a copy of CreatorProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatorProfileCopyWith<_CreatorProfile> get copyWith => __$CreatorProfileCopyWithImpl<_CreatorProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreatorProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatorProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._languages, _languages)&&(identical(other.country, country) || other.country == country)&&(identical(other.state, state) || other.state == state)&&(identical(other.city, city) || other.city == city)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,bio,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_languages),country,state,city,verificationStatus);

@override
String toString() {
  return 'CreatorProfile(id: $id, displayName: $displayName, bio: $bio, categories: $categories, languages: $languages, country: $country, state: $state, city: $city, verificationStatus: $verificationStatus)';
}


}

/// @nodoc
abstract mixin class _$CreatorProfileCopyWith<$Res> implements $CreatorProfileCopyWith<$Res> {
  factory _$CreatorProfileCopyWith(_CreatorProfile value, $Res Function(_CreatorProfile) _then) = __$CreatorProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String? displayName, String? bio, List<String> categories, List<String> languages, String country, String? state, String? city, VerificationStatus verificationStatus
});




}
/// @nodoc
class __$CreatorProfileCopyWithImpl<$Res>
    implements _$CreatorProfileCopyWith<$Res> {
  __$CreatorProfileCopyWithImpl(this._self, this._then);

  final _CreatorProfile _self;
  final $Res Function(_CreatorProfile) _then;

/// Create a copy of CreatorProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = freezed,Object? bio = freezed,Object? categories = null,Object? languages = null,Object? country = null,Object? state = freezed,Object? city = freezed,Object? verificationStatus = null,}) {
  return _then(_CreatorProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,languages: null == languages ? _self._languages : languages // ignore: cast_nullable_to_non_nullable
as List<String>,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VerificationStatus,
  ));
}


}

// dart format on
