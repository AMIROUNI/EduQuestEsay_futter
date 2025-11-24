class Course {
  final String id;
  final String title;
  final String description;
  final String teacherEmail;
  final DateTime createdAt;
  final String imageUrl;
  final double rating;
  final String category;
  final int duration;
  final String level ; 

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.teacherEmail,
    required this.createdAt,
    required this.imageUrl,
    required this.rating,
    required this.category,
    required this.duration,
    required this.level
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id']?.toString() ?? '',
      level: json['level']?.toString() ?? '' ,
      title: json['title']?.toString() ?? 'No Title',
      description: json['description']?.toString() ?? 'No Description',
      teacherEmail: json['teacherEmail']?.toString() ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      imageUrl: json['imageUrl']?.toString() ?? '',
      rating: (json['rating'] is int ? (json['rating'] as int).toDouble() : 
              json['rating'] is double ? json['rating'] as double : 0.0),
      category: json['category']?.toString() ?? 'General',
      duration: (json['duration'] is int ? json['duration'] as int : 
                int.tryParse(json['duration']?.toString() ?? '0') ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'teacherEmail': teacherEmail,
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
      'rating': rating,
      'category': category,
      'duration': duration,
      'level': level,
    };
  }
}