class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String profileImageUrl;
  final String role; //   "student", "teacher", "admin"
  final DateTime createdAt;
  final List<String> enrolledCourses; 
  final bool isPremium;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.profileImageUrl,
    required this.role,
    required this.createdAt,
    required this.enrolledCourses,
    required this.isPremium,
  });

  /// Factory constructor from Firebase User + Firestore Data
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      role: map['role'] ?? 'student',
      createdAt: (map['createdAt'])?.toDate() ?? DateTime.now(),
      enrolledCourses: List<String>.from(map['enrolledCourses'] ?? []),
      isPremium: map['isPremium'] ?? false,
    );
  }

  /// Convert to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'role': role,
      'createdAt': createdAt,
      'enrolledCourses': enrolledCourses,
      'isPremium': isPremium,
    };
  }
}
