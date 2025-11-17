import 'dart:convert';
import 'package:eduquestesay/data/models/course_model.dart';
import 'package:http/http.dart' as http;


class CourseService {
  // For web development - use localhost with port 8099
  // Make sure your backend is running on localhost:8099
  final String apiUrl = "http://localhost:8099/api/courses";

  Future<List<Course>> fetchCourses() async {
    try {
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

  // Mock data for development when API is not available
  List<Course> _getMockCourses() {
    return [
      Course(
        id: '1',
        title: 'Flutter Development',
        description: 'Learn Flutter from scratch',
        teacherId: 'teacher1',
        createdAt: DateTime.now(),
        imageUrl: 'https://picsum.photos/200/300?random=1',
        rating: 4.5,
        category: 'Mobile Development',
        duration: 30,
      ),
      Course(
        id: '2',
        title: 'React Native',
        description: 'Build cross-platform apps',
        teacherId: 'teacher2',
        createdAt: DateTime.now(),
        imageUrl: 'https://picsum.photos/200/300?random=2',
        rating: 4.2,
        category: 'Mobile Development',
        duration: 25,
      ),
      Course(
        id: '3',
        title: 'Web Development',
        description: 'Master HTML, CSS, and JavaScript',
        teacherId: 'teacher3',
        createdAt: DateTime.now(),
        imageUrl: 'https://picsum.photos/200/300?random=3',
        rating: 4.7,
        category: 'Web Development',
        duration: 40,
      ),
      Course(
        id: '4',
        title: 'Data Science',
        description: 'Python, ML, and Data Analysis',
        teacherId: 'teacher4',
        createdAt: DateTime.now(),
        imageUrl: 'https://picsum.photos/200/300?random=4',
        rating: 4.8,
        category: 'Data Science',
        duration: 50,
      ),
      Course(
        id: '5',
        title: 'UI/UX Design',
        description: 'Design beautiful user interfaces',
        teacherId: 'teacher5',
        createdAt: DateTime.now(),
        imageUrl: 'https://picsum.photos/200/300?random=5',
        rating: 4.6,
        category: 'Design',
        duration: 20,
      ),
    ];
  }
}