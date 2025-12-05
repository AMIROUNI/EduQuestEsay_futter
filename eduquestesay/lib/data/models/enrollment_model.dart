class Enrollment {
  final String? id;
  final DateTime enrollmentDate;
  final double progress;
  final String studentEmail;
  final String courseId;
  final String? courseTitle;
  final String? courseDescription;

  Enrollment({
    this.id,
    required this.enrollmentDate,
    required this.progress,
    required this.studentEmail,
    required this.courseId,
    this.courseTitle,
    this.courseDescription,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    try {
      // Gérer le ID
      String? id;
      if (json['id'] != null) {
        id = json['id'].toString();
      }

      // Gérer la date
      DateTime enrollmentDate;
      if (json['enrollmentDate'] != null) {
        if (json['enrollmentDate'] is String) {
          enrollmentDate = DateTime.parse(json['enrollmentDate']);
        } else {
          enrollmentDate = DateTime.now();
        }
      } else {
        enrollmentDate = DateTime.now();
      }

      // Gérer le progress
      double progress;
      if (json['progress'] != null) {
        if (json['progress'] is double) {
          progress = json['progress'];
        } else if (json['progress'] is int) {
          progress = (json['progress'] as int).toDouble();
        } else if (json['progress'] is String) {
          progress = double.tryParse(json['progress']) ?? 0.0;
        } else {
          progress = 0.0;
        }
      } else {
        progress = 0.0;
      }

      // Gérer studentEmail
      String studentEmail = json['studentEmail']?.toString() ?? '';

      // Gérer le course ID - C'EST ICI LE PROBLÈME PRINCIPAL
      String courseId = '';
      
      if (json['course'] != null) {
        if (json['course'] is Map<String, dynamic>) {
          // Si course est un objet avec 'id'
          final courseMap = json['course'] as Map<String, dynamic>;
          if (courseMap['id'] != null) {
            courseId = courseMap['id'].toString();
          }
        } else if (json['course'] is String) {
          // Si course est juste un ID string
          courseId = json['course'] as String;
        } else if (json['course'] is num) {
          // Si course est un nombre
          courseId = json['course'].toString();
        }
      } else if (json['courseId'] != null) {
        // Fallback à courseId direct
        courseId = json['courseId'].toString();
      }

      // Gérer courseTitle et courseDescription
      String? courseTitle;
      String? courseDescription;
      
      if (json['course'] != null && json['course'] is Map<String, dynamic>) {
        final courseMap = json['course'] as Map<String, dynamic>;
        courseTitle = courseMap['title']?.toString();
        courseDescription = courseMap['description']?.toString();
      }

      return Enrollment(
        id: id,
        enrollmentDate: enrollmentDate,
        progress: progress,
        studentEmail: studentEmail,
        courseId: courseId,
        courseTitle: courseTitle,
        courseDescription: courseDescription,
      );
    } catch (e, stackTrace) {
      print('Error parsing Enrollment JSON: $e');
      print('JSON was: $json');
      print('Stack trace: $stackTrace');
      // Retourner un Enrollment vide plutôt que de planter
      return Enrollment(
        id: null,
        enrollmentDate: DateTime.now(),
        progress: 0.0,
        studentEmail: json['studentEmail']?.toString() ?? '',
        courseId: json['courseId']?.toString() ?? '',
        courseTitle: null,
        courseDescription: null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'progress': progress,
      'studentEmail': studentEmail,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'courseDescription': courseDescription,
    };
  }

  Enrollment copyWith({
    String? id,
    DateTime? enrollmentDate,
    double? progress,
    String? studentEmail,
    String? courseId,
    String? courseTitle,
    String? courseDescription,
  }) {
    return Enrollment(
      id: id ?? this.id,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      progress: progress ?? this.progress,
      studentEmail: studentEmail ?? this.studentEmail,
      courseId: courseId ?? this.courseId,
      courseTitle: courseTitle ?? this.courseTitle,
      courseDescription: courseDescription ?? this.courseDescription,
    );
  }
}