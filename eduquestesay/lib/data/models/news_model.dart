class News {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String link;
  final DateTime createdAt;

  News({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.link,
    required this.createdAt,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      link: json['link'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'].toString()) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'link': link,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
