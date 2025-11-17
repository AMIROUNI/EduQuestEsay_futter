import 'package:eduquestesay/data/services/course_service.dart';
import 'package:flutter/foundation.dart';
import '../data/models/course_model.dart';


class CourseProvider with ChangeNotifier {
  final CourseService _courseService = CourseService();
  
  List<Course> _courses = [];
  List<Course> _filteredCourses = [];
  bool _isLoading = false;
  String _error = '';

  List<Course> get courses => _filteredCourses.isNotEmpty ? _filteredCourses : _courses;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasError => _error.isNotEmpty;

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
}