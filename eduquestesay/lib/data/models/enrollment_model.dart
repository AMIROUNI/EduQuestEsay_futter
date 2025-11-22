
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
    return Enrollment(
      id: json['id']?.toString(),
      enrollmentDate: json['enrollmentDate'] != null 
          ? DateTime.parse(json['enrollmentDate'])
          : DateTime.now(),
      progress: (json['progress'] ?? 0.0).toDouble(),
      studentEmail: json['studentEmail'] ?? '',
      courseId: json['course'] != null 
          ? json['course']['id']?.toString() ?? json['course'].toString()
          : json['courseId']?.toString() ?? '',
      courseTitle: json['course'] != null && json['course'] is Map
          ? json['course']['title']
          : json['courseTitle'],
      courseDescription: json['course'] != null && json['course'] is Map
          ? json['course']['description']
          : json['courseDescription'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'progress': progress,
      'studentEmail': studentEmail,
      'courseId': courseId,
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