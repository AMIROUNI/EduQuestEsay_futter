import 'package:eduquestesay/data/models/course_model.dart';
import 'package:eduquestesay/providers/auth_provider.dart';
import 'package:eduquestesay/providers/course_provider.dart';
import 'package:eduquestesay/providers/news_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CourseSearchWidget extends StatelessWidget {
  const CourseSearchWidget({super.key});


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
      backgroundColor: Colors.white,
   appBar: AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  toolbarHeight: 70,
  automaticallyImplyLeading: false,

  title: Row(
    children: [
      Image.asset(
        "assets/images/Logo.png",
        height: 40,
        fit: BoxFit.contain,
      ),

      const SizedBox(width: 12),

      const Text(
        "EduQuest",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w900,
          fontSize: 22,
          letterSpacing: -0.5,
        ),
      ),

      const Spacer(),

      PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'profile') {
            Navigator.pushNamed(context, '/profile');
          } else if (value == 'logout') {
            authProvider.signOut();
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        offset: const Offset(0, 50),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'profile',
            child: Row(
              children: const [
                Icon(Icons.person, size: 20),
                SizedBox(width: 10),
                Text("Profile"),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'logout',
            child: Row(
              children: const [
                Icon(Icons.logout, size: 20, color: Colors.red),
                SizedBox(width: 10),
                Text("Logout", style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.person, color: Colors.black),
        ),
      ),
    ],
  ),
),

      
      body: Column(
        children: [
          _buildNewsSlider(context),   
          _buildSearchBar(context),
          if (courseProvider.hasError) _buildErrorWidget(context),
          Expanded(child: _buildCourseList(context)),
        ],
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
        return _buildCourseCard(provider.courses[index]);
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
                course.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.book),
      ),
    );
  }
}
