import 'package:eduquestesay/data/models/course_model.dart';
import 'package:eduquestesay/presentation/screens/course_detail_screen.dart';
import 'package:eduquestesay/presentation/screens/enrollment_screen.dart';
import 'package:flutter/material.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/register_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/auth_wrapper_screen.dart';

class AppRouter {
  static const String authWrapper = '/'; 
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String courseDetails = '/courseDetails';
  static const String enrollment = '/enrollment';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
       case enrollment:
        final course = settings.arguments as Course; 
        return MaterialPageRoute(
          builder: (_) => EnrollmentScreen(course: course),
        );
      case courseDetails:
        final course = settings.arguments as Course; 
        return MaterialPageRoute(
          builder: (_) => CourseDetailsScreen(course: course),
        );
      case authWrapper:
        return MaterialPageRoute(builder: (_) => const AuthWrapperScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const CourseSearchWidget()); // Fixed to HomeScreen
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Route not found")),
          ),
        );
    }
  }
}