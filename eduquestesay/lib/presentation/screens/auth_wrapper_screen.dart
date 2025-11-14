import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class AuthWrapperScreen extends StatefulWidget {
  const AuthWrapperScreen({Key? key}) : super(key: key);

  @override
  State<AuthWrapperScreen> createState() => _AuthWrapperScreenState();
}

class _AuthWrapperScreenState extends State<AuthWrapperScreen> {
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      
      print('Auth check - SharedPreferences isLoggedIn: $isLoggedIn');
      
      if (isLoggedIn) {
        final userData = {
          'uid': prefs.getString('user_uid'),
          'email': prefs.getString('user_email'),
          'name': prefs.getString('user_name'),
        };
        print('Saved user data: $userData');
      }
      
      // Give the auth provider time to initialize
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('Error checking auth status: $e');
    } finally {
      setState(() {
        _isCheckingAuth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (_isCheckingAuth || authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Checking authentication...'),
            ],
          ),
        ),
      );
    }

    // Show error if any
    if (authProvider.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication Error: ${authProvider.error}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        authProvider.clearError();
      });
    }

    // Check if user is authenticated
    if (authProvider.user != null) {
      print('User is authenticated: ${authProvider.user!.email}');
      return const HomeScreen();
    } else {
      print('User is not authenticated, showing login screen');
      return const LoginScreen();
    }
  }
}