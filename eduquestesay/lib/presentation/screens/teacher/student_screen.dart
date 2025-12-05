import 'package:eduquestesay/core/app_router.dart';
import 'package:eduquestesay/providers/auth_provider.dart';
import 'package:eduquestesay/providers/enrollment_provider.dart';
import 'package:eduquestesay/utils/tab_navigation_handler.dart';
import 'package:eduquestesay/widgets/role_based_tabs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eduquestesay/utils/app_bar.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});
   

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  bool _hasFetchedEnrollments = false;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final String? userEmail = authProvider.user?.email;
              
              if (userEmail == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Consumer<EnrollmentProvider>(
                builder: (context, enrollmentProvider, child) {
                  // Appeler fetch UNE SEULE FOIS
                  if (!_hasFetchedEnrollments && 
                      !enrollmentProvider.isLoading && 
                      enrollmentProvider.studentEnrollments.isEmpty) {
                    _hasFetchedEnrollments = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      enrollmentProvider.fetchStudentEnrollments(userEmail);
                    });
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(context, userEmail),
                      const SizedBox(height: 24),
                      
                      // Stats Cards
                      _buildStatsSection(enrollmentProvider, userEmail),
                      const SizedBox(height: 24),
                      
                      // Course List
                      Expanded(
                        child: _buildCourseList(enrollmentProvider, userEmail, context),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        
      ),
          bottomNavigationBar: RoleBasedTabs(
        currentIndex: _currentIndex,
        onTabChanged: (index) {
          setState(() => _currentIndex = index);
          TabNavigationHandler.handleTabChange(context, index);
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userEmail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Learning',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade100, width: 2),
              ),
              child: const Icon(
                Icons.school,
                color: Colors.blue,
                size: 28,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Track your progress and continue learning',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Student: $userEmail',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(EnrollmentProvider enrollmentProvider, String studentEmail) {
    final total = enrollmentProvider.studentEnrollments.length;
    final completed = enrollmentProvider.getCompletedCoursesCount(studentEmail);
    final inProgress = enrollmentProvider.getInProgressCoursesCount(studentEmail);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(
          icon: Icons.check_circle_outline,
          value: completed.toString(),
          label: 'Completed',
          color: Colors.green.shade600,
        ),
        _buildStatCard(
          icon: Icons.timelapse_outlined,
          value: inProgress.toString(),
          label: 'In Progress',
          color: Colors.blue.shade600,
        ),
        _buildStatCard(
          icon: Icons.library_books_outlined,
          value: total.toString(),
          label: 'Total Courses',
          color: Colors.orange.shade600,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      width: 105,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseList(EnrollmentProvider enrollmentProvider, String studentEmail, BuildContext context) {
    // Skeleton loading state
    if (enrollmentProvider.isLoading && enrollmentProvider.studentEnrollments.isEmpty) {
      return _buildSkeletonLoading();
    }

    // Error state
    if (enrollmentProvider.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              enrollmentProvider.error,
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                enrollmentProvider.fetchStudentEnrollments(studentEmail);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final enrollments = enrollmentProvider.studentEnrollments;

    // Empty state
    if (enrollments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            const Text(
              'No Enrollments Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'You haven\'t enrolled in any courses yet. Browse courses to get started!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRouter.home),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text('Browse Courses'),
            ),
          ],
        ),
      );
    }

    // Data loaded - show courses
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Courses',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${enrollments.length} courses',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await enrollmentProvider.fetchStudentEnrollments(studentEmail);
            },
            child: ListView.builder(
              itemCount: enrollments.length,
              itemBuilder: (context, index) {
                final enrollment = enrollments[index];
                final progress = enrollment.progress;
                
                Color cardColor;
                if (progress >= 80) {
                  cardColor = Colors.green.shade600;
                } else if (progress >= 40) {
                  cardColor = Colors.blue.shade600;
                } else {
                  cardColor = Colors.orange.shade600;
                }

                return _buildEnrollmentCard(
                  enrollment.courseTitle ?? 'Untitled Course',
                  progress,
                  cardColor,
                  context,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Skeleton header
        Container(
          width: 150,
          height: 32,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        Container(
          width: 250,
          height: 16,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        
        // Skeleton stats cards
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSkeletonStatCard(),
            _buildSkeletonStatCard(),
            _buildSkeletonStatCard(),
          ],
        ),
        const SizedBox(height: 24),
        
        // Skeleton course list
        Expanded(
          child: ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 20,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonStatCard() {
    return Container(
      width: 105,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 60,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentCard(String title, double progress, Color color, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${progress.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progress Bar
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * (progress / 100),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(5),
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.8)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${progress.toStringAsFixed(0)}% completed',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (progress >= 90)
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Almost done!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}