package com.eduquesteasy.controllers;

import com.eduquesteasy.models.Enrollment;
import com.eduquesteasy.services.EnrollmentService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/enrollments")
public class EnrollmentController {

    private final EnrollmentService enrollmentService;

    public EnrollmentController(EnrollmentService enrollmentService) {
        this.enrollmentService = enrollmentService;
    }

    /**
     * Enroll a student in a course
     */
    @PostMapping("/enroll")
    public Enrollment enrollUser(
            @RequestParam String studentEmail,
            @RequestParam Long courseId
    ) {
        return enrollmentService.enrollUser(studentEmail, courseId);
    }

    /**
     * Get all enrollments
     */
    @GetMapping
    public List<Enrollment> getAll() {
        return enrollmentService.getAllEnrollments();
    }

    /**
     * Get all enrollments for a specific student by email
     */
    @GetMapping("/student/{email}")
    public List<Enrollment> getByStudent(@PathVariable String email) {
        return enrollmentService.getEnrollmentsByStudent(email);
    }

    /**
     * Get all enrollments for a specific course
     */
    @GetMapping("/course/{courseId}")
    public List<Enrollment> getByCourse(@PathVariable Long courseId) {
        return enrollmentService.getEnrollmentsByCourse(courseId);
    }

    /**
     * Withdraw a student from a course
     */
    @DeleteMapping("/withdraw")
    public String withdraw(
            @RequestParam String studentEmail,
            @RequestParam Long courseId
    ) {
        enrollmentService.withdraw(studentEmail, courseId);
        return "Student withdrawn successfully";
    }

    /**
     * Update progress for a student in a course
     */
    @PutMapping("/progress")
    public Enrollment updateProgress(
            @RequestParam String studentEmail,
            @RequestParam Long courseId,
            @RequestParam double progress
    ) {
        return enrollmentService.updateProgress(studentEmail, courseId, progress);
    }


}
