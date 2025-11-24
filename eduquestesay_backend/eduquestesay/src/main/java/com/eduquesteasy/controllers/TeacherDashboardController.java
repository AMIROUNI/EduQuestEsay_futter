package com.eduquesteasy.controllers;

import com.eduquesteasy.models.Course;
import com.eduquesteasy.models.Enrollment;
import com.eduquesteasy.models.Lesson;
import com.eduquesteasy.services.TeacherDashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/teacher")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class TeacherDashboardController {

    private final TeacherDashboardService teacherDashboardService;

    // 1. Get Teacher Dashboard Overview
    @GetMapping("/dashboard/{teacherEmail}")
    public ResponseEntity<Map<String, Object>> getTeacherDashboard(@PathVariable String teacherEmail) {
        try {
            Map<String, Object> dashboardData = new HashMap<>();

            // Basic stats
            long totalCourses = teacherDashboardService.countCoursesByTeacher(teacherEmail);
            long totalStudents = teacherDashboardService.countStudentsByTeacher(teacherEmail);
            long totalLessons = teacherDashboardService.countLessonsByTeacher(teacherEmail);
            double averageRating = teacherDashboardService.getAverageRatingByTeacher(teacherEmail);

            // Recent courses
            List<Course> recentCourses = teacherDashboardService.getRecentCoursesByTeacher(teacherEmail, 5);

            // Student progress summary
            Map<String, Object> progressSummary = teacherDashboardService.getStudentProgressSummary(teacherEmail);

            dashboardData.put("totalCourses", totalCourses);
            dashboardData.put("totalStudents", totalStudents);
            dashboardData.put("totalLessons", totalLessons);
            dashboardData.put("averageRating", averageRating);
            dashboardData.put("recentCourses", recentCourses);
            dashboardData.put("progressSummary", progressSummary);

            return ResponseEntity.ok(dashboardData);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // 2. Get Course Details with Enrollments
    @GetMapping("/course/{courseId}/details")
    public ResponseEntity<Map<String, Object>> getCourseDetails(@PathVariable Long courseId) {
        try {
            Map<String, Object> courseDetails = new HashMap<>();

            Course course = teacherDashboardService.getCourseById(courseId);
            List<Enrollment> enrollments = teacherDashboardService.getEnrollmentsByCourse(courseId);
            List<Lesson> lessons = teacherDashboardService.getLessonsByCourse(courseId);

            // Calculate course statistics
            double averageProgress = enrollments.stream()
                    .mapToDouble(Enrollment::getProgress)
                    .average()
                    .orElse(0.0);

            courseDetails.put("course", course);
            courseDetails.put("enrollments", enrollments);
            courseDetails.put("lessons", lessons);
            courseDetails.put("totalStudents", enrollments.size());
            courseDetails.put("averageProgress", averageProgress);

            return ResponseEntity.ok(courseDetails);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // 3. Get Students by Course
    @GetMapping("/course/{courseId}/students")
    public ResponseEntity<List<Enrollment>> getCourseStudents(@PathVariable Long courseId) {
        try {
            List<Enrollment> enrollments = teacherDashboardService.getEnrollmentsByCourse(courseId);
            return ResponseEntity.ok(enrollments);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(null);
        }
    }

    // 4. Add Lesson to Course
    @PostMapping("/course/{courseId}/lessons")
    public ResponseEntity<Lesson> addLessonToCourse(@PathVariable Long courseId, @RequestBody Lesson lesson) {
        try {
            Lesson savedLesson = teacherDashboardService.addLessonToCourse(courseId, lesson);
            return ResponseEntity.ok(savedLesson);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(null);
        }
    }

    // 5. Update Student Progress
    @PutMapping("/enrollment/{enrollmentId}/progress")
    public ResponseEntity<Enrollment> updateStudentProgress(
            @PathVariable Long enrollmentId,
            @RequestParam Double progress) {
        try {
            Enrollment updatedEnrollment = teacherDashboardService.updateStudentProgress(enrollmentId, progress);
            return ResponseEntity.ok(updatedEnrollment);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(null);
        }
    }

    // 6. Get Teacher Analytics
    @GetMapping("/{teacherEmail}/analytics")
    public ResponseEntity<Map<String, Object>> getTeacherAnalytics(@PathVariable String teacherEmail) {
        try {
            Map<String, Object> analytics = new HashMap<>();

            // Course performance
            List<Map<String, Object>> coursePerformance = teacherDashboardService.getCoursePerformance(teacherEmail);

            // Student engagement
            Map<String, Object> engagementStats = teacherDashboardService.getStudentEngagementStats(teacherEmail);

            // Progress trends
            List<Map<String, Object>> progressTrends = teacherDashboardService.getProgressTrends(teacherEmail);

            analytics.put("coursePerformance", coursePerformance);
            analytics.put("engagementStats", engagementStats);
            analytics.put("progressTrends", progressTrends);

            return ResponseEntity.ok(analytics);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}