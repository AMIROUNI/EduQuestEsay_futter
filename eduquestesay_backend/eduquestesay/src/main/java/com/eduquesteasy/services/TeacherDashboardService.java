package com.eduquesteasy.services;

import com.eduquesteasy.models.Course;
import com.eduquesteasy.models.Enrollment;
import com.eduquesteasy.models.Lesson;
import com.eduquesteasy.repositories.CourseRepository;
import com.eduquesteasy.repositories.EnrollmentRepository;
import com.eduquesteasy.repositories.LessonRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TeacherDashboardService {

    private final CourseRepository courseRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final LessonRepository lessonRepository;

    // Dashboard Statistics
    public long countCoursesByTeacher(String teacherEmail) {
        return courseRepository.findByTeacherEmail(teacherEmail).size();
    }

    public long countStudentsByTeacher(String teacherEmail) {
        // Get all courses by teacher, then count unique students across all enrollments
        List<Course> teacherCourses = courseRepository.findByTeacherEmail(teacherEmail);
        return teacherCourses.stream()
                .flatMap(course -> enrollmentRepository.findByCourseId(course.getId()).stream())
                .map(Enrollment::getStudentEmail)
                .distinct()
                .count();
    }

    public long countLessonsByTeacher(String teacherEmail) {
        // Get all courses by teacher, then sum lessons count
        List<Course> teacherCourses = courseRepository.findByTeacherEmail(teacherEmail);
        return teacherCourses.stream()
                .mapToLong(course -> lessonRepository.findByCourseId(course.getId()).size())
                .sum();
    }

    public double getAverageRatingByTeacher(String teacherEmail) {
        List<Course> teacherCourses = courseRepository.findByTeacherEmail(teacherEmail);
        if (teacherCourses.isEmpty()) {
            return 0.0;
        }
        return teacherCourses.stream()
                .mapToDouble(Course::getRating)
                .average()
                .orElse(0.0);
    }

    // Course Management
    public List<Course> getCoursesByTeacher(String teacherEmail) {
        return courseRepository.findByTeacherEmail(teacherEmail);
    }

    public List<Course> getRecentCoursesByTeacher(String teacherEmail, int limit) {
        List<Course> allCourses = courseRepository.findByTeacherEmail(teacherEmail);
        // Assuming courses have createdAt field, sort by ID for simplicity
        return allCourses.stream()
                .sorted((c1, c2) -> c2.getId().compareTo(c1.getId())) // Recent first
                .limit(limit)
                .collect(Collectors.toList());
    }

    public Course getCourseById(Long courseId) {
        return courseRepository.findById(courseId)
                .orElseThrow(() -> new RuntimeException("Course not found with id: " + courseId));
    }

    public Course createCourse(Course course) {
        return courseRepository.save(course);
    }

    public Course updateCourse(Long courseId, Course course) {
        Course existingCourse = getCourseById(courseId);

        // Update fields
        existingCourse.setTitle(course.getTitle());
        existingCourse.setDescription(course.getDescription());
        existingCourse.setCategory(course.getCategory());
        existingCourse.setImageUrl(course.getImageUrl());
        existingCourse.setLevel(course.getLevel());
        existingCourse.setRating(course.getRating());
        existingCourse.setDuration(course.getDuration());
        existingCourse.setTeacherEmail(course.getTeacherEmail());

        return courseRepository.save(existingCourse);
    }

    public void deleteCourse(Long courseId) {
        // First delete all lessons associated with the course
        List<Lesson> lessons = lessonRepository.findByCourseId(courseId);
        lessonRepository.deleteAll(lessons);

        // Then delete all enrollments
        List<Enrollment> enrollments = enrollmentRepository.findByCourseId(courseId);
        enrollmentRepository.deleteAll(enrollments);

        // Finally delete the course
        courseRepository.deleteById(courseId);
    }

    // Enrollment Management
    public List<Enrollment> getEnrollmentsByCourse(Long courseId) {
        return enrollmentRepository.findByCourseId(courseId);
    }

    public List<Enrollment> getEnrollmentsByTeacher(String teacherEmail) {
        // Get all courses by teacher, then get enrollments for each course
        List<Course> teacherCourses = courseRepository.findByTeacherEmail(teacherEmail);
        return teacherCourses.stream()
                .flatMap(course -> enrollmentRepository.findByCourseId(course.getId()).stream())
                .collect(Collectors.toList());
    }

    public Enrollment updateStudentProgress(Long enrollmentId, Double progress) {
        Enrollment enrollment = enrollmentRepository.findById(enrollmentId)
                .orElseThrow(() -> new RuntimeException("Enrollment not found with id: " + enrollmentId));

        enrollment.setProgress(progress);
        return enrollmentRepository.save(enrollment);
    }

    // Lesson Management
    public List<Lesson> getLessonsByCourse(Long courseId) {
        return lessonRepository.findByCourseIdOrderByOrderIndexAsc(courseId);
    }

    public Lesson addLessonToCourse(Long courseId, Lesson lesson) {
        Course course = getCourseById(courseId);
        lesson.setCourse(course);
        return lessonRepository.save(lesson);
    }

    // Analytics
    public Map<String, Object> getStudentProgressSummary(String teacherEmail) {
        Map<String, Object> summary = new HashMap<>();

        List<Enrollment> enrollments = getEnrollmentsByTeacher(teacherEmail);

        double averageProgress = enrollments.stream()
                .mapToDouble(Enrollment::getProgress)
                .average()
                .orElse(0.0);

        long completedStudents = enrollments.stream()
                .filter(e -> e.getProgress() >= 100.0)
                .count();

        long activeStudents = enrollments.stream()
                .filter(e -> e.getProgress() > 0 && e.getProgress() < 100)
                .count();

        long notStartedStudents = enrollments.stream()
                .filter(e -> e.getProgress() == 0)
                .count();

        summary.put("averageProgress", Math.round(averageProgress * 100.0) / 100.0);
        summary.put("completedStudents", completedStudents);
        summary.put("activeStudents", activeStudents);
        summary.put("notStartedStudents", notStartedStudents);
        summary.put("totalEnrollments", enrollments.size());

        return summary;
    }

    public List<Map<String, Object>> getCoursePerformance(String teacherEmail) {
        List<Course> courses = getCoursesByTeacher(teacherEmail);

        return courses.stream().map(course -> {
            Map<String, Object> performance = new HashMap<>();
            List<Enrollment> courseEnrollments = getEnrollmentsByCourse(course.getId());

            double avgProgress = courseEnrollments.stream()
                    .mapToDouble(Enrollment::getProgress)
                    .average()
                    .orElse(0.0);

            long totalStudents = courseEnrollments.size();
            long completedStudents = courseEnrollments.stream()
                    .filter(e -> e.getProgress() >= 100.0)
                    .count();

            performance.put("courseId", course.getId());
            performance.put("courseTitle", course.getTitle());
            performance.put("totalStudents", totalStudents);
            performance.put("completedStudents", completedStudents);
            performance.put("averageProgress", Math.round(avgProgress * 100.0) / 100.0);
            performance.put("rating", course.getRating());
            performance.put("completionRate", totalStudents > 0 ?
                    Math.round((completedStudents * 100.0 / totalStudents) * 100.0) / 100.0 : 0.0);

            return performance;
        }).collect(Collectors.toList());
    }

    public Map<String, Object> getStudentEngagementStats(String teacherEmail) {
        Map<String, Object> engagement = new HashMap<>();

        List<Enrollment> enrollments = getEnrollmentsByTeacher(teacherEmail);

        // Calculate engagement based on progress distribution
        long highEngagement = enrollments.stream()
                .filter(e -> e.getProgress() >= 75.0)
                .count();

        long mediumEngagement = enrollments.stream()
                .filter(e -> e.getProgress() >= 25.0 && e.getProgress() < 75.0)
                .count();

        long lowEngagement = enrollments.stream()
                .filter(e -> e.getProgress() > 0 && e.getProgress() < 25.0)
                .count();

        long noEngagement = enrollments.stream()
                .filter(e -> e.getProgress() == 0)
                .count();

        engagement.put("highEngagement", highEngagement);
        engagement.put("mediumEngagement", mediumEngagement);
        engagement.put("lowEngagement", lowEngagement);
        engagement.put("noEngagement", noEngagement);
        engagement.put("totalStudents", enrollments.size());

        // Calculate engagement rate (students with any progress)
        long engagedStudents = enrollments.stream()
                .filter(e -> e.getProgress() > 0)
                .count();

        double engagementRate = enrollments.size() > 0 ?
                Math.round((engagedStudents * 100.0 / enrollments.size()) * 100.0) / 100.0 : 0.0;

        engagement.put("engagementRate", engagementRate);

        return engagement;
    }

    public List<Map<String, Object>> getProgressTrends(String teacherEmail) {
        // For simplicity, return progress trends by course
        // In a real implementation, you might track progress over time
        List<Course> courses = getCoursesByTeacher(teacherEmail);

        return courses.stream().map(course -> {
            Map<String, Object> trend = new HashMap<>();
            List<Enrollment> courseEnrollments = getEnrollmentsByCourse(course.getId());

            double avgProgress = courseEnrollments.stream()
                    .mapToDouble(Enrollment::getProgress)
                    .average()
                    .orElse(0.0);

            trend.put("courseId", course.getId());
            trend.put("courseTitle", course.getTitle());
            trend.put("averageProgress", Math.round(avgProgress * 100.0) / 100.0);
            trend.put("studentCount", courseEnrollments.size());
            trend.put("trend", avgProgress > 50 ? "increasing" : "stable"); // Simplified trend

            return trend;
        }).collect(Collectors.toList());
    }
}