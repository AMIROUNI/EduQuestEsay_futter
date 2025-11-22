import 'package:eduquestesay/data/services/news_service.dart';
import 'package:flutter/material.dart';
import '../data/models/news_model.dart';

class NewsProvider extends ChangeNotifier {
  final NewsService _newsService = NewsService();

  bool isLoading = false;
  bool get loading => isLoading;
  List<News> newsList = [];
  List<News> get news => newsList;
  
  // Filtering properties
  String _searchQuery = '';
  List<News> _filteredNews = [];
  List<News> get filteredNews => _searchQuery.isEmpty ? newsList : _filteredNews;

  String get searchQuery => _searchQuery;

  Future<void> loadNews() async {
    isLoading = true;
    notifyListeners();
    try {
      newsList = await _newsService.getAllNews();
      _applyFilter(); // Apply any existing filter after loading
    } catch (e) {
      print(" Error loading news in provider: $e");
    }
    finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Simple search/filter method
  void searchNews(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applyFilter();
    notifyListeners();
  }

  // Clear search filter
  void clearSearch() {
    _searchQuery = '';
    _filteredNews = [];
    notifyListeners();
  }

  // Apply the filter based on search query
  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredNews = newsList;
    } else {
      _filteredNews = newsList.where((newsItem) {
        return newsItem.title.toLowerCase().contains(_searchQuery);
              
      }).toList();
    }
  }

  // Filter by category (if you have categories in your News model)
  void filterByCategory(String category) {
    _filteredNews = newsList.where((newsItem) {
      return newsItem.category?.toLowerCase() == category.toLowerCase();
    }).toList();
    notifyListeners();
  }

  // Get all unique categories from news
  List<String> getCategories() {
    final categories = newsList.map((news) => news.category ?? 'General').toSet().toList();
    categories.sort();
    return categories;
  }

  // Check if currently filtering
  bool get isFiltering => _searchQuery.isNotEmpty || _filteredNews.isNotEmpty;
}