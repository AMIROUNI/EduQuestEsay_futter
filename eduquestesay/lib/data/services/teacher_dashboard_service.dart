// services/teacher_dashboard_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';
import '../models/enrollment_model.dart';
import '../models/lesson_model.dart';

class TeacherDashboardService {
  static const String baseUrl = 'http://localhost:8099/api/teacher';
  final http.Client client;

  TeacherDashboardService({required this.client});

  // 1. Get Teacher Dashboard Overview
  Future<Map<String, dynamic>> getTeacherDashboard(String teacherEmail) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/dashboard/$teacherEmail'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load dashboard: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load dashboard: $e');
    }
  }

  // 2. Get Course Details with Enrollments
  Future<Map<String, dynamic>> getCourseDetails(int courseId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/course/$courseId/details'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Parse the course data
        if (data['course'] != null) {
          data['course'] = Course.fromJson(data['course']);
        }
        
        // Parse enrollments
        if (data['enrollments'] != null) {
          data['enrollments'] = (data['enrollments'] as List)
              .map((enrollment) => Enrollment.fromJson(enrollment))
              .toList();
        }
        
        // Parse lessons
        if (data['lessons'] != null) {
          data['lessons'] = (data['lessons'] as List)
              .map((lesson) => Lesson.fromJson(lesson))
              .toList();
        }
        
        return data;
      } else {
        throw Exception('Failed to load course details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load course details: $e');
    }
  }

  // 3. Get Students by Course
  Future<List<Enrollment>> getCourseStudents(int courseId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/course/$courseId/students'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((enrollment) => Enrollment.fromJson(enrollment)).toList();
      } else {
        throw Exception('Failed to load students: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load students: $e');
    }
  }

  // 4. Add Lesson to Course
  Future<Lesson> addLessonToCourse(int courseId, Lesson lesson) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/course/$courseId/lessons'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(lesson.toJson()),
      );

      if (response.statusCode == 200) {
        return Lesson.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add lesson: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add lesson: $e');
    }
  }

  // 5. Update Student Progress
  Future<Enrollment> updateStudentProgress(int enrollmentId, double progress) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/enrollment/$enrollmentId/progress?progress=$progress'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Enrollment.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update progress: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update progress: $e');
    }
  }

  // 6. Get Teacher Analytics
  Future<Map<String, dynamic>> getTeacherAnalytics(String teacherEmail) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/$teacherEmail/analytics'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load analytics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load analytics: $e');
    }
  }
}