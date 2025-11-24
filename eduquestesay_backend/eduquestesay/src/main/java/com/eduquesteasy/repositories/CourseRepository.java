package com.eduquesteasy.repositories;

import com.eduquesteasy.models.Course;
import com.eduquesteasy.services.CourseService;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface CourseRepository extends JpaRepository<Course, Long> {

    // 🔹 Find courses by category
    List<Course> findByCategory(String category);

    // 🔹 Find courses by level
    List<Course> findByLevel(String level);

    // 🔹 Find courses by teacher email
    List<Course> findByTeacherEmail(String teacherEmail);

    // 🔹 Search by title (contains)
    List<Course> findByTitleContainingIgnoreCase(String title);

    @Query("""
       SELECT e.course
       FROM Enrollment e
       WHERE e.studentEmail = :studentEmail
       """)
    List<Course> findEnrollmentCoursesByStudentEmail(@Param("studentEmail") String studentEmail);

}
