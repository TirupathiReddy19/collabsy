// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'support_chat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SupportChat {

 String get id; String get userId; String get userName; UserRole get userRole; SupportChatStatus get status;@NullableTimestampConverter() DateTime? get createdAt; String? get lastMessage;@NullableTimestampConverter() DateTime? get lastMessageAt; SupportSenderRole? get lastMessageSenderRole;@NullableTimestampConverter() DateTime? get userLastReadAt;@NullableTimestampConverter() DateTime? get supportLastReadAt; SupportTicketCategory? get category; String? get internalNotes;@NullableTimestampConverter() DateTime? get internalNotesUpdatedAt; String? get internalNotesUpdatedBy;
/// Create a copy of SupportChat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportChatCopyWith<SupportChat> get copyWith => _$SupportChatCopyWithImpl<SupportChat>(this as SupportChat, _$identity);

  /// Serializes this SupportChat to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportChat&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userRole, userRole) || other.userRole == userRole)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.lastMessageSenderRole, lastMessageSenderRole) || other.lastMessageSenderRole == lastMessageSenderRole)&&(identical(other.userLastReadAt, userLastReadAt) || other.userLastReadAt == userLastReadAt)&&(identical(other.supportLastReadAt, supportLastReadAt) || other.supportLastReadAt == supportLastReadAt)&&(identical(other.category, category) || other.category == category)&&(identical(other.internalNotes, internalNotes) || other.internalNotes == internalNotes)&&(identical(other.internalNotesUpdatedAt, internalNotesUpdatedAt) || other.internalNotesUpdatedAt == internalNotesUpdatedAt)&&(identical(other.internalNotesUpdatedBy, internalNotesUpdatedBy) || other.internalNotesUpdatedBy == internalNotesUpdatedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,userName,userRole,status,createdAt,lastMessage,lastMessageAt,lastMessageSenderRole,userLastReadAt,supportLastReadAt,category,internalNotes,internalNotesUpdatedAt,internalNotesUpdatedBy);

@override
String toString() {
  return 'SupportChat(id: $id, userId: $userId, userName: $userName, userRole: $userRole, status: $status, createdAt: $createdAt, lastMessage: $lastMessage, lastMessageAt: $lastMessageAt, lastMessageSenderRole: $lastMessageSenderRole, userLastReadAt: $userLastReadAt, supportLastReadAt: $supportLastReadAt, category: $category, internalNotes: $internalNotes, internalNotesUpdatedAt: $internalNotesUpdatedAt, internalNotesUpdatedBy: $internalNotesUpdatedBy)';
}


}

/// @nodoc
abstract mixin class $SupportChatCopyWith<$Res>  {
  factory $SupportChatCopyWith(SupportChat value, $Res Function(SupportChat) _then) = _$SupportChatCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String userName, UserRole userRole, SupportChatStatus status,@NullableTimestampConverter() DateTime? createdAt, String? lastMessage,@NullableTimestampConverter() DateTime? lastMessageAt, SupportSenderRole? lastMessageSenderRole,@NullableTimestampConverter() DateTime? userLastReadAt,@NullableTimestampConverter() DateTime? supportLastReadAt, SupportTicketCategory? category, String? internalNotes,@NullableTimestampConverter() DateTime? internalNotesUpdatedAt, String? internalNotesUpdatedBy
});




}
/// @nodoc
class _$SupportChatCopyWithImpl<$Res>
    implements $SupportChatCopyWith<$Res> {
  _$SupportChatCopyWithImpl(this._self, this._then);

  final SupportChat _self;
  final $Res Function(SupportChat) _then;

/// Create a copy of SupportChat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? userName = null,Object? userRole = null,Object? status = null,Object? createdAt = freezed,Object? lastMessage = freezed,Object? lastMessageAt = freezed,Object? lastMessageSenderRole = freezed,Object? userLastReadAt = freezed,Object? supportLastReadAt = freezed,Object? category = freezed,Object? internalNotes = freezed,Object? internalNotesUpdatedAt = freezed,Object? internalNotesUpdatedBy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userRole: null == userRole ? _self.userRole : userRole // ignore: cast_nullable_to_non_nullable
as UserRole,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SupportChatStatus,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastMessageSenderRole: freezed == lastMessageSenderRole ? _self.lastMessageSenderRole : lastMessageSenderRole // ignore: cast_nullable_to_non_nullable
as SupportSenderRole?,userLastReadAt: freezed == userLastReadAt ? _self.userLastReadAt : userLastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime?,supportLastReadAt: freezed == supportLastReadAt ? _self.supportLastReadAt : supportLastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as SupportTicketCategory?,internalNotes: freezed == internalNotes ? _self.internalNotes : internalNotes // ignore: cast_nullable_to_non_nullable
as String?,internalNotesUpdatedAt: freezed == internalNotesUpdatedAt ? _self.internalNotesUpdatedAt : internalNotesUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,internalNotesUpdatedBy: freezed == internalNotesUpdatedBy ? _self.internalNotesUpdatedBy : internalNotesUpdatedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SupportChat].
extension SupportChatPatterns on SupportChat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportChat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportChat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportChat value)  $default,){
final _that = this;
switch (_that) {
case _SupportChat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportChat value)?  $default,){
final _that = this;
switch (_that) {
case _SupportChat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String userName,  UserRole userRole,  SupportChatStatus status, @NullableTimestampConverter()  DateTime? createdAt,  String? lastMessage, @NullableTimestampConverter()  DateTime? lastMessageAt,  SupportSenderRole? lastMessageSenderRole, @NullableTimestampConverter()  DateTime? userLastReadAt, @NullableTimestampConverter()  DateTime? supportLastReadAt,  SupportTicketCategory? category,  String? internalNotes, @NullableTimestampConverter()  DateTime? internalNotesUpdatedAt,  String? internalNotesUpdatedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportChat() when $default != null:
return $default(_that.id,_that.userId,_that.userName,_that.userRole,_that.status,_that.createdAt,_that.lastMessage,_that.lastMessageAt,_that.lastMessageSenderRole,_that.userLastReadAt,_that.supportLastReadAt,_that.category,_that.internalNotes,_that.internalNotesUpdatedAt,_that.internalNotesUpdatedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String userName,  UserRole userRole,  SupportChatStatus status, @NullableTimestampConverter()  DateTime? createdAt,  String? lastMessage, @NullableTimestampConverter()  DateTime? lastMessageAt,  SupportSenderRole? lastMessageSenderRole, @NullableTimestampConverter()  DateTime? userLastReadAt, @NullableTimestampConverter()  DateTime? supportLastReadAt,  SupportTicketCategory? category,  String? internalNotes, @NullableTimestampConverter()  DateTime? internalNotesUpdatedAt,  String? internalNotesUpdatedBy)  $default,) {final _that = this;
switch (_that) {
case _SupportChat():
return $default(_that.id,_that.userId,_that.userName,_that.userRole,_that.status,_that.createdAt,_that.lastMessage,_that.lastMessageAt,_that.lastMessageSenderRole,_that.userLastReadAt,_that.supportLastReadAt,_that.category,_that.internalNotes,_that.internalNotesUpdatedAt,_that.internalNotesUpdatedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String userName,  UserRole userRole,  SupportChatStatus status, @NullableTimestampConverter()  DateTime? createdAt,  String? lastMessage, @NullableTimestampConverter()  DateTime? lastMessageAt,  SupportSenderRole? lastMessageSenderRole, @NullableTimestampConverter()  DateTime? userLastReadAt, @NullableTimestampConverter()  DateTime? supportLastReadAt,  SupportTicketCategory? category,  String? internalNotes, @NullableTimestampConverter()  DateTime? internalNotesUpdatedAt,  String? internalNotesUpdatedBy)?  $default,) {final _that = this;
switch (_that) {
case _SupportChat() when $default != null:
return $default(_that.id,_that.userId,_that.userName,_that.userRole,_that.status,_that.createdAt,_that.lastMessage,_that.lastMessageAt,_that.lastMessageSenderRole,_that.userLastReadAt,_that.supportLastReadAt,_that.category,_that.internalNotes,_that.internalNotesUpdatedAt,_that.internalNotesUpdatedBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SupportChat implements SupportChat {
  const _SupportChat({required this.id, required this.userId, required this.userName, required this.userRole, this.status = SupportChatStatus.open, @NullableTimestampConverter() this.createdAt, this.lastMessage, @NullableTimestampConverter() this.lastMessageAt, this.lastMessageSenderRole, @NullableTimestampConverter() this.userLastReadAt, @NullableTimestampConverter() this.supportLastReadAt, this.category, this.internalNotes, @NullableTimestampConverter() this.internalNotesUpdatedAt, this.internalNotesUpdatedBy});
  factory _SupportChat.fromJson(Map<String, dynamic> json) => _$SupportChatFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String userName;
@override final  UserRole userRole;
@override@JsonKey() final  SupportChatStatus status;
@override@NullableTimestampConverter() final  DateTime? createdAt;
@override final  String? lastMessage;
@override@NullableTimestampConverter() final  DateTime? lastMessageAt;
@override final  SupportSenderRole? lastMessageSenderRole;
@override@NullableTimestampConverter() final  DateTime? userLastReadAt;
@override@NullableTimestampConverter() final  DateTime? supportLastReadAt;
@override final  SupportTicketCategory? category;
@override final  String? internalNotes;
@override@NullableTimestampConverter() final  DateTime? internalNotesUpdatedAt;
@override final  String? internalNotesUpdatedBy;

/// Create a copy of SupportChat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportChatCopyWith<_SupportChat> get copyWith => __$SupportChatCopyWithImpl<_SupportChat>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SupportChatToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportChat&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userRole, userRole) || other.userRole == userRole)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.lastMessageSenderRole, lastMessageSenderRole) || other.lastMessageSenderRole == lastMessageSenderRole)&&(identical(other.userLastReadAt, userLastReadAt) || other.userLastReadAt == userLastReadAt)&&(identical(other.supportLastReadAt, supportLastReadAt) || other.supportLastReadAt == supportLastReadAt)&&(identical(other.category, category) || other.category == category)&&(identical(other.internalNotes, internalNotes) || other.internalNotes == internalNotes)&&(identical(other.internalNotesUpdatedAt, internalNotesUpdatedAt) || other.internalNotesUpdatedAt == internalNotesUpdatedAt)&&(identical(other.internalNotesUpdatedBy, internalNotesUpdatedBy) || other.internalNotesUpdatedBy == internalNotesUpdatedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,userName,userRole,status,createdAt,lastMessage,lastMessageAt,lastMessageSenderRole,userLastReadAt,supportLastReadAt,category,internalNotes,internalNotesUpdatedAt,internalNotesUpdatedBy);

@override
String toString() {
  return 'SupportChat(id: $id, userId: $userId, userName: $userName, userRole: $userRole, status: $status, createdAt: $createdAt, lastMessage: $lastMessage, lastMessageAt: $lastMessageAt, lastMessageSenderRole: $lastMessageSenderRole, userLastReadAt: $userLastReadAt, supportLastReadAt: $supportLastReadAt, category: $category, internalNotes: $internalNotes, internalNotesUpdatedAt: $internalNotesUpdatedAt, internalNotesUpdatedBy: $internalNotesUpdatedBy)';
}


}

/// @nodoc
abstract mixin class _$SupportChatCopyWith<$Res> implements $SupportChatCopyWith<$Res> {
  factory _$SupportChatCopyWith(_SupportChat value, $Res Function(_SupportChat) _then) = __$SupportChatCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String userName, UserRole userRole, SupportChatStatus status,@NullableTimestampConverter() DateTime? createdAt, String? lastMessage,@NullableTimestampConverter() DateTime? lastMessageAt, SupportSenderRole? lastMessageSenderRole,@NullableTimestampConverter() DateTime? userLastReadAt,@NullableTimestampConverter() DateTime? supportLastReadAt, SupportTicketCategory? category, String? internalNotes,@NullableTimestampConverter() DateTime? internalNotesUpdatedAt, String? internalNotesUpdatedBy
});




}
/// @nodoc
class __$SupportChatCopyWithImpl<$Res>
    implements _$SupportChatCopyWith<$Res> {
  __$SupportChatCopyWithImpl(this._self, this._then);

  final _SupportChat _self;
  final $Res Function(_SupportChat) _then;

/// Create a copy of SupportChat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? userName = null,Object? userRole = null,Object? status = null,Object? createdAt = freezed,Object? lastMessage = freezed,Object? lastMessageAt = freezed,Object? lastMessageSenderRole = freezed,Object? userLastReadAt = freezed,Object? supportLastReadAt = freezed,Object? category = freezed,Object? internalNotes = freezed,Object? internalNotesUpdatedAt = freezed,Object? internalNotesUpdatedBy = freezed,}) {
  return _then(_SupportChat(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userRole: null == userRole ? _self.userRole : userRole // ignore: cast_nullable_to_non_nullable
as UserRole,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SupportChatStatus,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastMessageSenderRole: freezed == lastMessageSenderRole ? _self.lastMessageSenderRole : lastMessageSenderRole // ignore: cast_nullable_to_non_nullable
as SupportSenderRole?,userLastReadAt: freezed == userLastReadAt ? _self.userLastReadAt : userLastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime?,supportLastReadAt: freezed == supportLastReadAt ? _self.supportLastReadAt : supportLastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as SupportTicketCategory?,internalNotes: freezed == internalNotes ? _self.internalNotes : internalNotes // ignore: cast_nullable_to_non_nullable
as String?,internalNotesUpdatedAt: freezed == internalNotesUpdatedAt ? _self.internalNotesUpdatedAt : internalNotesUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,internalNotesUpdatedBy: freezed == internalNotesUpdatedBy ? _self.internalNotesUpdatedBy : internalNotesUpdatedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
