import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eduquestesay/providers/auth_provider.dart';

class RoleBasedTabs extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;

  const RoleBasedTabs({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.user?.role ?? 'STUDENT';

    // Define tabs based on user role
    final List<BottomNavigationBarItem> tabs = _getTabsByRole(userRole);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTabChanged,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue.shade700,
      unselectedItemColor: Colors.grey.shade600,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      items: tabs,
    );
  }

  List<BottomNavigationBarItem> _getTabsByRole(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return _adminTabs();
      case 'TEACHER':
        return _teacherTabs();
      case 'STUDENT':
      default:
        return _studentTabs();
    }
  }

  List<BottomNavigationBarItem> _studentTabs() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.school),
        label: 'Courses',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.assignment),
        label: 'My Courses',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.article),
        label: 'News',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
  }

  List<BottomNavigationBarItem> _teacherTabs() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.school),
        label: 'My Courses',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.group),
        label: 'Students',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.analytics),
        label: 'Analytics',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
  }

  List<BottomNavigationBarItem> _adminTabs() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.people),
        label: 'Users',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.school),
        label: 'Courses',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Settings',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
  }
}