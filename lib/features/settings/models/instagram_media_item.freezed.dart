// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'instagram_media_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InstagramMediaItem {

 String get id; String get userId; String? get mediaUrl; String? get mediaType; String? get thumbnailUrl; String? get permalink; String? get caption;@NullableTimestampConverter() DateTime? get timestamp;
/// Create a copy of InstagramMediaItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InstagramMediaItemCopyWith<InstagramMediaItem> get copyWith => _$InstagramMediaItemCopyWithImpl<InstagramMediaItem>(this as InstagramMediaItem, _$identity);

  /// Serializes this InstagramMediaItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InstagramMediaItem&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.permalink, permalink) || other.permalink == permalink)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,mediaUrl,mediaType,thumbnailUrl,permalink,caption,timestamp);

@override
String toString() {
  return 'InstagramMediaItem(id: $id, userId: $userId, mediaUrl: $mediaUrl, mediaType: $mediaType, thumbnailUrl: $thumbnailUrl, permalink: $permalink, caption: $caption, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $InstagramMediaItemCopyWith<$Res>  {
  factory $InstagramMediaItemCopyWith(InstagramMediaItem value, $Res Function(InstagramMediaItem) _then) = _$InstagramMediaItemCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String? mediaUrl, String? mediaType, String? thumbnailUrl, String? permalink, String? caption,@NullableTimestampConverter() DateTime? timestamp
});




}
/// @nodoc
class _$InstagramMediaItemCopyWithImpl<$Res>
    implements $InstagramMediaItemCopyWith<$Res> {
  _$InstagramMediaItemCopyWithImpl(this._self, this._then);

  final InstagramMediaItem _self;
  final $Res Function(InstagramMediaItem) _then;

/// Create a copy of InstagramMediaItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? mediaUrl = freezed,Object? mediaType = freezed,Object? thumbnailUrl = freezed,Object? permalink = freezed,Object? caption = freezed,Object? timestamp = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,mediaUrl: freezed == mediaUrl ? _self.mediaUrl : mediaUrl // ignore: cast_nullable_to_non_nullable
as String?,mediaType: freezed == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,permalink: freezed == permalink ? _self.permalink : permalink // ignore: cast_nullable_to_non_nullable
as String?,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [InstagramMediaItem].
extension InstagramMediaItemPatterns on InstagramMediaItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InstagramMediaItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InstagramMediaItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InstagramMediaItem value)  $default,){
final _that = this;
switch (_that) {
case _InstagramMediaItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InstagramMediaItem value)?  $default,){
final _that = this;
switch (_that) {
case _InstagramMediaItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String? mediaUrl,  String? mediaType,  String? thumbnailUrl,  String? permalink,  String? caption, @NullableTimestampConverter()  DateTime? timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InstagramMediaItem() when $default != null:
return $default(_that.id,_that.userId,_that.mediaUrl,_that.mediaType,_that.thumbnailUrl,_that.permalink,_that.caption,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String? mediaUrl,  String? mediaType,  String? thumbnailUrl,  String? permalink,  String? caption, @NullableTimestampConverter()  DateTime? timestamp)  $default,) {final _that = this;
switch (_that) {
case _InstagramMediaItem():
return $default(_that.id,_that.userId,_that.mediaUrl,_that.mediaType,_that.thumbnailUrl,_that.permalink,_that.caption,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String? mediaUrl,  String? mediaType,  String? thumbnailUrl,  String? permalink,  String? caption, @NullableTimestampConverter()  DateTime? timestamp)?  $default,) {final _that = this;
switch (_that) {
case _InstagramMediaItem() when $default != null:
return $default(_that.id,_that.userId,_that.mediaUrl,_that.mediaType,_that.thumbnailUrl,_that.permalink,_that.caption,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InstagramMediaItem implements InstagramMediaItem {
  const _InstagramMediaItem({required this.id, required this.userId, this.mediaUrl, this.mediaType, this.thumbnailUrl, this.permalink, this.caption, @NullableTimestampConverter() this.timestamp});
  factory _InstagramMediaItem.fromJson(Map<String, dynamic> json) => _$InstagramMediaItemFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String? mediaUrl;
@override final  String? mediaType;
@override final  String? thumbnailUrl;
@override final  String? permalink;
@override final  String? caption;
@override@NullableTimestampConverter() final  DateTime? timestamp;

/// Create a copy of InstagramMediaItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InstagramMediaItemCopyWith<_InstagramMediaItem> get copyWith => __$InstagramMediaItemCopyWithImpl<_InstagramMediaItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InstagramMediaItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InstagramMediaItem&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.permalink, permalink) || other.permalink == permalink)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,mediaUrl,mediaType,thumbnailUrl,permalink,caption,timestamp);

@override
String toString() {
  return 'InstagramMediaItem(id: $id, userId: $userId, mediaUrl: $mediaUrl, mediaType: $mediaType, thumbnailUrl: $thumbnailUrl, permalink: $permalink, caption: $caption, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$InstagramMediaItemCopyWith<$Res> implements $InstagramMediaItemCopyWith<$Res> {
  factory _$InstagramMediaItemCopyWith(_InstagramMediaItem value, $Res Function(_InstagramMediaItem) _then) = __$InstagramMediaItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String? mediaUrl, String? mediaType, String? thumbnailUrl, String? permalink, String? caption,@NullableTimestampConverter() DateTime? timestamp
});




}
/// @nodoc
class __$InstagramMediaItemCopyWithImpl<$Res>
    implements _$InstagramMediaItemCopyWith<$Res> {
  __$InstagramMediaItemCopyWithImpl(this._self, this._then);

  final _InstagramMediaItem _self;
  final $Res Function(_InstagramMediaItem) _then;

/// Create a copy of InstagramMediaItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? mediaUrl = freezed,Object? mediaType = freezed,Object? thumbnailUrl = freezed,Object? permalink = freezed,Object? caption = freezed,Object? timestamp = freezed,}) {
  return _then(_InstagramMediaItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,mediaUrl: freezed == mediaUrl ? _self.mediaUrl : mediaUrl // ignore: cast_nullable_to_non_nullable
as String?,mediaType: freezed == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,permalink: freezed == permalink ? _self.permalink : permalink // ignore: cast_nullable_to_non_nullable
as String?,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
