// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deliverable.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Deliverable {

 String get id; String get campaignId; String get applicationId; String get creatorId; String get creatorName; String get brandId; DeliverableStatus get status; String? get submissionNote;@NullableTimestampConverter() DateTime? get submittedAt;@NullableTimestampConverter() DateTime? get reviewedAt;
/// Create a copy of Deliverable
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliverableCopyWith<Deliverable> get copyWith => _$DeliverableCopyWithImpl<Deliverable>(this as Deliverable, _$identity);

  /// Serializes this Deliverable to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Deliverable&&(identical(other.id, id) || other.id == id)&&(identical(other.campaignId, campaignId) || other.campaignId == campaignId)&&(identical(other.applicationId, applicationId) || other.applicationId == applicationId)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.creatorName, creatorName) || other.creatorName == creatorName)&&(identical(other.brandId, brandId) || other.brandId == brandId)&&(identical(other.status, status) || other.status == status)&&(identical(other.submissionNote, submissionNote) || other.submissionNote == submissionNote)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,campaignId,applicationId,creatorId,creatorName,brandId,status,submissionNote,submittedAt,reviewedAt);

@override
String toString() {
  return 'Deliverable(id: $id, campaignId: $campaignId, applicationId: $applicationId, creatorId: $creatorId, creatorName: $creatorName, brandId: $brandId, status: $status, submissionNote: $submissionNote, submittedAt: $submittedAt, reviewedAt: $reviewedAt)';
}


}

/// @nodoc
abstract mixin class $DeliverableCopyWith<$Res>  {
  factory $DeliverableCopyWith(Deliverable value, $Res Function(Deliverable) _then) = _$DeliverableCopyWithImpl;
@useResult
$Res call({
 String id, String campaignId, String applicationId, String creatorId, String creatorName, String brandId, DeliverableStatus status, String? submissionNote,@NullableTimestampConverter() DateTime? submittedAt,@NullableTimestampConverter() DateTime? reviewedAt
});




}
/// @nodoc
class _$DeliverableCopyWithImpl<$Res>
    implements $DeliverableCopyWith<$Res> {
  _$DeliverableCopyWithImpl(this._self, this._then);

  final Deliverable _self;
  final $Res Function(Deliverable) _then;

/// Create a copy of Deliverable
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? campaignId = null,Object? applicationId = null,Object? creatorId = null,Object? creatorName = null,Object? brandId = null,Object? status = null,Object? submissionNote = freezed,Object? submittedAt = freezed,Object? reviewedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,campaignId: null == campaignId ? _self.campaignId : campaignId // ignore: cast_nullable_to_non_nullable
as String,applicationId: null == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,creatorName: null == creatorName ? _self.creatorName : creatorName // ignore: cast_nullable_to_non_nullable
as String,brandId: null == brandId ? _self.brandId : brandId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeliverableStatus,submissionNote: freezed == submissionNote ? _self.submissionNote : submissionNote // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Deliverable].
extension DeliverablePatterns on Deliverable {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Deliverable value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Deliverable() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Deliverable value)  $default,){
final _that = this;
switch (_that) {
case _Deliverable():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Deliverable value)?  $default,){
final _that = this;
switch (_that) {
case _Deliverable() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String campaignId,  String applicationId,  String creatorId,  String creatorName,  String brandId,  DeliverableStatus status,  String? submissionNote, @NullableTimestampConverter()  DateTime? submittedAt, @NullableTimestampConverter()  DateTime? reviewedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Deliverable() when $default != null:
return $default(_that.id,_that.campaignId,_that.applicationId,_that.creatorId,_that.creatorName,_that.brandId,_that.status,_that.submissionNote,_that.submittedAt,_that.reviewedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String campaignId,  String applicationId,  String creatorId,  String creatorName,  String brandId,  DeliverableStatus status,  String? submissionNote, @NullableTimestampConverter()  DateTime? submittedAt, @NullableTimestampConverter()  DateTime? reviewedAt)  $default,) {final _that = this;
switch (_that) {
case _Deliverable():
return $default(_that.id,_that.campaignId,_that.applicationId,_that.creatorId,_that.creatorName,_that.brandId,_that.status,_that.submissionNote,_that.submittedAt,_that.reviewedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String campaignId,  String applicationId,  String creatorId,  String creatorName,  String brandId,  DeliverableStatus status,  String? submissionNote, @NullableTimestampConverter()  DateTime? submittedAt, @NullableTimestampConverter()  DateTime? reviewedAt)?  $default,) {final _that = this;
switch (_that) {
case _Deliverable() when $default != null:
return $default(_that.id,_that.campaignId,_that.applicationId,_that.creatorId,_that.creatorName,_that.brandId,_that.status,_that.submissionNote,_that.submittedAt,_that.reviewedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Deliverable implements Deliverable {
  const _Deliverable({required this.id, required this.campaignId, required this.applicationId, required this.creatorId, required this.creatorName, required this.brandId, this.status = DeliverableStatus.pending, this.submissionNote, @NullableTimestampConverter() this.submittedAt, @NullableTimestampConverter() this.reviewedAt});
  factory _Deliverable.fromJson(Map<String, dynamic> json) => _$DeliverableFromJson(json);

@override final  String id;
@override final  String campaignId;
@override final  String applicationId;
@override final  String creatorId;
@override final  String creatorName;
@override final  String brandId;
@override@JsonKey() final  DeliverableStatus status;
@override final  String? submissionNote;
@override@NullableTimestampConverter() final  DateTime? submittedAt;
@override@NullableTimestampConverter() final  DateTime? reviewedAt;

/// Create a copy of Deliverable
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliverableCopyWith<_Deliverable> get copyWith => __$DeliverableCopyWithImpl<_Deliverable>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeliverableToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Deliverable&&(identical(other.id, id) || other.id == id)&&(identical(other.campaignId, campaignId) || other.campaignId == campaignId)&&(identical(other.applicationId, applicationId) || other.applicationId == applicationId)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.creatorName, creatorName) || other.creatorName == creatorName)&&(identical(other.brandId, brandId) || other.brandId == brandId)&&(identical(other.status, status) || other.status == status)&&(identical(other.submissionNote, submissionNote) || other.submissionNote == submissionNote)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,campaignId,applicationId,creatorId,creatorName,brandId,status,submissionNote,submittedAt,reviewedAt);

@override
String toString() {
  return 'Deliverable(id: $id, campaignId: $campaignId, applicationId: $applicationId, creatorId: $creatorId, creatorName: $creatorName, brandId: $brandId, status: $status, submissionNote: $submissionNote, submittedAt: $submittedAt, reviewedAt: $reviewedAt)';
}


}

/// @nodoc
abstract mixin class _$DeliverableCopyWith<$Res> implements $DeliverableCopyWith<$Res> {
  factory _$DeliverableCopyWith(_Deliverable value, $Res Function(_Deliverable) _then) = __$DeliverableCopyWithImpl;
@override @useResult
$Res call({
 String id, String campaignId, String applicationId, String creatorId, String creatorName, String brandId, DeliverableStatus status, String? submissionNote,@NullableTimestampConverter() DateTime? submittedAt,@NullableTimestampConverter() DateTime? reviewedAt
});




}
/// @nodoc
class __$DeliverableCopyWithImpl<$Res>
    implements _$DeliverableCopyWith<$Res> {
  __$DeliverableCopyWithImpl(this._self, this._then);

  final _Deliverable _self;
  final $Res Function(_Deliverable) _then;

/// Create a copy of Deliverable
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? campaignId = null,Object? applicationId = null,Object? creatorId = null,Object? creatorName = null,Object? brandId = null,Object? status = null,Object? submissionNote = freezed,Object? submittedAt = freezed,Object? reviewedAt = freezed,}) {
  return _then(_Deliverable(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,campaignId: null == campaignId ? _self.campaignId : campaignId // ignore: cast_nullable_to_non_nullable
as String,applicationId: null == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,creatorName: null == creatorName ? _self.creatorName : creatorName // ignore: cast_nullable_to_non_nullable
as String,brandId: null == brandId ? _self.brandId : brandId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeliverableStatus,submissionNote: freezed == submissionNote ? _self.submissionNote : submissionNote // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
