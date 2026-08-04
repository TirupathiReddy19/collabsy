/// Whether a creator matches a broadcast's targeting criteria — shared by
/// the Creator-side filter (`myAnnouncementsProvider`) and the Admin's
/// live "~N creators match" preview/seen-count denominator. Takes plain
/// values rather than model types so both sides can pass in whatever
/// they already have on hand.
bool matchesAudience({
  required String targetType,
  List<String>? targetCategories,
  int? targetMinFollowers,
  int? targetMaxFollowers,
  String? targetCreatorId,
  required String creatorId,
  required List<String> creatorCategories,
  int? creatorFollowers,
}) => switch (targetType) {
  'creator' => targetCreatorId == creatorId,
  'category' =>
    (targetCategories ?? const []).isEmpty ||
        creatorCategories.any((targetCategories ?? const []).contains),
  'followerRange' =>
    (targetMinFollowers == null ||
            (creatorFollowers ?? 0) >= targetMinFollowers) &&
        (targetMaxFollowers == null ||
            (creatorFollowers ?? 0) <= targetMaxFollowers),
  _ => true,
};

/// Whether a brand matches a broadcast's targeting criteria — the Brand
/// counterpart of [matchesAudience], used the same way (Brand-side filter
/// on `myAnnouncementsProvider`, Admin's live "~N brands match" preview and
/// "seen by" denominator).
bool matchesBrandAudience({
  required String targetType,
  List<String>? targetCategories,
  String? targetCompanySize,
  String? targetBrandId,
  required String brandId,
  required List<String> brandCategories,
  String? brandCompanySize,
}) => switch (targetType) {
  'brand' => targetBrandId == brandId,
  'category' =>
    (targetCategories ?? const []).isEmpty ||
        brandCategories.any((targetCategories ?? const []).contains),
  'companySize' =>
    targetCompanySize == null || targetCompanySize == brandCompanySize,
  _ => true,
};
