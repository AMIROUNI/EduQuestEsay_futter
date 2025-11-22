import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String profileImageUrl;
  final String profileImageBase64; // Add this for Base64 storage
  final String role;
  final DateTime createdAt;
  final List<String> enrolledCourses;
  final bool isPremium;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.profileImageUrl,
    required this.profileImageBase64, // Add this
    required this.role,
    required this.createdAt,
    required this.enrolledCourses,
    required this.isPremium,
  });

   factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    // Handle createdAt field - it can be String or Timestamp
    DateTime parseCreatedAt(dynamic createdAt) {
      if (createdAt == null) return DateTime.now();
      
      if (createdAt is DateTime) {
        return createdAt;
      } else if (createdAt is String) {
        // Parse from ISO string
        return DateTime.tryParse(createdAt) ?? DateTime.now();
      } else if (createdAt is Timestamp) {
        // If it's a Firestore Timestamp
        return createdAt.toDate();
      } else {
        return DateTime.now();
      }
    }

    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      profileImageBase64: map['profileImageBase64'] ?? '',
      role: map['role'] ?? 'student',
      createdAt: parseCreatedAt(map['createdAt']),
      enrolledCourses: List<String>.from(map['enrolledCourses'] ?? []),
      isPremium: map['isPremium'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'profileImageBase64': profileImageBase64,
      'role': role,
      'createdAt': createdAt.toIso8601String(), // Store as ISO string for consistency
      'enrolledCourses': enrolledCourses,
      'isPremium': isPremium,
    };
  }

}