import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_management_app/app/data/models/user_models.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'users';

  User? get currentFirebaseUser => _auth.currentUser;

  Future<AppUser?> getCurrentUser() async {
    final user = currentFirebaseUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection(_collection).doc(user.uid).get();
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      } else {
        final appUser = AppUser.fromFirebaseUser(user);
        await createUser(appUser);
        return appUser;
      }
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  Future<void> createUser(AppUser user) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(user.uid)
          .set(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<void> updateUserProfile(AppUser user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      await _firestore.collection(_collection).doc(user.uid).update({
        'displayName': updatedUser.displayName,
        'phoneNumber': updatedUser.phoneNumber,
        'updatedAt': Timestamp.fromDate(updatedUser.updatedAt),
      });
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<void> updateFirebaseDisplayName(String displayName) async {
    try {
      final user = currentFirebaseUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.reload();
      }
    } catch (e) {
      throw Exception('Failed to update display name: $e');
    }
  }

  Stream<AppUser?> getCurrentUserStream() {
    final user = currentFirebaseUser;
    if (user == null) return Stream.value(null);

    return _firestore.collection(_collection).doc(user.uid).snapshots().map((
      doc,
    ) {
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
      return null;
    });
  }

  Future<bool> userExists(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}
