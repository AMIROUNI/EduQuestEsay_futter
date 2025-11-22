import 'package:eduquestesay/data/models/news_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eduquestesay/providers/news_provider.dart';
import 'package:eduquestesay/utils/app_bar.dart';
import 'package:eduquestesay/widgets/role_based_tabs.dart';
import 'package:eduquestesay/utils/tab_navigation_handler.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  int _currentTabIndex = 3; // Default to News tab
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  void _loadNews() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      if (newsProvider.news.isEmpty) {
        newsProvider.loadNews();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      body: Column(
        children: [
          _buildSearchBar(),
          if (newsProvider.hasError) _buildErrorWidget(context),
          Expanded(child: _buildNewsList()),
        ],            
      ),
      bottomNavigationBar: RoleBasedTabs(
        currentIndex: _currentTabIndex,
        onTabChanged: (index) {
          setState(() {
            _currentTabIndex = index;
          });
          TabNavigationHandler.handleTabChange(context, index);
        },
      ),
    );
  }

  // -------------------------------------------------------------
  // Search Bar
  // -------------------------------------------------------------
  Widget _buildSearchBar() {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: newsProvider.searchNews,
        decoration: InputDecoration(
          hintText: 'Search news...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              newsProvider.clearSearch();
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Error Widget
  // -------------------------------------------------------------
  Widget _buildErrorWidget(BuildContext context) {
    final provider = Provider.of<NewsProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Error loading news', style: const TextStyle(color: Colors.red)),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () {
              // You can add a clearError method to NewsProvider if needed
            },
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // News List
  // -------------------------------------------------------------
  Widget _buildNewsList() {
    final provider = Provider.of<NewsProvider>(context);

    // Load news if empty
    Future.microtask(() {
      if (provider.news.isEmpty && !provider.loading) {
        provider.loadNews();
      }
    });

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final displayNews = provider.filteredNews;

    if (displayNews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              provider.searchQuery.isEmpty
                  ? 'No news available'
                  : 'No news found matching your search',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: displayNews.length,
      itemBuilder: (context, index) {
        return _buildNewsCard(displayNews[index]);
      },
    );
  }

  // -------------------------------------------------------------
  // News Card
  // -------------------------------------------------------------
  Widget _buildNewsCard(News newsItem) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: ListTile(
        leading: newsItem.imageUrl.isNotEmpty
            ? Image.network(
                newsItem.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.article, size: 40, color: Colors.grey);
                },
              )
            : const Icon(Icons.article, size: 40, color: Colors.grey),
        title: Text(
          newsItem.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
          
            
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(newsItem.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          // You can add news detail navigation here if needed
          // Navigator.pushNamed(context, '/news-detail', arguments: newsItem);
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}