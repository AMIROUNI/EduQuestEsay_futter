import 'package:eduquestesay/data/services/news_service.dart';
import 'package:flutter/material.dart';
import '../data/models/news_model.dart';

class NewsProvider extends ChangeNotifier {
  final NewsService _newsService = NewsService();

  bool isLoading = false;
  bool get loading => isLoading;
  List<News> newsList = [];
  List<News> get news => newsList;
  

  Future<void> loadNews() async {
    isLoading = true;
    notifyListeners();
    try {
    newsList = await _newsService.getAllNews();

    } catch (e) {
      print(" Error loading news in provider: $e");
    }
    finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
