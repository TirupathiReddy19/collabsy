// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'brand_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BrandProfile {

 String get id; String? get companyName; String? get designation; String? get bio; List<String> get categories; String? get website; String? get companySize; String? get linkedinUrl; String get country; String? get state; String? get city; VerificationStatus get verificationStatus;
/// Create a copy of BrandProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BrandProfileCopyWith<BrandProfile> get copyWith => _$BrandProfileCopyWithImpl<BrandProfile>(this as BrandProfile, _$identity);

  /// Serializes this BrandProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BrandProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.designation, designation) || other.designation == designation)&&(identical(other.bio, bio) || other.bio == bio)&&const DeepCollectionEquality().equals(other.categories, categories)&&(identical(other.website, website) || other.website == website)&&(identical(other.companySize, companySize) || other.companySize == companySize)&&(identical(other.linkedinUrl, linkedinUrl) || other.linkedinUrl == linkedinUrl)&&(identical(other.country, country) || other.country == country)&&(identical(other.state, state) || other.state == state)&&(identical(other.city, city) || other.city == city)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyName,designation,bio,const DeepCollectionEquality().hash(categories),website,companySize,linkedinUrl,country,state,city,verificationStatus);

@override
String toString() {
  return 'BrandProfile(id: $id, companyName: $companyName, designation: $designation, bio: $bio, categories: $categories, website: $website, companySize: $companySize, linkedinUrl: $linkedinUrl, country: $country, state: $state, city: $city, verificationStatus: $verificationStatus)';
}


}

/// @nodoc
abstract mixin class $BrandProfileCopyWith<$Res>  {
  factory $BrandProfileCopyWith(BrandProfile value, $Res Function(BrandProfile) _then) = _$BrandProfileCopyWithImpl;
@useResult
$Res call({
 String id, String? companyName, String? designation, String? bio, List<String> categories, String? website, String? companySize, String? linkedinUrl, String country, String? state, String? city, VerificationStatus verificationStatus
});




}
/// @nodoc
class _$BrandProfileCopyWithImpl<$Res>
    implements $BrandProfileCopyWith<$Res> {
  _$BrandProfileCopyWithImpl(this._self, this._then);

  final BrandProfile _self;
  final $Res Function(BrandProfile) _then;

/// Create a copy of BrandProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyName = freezed,Object? designation = freezed,Object? bio = freezed,Object? categories = null,Object? website = freezed,Object? companySize = freezed,Object? linkedinUrl = freezed,Object? country = null,Object? state = freezed,Object? city = freezed,Object? verificationStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyName: freezed == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String?,designation: freezed == designation ? _self.designation : designation // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,companySize: freezed == companySize ? _self.companySize : companySize // ignore: cast_nullable_to_non_nullable
as String?,linkedinUrl: freezed == linkedinUrl ? _self.linkedinUrl : linkedinUrl // ignore: cast_nullable_to_non_nullable
as String?,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VerificationStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [BrandProfile].
extension BrandProfilePatterns on BrandProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BrandProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BrandProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BrandProfile value)  $default,){
final _that = this;
switch (_that) {
case _BrandProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BrandProfile value)?  $default,){
final _that = this;
switch (_that) {
case _BrandProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? companyName,  String? designation,  String? bio,  List<String> categories,  String? website,  String? companySize,  String? linkedinUrl,  String country,  String? state,  String? city,  VerificationStatus verificationStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BrandProfile() when $default != null:
return $default(_that.id,_that.companyName,_that.designation,_that.bio,_that.categories,_that.website,_that.companySize,_that.linkedinUrl,_that.country,_that.state,_that.city,_that.verificationStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? companyName,  String? designation,  String? bio,  List<String> categories,  String? website,  String? companySize,  String? linkedinUrl,  String country,  String? state,  String? city,  VerificationStatus verificationStatus)  $default,) {final _that = this;
switch (_that) {
case _BrandProfile():
return $default(_that.id,_that.companyName,_that.designation,_that.bio,_that.categories,_that.website,_that.companySize,_that.linkedinUrl,_that.country,_that.state,_that.city,_that.verificationStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? companyName,  String? designation,  String? bio,  List<String> categories,  String? website,  String? companySize,  String? linkedinUrl,  String country,  String? state,  String? city,  VerificationStatus verificationStatus)?  $default,) {final _that = this;
switch (_that) {
case _BrandProfile() when $default != null:
return $default(_that.id,_that.companyName,_that.designation,_that.bio,_that.categories,_that.website,_that.companySize,_that.linkedinUrl,_that.country,_that.state,_that.city,_that.verificationStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BrandProfile implements BrandProfile {
  const _BrandProfile({required this.id, this.companyName, this.designation, this.bio, final  List<String> categories = const [], this.website, this.companySize, this.linkedinUrl, this.country = 'India', this.state, this.city, this.verificationStatus = VerificationStatus.pending}): _categories = categories;
  factory _BrandProfile.fromJson(Map<String, dynamic> json) => _$BrandProfileFromJson(json);

@override final  String id;
@override final  String? companyName;
@override final  String? designation;
@override final  String? bio;
 final  List<String> _categories;
@override@JsonKey() List<String> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

@override final  String? website;
@override final  String? companySize;
@override final  String? linkedinUrl;
@override@JsonKey() final  String country;
@override final  String? state;
@override final  String? city;
@override@JsonKey() final  VerificationStatus verificationStatus;

/// Create a copy of BrandProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BrandProfileCopyWith<_BrandProfile> get copyWith => __$BrandProfileCopyWithImpl<_BrandProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BrandProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BrandProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.designation, designation) || other.designation == designation)&&(identical(other.bio, bio) || other.bio == bio)&&const DeepCollectionEquality().equals(other._categories, _categories)&&(identical(other.website, website) || other.website == website)&&(identical(other.companySize, companySize) || other.companySize == companySize)&&(identical(other.linkedinUrl, linkedinUrl) || other.linkedinUrl == linkedinUrl)&&(identical(other.country, country) || other.country == country)&&(identical(other.state, state) || other.state == state)&&(identical(other.city, city) || other.city == city)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyName,designation,bio,const DeepCollectionEquality().hash(_categories),website,companySize,linkedinUrl,country,state,city,verificationStatus);

@override
String toString() {
  return 'BrandProfile(id: $id, companyName: $companyName, designation: $designation, bio: $bio, categories: $categories, website: $website, companySize: $companySize, linkedinUrl: $linkedinUrl, country: $country, state: $state, city: $city, verificationStatus: $verificationStatus)';
}


}

/// @nodoc
abstract mixin class _$BrandProfileCopyWith<$Res> implements $BrandProfileCopyWith<$Res> {
  factory _$BrandProfileCopyWith(_BrandProfile value, $Res Function(_BrandProfile) _then) = __$BrandProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String? companyName, String? designation, String? bio, List<String> categories, String? website, String? companySize, String? linkedinUrl, String country, String? state, String? city, VerificationStatus verificationStatus
});




}
/// @nodoc
class __$BrandProfileCopyWithImpl<$Res>
    implements _$BrandProfileCopyWith<$Res> {
  __$BrandProfileCopyWithImpl(this._self, this._then);

  final _BrandProfile _self;
  final $Res Function(_BrandProfile) _then;

/// Create a copy of BrandProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyName = freezed,Object? designation = freezed,Object? bio = freezed,Object? categories = null,Object? website = freezed,Object? companySize = freezed,Object? linkedinUrl = freezed,Object? country = null,Object? state = freezed,Object? city = freezed,Object? verificationStatus = null,}) {
  return _then(_BrandProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyName: freezed == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String?,designation: freezed == designation ? _self.designation : designation // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,companySize: freezed == companySize ? _self.companySize : companySize // ignore: cast_nullable_to_non_nullable
as String?,linkedinUrl: freezed == linkedinUrl ? _self.linkedinUrl : linkedinUrl // ignore: cast_nullable_to_non_nullable
as String?,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VerificationStatus,
  ));
}


}

// dart format on
