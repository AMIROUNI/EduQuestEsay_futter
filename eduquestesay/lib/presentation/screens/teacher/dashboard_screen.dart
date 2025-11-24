// widgets/teacher_dashboard_screen.dart
import 'package:eduquestesay/data/models/course_model.dart';
import 'package:eduquestesay/providers/teacher_dashboard_provider.dart';
import 'package:eduquestesay/utils/app_bar.dart';
import 'package:eduquestesay/widgets/role_based_tabs.dart';
import 'package:eduquestesay/utils/tab_navigation_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  String? _teacherEmail;
  bool _isLoadingUser = true;
  String? _error;
  int _currentTabIndex = 0; // Default to Home/Dashboard tab

  @override
  void initState() {
    super.initState();
    _loadTeacherEmail();
  }

  Future<void> _loadTeacherEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email');
      
      if (email == null || email.isEmpty) {
        setState(() {
          _error = 'No user email found. Please log in again.';
          _isLoadingUser = false;
        });
        return;
      }

      setState(() {
        _teacherEmail = email;
        _isLoadingUser = false;
      });

      // Fetch dashboard data after getting email
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_teacherEmail != null) {
          context.read<TeacherDashboardProvider>().fetchTeacherDashboard(_teacherEmail!);
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading user data: $e';
        _isLoadingUser = false;
      });
    }
  }

  Future<void> _refreshDashboard() async {
    if (_teacherEmail != null) {
      await context.read<TeacherDashboardProvider>().fetchTeacherDashboard(_teacherEmail!);
    }
  }

  void _handleTabChange(int index) {
    setState(() {
      _currentTabIndex = index;
    });
    
    // Use TabNavigationHandler for navigation
    TabNavigationHandler.handleTabChange(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: _buildBody(),
      // Add the bottom navigation bar here
      bottomNavigationBar: RoleBasedTabs(
        currentIndex: _currentTabIndex,
        onTabChanged: _handleTabChange,
      ),
    );
  }

  Widget _buildBody() {
    // Show loading while getting user email
    if (_isLoadingUser) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error if couldn't load user email
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text(
              'Error Loading User Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTeacherEmail,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    // Show message if no teacher email found
    if (_teacherEmail == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No User Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please log in to access the teacher dashboard',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to login screen
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/login', 
                  (route) => false
                );
              },
              child: const Text('Go to Login'),
            ),
          ],
        ),
      );
    }

    // Show dashboard content based on current tab
    return _buildTabContent();
  }

  Widget _buildTabContent() {
    switch (_currentTabIndex) {
      case 0: // Home/Dashboard
        return _buildDashboardContent();
      case 1: // My Courses
        return _buildMyCoursesContent();
      case 2: // Students
        return _buildStudentsContent();
      case 3: // Analytics
        return _buildAnalyticsContent();
      case 4: // Profile
        return _buildProfileContent();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return Consumer<TeacherDashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.dashboardData == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                const Text(
                  'Error Loading Dashboard',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshDashboard,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshDashboard,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section with teacher email
                _buildWelcomeSection(),
                const SizedBox(height: 24),
                
                // Statistics Grid
                _buildStatisticsGrid(provider),
                const SizedBox(height: 24),
                
                // Recent Courses
                _buildRecentCourses(provider),
                const SizedBox(height: 24),
                
                // Progress Summary
                _buildProgressSummary(provider),
                
                // Teacher Email (for debugging/verification)
                _buildTeacherEmailSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyCoursesContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 64, color: Colors.blue.shade300),
          const SizedBox(height: 16),
          const Text(
            'My Courses',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your courses here',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to course management screen
              // Navigator.pushNamed(context, '/teacher-courses');
            },
            child: const Text('View All Courses'),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group, size: 64, color: Colors.green.shade300),
          const SizedBox(height: 16),
          const Text(
            'Students',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your students here',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to student management screen
              // Navigator.pushNamed(context, '/teacher-students');
            },
            child: const Text('View Students'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent() {
    return Consumer<TeacherDashboardProvider>(
      builder: (context, provider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.analytics, size: 64, color: Colors.orange.shade300),
              const SizedBox(height: 16),
              const Text(
                'Analytics',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'View teaching analytics and insights',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_teacherEmail != null) {
                    provider.fetchTeacherAnalytics(_teacherEmail!);
                  }
                },
                child: const Text('Load Analytics'),
              ),
              if (provider.analyticsData != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Analytics data loaded: ${provider.analyticsData!.length} items',
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: Colors.purple.shade300),
          const SizedBox(height: 16),
          const Text(
            'Profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your teacher profile',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to profile screen
              Navigator.pushNamed(context, '/profile');
            },
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  // Keep all your existing UI methods (they remain the same)
  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back, Teacher!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Here\'s your teaching overview',
            style: TextStyle(
              color: Colors.blue.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          if (_teacherEmail != null)
            Text(
              'Logged in as: $_teacherEmail',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(TeacherDashboardProvider provider) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Total Courses',
          provider.totalCourses.toString(),
          Icons.school,
          Colors.blue,
        ),
        _buildStatCard(
          'Total Students',
          provider.totalStudents.toString(),
          Icons.people,
          Colors.green,
        ),
        _buildStatCard(
          'Total Lessons',
          provider.totalLessons.toString(),
          Icons.library_books,
          Colors.orange,
        ),
        _buildStatCard(
          'Avg Rating',
          provider.averageRating.toStringAsFixed(1),
          Icons.star,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCourses(TeacherDashboardProvider provider) {
    final recentCourses = provider.recentCourses;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Recent Courses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${recentCourses.length} total',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentCourses.isEmpty)
              const Center(
                child: Text('No courses found'),
              )
            else
              ...recentCourses.map((course) => _buildCourseItem(course)),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseItem(Course course) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: const Icon(Icons.school, color: Colors.blue),
      ),
      title: Text(course.title),
      subtitle: Text(course.category),
      trailing: Chip(
        label: Text('${course.rating} ⭐'),
        backgroundColor: Colors.orange.shade50,
      ),
      onTap: () {
        // Navigate to course details
        // Navigator.push(context, MaterialPageRoute(
        //   builder: (context) => CourseDetailsScreen(courseId: course.id),
        // ));
      },
    );
  }

  Widget _buildProgressSummary(TeacherDashboardProvider provider) {
    final progressSummary = provider.progressSummary;
    if (progressSummary == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Student Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProgressItem(
              'Average Progress',
              '${progressSummary['averageProgress']?.toStringAsFixed(1) ?? '0'}%',
              Colors.blue,
            ),
            _buildProgressItem(
              'Completed Students',
              '${progressSummary['completedStudents'] ?? 0}',
              Colors.green,
            ),
            _buildProgressItem(
              'Active Students',
              '${progressSummary['activeStudents'] ?? 0}',
              Colors.orange,
            ),
            _buildProgressItem(
              'Total Enrollments',
              '${progressSummary['totalEnrollments'] ?? 0}',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherEmailSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          'Teacher: $_teacherEmail',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}