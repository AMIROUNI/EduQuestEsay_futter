// widgets/course_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eduquestesay/providers/course_provider.dart';
import 'package:eduquestesay/data/models/course_model.dart';

class CourseFormDialog extends StatefulWidget {
  final String teacherEmail;
  final Course? course;
  final VoidCallback onSave;

  const CourseFormDialog({
    super.key,
    required this.teacherEmail,
    this.course,
    required this.onSave,
  });

  @override
  State<CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _durationController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _levelController = TextEditingController();

  bool _isSaving = false;

  final List<String> _categories = [
    'Mobile Development',
    'Web Development',
    'Data Science',
    'Design',
    'Business',
    'Marketing',
    'Photography',
    'Music',
    'Health & Fitness',
    'Language',
  ];

  final List<String> _levels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'All Levels'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      _titleController.text = widget.course!.title;
      _descriptionController.text = widget.course!.description;
      _categoryController.text = widget.course!.category;
      _durationController.text = widget.course!.duration.toString();
      _imageUrlController.text = widget.course!.imageUrl;
      _levelController.text = widget.course!.level ?? 'Beginner';
    } else {
      _levelController.text = 'Beginner';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _durationController.dispose();
    _imageUrlController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.course == null ? 'Create New Course' : 'Edit Course'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Course Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categoryController.text.isEmpty ? null : _categoryController.text,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _categoryController.text = value ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _levelController.text,
                decoration: const InputDecoration(
                  labelText: 'Level *',
                  border: OutlineInputBorder(),
                ),
                items: _levels.map((String level) {
                  return DropdownMenuItem<String>(
                    value: level,
                    child: Text(level),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _levelController.text = value ?? 'Beginner';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a level';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (hours) *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter course duration';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (optional)',
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/image.jpg',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveCourse,
          child: _isSaving 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _saveCourse() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        final courseProvider = Provider.of<CourseProvider>(context, listen: false);
        
        final course = Course(
          id: widget.course?.id ?? '0', // Backend will generate ID
          title: _titleController.text,
          description: _descriptionController.text,
          teacherEmail: widget.teacherEmail,
          createdAt: widget.course?.createdAt ?? DateTime.now(),
          imageUrl: _imageUrlController.text,
          rating: widget.course?.rating ?? 0.0,
          category: _categoryController.text,
          duration: int.parse(_durationController.text),
          level: _levelController.text,
        );

        bool success;
        if (widget.course == null) {
          success = await courseProvider.createCourse(course);
        } else {
          success = await courseProvider.updateCourse(course);
        }

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.course == null 
                  ? 'Course "${course.title}" created successfully!'
                  : 'Course "${course.title}" updated successfully!'
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
          widget.onSave();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save course: ${courseProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving course: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }
}