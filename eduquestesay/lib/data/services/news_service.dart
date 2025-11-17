import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';

class NewsService {
  static const String baseUrl = "http://localhost:8099/api/news";

  Future<List<News>> getAllNews() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => News.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load news");
      }
    } catch (e) {
      print("⚠️ Error loading news: $e");
      return [];
    }
  }

  Future<News?> createNews(News news) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(news.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return News.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print("⚠️ Error creating news: $e");
      return null;
    }
  }
}
