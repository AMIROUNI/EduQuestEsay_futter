 import 'package:eduquestesay/presentation/screens/login_screen.dart';
import 'package:eduquestesay/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

AppBar buildAppBar(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 70,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Image.asset(
            "assets/images/Logo.png",
            height: 40,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          const Text(
            "EduQuest",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          // Show user role with professional badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${authProvider.user?.role?.toUpperCase() ?? 'STUDENT'}',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.pushNamed(context, '/profile');
              } else if (value == 'logout') {
                authProvider.signOut();
               Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => LoginScreen()),
);
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            offset: const Offset(0, 50),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: const [
                    Icon(Icons.person, size: 20, color: Colors.blue),
                    SizedBox(width: 10),
                    Text("Profile"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: const [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 10),
                    Text("Logout", style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.person, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }