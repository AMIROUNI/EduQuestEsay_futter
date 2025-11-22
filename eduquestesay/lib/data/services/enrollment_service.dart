// lib/data/services/enrollment_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/enrollment_model.dart';

class EnrollmentService {
  final String baseUrl = "http://localhost:8099/api/enrollments";

  // Enroll a student in a course
  Future<Enrollment> enrollUser(String studentEmail, String courseId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/enroll?studentEmail=$studentEmail&courseId=$courseId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return Enrollment.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to enroll. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to enroll: $e');
    }
  }

  // Get all enrollments
  Future<List<Enrollment>> getAllEnrollments() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((json) => Enrollment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load enrollments. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load enrollments: $e');
    }
  }

  // Get enrollments by student email
  Future<List<Enrollment>> getEnrollmentsByStudent(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student/$email'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((json) => Enrollment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load student enrollments. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load student enrollments: $e');
    }
  }

  // Get enrollments by course ID
  Future<List<Enrollment>> getEnrollmentsByCourse(String courseId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/course/$courseId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((json) => Enrollment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load course enrollments. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load course enrollments: $e');
    }
  }

  // Withdraw from a course
  Future<void> withdraw(String studentEmail, String courseId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/withdraw?studentEmail=$studentEmail&courseId=$courseId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to withdraw. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to withdraw: $e');
    }
  }

  // Update progress
  Future<Enrollment> updateProgress(String studentEmail, String courseId, double progress) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/progress?studentEmail=$studentEmail&courseId=$courseId&progress=$progress'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return Enrollment.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to update progress. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update progress: $e');
    }
  }

  // Check if student is enrolled in a course
  Future<bool> isStudentEnrolled(String studentEmail, String courseId) async {
    try {
      final enrollments = await getEnrollmentsByStudent(studentEmail);
      return enrollments.any((enrollment) => enrollment.courseId == courseId);
    } catch (e) {
      return false;
    }
  }
}