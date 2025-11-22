import 'package:eduquestesay/data/services/course_service.dart';
import 'package:flutter/foundation.dart';
import '../data/models/course_model.dart';

class CourseProvider with ChangeNotifier {
  final CourseService _courseService = CourseService();
  
  List<Course> _courses = [];
  List<Course> _filteredCourses = [];
  List<Course> _enrolledCourses = []; // NEW: Store enrolled courses
  bool _isLoading = false;
  bool _isLoadingEnrolled = false; // NEW: Separate loading state for enrolled courses
  String _error = '';
  String _enrolledError = ''; // NEW: Separate error state for enrolled courses

  List<Course> get courses => _filteredCourses.isNotEmpty ? _filteredCourses : _courses;
  List<Course> get enrolledCourses => _enrolledCourses; // NEW: Getter for enrolled courses
  bool get isLoading => _isLoading;
  bool get isLoadingEnrolled => _isLoadingEnrolled; // NEW: Getter for enrolled loading state
  String get error => _error;
  String get enrolledError => _enrolledError; // NEW: Getter for enrolled error
  bool get hasError => _error.isNotEmpty;
  bool get hasEnrolledError => _enrolledError.isNotEmpty; // NEW: Check if enrolled has error

  Future<void> fetchCourses() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _courses = await _courseService.fetchCourses();
      _filteredCourses = [];
      print("✅ Loaded ${_courses.length} courses in provider");
    } catch (e) {
      _error = e.toString();
      print("❌ Error in provider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // NEW METHOD: Fetch enrolled courses for a student
  Future<void> fetchEnrolledCourses(String studentEmail) async {
    _isLoadingEnrolled = true;
    _enrolledError = '';
    notifyListeners();

    try {
      _enrolledCourses = await _courseService.fetchEnrolledCourses(studentEmail);
      print("✅ Loaded ${_enrolledCourses.length} enrolled courses in provider");
    } catch (e) {
      _enrolledError = e.toString();
      print("❌ Error fetching enrolled courses in provider: $e");
    } finally {
      _isLoadingEnrolled = false;
      notifyListeners();
    }
  }

  void searchCourses(String query) {
    if (query.isEmpty) {
      _filteredCourses = [];
    } else {
      _filteredCourses = _courses.where((course) {
        final searchLower = query.toLowerCase();
        return course.title.toLowerCase().contains(searchLower) ||
               course.description.toLowerCase().contains(searchLower) ||
               course.category.toLowerCase().contains(searchLower);
      }).toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    _filteredCourses = [];
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  // NEW: Clear enrolled courses error
  void clearEnrolledError() {
    _enrolledError = '';
    notifyListeners();
  }

  // NEW: Clear enrolled courses
  void clearEnrolledCourses() {
    _enrolledCourses = [];
    notifyListeners();
  }
}