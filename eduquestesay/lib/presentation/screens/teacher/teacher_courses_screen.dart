// widgets/teacher_courses_screen.dart
import 'package:eduquestesay/widgets/course_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eduquestesay/providers/auth_provider.dart';
import 'package:eduquestesay/providers/course_provider.dart';
import 'package:eduquestesay/data/models/course_model.dart';
import 'package:eduquestesay/utils/app_bar.dart';

// IMPORTS AJOUTÉS
import 'package:eduquestesay/widgets/role_based_tabs.dart';
import 'package:eduquestesay/utils/tab_navigation_handler.dart';

class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({super.key});

  @override
  State<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  String? _teacherEmail;
  bool _isLoadingUser = true;

  // --- état pour la tab sélectionnée ---
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email');
      
      setState(() {
        _teacherEmail = email;
        _isLoadingUser = false;
      });

      // Load teacher's courses after getting email
      if (_teacherEmail != null) {
        _loadTeacherCourses();
      }
    } catch (e) {
      print('Error loading teacher data: $e');
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  void _loadTeacherCourses() {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    // Use the new method to fetch teacher-specific courses
    courseProvider.fetchCoursesByTeacher(_teacherEmail!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: _isLoadingUser
          ? const Center(child: CircularProgressIndicator())
          : _teacherEmail == null
              ? _buildNoUserWidget()
              : _buildCoursesContent(),
      floatingActionButton: _teacherEmail != null
          ? FloatingActionButton(
              onPressed: () => _showAddCourseDialog(),
              backgroundColor: Colors.blue.shade600,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,

      // --------- AJOUT: Bottom Navigation basé sur le rôle ----------
      bottomNavigationBar: RoleBasedTabs(
        currentIndex: _currentTabIndex,
        onTabChanged: (index) {
          // Mettre à jour l'index local pour l'état visuel
          setState(() {
            _currentTabIndex = index;
          });

          // Gérer la navigation selon le rôle et l'index (supprime la pile)
          TabNavigationHandler.handleTabChange(context, index);
        },
      ),
    );
  }

  Widget _buildNoUserWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No Teacher Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please log in as a teacher to manage courses',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesContent() {
    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        // Use teacherCourses from provider instead of filtering manually
        final teacherCourses = courseProvider.teacherCourses;

        return Column(
          children: [
            // Header
            _buildHeader(teacherCourses.length),
            
            // Loading or Error States
            if (courseProvider.isLoadingTeacherCourses) 
              const LinearProgressIndicator(),
            
            if (courseProvider.hasTeacherCoursesError)
              _buildErrorWidget(
                courseProvider.teacherCoursesError, 
                courseProvider.clearTeacherCoursesError
              ),
            
            // Courses List
            Expanded(
              child: teacherCourses.isEmpty
                  ? _buildEmptyState()
                  : _buildCoursesList(teacherCourses, courseProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(int courseCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Courses',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your teaching courses ($courseCount total)',
            style: TextStyle(
              color: Colors.blue.shade600,
              fontSize: 16,
            ),
          ),
          if (_teacherEmail != null)
            Text(
              'Teacher: $_teacherEmail',
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

  Widget _buildErrorWidget(String error, VoidCallback onClear) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: onClear,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No Courses Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first course to start teaching',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showAddCourseDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Create First Course'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList(List<Course> courses, CourseProvider courseProvider) {
    return RefreshIndicator(
      onRefresh: () async => courseProvider.fetchCoursesByTeacher(_teacherEmail!),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return _buildCourseCard(courses[index], courseProvider);
        },
      ),
    );
  }

  Widget _buildCourseCard(Course course, CourseProvider courseProvider) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Course Image
                _buildCourseImage(course),
                const SizedBox(width: 16),
                
                // Course Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCourseMeta(course),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            _buildActionButtons(course, courseProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseImage(Course course) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.shade100,
      ),
      child: course.imageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                course.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.school, color: Colors.blue, size: 40);
                },
              ),
            )
          : const Icon(Icons.school, color: Colors.blue, size: 40),
    );
  }

  Widget _buildCourseMeta(Course course) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _buildMetaChip(Icons.category, course.category),
        if (course.level != null && course.level!.isNotEmpty)
          _buildMetaChip(Icons.school, course.level!),
        _buildMetaChip(Icons.schedule, '${course.duration} hours'),
        _buildMetaChip(Icons.star, '${course.rating} ⭐'),
      ],
    );
  }

  Widget _buildMetaChip(IconData icon, String text) {
    return Chip(
      label: Text(text),
      avatar: Icon(icon, size: 16),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildActionButtons(Course course, CourseProvider courseProvider) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showEditCourseDialog(course),
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showCourseDetails(course),
            icon: const Icon(Icons.visibility, size: 18),
            label: const Text('View'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showDeleteDialog(course, courseProvider),
            icon: const Icon(Icons.delete, size: 18),
            label: const Text('Delete'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  void _showAddCourseDialog() {
    showDialog(
      context: context,
      builder: (context) => CourseFormDialog(
        teacherEmail: _teacherEmail!,
        onSave: _loadTeacherCourses,
      ),
    );
  }

  void _showEditCourseDialog(Course course) {
    showDialog(
      context: context,
      builder: (context) => CourseFormDialog(
        teacherEmail: _teacherEmail!,
        course: course,
        onSave: _loadTeacherCourses,
      ),
    );
  }

  void _showCourseDetails(Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(course.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (course.imageUrl.isNotEmpty)
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(course.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                course.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildDetailItem('Category', course.category),
              if (course.level != null && course.level!.isNotEmpty)
                _buildDetailItem('Level', course.level!),
              _buildDetailItem('Duration', '${course.duration} hours'),
              _buildDetailItem('Rating', '${course.rating} ⭐'),
              _buildDetailItem('Teacher', course.teacherEmail),
              _buildDetailItem('Created', _formatDate(course.createdAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showDeleteDialog(Course course, CourseProvider courseProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course.title}"? This action cannot be undone.'),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCourse(course, courseProvider);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCourse(Course course, CourseProvider courseProvider) async {
    try {
      final success = await courseProvider.deleteCourse(course.id);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Course "${course.title}" deleted successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete course: ${courseProvider.error}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting course: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
