package com.eduquesteasy.repositories;

import com.eduquesteasy.models.Enrollment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface EnrollmentRepository extends JpaRepository<Enrollment, Long> {

    List<Enrollment> findByStudentEmail(String studentEmail);

    // Get all enrollments of a course
    List<Enrollment> findByCourseId(Long courseId);

    // Check if a student is already enrolled in a course
    Optional<Enrollment> findByStudentEmailAndCourseId(String studentEmail, Long courseId);
}
