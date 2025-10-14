import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserIfNotExist(User firebaseUser) async {
    final userDoc = _db.collection('users').doc(firebaseUser.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({
        'name': firebaseUser.displayName ?? 'Anonymous',
        'email': firebaseUser.email,
        'skinType': 'Combination',
        'skinConditions': ['Acne', 'Blemishes'],
        'recommendedIngredients': [
          'Salicylic Acid',
          'Niacinamide',
          'Hyaluronic Acid'
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<List<String>> getRecommendedIngredients(String uid) async {
    final docSnapshot = await _db.collection('users').doc(uid).get();
    if (docSnapshot.exists) {
      return List<String>.from(
          docSnapshot.data()?['recommendedIngredients'] ?? []);
    }
    return [];
  }

  Future<void> addDummyIngredients(String uid, List<String> ingredients) async {
    await _db.collection('recommendations').doc(uid).set({
      'ingredients': ingredients,
    });
  }

  Future<void> saveScanDetections(
      String uid, List<Map<String, dynamic>> detections) async {
    await _db.collection('users').doc(uid).update({
      'scanDetections': FieldValue.arrayUnion(detections),
      'lastScan': DateTime.now(),
    });
  }
}
