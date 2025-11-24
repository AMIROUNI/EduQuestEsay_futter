// providers/course_provider.dart
import 'package:eduquestesay/data/services/course_service.dart';
import 'package:flutter/foundation.dart';
import '../data/models/course_model.dart';

class CourseProvider with ChangeNotifier {
  final CourseService _courseService = CourseService();
  
  List<Course> _courses = [];
  List<Course> _filteredCourses = [];
  List<Course> _enrolledCourses = [];
  List<Course> _teacherCourses = [];
  Course? _currentCourse;
  
  bool _isLoading = false;
  bool _isLoadingEnrolled = false;
  bool _isLoadingTeacherCourses = false;
  
  String _error = '';
  String _enrolledError = '';
  String _teacherCoursesError = '';

  // Getters
  List<Course> get courses => _filteredCourses.isNotEmpty ? _filteredCourses : _courses;
  List<Course> get enrolledCourses => _enrolledCourses;
  List<Course> get teacherCourses => _teacherCourses;
  Course? get currentCourse => _currentCourse;
  
  bool get isLoading => _isLoading;
  bool get isLoadingEnrolled => _isLoadingEnrolled;
  bool get isLoadingTeacherCourses => _isLoadingTeacherCourses;
  
  String get error => _error;
  String get enrolledError => _enrolledError;
  String get teacherCoursesError => _teacherCoursesError;
  
  bool get hasError => _error.isNotEmpty;
  bool get hasEnrolledError => _enrolledError.isNotEmpty;
  bool get hasTeacherCoursesError => _teacherCoursesError.isNotEmpty;

  // 🔹 Get all courses
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

  // 🔹 Get course by ID
  Future<void> fetchCourseById(int id) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _currentCourse = await _courseService.getCourseById(id);
      if (_currentCourse == null) {
        _error = 'Course not found';
      }
    } catch (e) {
      _error = e.toString();
      print("❌ Error fetching course by ID: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Create new course
  Future<bool> createCourse(Course course) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final createdCourse = await _courseService.createCourse(course);
      _courses.add(createdCourse);
      print("✅ Course added to local list: ${createdCourse.title}");
      return true;
    } catch (e) {
      _error = e.toString();
      print("❌ Error creating course in provider: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Update course
  Future<bool> updateCourse(Course course) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final updatedCourse = await _courseService.updateCourse(course);
      final index = _courses.indexWhere((c) => c.id == course.id);
      if (index != -1) {
        _courses[index] = updatedCourse;
      }
      print("✅ Course updated in local list: ${updatedCourse.title}");
      return true;
    } catch (e) {
      _error = e.toString();
      print("❌ Error updating course in provider: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Delete course
  Future<bool> deleteCourse(String courseId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _courseService.deleteCourse(courseId);
      _courses.removeWhere((course) => course.id == courseId);
      _teacherCourses.removeWhere((course) => course.id == courseId);
      print("✅ Course deleted from local list: $courseId");
      return true;
    } catch (e) {
      _error = e.toString();
      print("❌ Error deleting course in provider: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Get courses by category
  Future<void> fetchCoursesByCategory(String category) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _courses = await _courseService.getCoursesByCategory(category);
      _filteredCourses = [];
      print("✅ Loaded ${_courses.length} courses in category: $category");
    } catch (e) {
      _error = e.toString();
      print("❌ Error fetching courses by category: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Get courses by level
  Future<void> fetchCoursesByLevel(String level) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _courses = await _courseService.getCoursesByLevel(level);
      _filteredCourses = [];
      print("✅ Loaded ${_courses.length} courses with level: $level");
    } catch (e) {
      _error = e.toString();
      print("❌ Error fetching courses by level: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Get courses by teacher
  Future<void> fetchCoursesByTeacher(String teacherEmail) async {
    _isLoadingTeacherCourses = true;
    _teacherCoursesError = '';
    notifyListeners();

    try {
      _teacherCourses = await _courseService.getCoursesByTeacher(teacherEmail);
      print("✅ Loaded ${_teacherCourses.length} courses for teacher: $teacherEmail");
    } catch (e) {
      _teacherCoursesError = e.toString();
      print("❌ Error fetching teacher courses: $e");
    } finally {
      _isLoadingTeacherCourses = false;
      notifyListeners();
    }
  }

  // 🔹 Search courses by title
  Future<void> searchCourses(String title) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      if (title.isEmpty) {
        _filteredCourses = [];
      } else {
        _filteredCourses = await _courseService.searchCourses(title);
        print("✅ Found ${_filteredCourses.length} courses matching: $title");
      }
    } catch (e) {
      _error = e.toString();
      print("❌ Error searching courses: $e");
      
      // Fallback to local search if API fails
      _filteredCourses = _courses.where((course) {
        final searchLower = title.toLowerCase();
        return course.title.toLowerCase().contains(searchLower) ||
               course.description.toLowerCase().contains(searchLower) ||
               course.category.toLowerCase().contains(searchLower);
      }).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Get enrolled courses for a student
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

  // Helper methods
  void clearSearch() {
    _filteredCourses = [];
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  void clearEnrolledError() {
    _enrolledError = '';
    notifyListeners();
  }

  void clearTeacherCoursesError() {
    _teacherCoursesError = '';
    notifyListeners();
  }

  void clearEnrolledCourses() {
    _enrolledCourses = [];
    notifyListeners();
  }

  void clearTeacherCourses() {
    _teacherCourses = [];
    notifyListeners();
  }

  void clearCurrentCourse() {
    _currentCourse = null;
    notifyListeners();
  }
}