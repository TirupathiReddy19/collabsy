import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';
import '../../core/utils/campaign_categories.dart';
import '../../shared/models/brand_prospect.dart';

part 'admin_brand_prospects_providers.g.dart';

const _collection = 'brandProspects';

/// Per-category breakdown of the import pool — how many prospects in each
/// app category are still sitting unassigned, so admin knows what's left
/// to push out. `null` groups every prospect the one-time mapping script
/// couldn't confidently categorize; left out of push targets since there's
/// no single category to assign them under.
typedef BrandProspectCategoryCounts = ({
  String category,
  int unassigned,
  int assigned,
});

/// One page of `listByCategory` — [cursor] is `null` once there's nothing
/// left to load, otherwise it's the last doc read, to pass back in as the
/// next page's `startAfter`.
typedef BrandProspectPage = ({
  List<BrandProspect> prospects,
  DocumentSnapshot<Map<String, dynamic>>? cursor,
});

DateTime? _asDate(dynamic value) => value is Timestamp ? value.toDate() : null;

BrandProspect _prospectFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data()!;
  return (
    id: doc.id,
    brandName: data['brandName'] as String? ?? '',
    website: data['website'] as String?,
    category: data['category'] as String?,
    rawCategory: data['rawCategory'] as String?,
    location: data['location'] as String?,
    city: data['city'] as String?,
    teamSize: data['teamSize'] as String?,
    igFollowers: data['igFollowers'] as String?,
    monthlyVisits: data['monthlyVisits'] as String?,
    instagramUrl: data['instagramUrl'] as String?,
    linkedinUrl: data['linkedinUrl'] as String?,
    emails: List<String>.from((data['emails'] as List?) ?? const []),
    status: data['status'] as String? ?? 'unassigned',
    assignedTo: data['assignedTo'] as String?,
    assignedToEmail: data['assignedToEmail'] as String?,
    assignedAt: _asDate(data['assignedAt']),
    contacted: data['contacted'] as bool? ?? false,
    contactedAt: _asDate(data['contactedAt']),
  );
}

/// The only place that talks to the `brandProspects` collection directly.
/// Bulk import and category-to-intern assignment are both one-off, bursty
/// admin actions — not something worth a live `snapshots()` listener over
/// 30k+ docs — so this reads with plain `get()`/aggregate-count queries
/// instead of streaming the whole pool into the app.
class AdminBrandProspectsRepository {
  AdminBrandProspectsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(_collection);

  /// Writes every row from the prepared import JSON (see
  /// `prepare_brand_prospects.py`), 500 at a time. `onProgress` is called
  /// after each batch commits with the running total written, so the UI
  /// can show a progress bar across the ~70 batches a 34k-row file needs.
  Future<void> bulkImport(
    List<Map<String, dynamic>> rows, {
    void Function(int written, int total)? onProgress,
  }) async {
    const chunkSize = 500;
    var written = 0;
    for (var start = 0; start < rows.length; start += chunkSize) {
      final chunk = rows.sublist(
        start,
        start + chunkSize > rows.length ? rows.length : start + chunkSize,
      );
      final batch = _firestore.batch();
      for (final row in chunk) {
        final id = row['id'] as String;
        batch.set(_col.doc(id), {
          'brandName': row['brandName'],
          'website': row['website'],
          'category': row['category'],
          'rawCategory': row['rawCategory'],
          'location': row['location'],
          'city': row['city'],
          'teamSize': row['teamSize'],
          'igFollowers': row['igFollowers'],
          'monthlyVisits': row['monthlyVisits'],
          'instagramUrl': row['instagramUrl'],
          'linkedinUrl': row['linkedinUrl'],
          'emails': row['emails'],
          'status': 'unassigned',
          'contacted': false,
        });
      }
      await batch.commit();
      written += chunk.length;
      onProgress?.call(written, rows.length);
    }
  }

  /// Count of unassigned/assigned prospects for every app category, via
  /// aggregate `count()` queries — cheap even over a 30k-doc collection,
  /// since Firestore bills these as a handful of index reads, not one per
  /// document.
  Future<List<BrandProspectCategoryCounts>> categoryBreakdown() async {
    final results = <BrandProspectCategoryCounts>[];
    for (final category in campaignCategories) {
      final unassigned = await _col
          .where('category', isEqualTo: category)
          .where('status', isEqualTo: 'unassigned')
          .count()
          .get();
      final assigned = await _col
          .where('category', isEqualTo: category)
          .where('status', isEqualTo: 'assigned')
          .count()
          .get();
      results.add((
        category: category,
        unassigned: unassigned.count ?? 0,
        assigned: assigned.count ?? 0,
      ));
    }
    return results;
  }

  Future<int> totalImported() async {
    final result = await _col.count().get();
    return result.count ?? 0;
  }

  /// One page of individual prospects in [category] — the admin "View
  /// prospects" browser, so admin can see each brand's website, email(s),
  /// Instagram, and LinkedIn before deciding what to push. Deliberately
  /// paginated (never a live listener) since a single category can hold
  /// upwards of 10k docs. [status] narrows to `'unassigned'`/`'assigned'`;
  /// `null` shows both. Pass the previous page's `cursor` back as
  /// [startAfter] to keep paging.
  Future<BrandProspectPage> listByCategory({
    required String category,
    String? status,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
    int pageSize = 50,
  }) async {
    Query<Map<String, dynamic>> query = _col.where(
      'category',
      isEqualTo: category,
    );
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    query = query.orderBy(FieldPath.documentId).limit(pageSize);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    final snapshot = await query.get();
    return (
      prospects: snapshot.docs.map(_prospectFromDoc).toList(),
      cursor: snapshot.docs.isEmpty ? null : snapshot.docs.last,
    );
  }

  /// Pushes up to [limit] prospects in [category] to one intern — the
  /// admin-controlled "push" the brand-intern tool's My Prospects tab reads
  /// from. By default only pulls from the still-unassigned pool (so a
  /// category can be split across several interns over multiple pushes);
  /// [includeAlreadyAssigned] widens the source pool to every prospect in
  /// the category regardless of current assignment, for the "reassign
  /// everything, including what's already out, to this intern" case. Not a
  /// live transaction: two admins pushing the same category at once could
  /// double-assign a handful of docs, which is an acceptable, self
  /// -correcting edge case for a manual, occasional action like this.
  Future<int> assignCategoryToIntern({
    required String category,
    required String internUid,
    required String internEmail,
    required int limit,
    bool includeAlreadyAssigned = false,
  }) async {
    Query<Map<String, dynamic>> query = _col.where(
      'category',
      isEqualTo: category,
    );
    if (!includeAlreadyAssigned) {
      query = query.where('status', isEqualTo: 'unassigned');
    }
    final snapshot = await query.limit(limit).get();
    const chunkSize = 500;
    final docs = snapshot.docs;
    for (var start = 0; start < docs.length; start += chunkSize) {
      final chunk = docs.sublist(
        start,
        start + chunkSize > docs.length ? docs.length : start + chunkSize,
      );
      final batch = _firestore.batch();
      for (final doc in chunk) {
        batch.update(doc.reference, {
          'assignedTo': internUid,
          'assignedToEmail': internEmail,
          'assignedAt': FieldValue.serverTimestamp(),
          'status': 'assigned',
        });
      }
      await batch.commit();
    }
    return docs.length;
  }
}

@Riverpod(keepAlive: true)
AdminBrandProspectsRepository adminBrandProspectsRepository(Ref ref) {
  return AdminBrandProspectsRepository(ref.watch(firestoreProvider));
}

@riverpod
Future<List<BrandProspectCategoryCounts>> brandProspectCategoryBreakdown(
  Ref ref,
) {
  return ref.watch(adminBrandProspectsRepositoryProvider).categoryBreakdown();
}

@riverpod
Future<int> brandProspectTotalImported(Ref ref) {
  return ref.watch(adminBrandProspectsRepositoryProvider).totalImported();
}
