// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Chat {

 String get id; String get creatorId; String get creatorName; String get brandId; String get brandName; ChatStatus get status; String? get lastMessage;@NullableTimestampConverter() DateTime? get lastMessageAt;@NullableTimestampConverter() DateTime? get creatorLastReadAt;@NullableTimestampConverter() DateTime? get brandLastReadAt;
/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatCopyWith<Chat> get copyWith => _$ChatCopyWithImpl<Chat>(this as Chat, _$identity);

  /// Serializes this Chat to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Chat&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.creatorName, creatorName) || other.creatorName == creatorName)&&(identical(other.brandId, brandId) || other.brandId == brandId)&&(identical(other.brandName, brandName) || other.brandName == brandName)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.creatorLastReadAt, creatorLastReadAt) || other.creatorLastReadAt == creatorLastReadAt)&&(identical(other.brandLastReadAt, brandLastReadAt) || other.brandLastReadAt == brandLastReadAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creatorId,creatorName,brandId,brandName,status,lastMessage,lastMessageAt,creatorLastReadAt,brandLastReadAt);

@override
String toString() {
  return 'Chat(id: $id, creatorId: $creatorId, creatorName: $creatorName, brandId: $brandId, brandName: $brandName, status: $status, lastMessage: $lastMessage, lastMessageAt: $lastMessageAt, creatorLastReadAt: $creatorLastReadAt, brandLastReadAt: $brandLastReadAt)';
}


}

/// @nodoc
abstract mixin class $ChatCopyWith<$Res>  {
  factory $ChatCopyWith(Chat value, $Res Function(Chat) _then) = _$ChatCopyWithImpl;
@useResult
$Res call({
 String id, String creatorId, String creatorName, String brandId, String brandName, ChatStatus status, String? lastMessage,@NullableTimestampConverter() DateTime? lastMessageAt,@NullableTimestampConverter() DateTime? creatorLastReadAt,@NullableTimestampConverter() DateTime? brandLastReadAt
});




}
/// @nodoc
class _$ChatCopyWithImpl<$Res>
    implements $ChatCopyWith<$Res> {
  _$ChatCopyWithImpl(this._self, this._then);

  final Chat _self;
  final $Res Function(Chat) _then;

/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? creatorId = null,Object? creatorName = null,Object? brandId = null,Object? brandName = null,Object? status = null,Object? lastMessage = freezed,Object? lastMessageAt = freezed,Object? creatorLastReadAt = freezed,Object? brandLastReadAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,creatorName: null == creatorName ? _self.creatorName : creatorName // ignore: cast_nullable_to_non_nullable
as String,brandId: null == brandId ? _self.brandId : brandId // ignore: cast_nullable_to_non_nullable
as String,brandName: null == brandName ? _self.brandName : brandName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChatStatus,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,creatorLastReadAt: freezed == creatorLastReadAt ? _self.creatorLastReadAt : creatorLastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime?,brandLastReadAt: freezed == brandLastReadAt ? _self.brandLastReadAt : brandLastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Chat].
extension ChatPatterns on Chat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Chat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Chat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Chat value)  $default,){
final _that = this;
switch (_that) {
case _Chat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Chat value)?  $default,){
final _that = this;
switch (_that) {
case _Chat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String creatorId,  String creatorName,  String brandId,  String brandName,  ChatStatus status,  String? lastMessage, @NullableTimestampConverter()  DateTime? lastMessageAt, @NullableTimestampConverter()  DateTime? creatorLastReadAt, @NullableTimestampConverter()  DateTime? brandLastReadAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Chat() when $default != null:
return $default(_that.id,_that.creatorId,_that.creatorName,_that.brandId,_that.brandName,_that.status,_that.lastMessage,_that.lastMessageAt,_that.creatorLastReadAt,_that.brandLastReadAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String creatorId,  String creatorName,  String brandId,  String brandName,  ChatStatus status,  String? lastMessage, @NullableTimestampConverter()  DateTime? lastMessageAt, @NullableTimestampConverter()  DateTime? creatorLastReadAt, @NullableTimestampConverter()  DateTime? brandLastReadAt)  $default,) {final _that = this;
switch (_that) {
case _Chat():
return $default(_that.id,_that.creatorId,_that.creatorName,_that.brandId,_that.brandName,_that.status,_that.lastMessage,_that.lastMessageAt,_that.creatorLastReadAt,_that.brandLastReadAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String creatorId,  String creatorName,  String brandId,  String brandName,  ChatStatus status,  String? lastMessage, @NullableTimestampConverter()  DateTime? lastMessageAt, @NullableTimestampConverter()  DateTime? creatorLastReadAt, @NullableTimestampConverter()  DateTime? brandLastReadAt)?  $default,) {final _that = this;
switch (_that) {
case _Chat() when $default != null:
return $default(_that.id,_that.creatorId,_that.creatorName,_that.brandId,_that.brandName,_that.status,_that.lastMessage,_that.lastMessageAt,_that.creatorLastReadAt,_that.brandLastReadAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Chat implements Chat {
  const _Chat({required this.id, required this.creatorId, required this.creatorName, required this.brandId, required this.brandName, this.status = ChatStatus.request, this.lastMessage, @NullableTimestampConverter() this.lastMessageAt, @NullableTimestampConverter() this.creatorLastReadAt, @NullableTimestampConverter() this.brandLastReadAt});
  factory _Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);

@override final  String id;
@override final  String creatorId;
@override final  String creatorName;
@override final  String brandId;
@override final  String brandName;
@override@JsonKey() final  ChatStatus status;
@override final  String? lastMessage;
@override@NullableTimestampConverter() final  DateTime? lastMessageAt;
@override@NullableTimestampConverter() final  DateTime? creatorLastReadAt;
@override@NullableTimestampConverter() final  DateTime? brandLastReadAt;

/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatCopyWith<_Chat> get copyWith => __$ChatCopyWithImpl<_Chat>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Chat&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.creatorName, creatorName) || other.creatorName == creatorName)&&(identical(other.brandId, brandId) || other.brandId == brandId)&&(identical(other.brandName, brandName) || other.brandName == brandName)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.creatorLastReadAt, creatorLastReadAt) || other.creatorLastReadAt == creatorLastReadAt)&&(identical(other.brandLastReadAt, brandLastReadAt) || other.brandLastReadAt == brandLastReadAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creatorId,creatorName,brandId,brandName,status,lastMessage,lastMessageAt,creatorLastReadAt,brandLastReadAt);

@override
String toString() {
  return 'Chat(id: $id, creatorId: $creatorId, creatorName: $creatorName, brandId: $brandId, brandName: $brandName, status: $status, lastMessage: $lastMessage, lastMessageAt: $lastMessageAt, creatorLastReadAt: $creatorLastReadAt, brandLastReadAt: $brandLastReadAt)';
}


}

/// @nodoc
abstract mixin class _$ChatCopyWith<$Res> implements $ChatCopyWith<$Res> {
  factory _$ChatCopyWith(_Chat value, $Res Function(_Chat) _then) = __$ChatCopyWithImpl;
@override @useResult
$Res call({
 String id, String creatorId, String creatorName, String brandId, String brandName, ChatStatus status, String? lastMessage,@NullableTimestampConverter() DateTime? lastMessageAt,@NullableTimestampConverter() DateTime? creatorLastReadAt,@NullableTimestampConverter() DateTime? brandLastReadAt
});




}
/// @nodoc
class __$ChatCopyWithImpl<$Res>
    implements _$ChatCopyWith<$Res> {
  __$ChatCopyWithImpl(this._self, this._then);

  final _Chat _self;
  final $Res Function(_Chat) _then;

/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? creatorId = null,Object? creatorName = null,Object? brandId = null,Object? brandName = null,Object? status = null,Object? lastMessage = freezed,Object? lastMessageAt = freezed,Object? creatorLastReadAt = freezed,Object? brandLastReadAt = freezed,}) {
  return _then(_Chat(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,creatorName: null == creatorName ? _self.creatorName : creatorName // ignore: cast_nullable_to_non_nullable
as String,brandId: null == brandId ? _self.brandId : brandId // ignore: cast_nullable_to_non_nullable
as String,brandName: null == brandName ? _self.brandName : brandName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChatStatus,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,creatorLastReadAt: freezed == creatorLastReadAt ? _self.creatorLastReadAt : creatorLastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime?,brandLastReadAt: freezed == brandLastReadAt ? _self.brandLastReadAt : brandLastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
