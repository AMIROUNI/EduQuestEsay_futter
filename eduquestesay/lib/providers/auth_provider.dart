import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  Stream<User?> get userStream => _authService.userStream;
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _initializeUser();
  }

  // Initialize user from SharedPreferences or Firebase Auth
  Future<void> _initializeUser() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if user was previously logged in
      final bool wasLoggedIn = await _authService.isUserLoggedIn();
      
      if (wasLoggedIn) {
        final savedUserData = await _authService.getSavedUserData();
        print('Found saved user data: ${savedUserData['email']}');
        
        // Set user from saved data temporarily
        _user = FirebaseAuth.instance.currentUser;
        
        // If Firebase user is null but we have saved data, try to restore session
        if (_user == null && savedUserData['uid']!.isNotEmpty) {
          // Create a temporary user object from saved data
          _user = FirebaseAuth.instance.currentUser;
        }
      } else {
        _user = FirebaseAuth.instance.currentUser;
      }

      // Listen to auth state changes
      _authService.userStream.listen((User? user) {
        _user = user;
        notifyListeners();
      });

    } catch (e) {
      print('Error initializing user: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _authService.signInWithGoogle();
      _user = user;
      
      if (user == null) {
        _error = 'Google Sign-In was cancelled';
      }

      return user;
    } catch (e) {
      _error = e.toString();
      print('Google Sign-In error in provider: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<User?> loginWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _authService.loginWithEmail(email, password);
      _user = user;
      return user;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<User?>   registerWithEmail(String email, String password, String fullName  ,
  String phoneNumber,
  String role,
 ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _authService.registerWithEmail(email, password, fullName, phoneNumber, role);
      _user = user;
      return user;
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
} 