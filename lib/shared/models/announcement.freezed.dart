// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'announcement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Announcement {

 String get id; String get title; String get body; String get audience;@NullableTimestampConverter() DateTime? get createdAt; String? get createdBy; String get targetType; List<String>? get targetCategories; int? get targetMinFollowers; int? get targetMaxFollowers; String? get targetCreatorId; String? get targetCreatorName; String? get targetBrandId; String? get targetBrandName; String? get targetCompanySize;
/// Create a copy of Announcement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnnouncementCopyWith<Announcement> get copyWith => _$AnnouncementCopyWithImpl<Announcement>(this as Announcement, _$identity);

  /// Serializes this Announcement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Announcement&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&const DeepCollectionEquality().equals(other.targetCategories, targetCategories)&&(identical(other.targetMinFollowers, targetMinFollowers) || other.targetMinFollowers == targetMinFollowers)&&(identical(other.targetMaxFollowers, targetMaxFollowers) || other.targetMaxFollowers == targetMaxFollowers)&&(identical(other.targetCreatorId, targetCreatorId) || other.targetCreatorId == targetCreatorId)&&(identical(other.targetCreatorName, targetCreatorName) || other.targetCreatorName == targetCreatorName)&&(identical(other.targetBrandId, targetBrandId) || other.targetBrandId == targetBrandId)&&(identical(other.targetBrandName, targetBrandName) || other.targetBrandName == targetBrandName)&&(identical(other.targetCompanySize, targetCompanySize) || other.targetCompanySize == targetCompanySize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,body,audience,createdAt,createdBy,targetType,const DeepCollectionEquality().hash(targetCategories),targetMinFollowers,targetMaxFollowers,targetCreatorId,targetCreatorName,targetBrandId,targetBrandName,targetCompanySize);

@override
String toString() {
  return 'Announcement(id: $id, title: $title, body: $body, audience: $audience, createdAt: $createdAt, createdBy: $createdBy, targetType: $targetType, targetCategories: $targetCategories, targetMinFollowers: $targetMinFollowers, targetMaxFollowers: $targetMaxFollowers, targetCreatorId: $targetCreatorId, targetCreatorName: $targetCreatorName, targetBrandId: $targetBrandId, targetBrandName: $targetBrandName, targetCompanySize: $targetCompanySize)';
}


}

/// @nodoc
abstract mixin class $AnnouncementCopyWith<$Res>  {
  factory $AnnouncementCopyWith(Announcement value, $Res Function(Announcement) _then) = _$AnnouncementCopyWithImpl;
@useResult
$Res call({
 String id, String title, String body, String audience,@NullableTimestampConverter() DateTime? createdAt, String? createdBy, String targetType, List<String>? targetCategories, int? targetMinFollowers, int? targetMaxFollowers, String? targetCreatorId, String? targetCreatorName, String? targetBrandId, String? targetBrandName, String? targetCompanySize
});




}
/// @nodoc
class _$AnnouncementCopyWithImpl<$Res>
    implements $AnnouncementCopyWith<$Res> {
  _$AnnouncementCopyWithImpl(this._self, this._then);

  final Announcement _self;
  final $Res Function(Announcement) _then;

/// Create a copy of Announcement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? body = null,Object? audience = null,Object? createdAt = freezed,Object? createdBy = freezed,Object? targetType = null,Object? targetCategories = freezed,Object? targetMinFollowers = freezed,Object? targetMaxFollowers = freezed,Object? targetCreatorId = freezed,Object? targetCreatorName = freezed,Object? targetBrandId = freezed,Object? targetBrandName = freezed,Object? targetCompanySize = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as String,targetCategories: freezed == targetCategories ? _self.targetCategories : targetCategories // ignore: cast_nullable_to_non_nullable
as List<String>?,targetMinFollowers: freezed == targetMinFollowers ? _self.targetMinFollowers : targetMinFollowers // ignore: cast_nullable_to_non_nullable
as int?,targetMaxFollowers: freezed == targetMaxFollowers ? _self.targetMaxFollowers : targetMaxFollowers // ignore: cast_nullable_to_non_nullable
as int?,targetCreatorId: freezed == targetCreatorId ? _self.targetCreatorId : targetCreatorId // ignore: cast_nullable_to_non_nullable
as String?,targetCreatorName: freezed == targetCreatorName ? _self.targetCreatorName : targetCreatorName // ignore: cast_nullable_to_non_nullable
as String?,targetBrandId: freezed == targetBrandId ? _self.targetBrandId : targetBrandId // ignore: cast_nullable_to_non_nullable
as String?,targetBrandName: freezed == targetBrandName ? _self.targetBrandName : targetBrandName // ignore: cast_nullable_to_non_nullable
as String?,targetCompanySize: freezed == targetCompanySize ? _self.targetCompanySize : targetCompanySize // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Announcement].
extension AnnouncementPatterns on Announcement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Announcement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Announcement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Announcement value)  $default,){
final _that = this;
switch (_that) {
case _Announcement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Announcement value)?  $default,){
final _that = this;
switch (_that) {
case _Announcement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String body,  String audience, @NullableTimestampConverter()  DateTime? createdAt,  String? createdBy,  String targetType,  List<String>? targetCategories,  int? targetMinFollowers,  int? targetMaxFollowers,  String? targetCreatorId,  String? targetCreatorName,  String? targetBrandId,  String? targetBrandName,  String? targetCompanySize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Announcement() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.audience,_that.createdAt,_that.createdBy,_that.targetType,_that.targetCategories,_that.targetMinFollowers,_that.targetMaxFollowers,_that.targetCreatorId,_that.targetCreatorName,_that.targetBrandId,_that.targetBrandName,_that.targetCompanySize);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String body,  String audience, @NullableTimestampConverter()  DateTime? createdAt,  String? createdBy,  String targetType,  List<String>? targetCategories,  int? targetMinFollowers,  int? targetMaxFollowers,  String? targetCreatorId,  String? targetCreatorName,  String? targetBrandId,  String? targetBrandName,  String? targetCompanySize)  $default,) {final _that = this;
switch (_that) {
case _Announcement():
return $default(_that.id,_that.title,_that.body,_that.audience,_that.createdAt,_that.createdBy,_that.targetType,_that.targetCategories,_that.targetMinFollowers,_that.targetMaxFollowers,_that.targetCreatorId,_that.targetCreatorName,_that.targetBrandId,_that.targetBrandName,_that.targetCompanySize);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String body,  String audience, @NullableTimestampConverter()  DateTime? createdAt,  String? createdBy,  String targetType,  List<String>? targetCategories,  int? targetMinFollowers,  int? targetMaxFollowers,  String? targetCreatorId,  String? targetCreatorName,  String? targetBrandId,  String? targetBrandName,  String? targetCompanySize)?  $default,) {final _that = this;
switch (_that) {
case _Announcement() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.audience,_that.createdAt,_that.createdBy,_that.targetType,_that.targetCategories,_that.targetMinFollowers,_that.targetMaxFollowers,_that.targetCreatorId,_that.targetCreatorName,_that.targetBrandId,_that.targetBrandName,_that.targetCompanySize);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Announcement implements Announcement {
  const _Announcement({required this.id, required this.title, required this.body, required this.audience, @NullableTimestampConverter() this.createdAt, this.createdBy, this.targetType = 'all', final  List<String>? targetCategories, this.targetMinFollowers, this.targetMaxFollowers, this.targetCreatorId, this.targetCreatorName, this.targetBrandId, this.targetBrandName, this.targetCompanySize}): _targetCategories = targetCategories;
  factory _Announcement.fromJson(Map<String, dynamic> json) => _$AnnouncementFromJson(json);

@override final  String id;
@override final  String title;
@override final  String body;
@override final  String audience;
@override@NullableTimestampConverter() final  DateTime? createdAt;
@override final  String? createdBy;
@override@JsonKey() final  String targetType;
 final  List<String>? _targetCategories;
@override List<String>? get targetCategories {
  final value = _targetCategories;
  if (value == null) return null;
  if (_targetCategories is EqualUnmodifiableListView) return _targetCategories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  int? targetMinFollowers;
@override final  int? targetMaxFollowers;
@override final  String? targetCreatorId;
@override final  String? targetCreatorName;
@override final  String? targetBrandId;
@override final  String? targetBrandName;
@override final  String? targetCompanySize;

/// Create a copy of Announcement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnnouncementCopyWith<_Announcement> get copyWith => __$AnnouncementCopyWithImpl<_Announcement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnnouncementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Announcement&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&const DeepCollectionEquality().equals(other._targetCategories, _targetCategories)&&(identical(other.targetMinFollowers, targetMinFollowers) || other.targetMinFollowers == targetMinFollowers)&&(identical(other.targetMaxFollowers, targetMaxFollowers) || other.targetMaxFollowers == targetMaxFollowers)&&(identical(other.targetCreatorId, targetCreatorId) || other.targetCreatorId == targetCreatorId)&&(identical(other.targetCreatorName, targetCreatorName) || other.targetCreatorName == targetCreatorName)&&(identical(other.targetBrandId, targetBrandId) || other.targetBrandId == targetBrandId)&&(identical(other.targetBrandName, targetBrandName) || other.targetBrandName == targetBrandName)&&(identical(other.targetCompanySize, targetCompanySize) || other.targetCompanySize == targetCompanySize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,body,audience,createdAt,createdBy,targetType,const DeepCollectionEquality().hash(_targetCategories),targetMinFollowers,targetMaxFollowers,targetCreatorId,targetCreatorName,targetBrandId,targetBrandName,targetCompanySize);

@override
String toString() {
  return 'Announcement(id: $id, title: $title, body: $body, audience: $audience, createdAt: $createdAt, createdBy: $createdBy, targetType: $targetType, targetCategories: $targetCategories, targetMinFollowers: $targetMinFollowers, targetMaxFollowers: $targetMaxFollowers, targetCreatorId: $targetCreatorId, targetCreatorName: $targetCreatorName, targetBrandId: $targetBrandId, targetBrandName: $targetBrandName, targetCompanySize: $targetCompanySize)';
}


}

/// @nodoc
abstract mixin class _$AnnouncementCopyWith<$Res> implements $AnnouncementCopyWith<$Res> {
  factory _$AnnouncementCopyWith(_Announcement value, $Res Function(_Announcement) _then) = __$AnnouncementCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String body, String audience,@NullableTimestampConverter() DateTime? createdAt, String? createdBy, String targetType, List<String>? targetCategories, int? targetMinFollowers, int? targetMaxFollowers, String? targetCreatorId, String? targetCreatorName, String? targetBrandId, String? targetBrandName, String? targetCompanySize
});




}
/// @nodoc
class __$AnnouncementCopyWithImpl<$Res>
    implements _$AnnouncementCopyWith<$Res> {
  __$AnnouncementCopyWithImpl(this._self, this._then);

  final _Announcement _self;
  final $Res Function(_Announcement) _then;

/// Create a copy of Announcement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? body = null,Object? audience = null,Object? createdAt = freezed,Object? createdBy = freezed,Object? targetType = null,Object? targetCategories = freezed,Object? targetMinFollowers = freezed,Object? targetMaxFollowers = freezed,Object? targetCreatorId = freezed,Object? targetCreatorName = freezed,Object? targetBrandId = freezed,Object? targetBrandName = freezed,Object? targetCompanySize = freezed,}) {
  return _then(_Announcement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as String,targetCategories: freezed == targetCategories ? _self._targetCategories : targetCategories // ignore: cast_nullable_to_non_nullable
as List<String>?,targetMinFollowers: freezed == targetMinFollowers ? _self.targetMinFollowers : targetMinFollowers // ignore: cast_nullable_to_non_nullable
as int?,targetMaxFollowers: freezed == targetMaxFollowers ? _self.targetMaxFollowers : targetMaxFollowers // ignore: cast_nullable_to_non_nullable
as int?,targetCreatorId: freezed == targetCreatorId ? _self.targetCreatorId : targetCreatorId // ignore: cast_nullable_to_non_nullable
as String?,targetCreatorName: freezed == targetCreatorName ? _self.targetCreatorName : targetCreatorName // ignore: cast_nullable_to_non_nullable
as String?,targetBrandId: freezed == targetBrandId ? _self.targetBrandId : targetBrandId // ignore: cast_nullable_to_non_nullable
as String?,targetBrandName: freezed == targetBrandName ? _self.targetBrandName : targetBrandName // ignore: cast_nullable_to_non_nullable
as String?,targetCompanySize: freezed == targetCompanySize ? _self.targetCompanySize : targetCompanySize // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
