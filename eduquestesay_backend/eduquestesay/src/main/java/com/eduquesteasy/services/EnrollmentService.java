package com.eduquesteasy.services;

import com.eduquesteasy.models.Course;
import com.eduquesteasy.models.Enrollment;
import com.eduquesteasy.repositories.CourseRepository;
import com.eduquesteasy.repositories.EnrollmentRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class EnrollmentService {

    private final EnrollmentRepository enrollmentRepository;
    private final CourseRepository courseRepository;

    public EnrollmentService(
            EnrollmentRepository enrollmentRepository,
            CourseRepository courseRepository
    ) {
        this.enrollmentRepository = enrollmentRepository;
        this.courseRepository = courseRepository;
    }

    /**
     * Enroll a student (by email) in a course
     */
    public Enrollment enrollUser(String studentEmail, Long courseId) {

        // Check if course exists
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new RuntimeException("Course not found"));

        // Check if already enrolled
        enrollmentRepository.findByStudentEmailAndCourseId(studentEmail, courseId)
                .ifPresent(e -> {
                    throw new RuntimeException("Student already enrolled in this course");
                });

        // Create new enrollment
        Enrollment enrollment = new Enrollment();
        enrollment.setStudentEmail(studentEmail);
        enrollment.setCourse(course);

        return enrollmentRepository.save(enrollment);
    }

    /**
     * Get all enrollments
     */
    public List<Enrollment> getAllEnrollments() {
        return enrollmentRepository.findAll();
    }

    /**
     * Get all enrollments for a specific student
     */
    public List<Enrollment> getEnrollmentsByStudent(String studentEmail) {
        return enrollmentRepository.findByStudentEmail(studentEmail);
    }

    /**
     * Get all enrollments for a specific course
     */
    public List<Enrollment> getEnrollmentsByCourse(Long courseId) {
        return enrollmentRepository.findByCourseId(courseId);
    }

    /**
     * Withdraw student from course
     */
    public void withdraw(String studentEmail, Long courseId) {
        Enrollment enrollment = enrollmentRepository
                .findByStudentEmailAndCourseId(studentEmail, courseId)
                .orElseThrow(() -> new RuntimeException("Enrollment not found"));

        enrollmentRepository.delete(enrollment);
    }

    /**
     * Update progress of a student in a course
     */
    public Enrollment updateProgress(String studentEmail, Long courseId, double progress) {

        if (progress < 0 || progress > 100) {
            throw new RuntimeException("Progress must be between 0 and 100");
        }

        Enrollment enrollment = enrollmentRepository
                .findByStudentEmailAndCourseId(studentEmail, courseId)
                .orElseThrow(() -> new RuntimeException("Enrollment not found"));

        enrollment.setProgress(progress);

        return enrollmentRepository.save(enrollment);
    }
}
