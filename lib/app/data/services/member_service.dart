import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_management_app/app/data/models/member_model.dart';

class MemberService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'members';

  Future<String> addMember({
    required String memberName,
    required String memberLastname,
    required String cardNumber,
    required String phoneNumber,
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
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Member.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get members: $e');
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
}
