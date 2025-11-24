import 'dart:convert';
import 'package:eduquestesay/data/models/course_model.dart';
import 'package:http/http.dart' as http;

class CourseService {
  // For web development - use localhost with port 8099
  // Make sure your backend is running on localhost:8099
  final String baseUrl = "http://localhost:8099/api";

  // 🔹 Get all courses
  Future<List<Course>> fetchCourses() async {
    try {
      final apiUrl = "$baseUrl/courses";
      print("Fetching courses from: $apiUrl");
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print(" Response status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(" Successfully fetched ${data.length} courses");
        
        final courses = data.map((courseJson) => Course.fromJson(courseJson)).toList();
        return courses;
      } else {
        print(" API Error: ${response.statusCode} - ${response.body}");
        
        // Return mock data for testing if API fails
        if (response.statusCode == 404 || response.statusCode == 500) {
          print("Using mock data for development");
          return _getMockCourses();
        }
        
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } catch (e) {
      print("Network Error: $e");
      
      // Return mock data for development
      print(" Using mock data due to error");
      return _getMockCourses();
    }
  }

  // 🔹 Get course by ID
  Future<Course?> getCourseById(int id) async {
    try {
      final apiUrl = "$baseUrl/courses/$id";
      print("Fetching course by ID from: $apiUrl");
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print(" Response status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        final course = Course.fromJson(data);
        print(" Successfully fetched course: ${course.title}");
        return course;
      } else if (response.statusCode == 404) {
        print(" Course not found with ID: $id");
        return null;
      } else {
        print(" API Error: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to load course: ${response.statusCode}');
      }
    } catch (e) {
      print("Network Error fetching course by ID: $e");
      throw Exception('Failed to load course: $e');
    }
  }

  // services/course_service.dart
Future<Course> createCourse(Course course) async {
  try {
    final apiUrl = "$baseUrl/courses";
    print("Creating course at: $apiUrl");
    
    // Convert course to JSON properly
    final courseJson = course.toJson();
    print("Course data: $courseJson");

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(courseJson), // Use jsonEncode instead of json.encode
    ).timeout(const Duration(seconds: 15));

    print("Create course response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dynamic data = jsonDecode(response.body);
      final createdCourse = Course.fromJson(data);
      print(" Course created successfully: ${createdCourse.title}");
      return createdCourse;
    } else {
      print(" API Error creating course: ${response.statusCode} - ${response.body}");
      throw Exception('Failed to create course: ${response.statusCode}');
    }
  } catch (e) {
    print(" Network Error creating course: $e");
    throw Exception('Failed to create course: $e');
  }
}

  // 🔹 Update course
  Future<Course> updateCourse(Course course) async {
    try {
      final apiUrl = "$baseUrl/courses/${course.id}";
      print("Updating course at: $apiUrl");
      print("Course data: ${course.toJson()}");

      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(course.toJson()),
      ).timeout(const Duration(seconds: 15));

      print("Update course response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        final updatedCourse = Course.fromJson(data);
        print(" Course updated successfully: ${updatedCourse.title}");
        return updatedCourse;
      } else if (response.statusCode == 404) {
        throw Exception('Course not found with ID: ${course.id}');
      } else {
        final errorMessage = json.decode(response.body);
        print(" API Error updating course: ${response.statusCode} - $errorMessage");
        throw Exception('Failed to update course: ${response.statusCode} - $errorMessage');
      }
    } catch (e) {
      print(" Network Error updating course: $e");
      throw Exception('Failed to update course: $e');
    }
  }

  // 🔹 Delete course
  Future<void> deleteCourse(String courseId) async {
    try {
      final apiUrl = "$baseUrl/courses/$courseId";
      print("Deleting course at: $apiUrl");

      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print("Delete course response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        print(" Course deleted successfully: $courseId");
      } else if (response.statusCode == 404) {
        throw Exception('Course not found with ID: $courseId');
      } else {
        final errorMessage = json.decode(response.body);
        print(" API Error deleting course: ${response.statusCode} - $errorMessage");
        throw Exception('Failed to delete course: ${response.statusCode} - $errorMessage');
      }
    } catch (e) {
      print(" Network Error deleting course: $e");
      throw Exception('Failed to delete course: $e');
    }
  }

  // 🔹 Get courses by category
  Future<List<Course>> getCoursesByCategory(String category) async {
    try {
      final encodedCategory = Uri.encodeComponent(category);
      final apiUrl = "$baseUrl/courses/category/$encodedCategory";
      print("Fetching courses by category from: $apiUrl");
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print(" Response status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(" Successfully fetched ${data.length} courses in category: $category");
        
        final courses = data.map((courseJson) => Course.fromJson(courseJson)).toList();
        return courses;
      } else {
        print(" API Error: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to load courses by category: ${response.statusCode}');
      }
    } catch (e) {
      print("Network Error fetching courses by category: $e");
      throw Exception('Failed to load courses by category: $e');
    }
  }

  // 🔹 Get courses by level
  Future<List<Course>> getCoursesByLevel(String level) async {
    try {
      final encodedLevel = Uri.encodeComponent(level);
      final apiUrl = "$baseUrl/courses/level/$encodedLevel";
      print("Fetching courses by level from: $apiUrl");
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print(" Response status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(" Successfully fetched ${data.length} courses with level: $level");
        
        final courses = data.map((courseJson) => Course.fromJson(courseJson)).toList();
        return courses;
      } else {
        print(" API Error: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to load courses by level: ${response.statusCode}');
      }
    } catch (e) {
      print("Network Error fetching courses by level: $e");
      throw Exception('Failed to load courses by level: $e');
    }
  }

  // 🔹 Get courses by teacher
  Future<List<Course>> getCoursesByTeacher(String teacherEmail) async {
    try {
      final encodedEmail = Uri.encodeComponent(teacherEmail);
      final apiUrl = "$baseUrl/courses/teacher/$encodedEmail";
      print("Fetching courses by teacher from: $apiUrl");
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print(" Response status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(" Successfully fetched ${data.length} courses for teacher: $teacherEmail");
        
        final courses = data.map((courseJson) => Course.fromJson(courseJson)).toList();
        return courses;
      } else {
        print(" API Error: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to load courses by teacher: ${response.statusCode}');
      }
    } catch (e) {
      print("Network Error fetching courses by teacher: $e");
      throw Exception('Failed to load courses by teacher: $e');
    }
  }

  // 🔹 Search courses by title
  Future<List<Course>> searchCourses(String title) async {
    try {
      final encodedTitle = Uri.encodeComponent(title);
      final apiUrl = "$baseUrl/courses/search?title=$encodedTitle";
      print("Searching courses from: $apiUrl");
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print(" Response status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(" Successfully found ${data.length} courses matching: $title");
        
        final courses = data.map((courseJson) => Course.fromJson(courseJson)).toList();
        return courses;
      } else {
        print(" API Error: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to search courses: ${response.statusCode}');
      }
    } catch (e) {
      print("Network Error searching courses: $e");
      throw Exception('Failed to search courses: $e');
    }
  }

  // 🔹 Get enrolled courses for a student
  Future<List<Course>> fetchEnrolledCourses(String studentEmail) async {
    try {
      final encodedEmail = Uri.encodeComponent(studentEmail);
      final apiUrl = "$baseUrl/courses/get/enrollment/courses/$encodedEmail";
      
      print("Fetching enrolled courses from: $apiUrl");
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print(" Response status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        print(" Successfully fetched enrolled courses");
        
        if (data is List) {
          final courses = data.map<Course>((courseJson) => Course.fromJson(courseJson)).toList();
          print(" Parsed ${courses.length} enrolled courses");
          return courses;
        } else {
          print(" Unexpected response format for enrolled courses: $data");
          return [];
        }
      } else if (response.statusCode == 500) {
        final errorMessage = json.decode(response.body);
        throw Exception('Server error: $errorMessage');
      } else {
        print(" API Error for enrolled courses: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to load enrolled courses: ${response.statusCode}');
      }
    } catch (e) {
      print("Network Error fetching enrolled courses: $e");
      
      // Return mock enrolled courses for development
      print(" Using mock enrolled courses due to error");
      return _getMockEnrolledCourses();
    }
  }

  // Mock data for development when API is not available
  List<Course> _getMockCourses() {
    return [
      Course(
        id: '1',
        title: 'Flutter Development',
        description: 'Learn Flutter from scratch',
        teacherEmail: 'teacher1',
        createdAt: DateTime.now(),
        imageUrl: 'https://picsum.photos/200/300?random=1',
        rating: 4.5,
        category: 'Mobile Development',
        duration: 30,
        level: 'Beginner',
      ),
      Course(
        id: '2',
        title: 'React Native',
        description: 'Build cross-platform apps',
        teacherEmail: 'teacher2',
        createdAt: DateTime.now(),
        imageUrl: 'https://picsum.photos/200/300?random=2',
        rating: 4.2,
        category: 'Mobile Development',
        duration: 25,
        level: 'Intermediate',
      ),
      Course(
        id: '3',
        title: 'Web Development',
        description: 'Master HTML, CSS, and JavaScript',
        teacherEmail: 'teacher3',
        createdAt: DateTime.now(),
        imageUrl: 'https://picsum.photos/200/300?random=3',
        rating: 4.7,
        category: 'Web Development',
        duration: 40,
        level: 'Beginner',
      ),
      Course(
        id: '4',
        title: 'Data Science',
        description: 'Python, ML, and Data Analysis',
        teacherEmail: 'teacher4',
        createdAt: DateTime.now(),
        imageUrl: 'https://picsum.photos/200/300?random=4',
        rating: 4.8,
        category: 'Data Science',
        duration: 50,
        level: 'Advanced',
      ),
      Course(
        id: '5',
        title: 'UI/UX Design',
        description: 'Design beautiful user interfaces',
        teacherEmail: 'teacher5',
        createdAt: DateTime.now(),
        imageUrl: 'https://picsum.photos/200/300?random=5',
        rating: 4.6,
        category: 'Design',
        duration: 20,
        level: 'Intermediate',
      ),
    ];
  }

  // Mock enrolled courses for development
  List<Course> _getMockEnrolledCourses() {
    return [
      Course(
        id: '1',
        title: 'Flutter Development',
        description: 'Learn Flutter from scratch - ENROLLED',
        teacherEmail: 'teacher1',
        createdAt: DateTime.now(),
        imageUrl: 'https://picsum.photos/200/300?random=1',
        rating: 4.5,
        category: 'Mobile Development',
        duration: 30,
        level: 'Beginner',
      ),
      Course(
        id: '3',
        title: 'Web Development',
        description: 'Master HTML, CSS, and JavaScript - ENROLLED',
        teacherEmail: 'teacher3',
        createdAt: DateTime.now(),
        imageUrl: 'https://picsum.photos/200/300?random=3',
        rating: 4.7,
        category: 'Web Development',
        duration: 40,
        level: 'Beginner',
      ),
    ];
  }
}