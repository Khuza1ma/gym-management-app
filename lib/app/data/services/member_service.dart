import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_management_app/app/data/models/member_model.dart';

/// Represents a single page of paginated member results.
/// [lastDocument] should be passed as [startAfter] for the next page.
/// [hasMore] indicates whether more pages may be available.
class PaginatedMembers {
  final List<Member> members;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  PaginatedMembers({
    required this.members,
    required this.lastDocument,
    required this.hasMore,
  });
}

class MemberService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'members';

  Future<String> addMember({
    required String memberName,
    required String memberLastname,
    required int cardNumber,
    required String phoneNumber,
    required String address,
    required DateTime planStartDate,
    required DateTime planEndDate,
  }) async {
    try {
      final now = DateTime.now();
      final docRef = await _firestore.collection(_collection).add({
        'memberName': memberName,
        'memberLastname': memberLastname,
        'cardNumber': cardNumber,
        'phoneNumber': phoneNumber,
        'address': address,
        'planStartDate': Timestamp.fromDate(planStartDate),
        'planEndDate': Timestamp.fromDate(planEndDate),
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add member: $e');
    }
  }

  Future<List<Member>> getAllMembers() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('cardNumber', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => Member.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get members: $e');
    }
  }

  /// Paginated fetch for all members ordered by `cardNumber` ascending.
  Future<PaginatedMembers> getAllMembersPaginated({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .orderBy('cardNumber', descending: false)
          .limit(limit);

      if (startAfter != null) {
        query = (query as Query<Map<String, dynamic>>).startAfterDocument(
          startAfter,
        );
      }

      final querySnapshot = await query.get();
      final docs = querySnapshot.docs;
      final members = docs.map((doc) => Member.fromFirestore(doc)).toList();

      final lastDoc = docs.isNotEmpty ? docs.last : null;
      final hasMore = docs.length >= limit;

      return PaginatedMembers(
        members: members,
        lastDocument: lastDoc,
        hasMore: hasMore,
      );
    } catch (e) {
      throw Exception('Failed to get members (paginated): $e');
    }
  }

  Future<Member?> getMemberById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Member.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get member: $e');
    }
  }

  Future<void> updateMember(Member member) async {
    try {
      await _firestore.collection(_collection).doc(member.id).update({
        'memberName': member.memberName,
        'memberLastname': member.memberLastname,
        'cardNumber': member.cardNumber,
        'phoneNumber': member.phoneNumber,
        'address': member.address,
        'planStartDate': Timestamp.fromDate(member.planStartDate),
        'planEndDate': Timestamp.fromDate(member.planEndDate),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update member: $e');
    }
  }

  Future<void> deleteMember(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete member: $e');
    }
  }

  Future<List<Member>> getMembersExpiringSoon({int daysThreshold = 7}) async {
    try {
      final now = DateTime.now();
      final thresholdDate = now.add(Duration(days: daysThreshold));

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('planEndDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where(
            'planEndDate',
            isLessThanOrEqualTo: Timestamp.fromDate(thresholdDate),
          )
          .orderBy('planEndDate', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => Member.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get expiring members: $e');
    }
  }

  Future<List<Member>> getExpiredMembers() async {
    try {
      final now = DateTime.now();

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('planEndDate', isLessThan: Timestamp.fromDate(now))
          .orderBy('planEndDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Member.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get expired members: $e');
    }
  }

  Future<List<Member>> searchMembers({
    required String query,
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      final trimmed = query.trim();
      if (trimmed.isEmpty) return [];

      Query nameQuery = _firestore
          .collection(_collection)
          .orderBy('memberName')
          .startAt([trimmed])
          .endAt(['$trimmed\uf8ff']);
      if (limit != null) nameQuery = nameQuery.limit(limit);
      if (startAfter != null) {
        nameQuery = nameQuery.startAfterDocument(startAfter);
      }

      Query lastNameQuery = _firestore
          .collection(_collection)
          .orderBy('memberLastname')
          .startAt([trimmed])
          .endAt(['$trimmed\uf8ff']);
      if (limit != null) lastNameQuery = lastNameQuery.limit(limit);
      if (startAfter != null) {
        lastNameQuery = lastNameQuery.startAfterDocument(startAfter);
      }

      final intQuery = int.tryParse(trimmed);
      QuerySnapshot? cardNumberSnapshot;
      if (intQuery != null) {
        final cardQuery = _firestore
            .collection(_collection)
            .where('cardNumber', isEqualTo: intQuery);
        cardNumberSnapshot = await cardQuery.get();
      }

      final results = await Future.wait([nameQuery.get(), lastNameQuery.get()]);

      final Map<String, Member> idToMember = {};
      for (final snap in results) {
        for (final doc in snap.docs) {
          idToMember[doc.id] = Member.fromFirestore(doc);
        }
      }
      if (cardNumberSnapshot != null) {
        for (final doc in cardNumberSnapshot.docs) {
          idToMember[doc.id] = Member.fromFirestore(doc);
        }
      }

      var members = idToMember.values.toList();
      members.sort((a, b) => a.cardNumber.compareTo(b.cardNumber));

      if (limit != null && members.length > limit) {
        members = members.sublist(0, limit);
      }

      return members;
    } catch (e) {
      throw Exception('Failed to search members: $e');
    }
  }
}
