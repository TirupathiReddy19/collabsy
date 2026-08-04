// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'block.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Block {

 String get id; String get blockerId; UserRole get blockerRole; String get blockedId; UserRole get blockedRole;@NullableTimestampConverter() DateTime? get createdAt;
/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BlockCopyWith<Block> get copyWith => _$BlockCopyWithImpl<Block>(this as Block, _$identity);

  /// Serializes this Block to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Block&&(identical(other.id, id) || other.id == id)&&(identical(other.blockerId, blockerId) || other.blockerId == blockerId)&&(identical(other.blockerRole, blockerRole) || other.blockerRole == blockerRole)&&(identical(other.blockedId, blockedId) || other.blockedId == blockedId)&&(identical(other.blockedRole, blockedRole) || other.blockedRole == blockedRole)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,blockerId,blockerRole,blockedId,blockedRole,createdAt);

@override
String toString() {
  return 'Block(id: $id, blockerId: $blockerId, blockerRole: $blockerRole, blockedId: $blockedId, blockedRole: $blockedRole, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BlockCopyWith<$Res>  {
  factory $BlockCopyWith(Block value, $Res Function(Block) _then) = _$BlockCopyWithImpl;
@useResult
$Res call({
 String id, String blockerId, UserRole blockerRole, String blockedId, UserRole blockedRole,@NullableTimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class _$BlockCopyWithImpl<$Res>
    implements $BlockCopyWith<$Res> {
  _$BlockCopyWithImpl(this._self, this._then);

  final Block _self;
  final $Res Function(Block) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? blockerId = null,Object? blockerRole = null,Object? blockedId = null,Object? blockedRole = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,blockerId: null == blockerId ? _self.blockerId : blockerId // ignore: cast_nullable_to_non_nullable
as String,blockerRole: null == blockerRole ? _self.blockerRole : blockerRole // ignore: cast_nullable_to_non_nullable
as UserRole,blockedId: null == blockedId ? _self.blockedId : blockedId // ignore: cast_nullable_to_non_nullable
as String,blockedRole: null == blockedRole ? _self.blockedRole : blockedRole // ignore: cast_nullable_to_non_nullable
as UserRole,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Block].
extension BlockPatterns on Block {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Block value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Block() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Block value)  $default,){
final _that = this;
switch (_that) {
case _Block():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Block value)?  $default,){
final _that = this;
switch (_that) {
case _Block() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String blockerId,  UserRole blockerRole,  String blockedId,  UserRole blockedRole, @NullableTimestampConverter()  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Block() when $default != null:
return $default(_that.id,_that.blockerId,_that.blockerRole,_that.blockedId,_that.blockedRole,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String blockerId,  UserRole blockerRole,  String blockedId,  UserRole blockedRole, @NullableTimestampConverter()  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Block():
return $default(_that.id,_that.blockerId,_that.blockerRole,_that.blockedId,_that.blockedRole,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String blockerId,  UserRole blockerRole,  String blockedId,  UserRole blockedRole, @NullableTimestampConverter()  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Block() when $default != null:
return $default(_that.id,_that.blockerId,_that.blockerRole,_that.blockedId,_that.blockedRole,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Block implements Block {
  const _Block({required this.id, required this.blockerId, required this.blockerRole, required this.blockedId, required this.blockedRole, @NullableTimestampConverter() this.createdAt});
  factory _Block.fromJson(Map<String, dynamic> json) => _$BlockFromJson(json);

@override final  String id;
@override final  String blockerId;
@override final  UserRole blockerRole;
@override final  String blockedId;
@override final  UserRole blockedRole;
@override@NullableTimestampConverter() final  DateTime? createdAt;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BlockCopyWith<_Block> get copyWith => __$BlockCopyWithImpl<_Block>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BlockToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Block&&(identical(other.id, id) || other.id == id)&&(identical(other.blockerId, blockerId) || other.blockerId == blockerId)&&(identical(other.blockerRole, blockerRole) || other.blockerRole == blockerRole)&&(identical(other.blockedId, blockedId) || other.blockedId == blockedId)&&(identical(other.blockedRole, blockedRole) || other.blockedRole == blockedRole)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,blockerId,blockerRole,blockedId,blockedRole,createdAt);

@override
String toString() {
  return 'Block(id: $id, blockerId: $blockerId, blockerRole: $blockerRole, blockedId: $blockedId, blockedRole: $blockedRole, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BlockCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory _$BlockCopyWith(_Block value, $Res Function(_Block) _then) = __$BlockCopyWithImpl;
@override @useResult
$Res call({
 String id, String blockerId, UserRole blockerRole, String blockedId, UserRole blockedRole,@NullableTimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class __$BlockCopyWithImpl<$Res>
    implements _$BlockCopyWith<$Res> {
  __$BlockCopyWithImpl(this._self, this._then);

  final _Block _self;
  final $Res Function(_Block) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? blockerId = null,Object? blockerRole = null,Object? blockedId = null,Object? blockedRole = null,Object? createdAt = freezed,}) {
  return _then(_Block(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,blockerId: null == blockerId ? _self.blockerId : blockerId // ignore: cast_nullable_to_non_nullable
as String,blockerRole: null == blockerRole ? _self.blockerRole : blockerRole // ignore: cast_nullable_to_non_nullable
as UserRole,blockedId: null == blockedId ? _self.blockedId : blockedId // ignore: cast_nullable_to_non_nullable
as String,blockedRole: null == blockedRole ? _self.blockedRole : blockedRole // ignore: cast_nullable_to_non_nullable
as UserRole,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
