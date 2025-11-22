import 'package:eduquestesay/data/models/lesson_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LessonService {
  final String apiUrl = "http://localhost:8099/api/lessons";

  Future<List<Lesson>> getLessonsByCourse(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/course/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        final List<dynamic> jsonResponse = json.decode(response.body);
        
        // Convert JSON list to List<Lesson>
        return jsonResponse.map((lessonJson) => Lesson.fromJson(lessonJson)).toList();
      } else {
        throw Exception('Failed to load lessons. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load lessons: $e');
    }
  }

  // Additional methods you might need:

  // Get all lessons
  Future<List<Lesson>> getAllLessons() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((lessonJson) => Lesson.fromJson(lessonJson)).toList();
      } else {
        throw Exception('Failed to load lessons. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load lessons: $e');
    }
  }

  // Get lesson by ID
  Future<Lesson> getLessonById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return Lesson.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load lesson. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load lesson: $e');
    }
  }

  // Create new lesson
  Future<Lesson> createLesson(Lesson lesson) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(lesson.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return Lesson.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to create lesson. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create lesson: $e');
    }
  }

  // Update lesson
  Future<Lesson> updateLesson(String id, Lesson lesson) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(lesson.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return Lesson.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to update lesson. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update lesson: $e');
    }
  }

  // Delete lesson
  Future<void> deleteLesson(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete lesson. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete lesson: $e');
    }
  }
}