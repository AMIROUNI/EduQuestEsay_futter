import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/services/auth_service.dart';
import '../data/models/user_model.dart'; // Import your UserModel

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Stream<User?> get userStream => _authService.userStream;
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _initializeUser();
  }

  // Initialize user from Firebase Auth and Firestore
  Future<void> _initializeUser() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if user was previously logged in
      final bool wasLoggedIn = await _authService.isUserLoggedIn();
      
      if (wasLoggedIn) {
        final savedUserData = await _authService.getSavedUserData();
        print('Found saved user data: ${savedUserData['email']}');
        
        // Load user data from Firestore
        if (savedUserData['uid']!.isNotEmpty) {
          await _loadUserFromFirestore(savedUserData['uid']!);
        }
      } else {
        // Check current Firebase user
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await _loadUserFromFirestore(currentUser.uid);
        }
      }

      // Listen to auth state changes
      _authService.userStream.listen((User? firebaseUser) async {
        if (firebaseUser != null) {
          await _loadUserFromFirestore(firebaseUser.uid);
        } else {
          _user = null;
          notifyListeners();
        }
      });

    } catch (e) {
      print('Error initializing user: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user data from Firestore including role
  // Load user data from Firestore including role
Future<void> _loadUserFromFirestore(String uid) async {
  try {
    final doc = await _firestore.collection('users').doc(uid).get();
    
    if (doc.exists) {
      final userData = doc.data() as Map<String, dynamic>;
      print('User data from Firestore: $userData'); // Debug print
      
      _user = UserModel.fromMap(userData, uid);
      print('User role loaded: ${_user?.role}');
    } else {
      // If user document doesn't exist, create a basic one
      _user = UserModel(
        uid: uid,
        email: FirebaseAuth.instance.currentUser?.email ?? '',
        fullName: FirebaseAuth.instance.currentUser?.displayName ?? 'User',
        phoneNumber: FirebaseAuth.instance.currentUser?.phoneNumber ?? '',
        profileImageUrl: FirebaseAuth.instance.currentUser?.photoURL ?? '',
        profileImageBase64: FirebaseAuth.instance.currentUser?.photoURL?? '',
        role: 'student', // Default role
        createdAt: DateTime.now(),
        enrolledCourses: [],
        isPremium: false,
      );
      
      // Save to Firestore
      await _firestore.collection('users').doc(uid).set(_user!.toMap());
    }
    
    notifyListeners();
  } catch (e) {
    print('Error loading user from Firestore: $e');
    _error = 'Failed to load user data: $e';
  }
}

  Future<UserModel?> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _authService.signInWithGoogle();
      
      if (user != null) {
        await _loadUserFromFirestore(user.uid);
      } else {
        _error = 'Google Sign-In was cancelled';
      }

      return _user;
    } catch (e) {
      _error = e.toString();
      print('Google Sign-In error in provider: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel?> loginWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _authService.loginWithEmail(email, password);
      
      if (user != null) {
        await _loadUserFromFirestore(user.uid);
      }

      return _user;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel?> registerWithEmail(
    String email, 
    String password, 
    String fullName,
    String phoneNumber,
    String role,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _authService.registerWithEmail(
        email, password, fullName, phoneNumber, role
      );
      
      if (user != null) {
        await _loadUserFromFirestore(user.uid);
      }

      return _user;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signOut();
      _user = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh user data from Firestore
  Future<void> refreshUserData() async {
    if (_user != null) {
      await _loadUserFromFirestore(_user!.uid);
    }
  }



  
  Future<void> loadUserData() async {
    _isLoading = true;
    
    try {
      final isLoggedIn = await _authService.isUserLoggedIn();
      
      if (isLoggedIn) {
        final savedData = await _authService.getSavedUserData();
        final userId = savedData['uid'];
        
        if (userId != null && userId.isNotEmpty) {
          // Get user data from Firestore including role
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
              
          if (userDoc.exists) {
            _user = UserModel.fromMap(userDoc.data()!,userId);
            
            // Save role to SharedPreferences for quick access
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_role', _user!.role);
            
            print('User role loaded: ${_user!.role}');
          }
        }
      }
    } catch (e) {
      _error = 'Error loading user data: $e';
    } finally {
      _isLoading = false;
    }
  }

}