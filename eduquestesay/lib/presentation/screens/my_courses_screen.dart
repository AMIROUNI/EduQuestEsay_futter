import 'package:eduquestesay/utils/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eduquestesay/providers/course_provider.dart';
import 'package:eduquestesay/providers/auth_provider.dart';
import 'package:eduquestesay/data/models/course_model.dart';
import 'package:eduquestesay/widgets/role_based_tabs.dart';
import 'package:eduquestesay/utils/tab_navigation_handler.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  int _currentTabIndex = 2; // Default to My Courses tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: ChangeNotifierProvider(
        create: (context) => CourseProvider(),
        child: const _MyCoursesContent(),
      ),
      // Add the bottom navigation bar here
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
}

class _MyCoursesContent extends StatelessWidget {
  const _MyCoursesContent();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final courseProvider = Provider.of<CourseProvider>(context);

    // Load enrolled courses when screen builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userEmail = authProvider.user?.email;
      if (userEmail != null && courseProvider.enrolledCourses.isEmpty) {
        courseProvider.fetchEnrolledCourses(userEmail);
      }
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Student Profile',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Name: ${authProvider.user?.fullName ?? 'Unknown'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Email: ${authProvider.user?.email ?? 'No email'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Enrolled Courses Section
          Text(
            'My Courses',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Loading State
          if (courseProvider.isLoadingEnrolled)
            _buildLoadingState(),

          // Error State
          if (courseProvider.hasEnrolledError)
            _buildErrorState(context, courseProvider.enrolledError, courseProvider),

          // Empty State
          if (!courseProvider.isLoadingEnrolled &&
              !courseProvider.hasEnrolledError &&
              courseProvider.enrolledCourses.isEmpty)
            _buildEmptyState(context, authProvider.user?.email),

          // Enrolled Courses List
          if (!courseProvider.isLoadingEnrolled &&
              courseProvider.enrolledCourses.isNotEmpty)
            _buildEnrolledCoursesList(context, courseProvider),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          SizedBox(height: 16),
          Text(
            'Loading your courses...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error, CourseProvider courseProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 8),
          const Text(
            'Failed to load courses',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final userEmail = authProvider.user?.email;
              if (userEmail != null) {
                courseProvider.fetchEnrolledCourses(userEmail);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String? userEmail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue),
      ),
      child: Column(
        children: [
          const Icon(Icons.school, color: Colors.blue, size: 60),
          const SizedBox(height: 16),
          const Text(
            'No Courses Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You haven\'t enrolled in any courses yet.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'User: $userEmail',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navigate to courses screen
              Navigator.pushNamed(context, '/courses');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Browse Courses'),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrolledCoursesList(BuildContext context, CourseProvider courseProvider) {
    return Expanded(
      child: ListView.builder(
        itemCount: courseProvider.enrolledCourses.length,
        itemBuilder: (context, index) {
          final course = courseProvider.enrolledCourses[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/courseDetails',
                arguments: course, // FIX: Use the current course from enrolledCourses, not courses[index]
              );
            },
            child: _buildCourseCard(course, context),
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(Course course, BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: course.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        course.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.book, color: Colors.grey);
                        },
                      ),
                    )
                  : const Icon(Icons.book, color: Colors.grey),
            ),
            
            const SizedBox(width: 16),
            
            // Course Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Course Meta Info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          course.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.star, color: Colors.amber[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        course.rating.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.schedule, color: Colors.grey[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${course.duration}h',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Enrolled Badge
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}