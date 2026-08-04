// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'campaign_application.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CampaignApplication {

 String get id; String get campaignId; String get campaignTitle; String get creatorId; String get creatorName; String get brandId; ApplicationStatus get status;@NullableTimestampConverter() DateTime? get appliedAt; String? get agreedDeliverablesSummary; int? get agreedBudget;
/// Create a copy of CampaignApplication
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CampaignApplicationCopyWith<CampaignApplication> get copyWith => _$CampaignApplicationCopyWithImpl<CampaignApplication>(this as CampaignApplication, _$identity);

  /// Serializes this CampaignApplication to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CampaignApplication&&(identical(other.id, id) || other.id == id)&&(identical(other.campaignId, campaignId) || other.campaignId == campaignId)&&(identical(other.campaignTitle, campaignTitle) || other.campaignTitle == campaignTitle)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.creatorName, creatorName) || other.creatorName == creatorName)&&(identical(other.brandId, brandId) || other.brandId == brandId)&&(identical(other.status, status) || other.status == status)&&(identical(other.appliedAt, appliedAt) || other.appliedAt == appliedAt)&&(identical(other.agreedDeliverablesSummary, agreedDeliverablesSummary) || other.agreedDeliverablesSummary == agreedDeliverablesSummary)&&(identical(other.agreedBudget, agreedBudget) || other.agreedBudget == agreedBudget));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,campaignId,campaignTitle,creatorId,creatorName,brandId,status,appliedAt,agreedDeliverablesSummary,agreedBudget);

@override
String toString() {
  return 'CampaignApplication(id: $id, campaignId: $campaignId, campaignTitle: $campaignTitle, creatorId: $creatorId, creatorName: $creatorName, brandId: $brandId, status: $status, appliedAt: $appliedAt, agreedDeliverablesSummary: $agreedDeliverablesSummary, agreedBudget: $agreedBudget)';
}


}

/// @nodoc
abstract mixin class $CampaignApplicationCopyWith<$Res>  {
  factory $CampaignApplicationCopyWith(CampaignApplication value, $Res Function(CampaignApplication) _then) = _$CampaignApplicationCopyWithImpl;
@useResult
$Res call({
 String id, String campaignId, String campaignTitle, String creatorId, String creatorName, String brandId, ApplicationStatus status,@NullableTimestampConverter() DateTime? appliedAt, String? agreedDeliverablesSummary, int? agreedBudget
});




}
/// @nodoc
class _$CampaignApplicationCopyWithImpl<$Res>
    implements $CampaignApplicationCopyWith<$Res> {
  _$CampaignApplicationCopyWithImpl(this._self, this._then);

  final CampaignApplication _self;
  final $Res Function(CampaignApplication) _then;

/// Create a copy of CampaignApplication
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? campaignId = null,Object? campaignTitle = null,Object? creatorId = null,Object? creatorName = null,Object? brandId = null,Object? status = null,Object? appliedAt = freezed,Object? agreedDeliverablesSummary = freezed,Object? agreedBudget = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,campaignId: null == campaignId ? _self.campaignId : campaignId // ignore: cast_nullable_to_non_nullable
as String,campaignTitle: null == campaignTitle ? _self.campaignTitle : campaignTitle // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,creatorName: null == creatorName ? _self.creatorName : creatorName // ignore: cast_nullable_to_non_nullable
as String,brandId: null == brandId ? _self.brandId : brandId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ApplicationStatus,appliedAt: freezed == appliedAt ? _self.appliedAt : appliedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,agreedDeliverablesSummary: freezed == agreedDeliverablesSummary ? _self.agreedDeliverablesSummary : agreedDeliverablesSummary // ignore: cast_nullable_to_non_nullable
as String?,agreedBudget: freezed == agreedBudget ? _self.agreedBudget : agreedBudget // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CampaignApplication].
extension CampaignApplicationPatterns on CampaignApplication {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CampaignApplication value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CampaignApplication() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CampaignApplication value)  $default,){
final _that = this;
switch (_that) {
case _CampaignApplication():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CampaignApplication value)?  $default,){
final _that = this;
switch (_that) {
case _CampaignApplication() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String campaignId,  String campaignTitle,  String creatorId,  String creatorName,  String brandId,  ApplicationStatus status, @NullableTimestampConverter()  DateTime? appliedAt,  String? agreedDeliverablesSummary,  int? agreedBudget)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CampaignApplication() when $default != null:
return $default(_that.id,_that.campaignId,_that.campaignTitle,_that.creatorId,_that.creatorName,_that.brandId,_that.status,_that.appliedAt,_that.agreedDeliverablesSummary,_that.agreedBudget);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String campaignId,  String campaignTitle,  String creatorId,  String creatorName,  String brandId,  ApplicationStatus status, @NullableTimestampConverter()  DateTime? appliedAt,  String? agreedDeliverablesSummary,  int? agreedBudget)  $default,) {final _that = this;
switch (_that) {
case _CampaignApplication():
return $default(_that.id,_that.campaignId,_that.campaignTitle,_that.creatorId,_that.creatorName,_that.brandId,_that.status,_that.appliedAt,_that.agreedDeliverablesSummary,_that.agreedBudget);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String campaignId,  String campaignTitle,  String creatorId,  String creatorName,  String brandId,  ApplicationStatus status, @NullableTimestampConverter()  DateTime? appliedAt,  String? agreedDeliverablesSummary,  int? agreedBudget)?  $default,) {final _that = this;
switch (_that) {
case _CampaignApplication() when $default != null:
return $default(_that.id,_that.campaignId,_that.campaignTitle,_that.creatorId,_that.creatorName,_that.brandId,_that.status,_that.appliedAt,_that.agreedDeliverablesSummary,_that.agreedBudget);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CampaignApplication implements CampaignApplication {
  const _CampaignApplication({required this.id, required this.campaignId, required this.campaignTitle, required this.creatorId, required this.creatorName, required this.brandId, this.status = ApplicationStatus.pending, @NullableTimestampConverter() this.appliedAt, this.agreedDeliverablesSummary, this.agreedBudget});
  factory _CampaignApplication.fromJson(Map<String, dynamic> json) => _$CampaignApplicationFromJson(json);

@override final  String id;
@override final  String campaignId;
@override final  String campaignTitle;
@override final  String creatorId;
@override final  String creatorName;
@override final  String brandId;
@override@JsonKey() final  ApplicationStatus status;
@override@NullableTimestampConverter() final  DateTime? appliedAt;
@override final  String? agreedDeliverablesSummary;
@override final  int? agreedBudget;

/// Create a copy of CampaignApplication
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CampaignApplicationCopyWith<_CampaignApplication> get copyWith => __$CampaignApplicationCopyWithImpl<_CampaignApplication>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CampaignApplicationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CampaignApplication&&(identical(other.id, id) || other.id == id)&&(identical(other.campaignId, campaignId) || other.campaignId == campaignId)&&(identical(other.campaignTitle, campaignTitle) || other.campaignTitle == campaignTitle)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.creatorName, creatorName) || other.creatorName == creatorName)&&(identical(other.brandId, brandId) || other.brandId == brandId)&&(identical(other.status, status) || other.status == status)&&(identical(other.appliedAt, appliedAt) || other.appliedAt == appliedAt)&&(identical(other.agreedDeliverablesSummary, agreedDeliverablesSummary) || other.agreedDeliverablesSummary == agreedDeliverablesSummary)&&(identical(other.agreedBudget, agreedBudget) || other.agreedBudget == agreedBudget));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,campaignId,campaignTitle,creatorId,creatorName,brandId,status,appliedAt,agreedDeliverablesSummary,agreedBudget);

@override
String toString() {
  return 'CampaignApplication(id: $id, campaignId: $campaignId, campaignTitle: $campaignTitle, creatorId: $creatorId, creatorName: $creatorName, brandId: $brandId, status: $status, appliedAt: $appliedAt, agreedDeliverablesSummary: $agreedDeliverablesSummary, agreedBudget: $agreedBudget)';
}


}

/// @nodoc
abstract mixin class _$CampaignApplicationCopyWith<$Res> implements $CampaignApplicationCopyWith<$Res> {
  factory _$CampaignApplicationCopyWith(_CampaignApplication value, $Res Function(_CampaignApplication) _then) = __$CampaignApplicationCopyWithImpl;
@override @useResult
$Res call({
 String id, String campaignId, String campaignTitle, String creatorId, String creatorName, String brandId, ApplicationStatus status,@NullableTimestampConverter() DateTime? appliedAt, String? agreedDeliverablesSummary, int? agreedBudget
});




}
/// @nodoc
class __$CampaignApplicationCopyWithImpl<$Res>
    implements _$CampaignApplicationCopyWith<$Res> {
  __$CampaignApplicationCopyWithImpl(this._self, this._then);

  final _CampaignApplication _self;
  final $Res Function(_CampaignApplication) _then;

/// Create a copy of CampaignApplication
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? campaignId = null,Object? campaignTitle = null,Object? creatorId = null,Object? creatorName = null,Object? brandId = null,Object? status = null,Object? appliedAt = freezed,Object? agreedDeliverablesSummary = freezed,Object? agreedBudget = freezed,}) {
  return _then(_CampaignApplication(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,campaignId: null == campaignId ? _self.campaignId : campaignId // ignore: cast_nullable_to_non_nullable
as String,campaignTitle: null == campaignTitle ? _self.campaignTitle : campaignTitle // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,creatorName: null == creatorName ? _self.creatorName : creatorName // ignore: cast_nullable_to_non_nullable
as String,brandId: null == brandId ? _self.brandId : brandId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ApplicationStatus,appliedAt: freezed == appliedAt ? _self.appliedAt : appliedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,agreedDeliverablesSummary: freezed == agreedDeliverablesSummary ? _self.agreedDeliverablesSummary : agreedDeliverablesSummary // ignore: cast_nullable_to_non_nullable
as String?,agreedBudget: freezed == agreedBudget ? _self.agreedBudget : agreedBudget // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
