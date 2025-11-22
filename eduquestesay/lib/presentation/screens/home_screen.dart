import 'package:eduquestesay/data/models/course_model.dart';
import 'package:eduquestesay/providers/auth_provider.dart';
import 'package:eduquestesay/providers/course_provider.dart';
import 'package:eduquestesay/providers/news_provider.dart';
import 'package:eduquestesay/widgets/role_based_tabs.dart';
import 'package:eduquestesay/utils/tab_navigation_handler.dart';
import 'package:eduquestesay/utils/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CourseSearchWidget extends StatefulWidget {
  const CourseSearchWidget({super.key});

  @override
  State<CourseSearchWidget> createState() => _CourseSearchWidgetState();
}

class _CourseSearchWidgetState extends State<CourseSearchWidget> {
  int _currentTabIndex = 1; // Default to Courses tab

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final newsProvider = Provider.of<NewsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Load news only once
    Future.microtask(() {
      if (newsProvider.news.isEmpty && !newsProvider.loading) {
        newsProvider.loadNews();
      }
    });

    return Scaffold(
      appBar: buildAppBar(context) ,
      body: Column(
        children: [
          _buildNewsSlider(context),   
          _buildSearchBar(context),
          if (courseProvider.hasError) _buildErrorWidget(context),
          Expanded(child: _buildCourseList(context)),
        ],
      ),
      // Add the bottom navigation bar here
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
  Widget _buildNewsSlider(BuildContext context) {
    final provider = Provider.of<NewsProvider>(context);

    if (provider.loading) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.news.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text("No news available")),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.news.length,
        itemBuilder: (context, index) {
          final item = provider.news[index];

          return Container(
            width: 300,
            margin: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                  color: Colors.black.withOpacity(0.15),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  // FULL IMAGE
                  Image.network(
                    item.imageUrl,
                    width: 300,
                    height: 200,
                    fit: BoxFit.cover,
                  ),

                  // GRADIENT OVERLAY
                  Container(
                    width: 300,
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent
                        ],
                      ),
                    ),
                  ),

                  // TITLE TEXT
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------
  // Search Bar
  // -------------------------------------------------------------
  Widget _buildSearchBar(BuildContext context) {
    final provider = Provider.of<CourseProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: provider.searchCourses,
        decoration: InputDecoration(
          hintText: 'Search courses...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
    final provider = Provider.of<CourseProvider>(context, listen: false);

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
            child: Text(provider.error, style: const TextStyle(color: Colors.red)),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: provider.clearError,
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Courses List
  // -------------------------------------------------------------
  Widget _buildCourseList(BuildContext context) {
    final provider = Provider.of<CourseProvider>(context);

    Future.microtask(() {
      if (provider.courses.isEmpty) {
        provider.fetchCourses();
      }
    });

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.courses.isEmpty) {
      return const Center(
        child: Text('No courses found', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: provider.courses.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          child: _buildCourseCard(provider.courses[index]),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/enrollment',
              arguments: provider.courses[index],
            );
          },
        );
      },
    );
  }

  // -------------------------------------------------------------
  // Course Card
  // -------------------------------------------------------------
  Widget _buildCourseCard(Course course) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: ListTile(
        title: Text(course.title),
        subtitle: Text(
          course.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        leading: course.imageUrl.isNotEmpty
            ? Image.network(
                  course.imageUrl ?? 'https://via.placeholder.com/400x200/3F51B5/FFFFFF?text=No+Image',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.book),
      ),
    );
  }
}