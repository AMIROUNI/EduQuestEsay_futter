// providers/teacher_dashboard_provider.dart
import 'package:eduquestesay/data/models/course_model.dart';
import 'package:eduquestesay/data/models/enrollment_model.dart';
import 'package:eduquestesay/data/models/lesson_model.dart';
import 'package:eduquestesay/data/services/teacher_dashboard_service.dart';
import 'package:flutter/foundation.dart';


class TeacherDashboardProvider with ChangeNotifier {
  final TeacherDashboardService _service;

  TeacherDashboardProvider({required TeacherDashboardService service}) 
      : _service = service;

  // State variables
  bool _isLoading = false;
  String _error = '';
  Map<String, dynamic>? _dashboardData;
  Map<String, dynamic>? _courseDetails;
  List<Enrollment> _courseStudents = [];
  Map<String, dynamic>? _analyticsData;

  // Getters
  bool get isLoading => _isLoading;
  String get error => _error;
  Map<String, dynamic>? get dashboardData => _dashboardData;
  Map<String, dynamic>? get courseDetails => _courseDetails;
  List<Enrollment> get courseStudents => _courseStudents;
  Map<String, dynamic>? get analyticsData => _analyticsData;

  // Helper getters for dashboard data
  int get totalCourses => _dashboardData?['totalCourses'] ?? 0;
  int get totalStudents => _dashboardData?['totalStudents'] ?? 0;
  int get totalLessons => _dashboardData?['totalLessons'] ?? 0;
  double get averageRating => _dashboardData?['averageRating']?.toDouble() ?? 0.0;
  List<Course> get recentCourses {
    if (_dashboardData?['recentCourses'] != null) {
      return (_dashboardData!['recentCourses'] as List)
          .map((course) => Course.fromJson(course))
          .toList();
    }
    return [];
  }
  Map<String, dynamic>? get progressSummary => _dashboardData?['progressSummary'];

  // State management methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  // 1. Get Teacher Dashboard Overview
  Future<void> fetchTeacherDashboard(String teacherEmail) async {
    _setLoading(true);
    _setError('');

    try {
      _dashboardData = await _service.getTeacherDashboard(teacherEmail);
      _setError('');
    } catch (e) {
      _setError('Failed to load dashboard: $e');
      _dashboardData = null;
    } finally {
      _setLoading(false);
    }
  }

  // 2. Get Course Details with Enrollments
  Future<void> fetchCourseDetails(int courseId) async {
    _setLoading(true);
    _setError('');

    try {
      _courseDetails = await _service.getCourseDetails(courseId);
      _setError('');
    } catch (e) {
      _setError('Failed to load course details: $e');
      _courseDetails = null;
    } finally {
      _setLoading(false);
    }
  }

  // 3. Get Students by Course
  Future<void> fetchCourseStudents(int courseId) async {
    _setLoading(true);
    _setError('');

    try {
      _courseStudents = await _service.getCourseStudents(courseId);
      _setError('');
    } catch (e) {
      _setError('Failed to load students: $e');
      _courseStudents = [];
    } finally {
      _setLoading(false);
    }
  }

  // 4. Add Lesson to Course
  Future<Lesson?> addLessonToCourse(int courseId, Lesson lesson) async {
    _setLoading(true);
    _setError('');

    try {
      final newLesson = await _service.addLessonToCourse(courseId, lesson);
      _setError('');
      
      // Refresh course details after adding lesson
      if (_courseDetails != null && _courseDetails!['course']?.id == courseId) {
        await fetchCourseDetails(courseId);
      }
      
      return newLesson;
    } catch (e) {
      _setError('Failed to add lesson: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // 5. Update Student Progress
  Future<Enrollment?> updateStudentProgress(int enrollmentId, double progress) async {
    _setLoading(true);
    _setError('');

    try {
      final updatedEnrollment = await _service.updateStudentProgress(enrollmentId, progress);
      
      // Update local state
      final index = _courseStudents.indexWhere((e) => e.id == enrollmentId);
      if (index != -1) {
        _courseStudents[index] = updatedEnrollment;
        notifyListeners();
      }
      
      _setError('');
      return updatedEnrollment;
    } catch (e) {
      _setError('Failed to update progress: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // 6. Get Teacher Analytics
  Future<void> fetchTeacherAnalytics(String teacherEmail) async {
    _setLoading(true);
    _setError('');

    try {
      _analyticsData = await _service.getTeacherAnalytics(teacherEmail);
      _setError('');
    } catch (e) {
      _setError('Failed to load analytics: $e');
      _analyticsData = null;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods to clear data
  void clearDashboardData() {
    _dashboardData = null;
    notifyListeners();
  }

  void clearCourseDetails() {
    _courseDetails = null;
    notifyListeners();
  }

  void clearAnalytics() {
    _analyticsData = null;
    notifyListeners();
  }

  void clearCourseStudents() {
    _courseStudents = [];
    notifyListeners();
  }

  void clearAll() {
    _dashboardData = null;
    _courseDetails = null;
    _courseStudents = [];
    _analyticsData = null;
    _error = '';
    notifyListeners();
  }
}