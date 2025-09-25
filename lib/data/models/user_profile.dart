import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String skinType;
  final List<String> skinConditions;
  final List<String> recommendedIngredients;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.skinType,
    required this.skinConditions,
    required this.recommendedIngredients,
  });

  factory UserProfile.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      skinType: data['skinType'] ?? 'Unknown',
      skinConditions: List<String>.from(data['skinConditions'] ?? []),
      recommendedIngredients: List<String>.from(data['recommendedIngredients'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'skinType': skinType,
      'skinConditions': skinConditions,
      'recommendedIngredients': recommendedIngredients,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }
}
