import 'package:eduquestesay/data/models/lesson_model.dart';
import 'package:eduquestesay/data/services/lesson_service.dart';
import 'package:flutter/foundation.dart';

class LessonProvider with ChangeNotifier {
  final LessonService _lessonService = LessonService();
  
  List<Lesson> _lessons = [];
  List<Lesson> _filteredLessons = [];
  bool _isLoading = false;
  String _error = '';

  List<Lesson> get lessons => _filteredLessons.isNotEmpty ? _filteredLessons : _lessons;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasError => _error.isNotEmpty;

  // Get lesson by course ID
  Future<void> fetchLessonsByCourse(String courseId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _lessons = await _lessonService.getLessonsByCourse(courseId);
      _filteredLessons = [];
      print(" Loaded ${_lessons.length} lessons for course $courseId");
    } catch (e) {
      _error = e.toString();
      print(" Error fetching lessons: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get all lessons
  Future<void> fetchAllLessons() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _lessons = await _lessonService.getAllLessons();
      _filteredLessons = [];
      print(" Loaded ${_lessons.length} lessons");
    } catch (e) {
      _error = e.toString();
      print(" Error fetching all lessons: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get lesson by ID
  Future<Lesson?> fetchLessonById(String id) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final lesson = await _lessonService.getLessonById(id);
      _isLoading = false;
      notifyListeners();
      return lesson;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Create new lesson
  Future<bool> createLesson(Lesson lesson) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final newLesson = await _lessonService.createLesson(lesson);
      _lessons.add(newLesson);
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

  // Update lesson
  Future<bool> updateLesson(String id, Lesson lesson) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final updatedLesson = await _lessonService.updateLesson(id, lesson);
      final index = _lessons.indexWhere((l) => l.id == id);
      if (index != -1) {
        _lessons[index] = updatedLesson;
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

  // Delete lesson
  Future<bool> deleteLesson(String id) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _lessonService.deleteLesson(id);
      _lessons.removeWhere((lesson) => lesson.id == id);
      _filteredLessons.removeWhere((lesson) => lesson.id == id);
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

  // Search lessons
  void searchLessons(String query) {
    if (query.isEmpty) {
      _filteredLessons = [];
    } else {
      _filteredLessons = _lessons.where((lesson) {
        final searchLower = query.toLowerCase();
        return lesson.title.toLowerCase().contains(searchLower) ||
               lesson.content?.toLowerCase().contains(searchLower) == true;
      }).toList();
    }
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _filteredLessons = [];
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }



  // Get lesson by ID from local cache
  Lesson? getLessonById(String id) {
    try {
      return _lessons.firstWhere((lesson) => lesson.id == id);
    } catch (e) {
      return null;
    }
  }
}