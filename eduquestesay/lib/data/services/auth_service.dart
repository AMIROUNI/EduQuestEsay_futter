import 'package:eduquestesay/core/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  Stream<User?> get userStream => _auth.authStateChanges();

  // Save user session to SharedPreferences
  Future<void> _saveUserSession(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_uid', user.uid);
      await prefs.setString('user_email', user.email ?? '');
      await prefs.setString('user_name', user.displayName ?? '');
      await prefs.setString('user_photo', user.photoURL ?? '');
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('login_method', 'google');
    } catch (e) {
      print('Error saving user session: $e');
    }
  }

  // Clear user session from SharedPreferences
  Future<void> _clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_uid');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.remove('user_photo');
      await prefs.setBool('is_logged_in', false);
      await prefs.remove('login_method');
    } catch (e) {
      print('Error clearing user session: $e');
    }
  }

  // Check if user is logged in from SharedPreferences
  Future<bool> isUserLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('is_logged_in') ?? false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Get saved user data from SharedPreferences
  Future<Map<String, String>> getSavedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'uid': prefs.getString('user_uid') ?? '',
        'email': prefs.getString('user_email') ?? '',
        'name': prefs.getString('user_name') ?? '',
        'photo': prefs.getString('user_photo') ?? '',
        'login_method': prefs.getString('login_method') ?? '',
      };
    } catch (e) {
      print('Error getting saved user data: $e');
      return {};
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In...');

      // For web, we'll use a different approach without clientId
      GoogleSignInAccount? googleUser;
      
      if (kIsWeb) {
        // Web approach - use Firebase directly with Google Auth Provider
        print('Using web Google Sign-In approach...');
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        
        final UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
        final User? user = userCredential.user;
        
        if (user != null) {
          await _saveUserSession(user);
          await _saveUserToFirestore(user, user.displayName ?? 'User');
        }
        
        return user;
      } else {
        // Mobile approach
        googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          print('Google Sign-In cancelled by user');
          return null;
        }

        print('Google user obtained: ${googleUser.email}');

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        print('Google authentication completed');

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        print('Attempting Firebase sign-in with credential...');
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        print('Firebase sign-in completed. User: ${user?.uid}');

        if (user != null) {
          await _saveUserSession(user);
          await _saveUserToFirestore(user, googleUser.displayName ?? 'User');
          print('User saved to Firestore and SharedPreferences');
        }

        return user;
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      
      // Fallback: Try redirect method for web
      if (kIsWeb && e.toString().contains('popup')) {
        try {
          print('Trying redirect method...');
          final GoogleAuthProvider googleProvider = GoogleAuthProvider();
          await _auth.signInWithRedirect(googleProvider);
          return null; // Will be handled by authStateChanges
        } catch (redirectError) {
          print('Redirect method also failed: $redirectError');
          rethrow;
        }
      }
      
      rethrow;
    }
  }

  // Email/Password methods
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final User? user = userCredential.user;
      if (user != null) {
        await _saveUserSession(user);
      }
      
      return user;
    } catch (e) {
      rethrow;
    }
  }

Future<User?> registerWithEmail(
  String email,
  String password,
  String fullName,
  String phoneNumber,
  String role,
) async {
  try {
    // Create user in Firebase Authentication
    final UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final User? user = userCredential.user;

    if (user != null) {
      // Save user data in Firestore using UserModel
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        profileImageUrl: "",
        profileImageBase64: "",
        role: role,
        createdAt: DateTime.now(),
        enrolledCourses: [],
        isPremium: false,
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set(userModel.toMap());

      // Save session locally if needed
      await _saveUserSession(user);

      return user;
    }
  } catch (e) {
    print("Error registering user: $e");
    rethrow;
  }
}

  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
      await _clearUserSession();
      print('User signed out and session cleared');
    } catch (e) {
      print('Error during sign out: $e');
      rethrow;
    }
  }

  Future<void> _saveUserToFirestore(User user, String fullName) async {
    try {
      final usersCollection = _firestore.collection('users');
      final userDoc = await usersCollection.doc(user.uid).get();
      
      if (!userDoc.exists) {
        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          fullName: fullName,
          phoneNumber: user.phoneNumber ?? '',
          profileImageUrl: user.photoURL ?? '',
          profileImageBase64: "",
          role: 'student',
          createdAt: DateTime.now(),
          enrolledCourses: [],
          isPremium: false,
        );

        await usersCollection.doc(user.uid).set(userModel.toMap());
      }
    } catch (e) {
      print('Error saving user to Firestore: $e');
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      
      if (fullName != null) updateData['fullName'] = fullName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;
      
      if (updateData.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update(updateData);
      }
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Update profile image only
  Future<void> updateProfileImage(String userId, String imageUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': imageUrl,
      });
    } catch (e) {
      print('Error updating profile image: $e');
      rethrow;
    }
  }

  

  Future<void> updateUserProfileWithBase64({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? profileImageBase64,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      
      if (fullName != null) updateData['fullName'] = fullName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (profileImageBase64 != null) {
        updateData['profileImageBase64'] = profileImageBase64;
        // Also update the URL field for backward compatibility
        updateData['profileImageUrl'] = 'base64://$userId'; 
      }
      
      if (updateData.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update(updateData);
      }
    } catch (e) {
      print('Error updating user profile with Base64: $e');
      rethrow;
    }
  }

  // Update only Base64 profile image
  Future<void> updateProfileImageBase64(String userId, String base64Image) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'profileImageBase64': base64Image,
        'profileImageUrl': 'base64://$userId', // Marker for Base64 images
      });
    } catch (e) {
      print('Error updating Base64 profile image: $e');
      rethrow;
    }
  }
}