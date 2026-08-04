// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'campaign.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Campaign {

 String get id; String get brandId; String get brandName; String get title; String get description; List<String> get categories; String? get goal; String? get targetLocation; List<String> get targetLocations; int? get minFollowers; int? get maxFollowers; int? get creatorsNeeded; DeliverableType get deliverableType; int get instagramStoryCount; int get instagramPostCount; CompensationType get compensationType; int? get budget; String? get barterDescription; String? get state; String? get city;@NullableTimestampConverter() DateTime? get startDate;@NullableTimestampConverter() DateTime? get endDate; String? get acceptanceMessage; String? get rejectionMessage; CampaignStatus get status;@NullableTimestampConverter() DateTime? get createdAt; List<String> get viewedByCreatorIds; int get viewCount;
/// Create a copy of Campaign
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CampaignCopyWith<Campaign> get copyWith => _$CampaignCopyWithImpl<Campaign>(this as Campaign, _$identity);

  /// Serializes this Campaign to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Campaign&&(identical(other.id, id) || other.id == id)&&(identical(other.brandId, brandId) || other.brandId == brandId)&&(identical(other.brandName, brandName) || other.brandName == brandName)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.categories, categories)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.targetLocation, targetLocation) || other.targetLocation == targetLocation)&&const DeepCollectionEquality().equals(other.targetLocations, targetLocations)&&(identical(other.minFollowers, minFollowers) || other.minFollowers == minFollowers)&&(identical(other.maxFollowers, maxFollowers) || other.maxFollowers == maxFollowers)&&(identical(other.creatorsNeeded, creatorsNeeded) || other.creatorsNeeded == creatorsNeeded)&&(identical(other.deliverableType, deliverableType) || other.deliverableType == deliverableType)&&(identical(other.instagramStoryCount, instagramStoryCount) || other.instagramStoryCount == instagramStoryCount)&&(identical(other.instagramPostCount, instagramPostCount) || other.instagramPostCount == instagramPostCount)&&(identical(other.compensationType, compensationType) || other.compensationType == compensationType)&&(identical(other.budget, budget) || other.budget == budget)&&(identical(other.barterDescription, barterDescription) || other.barterDescription == barterDescription)&&(identical(other.state, state) || other.state == state)&&(identical(other.city, city) || other.city == city)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.acceptanceMessage, acceptanceMessage) || other.acceptanceMessage == acceptanceMessage)&&(identical(other.rejectionMessage, rejectionMessage) || other.rejectionMessage == rejectionMessage)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.viewedByCreatorIds, viewedByCreatorIds)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,brandId,brandName,title,description,const DeepCollectionEquality().hash(categories),goal,targetLocation,const DeepCollectionEquality().hash(targetLocations),minFollowers,maxFollowers,creatorsNeeded,deliverableType,instagramStoryCount,instagramPostCount,compensationType,budget,barterDescription,state,city,startDate,endDate,acceptanceMessage,rejectionMessage,status,createdAt,const DeepCollectionEquality().hash(viewedByCreatorIds),viewCount]);

@override
String toString() {
  return 'Campaign(id: $id, brandId: $brandId, brandName: $brandName, title: $title, description: $description, categories: $categories, goal: $goal, targetLocation: $targetLocation, targetLocations: $targetLocations, minFollowers: $minFollowers, maxFollowers: $maxFollowers, creatorsNeeded: $creatorsNeeded, deliverableType: $deliverableType, instagramStoryCount: $instagramStoryCount, instagramPostCount: $instagramPostCount, compensationType: $compensationType, budget: $budget, barterDescription: $barterDescription, state: $state, city: $city, startDate: $startDate, endDate: $endDate, acceptanceMessage: $acceptanceMessage, rejectionMessage: $rejectionMessage, status: $status, createdAt: $createdAt, viewedByCreatorIds: $viewedByCreatorIds, viewCount: $viewCount)';
}


}

/// @nodoc
abstract mixin class $CampaignCopyWith<$Res>  {
  factory $CampaignCopyWith(Campaign value, $Res Function(Campaign) _then) = _$CampaignCopyWithImpl;
@useResult
$Res call({
 String id, String brandId, String brandName, String title, String description, List<String> categories, String? goal, String? targetLocation, List<String> targetLocations, int? minFollowers, int? maxFollowers, int? creatorsNeeded, DeliverableType deliverableType, int instagramStoryCount, int instagramPostCount, CompensationType compensationType, int? budget, String? barterDescription, String? state, String? city,@NullableTimestampConverter() DateTime? startDate,@NullableTimestampConverter() DateTime? endDate, String? acceptanceMessage, String? rejectionMessage, CampaignStatus status,@NullableTimestampConverter() DateTime? createdAt, List<String> viewedByCreatorIds, int viewCount
});




}
/// @nodoc
class _$CampaignCopyWithImpl<$Res>
    implements $CampaignCopyWith<$Res> {
  _$CampaignCopyWithImpl(this._self, this._then);

  final Campaign _self;
  final $Res Function(Campaign) _then;

/// Create a copy of Campaign
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? brandId = null,Object? brandName = null,Object? title = null,Object? description = null,Object? categories = null,Object? goal = freezed,Object? targetLocation = freezed,Object? targetLocations = null,Object? minFollowers = freezed,Object? maxFollowers = freezed,Object? creatorsNeeded = freezed,Object? deliverableType = null,Object? instagramStoryCount = null,Object? instagramPostCount = null,Object? compensationType = null,Object? budget = freezed,Object? barterDescription = freezed,Object? state = freezed,Object? city = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? acceptanceMessage = freezed,Object? rejectionMessage = freezed,Object? status = null,Object? createdAt = freezed,Object? viewedByCreatorIds = null,Object? viewCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,brandId: null == brandId ? _self.brandId : brandId // ignore: cast_nullable_to_non_nullable
as String,brandName: null == brandName ? _self.brandName : brandName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,goal: freezed == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as String?,targetLocation: freezed == targetLocation ? _self.targetLocation : targetLocation // ignore: cast_nullable_to_non_nullable
as String?,targetLocations: null == targetLocations ? _self.targetLocations : targetLocations // ignore: cast_nullable_to_non_nullable
as List<String>,minFollowers: freezed == minFollowers ? _self.minFollowers : minFollowers // ignore: cast_nullable_to_non_nullable
as int?,maxFollowers: freezed == maxFollowers ? _self.maxFollowers : maxFollowers // ignore: cast_nullable_to_non_nullable
as int?,creatorsNeeded: freezed == creatorsNeeded ? _self.creatorsNeeded : creatorsNeeded // ignore: cast_nullable_to_non_nullable
as int?,deliverableType: null == deliverableType ? _self.deliverableType : deliverableType // ignore: cast_nullable_to_non_nullable
as DeliverableType,instagramStoryCount: null == instagramStoryCount ? _self.instagramStoryCount : instagramStoryCount // ignore: cast_nullable_to_non_nullable
as int,instagramPostCount: null == instagramPostCount ? _self.instagramPostCount : instagramPostCount // ignore: cast_nullable_to_non_nullable
as int,compensationType: null == compensationType ? _self.compensationType : compensationType // ignore: cast_nullable_to_non_nullable
as CompensationType,budget: freezed == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as int?,barterDescription: freezed == barterDescription ? _self.barterDescription : barterDescription // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,acceptanceMessage: freezed == acceptanceMessage ? _self.acceptanceMessage : acceptanceMessage // ignore: cast_nullable_to_non_nullable
as String?,rejectionMessage: freezed == rejectionMessage ? _self.rejectionMessage : rejectionMessage // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CampaignStatus,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,viewedByCreatorIds: null == viewedByCreatorIds ? _self.viewedByCreatorIds : viewedByCreatorIds // ignore: cast_nullable_to_non_nullable
as List<String>,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Campaign].
extension CampaignPatterns on Campaign {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Campaign value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Campaign() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Campaign value)  $default,){
final _that = this;
switch (_that) {
case _Campaign():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Campaign value)?  $default,){
final _that = this;
switch (_that) {
case _Campaign() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String brandId,  String brandName,  String title,  String description,  List<String> categories,  String? goal,  String? targetLocation,  List<String> targetLocations,  int? minFollowers,  int? maxFollowers,  int? creatorsNeeded,  DeliverableType deliverableType,  int instagramStoryCount,  int instagramPostCount,  CompensationType compensationType,  int? budget,  String? barterDescription,  String? state,  String? city, @NullableTimestampConverter()  DateTime? startDate, @NullableTimestampConverter()  DateTime? endDate,  String? acceptanceMessage,  String? rejectionMessage,  CampaignStatus status, @NullableTimestampConverter()  DateTime? createdAt,  List<String> viewedByCreatorIds,  int viewCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Campaign() when $default != null:
return $default(_that.id,_that.brandId,_that.brandName,_that.title,_that.description,_that.categories,_that.goal,_that.targetLocation,_that.targetLocations,_that.minFollowers,_that.maxFollowers,_that.creatorsNeeded,_that.deliverableType,_that.instagramStoryCount,_that.instagramPostCount,_that.compensationType,_that.budget,_that.barterDescription,_that.state,_that.city,_that.startDate,_that.endDate,_that.acceptanceMessage,_that.rejectionMessage,_that.status,_that.createdAt,_that.viewedByCreatorIds,_that.viewCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String brandId,  String brandName,  String title,  String description,  List<String> categories,  String? goal,  String? targetLocation,  List<String> targetLocations,  int? minFollowers,  int? maxFollowers,  int? creatorsNeeded,  DeliverableType deliverableType,  int instagramStoryCount,  int instagramPostCount,  CompensationType compensationType,  int? budget,  String? barterDescription,  String? state,  String? city, @NullableTimestampConverter()  DateTime? startDate, @NullableTimestampConverter()  DateTime? endDate,  String? acceptanceMessage,  String? rejectionMessage,  CampaignStatus status, @NullableTimestampConverter()  DateTime? createdAt,  List<String> viewedByCreatorIds,  int viewCount)  $default,) {final _that = this;
switch (_that) {
case _Campaign():
return $default(_that.id,_that.brandId,_that.brandName,_that.title,_that.description,_that.categories,_that.goal,_that.targetLocation,_that.targetLocations,_that.minFollowers,_that.maxFollowers,_that.creatorsNeeded,_that.deliverableType,_that.instagramStoryCount,_that.instagramPostCount,_that.compensationType,_that.budget,_that.barterDescription,_that.state,_that.city,_that.startDate,_that.endDate,_that.acceptanceMessage,_that.rejectionMessage,_that.status,_that.createdAt,_that.viewedByCreatorIds,_that.viewCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String brandId,  String brandName,  String title,  String description,  List<String> categories,  String? goal,  String? targetLocation,  List<String> targetLocations,  int? minFollowers,  int? maxFollowers,  int? creatorsNeeded,  DeliverableType deliverableType,  int instagramStoryCount,  int instagramPostCount,  CompensationType compensationType,  int? budget,  String? barterDescription,  String? state,  String? city, @NullableTimestampConverter()  DateTime? startDate, @NullableTimestampConverter()  DateTime? endDate,  String? acceptanceMessage,  String? rejectionMessage,  CampaignStatus status, @NullableTimestampConverter()  DateTime? createdAt,  List<String> viewedByCreatorIds,  int viewCount)?  $default,) {final _that = this;
switch (_that) {
case _Campaign() when $default != null:
return $default(_that.id,_that.brandId,_that.brandName,_that.title,_that.description,_that.categories,_that.goal,_that.targetLocation,_that.targetLocations,_that.minFollowers,_that.maxFollowers,_that.creatorsNeeded,_that.deliverableType,_that.instagramStoryCount,_that.instagramPostCount,_that.compensationType,_that.budget,_that.barterDescription,_that.state,_that.city,_that.startDate,_that.endDate,_that.acceptanceMessage,_that.rejectionMessage,_that.status,_that.createdAt,_that.viewedByCreatorIds,_that.viewCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Campaign extends Campaign {
  const _Campaign({required this.id, required this.brandId, required this.brandName, required this.title, required this.description, final  List<String> categories = const <String>[], this.goal, this.targetLocation, final  List<String> targetLocations = const <String>[], this.minFollowers, this.maxFollowers, this.creatorsNeeded, required this.deliverableType, this.instagramStoryCount = 0, this.instagramPostCount = 0, this.compensationType = CompensationType.cash, this.budget, this.barterDescription, this.state, this.city, @NullableTimestampConverter() this.startDate, @NullableTimestampConverter() this.endDate, this.acceptanceMessage, this.rejectionMessage, this.status = CampaignStatus.draft, @NullableTimestampConverter() this.createdAt, final  List<String> viewedByCreatorIds = const <String>[], this.viewCount = 0}): _categories = categories,_targetLocations = targetLocations,_viewedByCreatorIds = viewedByCreatorIds,super._();
  factory _Campaign.fromJson(Map<String, dynamic> json) => _$CampaignFromJson(json);

@override final  String id;
@override final  String brandId;
@override final  String brandName;
@override final  String title;
@override final  String description;
 final  List<String> _categories;
@override@JsonKey() List<String> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

@override final  String? goal;
@override final  String? targetLocation;
 final  List<String> _targetLocations;
@override@JsonKey() List<String> get targetLocations {
  if (_targetLocations is EqualUnmodifiableListView) return _targetLocations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_targetLocations);
}

@override final  int? minFollowers;
@override final  int? maxFollowers;
@override final  int? creatorsNeeded;
@override final  DeliverableType deliverableType;
@override@JsonKey() final  int instagramStoryCount;
@override@JsonKey() final  int instagramPostCount;
@override@JsonKey() final  CompensationType compensationType;
@override final  int? budget;
@override final  String? barterDescription;
@override final  String? state;
@override final  String? city;
@override@NullableTimestampConverter() final  DateTime? startDate;
@override@NullableTimestampConverter() final  DateTime? endDate;
@override final  String? acceptanceMessage;
@override final  String? rejectionMessage;
@override@JsonKey() final  CampaignStatus status;
@override@NullableTimestampConverter() final  DateTime? createdAt;
 final  List<String> _viewedByCreatorIds;
@override@JsonKey() List<String> get viewedByCreatorIds {
  if (_viewedByCreatorIds is EqualUnmodifiableListView) return _viewedByCreatorIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_viewedByCreatorIds);
}

@override@JsonKey() final  int viewCount;

/// Create a copy of Campaign
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CampaignCopyWith<_Campaign> get copyWith => __$CampaignCopyWithImpl<_Campaign>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CampaignToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Campaign&&(identical(other.id, id) || other.id == id)&&(identical(other.brandId, brandId) || other.brandId == brandId)&&(identical(other.brandName, brandName) || other.brandName == brandName)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._categories, _categories)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.targetLocation, targetLocation) || other.targetLocation == targetLocation)&&const DeepCollectionEquality().equals(other._targetLocations, _targetLocations)&&(identical(other.minFollowers, minFollowers) || other.minFollowers == minFollowers)&&(identical(other.maxFollowers, maxFollowers) || other.maxFollowers == maxFollowers)&&(identical(other.creatorsNeeded, creatorsNeeded) || other.creatorsNeeded == creatorsNeeded)&&(identical(other.deliverableType, deliverableType) || other.deliverableType == deliverableType)&&(identical(other.instagramStoryCount, instagramStoryCount) || other.instagramStoryCount == instagramStoryCount)&&(identical(other.instagramPostCount, instagramPostCount) || other.instagramPostCount == instagramPostCount)&&(identical(other.compensationType, compensationType) || other.compensationType == compensationType)&&(identical(other.budget, budget) || other.budget == budget)&&(identical(other.barterDescription, barterDescription) || other.barterDescription == barterDescription)&&(identical(other.state, state) || other.state == state)&&(identical(other.city, city) || other.city == city)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.acceptanceMessage, acceptanceMessage) || other.acceptanceMessage == acceptanceMessage)&&(identical(other.rejectionMessage, rejectionMessage) || other.rejectionMessage == rejectionMessage)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._viewedByCreatorIds, _viewedByCreatorIds)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,brandId,brandName,title,description,const DeepCollectionEquality().hash(_categories),goal,targetLocation,const DeepCollectionEquality().hash(_targetLocations),minFollowers,maxFollowers,creatorsNeeded,deliverableType,instagramStoryCount,instagramPostCount,compensationType,budget,barterDescription,state,city,startDate,endDate,acceptanceMessage,rejectionMessage,status,createdAt,const DeepCollectionEquality().hash(_viewedByCreatorIds),viewCount]);

@override
String toString() {
  return 'Campaign(id: $id, brandId: $brandId, brandName: $brandName, title: $title, description: $description, categories: $categories, goal: $goal, targetLocation: $targetLocation, targetLocations: $targetLocations, minFollowers: $minFollowers, maxFollowers: $maxFollowers, creatorsNeeded: $creatorsNeeded, deliverableType: $deliverableType, instagramStoryCount: $instagramStoryCount, instagramPostCount: $instagramPostCount, compensationType: $compensationType, budget: $budget, barterDescription: $barterDescription, state: $state, city: $city, startDate: $startDate, endDate: $endDate, acceptanceMessage: $acceptanceMessage, rejectionMessage: $rejectionMessage, status: $status, createdAt: $createdAt, viewedByCreatorIds: $viewedByCreatorIds, viewCount: $viewCount)';
}


}

/// @nodoc
abstract mixin class _$CampaignCopyWith<$Res> implements $CampaignCopyWith<$Res> {
  factory _$CampaignCopyWith(_Campaign value, $Res Function(_Campaign) _then) = __$CampaignCopyWithImpl;
@override @useResult
$Res call({
 String id, String brandId, String brandName, String title, String description, List<String> categories, String? goal, String? targetLocation, List<String> targetLocations, int? minFollowers, int? maxFollowers, int? creatorsNeeded, DeliverableType deliverableType, int instagramStoryCount, int instagramPostCount, CompensationType compensationType, int? budget, String? barterDescription, String? state, String? city,@NullableTimestampConverter() DateTime? startDate,@NullableTimestampConverter() DateTime? endDate, String? acceptanceMessage, String? rejectionMessage, CampaignStatus status,@NullableTimestampConverter() DateTime? createdAt, List<String> viewedByCreatorIds, int viewCount
});




}
/// @nodoc
class __$CampaignCopyWithImpl<$Res>
    implements _$CampaignCopyWith<$Res> {
  __$CampaignCopyWithImpl(this._self, this._then);

  final _Campaign _self;
  final $Res Function(_Campaign) _then;

/// Create a copy of Campaign
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? brandId = null,Object? brandName = null,Object? title = null,Object? description = null,Object? categories = null,Object? goal = freezed,Object? targetLocation = freezed,Object? targetLocations = null,Object? minFollowers = freezed,Object? maxFollowers = freezed,Object? creatorsNeeded = freezed,Object? deliverableType = null,Object? instagramStoryCount = null,Object? instagramPostCount = null,Object? compensationType = null,Object? budget = freezed,Object? barterDescription = freezed,Object? state = freezed,Object? city = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? acceptanceMessage = freezed,Object? rejectionMessage = freezed,Object? status = null,Object? createdAt = freezed,Object? viewedByCreatorIds = null,Object? viewCount = null,}) {
  return _then(_Campaign(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,brandId: null == brandId ? _self.brandId : brandId // ignore: cast_nullable_to_non_nullable
as String,brandName: null == brandName ? _self.brandName : brandName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,goal: freezed == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as String?,targetLocation: freezed == targetLocation ? _self.targetLocation : targetLocation // ignore: cast_nullable_to_non_nullable
as String?,targetLocations: null == targetLocations ? _self._targetLocations : targetLocations // ignore: cast_nullable_to_non_nullable
as List<String>,minFollowers: freezed == minFollowers ? _self.minFollowers : minFollowers // ignore: cast_nullable_to_non_nullable
as int?,maxFollowers: freezed == maxFollowers ? _self.maxFollowers : maxFollowers // ignore: cast_nullable_to_non_nullable
as int?,creatorsNeeded: freezed == creatorsNeeded ? _self.creatorsNeeded : creatorsNeeded // ignore: cast_nullable_to_non_nullable
as int?,deliverableType: null == deliverableType ? _self.deliverableType : deliverableType // ignore: cast_nullable_to_non_nullable
as DeliverableType,instagramStoryCount: null == instagramStoryCount ? _self.instagramStoryCount : instagramStoryCount // ignore: cast_nullable_to_non_nullable
as int,instagramPostCount: null == instagramPostCount ? _self.instagramPostCount : instagramPostCount // ignore: cast_nullable_to_non_nullable
as int,compensationType: null == compensationType ? _self.compensationType : compensationType // ignore: cast_nullable_to_non_nullable
as CompensationType,budget: freezed == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as int?,barterDescription: freezed == barterDescription ? _self.barterDescription : barterDescription // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,acceptanceMessage: freezed == acceptanceMessage ? _self.acceptanceMessage : acceptanceMessage // ignore: cast_nullable_to_non_nullable
as String?,rejectionMessage: freezed == rejectionMessage ? _self.rejectionMessage : rejectionMessage // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CampaignStatus,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,viewedByCreatorIds: null == viewedByCreatorIds ? _self._viewedByCreatorIds : viewedByCreatorIds // ignore: cast_nullable_to_non_nullable
as List<String>,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
