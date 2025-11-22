import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eduquestesay/providers/auth_provider.dart';
import 'package:eduquestesay/core/app_router.dart';

class TabNavigationHandler {
  static void handleTabChange(BuildContext context, int index) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userRole = authProvider.user?.role?.toUpperCase() ?? 'STUDENT';

    print('Navigating with role: $userRole, index: $index');

    String route = _getRouteByIndexAndRole(index, userRole);

    if (route.isNotEmpty) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        route,
        (route) => false,
      );
    }
  }

  static String _getRouteByIndexAndRole(int index, String role) {
    switch (role) {
      case 'ADMIN':
        return _getAdminRoute(index);
      case 'TEACHER':
        return _getTeacherRoute(index);
      case 'STUDENT':
      default:
        return _getStudentRoute(index);
    }
  }

  static String _getStudentRoute(int index) {
    switch (index) {
      case 0:
        return AppRouter.home;
      case 1:
        return AppRouter.home;
      case 2:
        return AppRouter.mycourses;
      case 3:
        return AppRouter.home;
      case 4:
        return '/profile';
      default:
        return AppRouter.home;
    }
  }

  static String _getTeacherRoute(int index) {
    switch (index) {
      case 0:
        return AppRouter.home;
      case 1:
        return AppRouter.home;
      case 2:
        return AppRouter.home;
      case 3:
        return AppRouter.home;
      case 4:
        return '/profile';
      default:
        return AppRouter.home;
    }
  }

  static String _getAdminRoute(int index) {
    switch (index) {
      case 0:
        return AppRouter.home;
      case 1:
        return AppRouter.home;
      case 2:
        return AppRouter.home;
      case 3:
        return AppRouter.home;
      case 4:
        return '/profile';
      default:
        return AppRouter.home;
    }
  }
}