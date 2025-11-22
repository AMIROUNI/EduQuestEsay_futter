import 'package:eduquestesay/data/models/enrollment_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eduquestesay/providers/enrollment_provider.dart';
import 'package:eduquestesay/providers/auth_provider.dart';
import 'package:eduquestesay/data/models/course_model.dart';

class EnrollmentScreen extends StatelessWidget {
  final Course course;

  const EnrollmentScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enroll in ${course.title}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Info Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'By ${course.teacherEmail}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        course.category,
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Enrollment Button Section
            Text(
              'Enrollment',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // The enrollment button
            ChangeNotifierProvider(
              create: (context) => EnrollmentProvider(),
              child: _EnrollmentButtonWidget(course: course),
            ),
            
            const SizedBox(height: 24),
            
            // Additional Info
            _buildEnrollmentInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrollmentInfo() {
    return const Card(
      color: Color.fromARGB(255, 45, 145, 216),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Enrollment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• Access all course materials\n'
              '• Track your progress\n'
              '• Withdraw anytime\n'
              '• Start learning immediately',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnrollmentButtonWidget extends StatelessWidget {
  final Course course;

  const _EnrollmentButtonWidget({required this.course});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.isLoading) {
      return _buildLoadingButton();
    }

    if (authProvider.user == null) {
      return _buildLoginRequiredButton(context);
    }

    return _EnrollmentButtonContent(
      course: course,
      studentEmail: authProvider.user!.email!,
    );
  }

  Widget _buildLoadingButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          SizedBox(height: 8),
          Text('Checking enrollment status...'),
        ],
      ),
    );
  }

  Widget _buildLoginRequiredButton(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange),
          ),
          child: const Column(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange, size: 40),
              SizedBox(height: 8),
              Text(
                'Login Required',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'You need to be logged in to enroll in this course',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.login, size: 24),
                SizedBox(width: 8),
                Text(
                  'Go to Login',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EnrollmentButtonContent extends StatelessWidget {
  final Course course;
  final String studentEmail;

  const _EnrollmentButtonContent({
    required this.course,
    required this.studentEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<EnrollmentProvider>(
      builder: (context, enrollmentProvider, child) {
        final isEnrolled = enrollmentProvider.getEnrollment(studentEmail, course.id!) != null;
        final enrollment = enrollmentProvider.getEnrollment(studentEmail, course.id!);
        
        if (enrollmentProvider.isLoading) {
          return _buildProcessingButton();
        }

        if (isEnrolled && enrollment != null) {
          return _buildEnrolledSection(enrollment, enrollmentProvider, context);
        }

        return _buildEnrollSection(enrollmentProvider, context);
      },
    );
  }

  Widget _buildProcessingButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          SizedBox(height: 8),
          Text('Processing your request...'),
        ],
      ),
    );
  }

  Widget _buildEnrollSection(EnrollmentProvider enrollmentProvider, BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green),
          ),
          child: const Column(
            children: [
              Icon(Icons.school, color: Colors.green, size: 50),
              SizedBox(height: 8),
              Text(
                'Ready to Start Learning?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Enroll now to get full access to this course',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _enrollCourse(enrollmentProvider, context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 24),
                SizedBox(width: 8),
                Text(
                  'Enroll in Course',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnrolledSection(
    Enrollment enrollment, 
    EnrollmentProvider enrollmentProvider, 
    BuildContext context
  ) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green),
          ),
          child: Column(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 50),
              const SizedBox(height: 8),
              const Text(
                'You\'re Enrolled!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Progress: ${enrollment.progress.toInt()}% Complete',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              
              // Progress bar
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: double.infinity * (enrollment.progress / 100),
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to course content
                  Navigator.pop(context); // Close enrollment screen
                  // You can add navigation to course content here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Continue Learning'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _showWithdrawDialog(enrollmentProvider, context),
              icon: const Icon(Icons.exit_to_app, color: Colors.red, size: 30),
              style: IconButton.styleFrom(
                backgroundColor: Colors.red[50],
                padding: const EdgeInsets.all(16),
              ),
              tooltip: 'Withdraw from course',
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _enrollCourse(EnrollmentProvider enrollmentProvider, BuildContext context) async {
    try {
      final success = await enrollmentProvider.enrollUser(studentEmail, course.id!);
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully enrolled in course!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to enroll: ${enrollmentProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Enrollment failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showWithdrawDialog(EnrollmentProvider enrollmentProvider, BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw from Course'),
        content: Text('Are you sure you want to withdraw from "${course.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _withdrawCourse(enrollmentProvider, context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  Future<void> _withdrawCourse(EnrollmentProvider enrollmentProvider, BuildContext context) async {
    try {
      final success = await enrollmentProvider.withdraw(studentEmail, course.id!);
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Withdrawn from ${course.title}'),
            backgroundColor: Colors.orange,
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to withdraw: ${enrollmentProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Withdrawal failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}