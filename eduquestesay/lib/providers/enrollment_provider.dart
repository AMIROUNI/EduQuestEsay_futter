
import 'package:flutter/foundation.dart';
import '../data/models/enrollment_model.dart';
import '../data/services/enrollment_service.dart';

class EnrollmentProvider with ChangeNotifier {
  final EnrollmentService _enrollmentService = EnrollmentService();
  
  List<Enrollment> _enrollments = [];
  List<Enrollment> _studentEnrollments = [];
  bool _isLoading = false;
  String _error = '';

  List<Enrollment> get enrollments => _enrollments;
  List<Enrollment> get studentEnrollments => _studentEnrollments;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasError => _error.isNotEmpty;

  // Enroll in a course
  Future<bool> enrollUser(String studentEmail, String courseId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final newEnrollment = await _enrollmentService.enrollUser(studentEmail, courseId);
      _enrollments.add(newEnrollment);
      _studentEnrollments.add(newEnrollment);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get all enrollments
  Future<void> fetchAllEnrollments() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _enrollments = await _enrollmentService.getAllEnrollments();
      print("✅ Loaded ${_enrollments.length} enrollments");
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print("❌ Error fetching enrollments: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get enrollments by student
  Future<void> fetchStudentEnrollments(String email) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _studentEnrollments = await _enrollmentService.getEnrollmentsByStudent(email);
      print(" Loaded ${_studentEnrollments.length} enrollments for student: $email");
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print(" Error fetching student enrollments: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

   Future<void> fetchTeacherEnrollments(String email) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _studentEnrollments = await _enrollmentService.getEnrollmentsByTeacher(email);
      print(" Loaded ${_studentEnrollments.length} enrollments for student: $email");
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print(" Error fetching student enrollments: $e");
      _isLoading = false;
      notifyListeners();
    }
  }


  // Get enrollments by course
  Future<List<Enrollment>> fetchCourseEnrollments(String courseId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final courseEnrollments = await _enrollmentService.getEnrollmentsByCourse(courseId);
      _isLoading = false;
      notifyListeners();
      return courseEnrollments;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Withdraw from course
  Future<bool> withdraw(String studentEmail, String courseId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _enrollmentService.withdraw(studentEmail, courseId);
      _enrollments.removeWhere((enrollment) => 
          enrollment.studentEmail == studentEmail && enrollment.courseId == courseId);
      _studentEnrollments.removeWhere((enrollment) => 
          enrollment.studentEmail == studentEmail && enrollment.courseId == courseId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update progress
  Future<bool> updateProgress(String studentEmail, String courseId, double progress) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final updatedEnrollment = await _enrollmentService.updateProgress(
        studentEmail, courseId, progress
      );

      // Update in enrollments list
      final index = _enrollments.indexWhere((e) => 
          e.studentEmail == studentEmail && e.courseId == courseId);
      if (index != -1) {
        _enrollments[index] = updatedEnrollment;
      }

      // Update in student enrollments list
      final studentIndex = _studentEnrollments.indexWhere((e) => 
          e.studentEmail == studentEmail && e.courseId == courseId);
      if (studentIndex != -1) {
        _studentEnrollments[studentIndex] = updatedEnrollment;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check if enrolled
  Future<bool> isEnrolled(String studentEmail, String courseId) async {
    try {
      return await _enrollmentService.isStudentEnrolled(studentEmail, courseId);
    } catch (e) {
      return false;
    }
  }

  // Get enrollment by course and student
  Enrollment? getEnrollment(String studentEmail, String courseId) {
    try {
      return _studentEnrollments.firstWhere(
        (enrollment) => 
            enrollment.studentEmail == studentEmail && enrollment.courseId == courseId
      );
    } catch (e) {
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Get progress for a course
  double getProgress(String studentEmail, String courseId) {
    final enrollment = getEnrollment(studentEmail, courseId);
    return enrollment?.progress ?? 0.0;
  }

  // Get completed courses count
  int getCompletedCoursesCount(String studentEmail) {
    return _studentEnrollments
        .where((enrollment) => 
            enrollment.studentEmail == studentEmail && enrollment.progress >= 100.0)
        .length;
  }

  // Get in-progress courses count
  int getInProgressCoursesCount(String studentEmail) {
    return _studentEnrollments
        .where((enrollment) => 
            enrollment.studentEmail == studentEmail && 
            enrollment.progress > 0.0 && 
            enrollment.progress < 100.0)
        .length;
  }
}