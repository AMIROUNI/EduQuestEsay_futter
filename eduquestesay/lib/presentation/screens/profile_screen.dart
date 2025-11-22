import 'package:eduquestesay/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eduquestesay/providers/auth_provider.dart';
import 'package:eduquestesay/providers/profile_provider.dart';
import 'package:eduquestesay/data/services/base64_image_service.dart';
import 'package:eduquestesay/widgets/role_based_tabs.dart';
import 'package:eduquestesay/utils/tab_navigation_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentTabIndex = 4; // Default to Profile tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: ChangeNotifierProvider(
        create: (context) => ProfileProvider(),
        child: const _ProfileContent(),
      ),
      bottomNavigationBar: RoleBasedTabs(
        currentIndex: _currentTabIndex,
        onTabChanged: (index) {
          setState(() {
            _currentTabIndex = index;
          });
          TabNavigationHandler.handleTabChange(context, index);
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
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
          // Show user role
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
                // Already on profile
              } else if (value == 'logout') {
                authProvider.signOut();
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
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final base64Service = Base64ImageService();

    return authProvider.user == null
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Loading profile...',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          )
        : _buildProfileContent(context, authProvider.user!, profileProvider, base64Service, authProvider);
  }

  Widget _buildProfileContent(
    BuildContext context, 
    UserModel user, 
    ProfileProvider profileProvider,
    Base64ImageService base64Service,
    AuthProvider authProvider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Profile Header Section
          _buildProfileHeader(context, user, profileProvider, base64Service),
          
          const SizedBox(height: 32),
          
          // User Info Section
          _buildUserInfoSection(user),
          
          const SizedBox(height: 24),
          
          // Actions Section
          _buildActionsSection(context, authProvider, user),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context, 
    UserModel user, 
    ProfileProvider profileProvider,
    Base64ImageService base64Service,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              // Profile Image Container
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _buildProfileImage(user, base64Service),
                ),
              ),
              
              // Upload Button
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    onPressed: profileProvider.isLoading
                        ? null
                        : () => _uploadProfileImage(context, profileProvider, user.uid),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // User Name and Email
          Text(
            user.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue.shade700,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified,
                  color: Colors.blue.shade600,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${user.role.toUpperCase()} MEMBER',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Upload Status Messages
          if (profileProvider.uploadProgress.isNotEmpty)
            _buildStatusMessage(
              profileProvider.uploadProgress,
              Colors.green,
              Icons.check_circle,
            ),
          
          if (profileProvider.error.isNotEmpty)
            _buildStatusMessage(
              profileProvider.error,
              Colors.red,
              Icons.error,
              onClose: profileProvider.clearError,
            ),
          
          if (profileProvider.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(UserModel user, Base64ImageService base64Service) {
    // Try Base64 image first
    if (user.profileImageBase64.isNotEmpty && base64Service.isValidBase64(user.profileImageBase64)) {
      return base64Service.base64ToImage(user.profileImageBase64);
    }
    
    // Try network image
    if (user.profileImageUrl.isNotEmpty && !user.profileImageUrl.startsWith('base64://')) {
      return Image.network(
        user.profileImageUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          );
        },
      );
    }
    
    // Default avatar
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.blue.shade100,
      child: const Icon(
        Icons.person,
        size: 50,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildStatusMessage(String message, Color color, IconData icon, {VoidCallback? onClose}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onClose != null)
            IconButton(
              icon: Icon(Icons.close, color: color, size: 18),
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection(UserModel user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow(Icons.person, 'Full Name', user.fullName),
            _buildInfoRow(Icons.email, 'Email', user.email),
            _buildInfoRow(Icons.phone, 'Phone', user.phoneNumber.isEmpty ? 'Not set' : user.phoneNumber),
            _buildInfoRow(Icons.school, 'Role', user.role.toUpperCase()),
            _buildInfoRow(Icons.calendar_today, 'Member Since', _formatDate(user.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.blue.shade600,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, AuthProvider authProvider, UserModel user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showEditProfileDialog(context, user),
                icon: const Icon(Icons.edit, size: 20),
                label: const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context, authProvider),
                icon: const Icon(Icons.logout, size: 20),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.shade300),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadProfileImage(BuildContext context, ProfileProvider profileProvider, String userId) async {
    final String? imageUrl = await profileProvider.uploadProfileImageBase64(userId);
    
    if (imageUrl != null && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.refreshUserData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile image updated successfully!'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _showEditProfileDialog(BuildContext context, UserModel user) async {
    final TextEditingController nameController = TextEditingController(text: user.fullName);
    final TextEditingController phoneController = TextEditingController(text: user.phoneNumber);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone, color: Colors.blue),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await profileProvider.updateUserProfile(
                userId: user.uid,
                fullName: nameController.text.trim(),
                phoneNumber: phoneController.text.trim(),
              );
              
              if (success && context.mounted) {
                Navigator.pop(context);
                authProvider.refreshUserData();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Profile updated successfully!'),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, AuthProvider authProvider) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}