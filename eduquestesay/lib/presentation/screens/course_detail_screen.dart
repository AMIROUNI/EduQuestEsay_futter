import 'package:eduquestesay/data/models/course_model.dart';
import 'package:eduquestesay/data/models/lesson_model.dart';
import 'package:eduquestesay/providers/lesson_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CourseDetailsScreen extends StatelessWidget {
  final Course course;

  const CourseDetailsScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LessonProvider()..fetchLessonsByCourse(course.id!),
      child: Scaffold(
        appBar: AppBar(
          title: Text(course.title),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Course Header Section
            CourseHeader(course: course),
            
            // Lessons Section
            Expanded(
              child: Consumer<LessonProvider>(
                builder: (context, lessonProvider, child) {
                  return LessonsSection(
                    course: course, 
                    lessonProvider: lessonProvider
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseHeader extends StatelessWidget {
  final Course course;

  const CourseHeader({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'By ${course.teacherEmail}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              course.category,
              style: TextStyle(
                color: Colors.blue[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            course.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class LessonsSection extends StatelessWidget {
  final Course course;
  final LessonProvider lessonProvider;

  const LessonsSection({
    super.key,
    required this.course,
    required this.lessonProvider,
  });

  @override
  Widget build(BuildContext context) {
    if (lessonProvider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading Lessons...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (lessonProvider.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading lessons',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              lessonProvider.error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                lessonProvider.fetchLessonsByCourse(course.id!);
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    final lessons = lessonProvider.lessons;

    if (lessons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No Lessons Available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lessons for "${course.title}" will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Course Lessons',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              Chip(
                backgroundColor: Colors.blue[100],
                label: Text(
                  '${lessons.length} ${lessons.length == 1 ? 'Lesson' : 'Lessons'}',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                return LessonCard(lesson: lesson, index: index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final int index;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lesson Number
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue[500],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Lesson Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey,
                    ),
                  ),
                  if (lesson.content != null && lesson.content!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      lesson.content!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Lesson Resources
                  Row(
                    children: [
                      if (lesson.videoUrl != null && lesson.videoUrl!.isNotEmpty)
                        ResourceChip(
                          icon: Icons.videocam,
                          label: 'Video',
                          color: Colors.green,
                        ),
                      if (lesson.pdfFile != null && lesson.pdfFile!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        ResourceChip(
                          icon: Icons.picture_as_pdf,
                          label: 'PDF',
                          color: Colors.red,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Play/View Button
            IconButton(
              onPressed: () {
                _showLessonPreview(context, lesson);
              },
              icon: Icon(
                Icons.play_arrow_rounded,
                color: Colors.blue[700],
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLessonPreview(BuildContext context, Lesson lesson) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              lesson.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (lesson.content != null) ...[
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    lesson.content!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implement lesson viewing logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Start Lesson'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ResourceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const ResourceChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}