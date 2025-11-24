package com.eduquesteasy.controllers;

import com.eduquesteasy.Request.CourseRequest;
import com.eduquesteasy.models.Course;
import com.eduquesteasy.services.CourseService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
@Slf4j
@RestController
@RequestMapping("/api/courses")
@CrossOrigin(origins = "*")
public class CourseController {

    @Autowired
    private CourseService courseService;

    // 🔹 Get all courses
    @GetMapping
    public List<Course> getAllCourses() {
        return courseService.getAllCourses();
    }

    // 🔹 Get course by ID
    @GetMapping("/{id}")
    public ResponseEntity<Course> getCourseById(@PathVariable Long id) {
        Optional<Course> course = courseService.getCourseById(id);
        return course.map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // 🔹 Create new course
    @PostMapping
    public ResponseEntity<?> createCourse(@RequestBody CourseRequest courseRequest) {
        try {

            log.info("Creating course from request: {}", courseRequest.toString());
            log.info("Teacher Email received: {}", courseRequest.getTeacherEmail());
            log.info("Level received: {}", courseRequest.getLevel());
            log.info("Creating course from request: {}", courseRequest);

            // Convert DTO to Entity
            Course course = new Course();
            course.setTitle(courseRequest.getTitle());
            course.setDescription(courseRequest.getDescription());
            course.setCategory(courseRequest.getCategory());
            course.setImageUrl(courseRequest.getImageUrl());
            course.setLevel(courseRequest.getLevel());
            course.setRating(courseRequest.getRating());
            course.setDuration(courseRequest.getDuration());
            course.setTeacherEmail(courseRequest.getTeacherEmail());

            Course savedCourse = courseService.saveCourse(course);
            return ResponseEntity.ok().body(savedCourse);
        } catch (Exception e) {
            log.error("Error creating course: ", e);
            return ResponseEntity.internalServerError().body(e.getMessage());
        }
    }


    // 🔹 Update course
    @PutMapping("/{id}")
    public ResponseEntity<Course> updateCourse(@PathVariable Long id, @RequestBody CourseRequest  courseDetails) {
        Optional<Course> existingCourse = courseService.getCourseById(id);

        if (existingCourse.isPresent()) {
            Course course = existingCourse.get();
            course.setTitle(courseDetails.getTitle());
            course.setDescription(courseDetails.getDescription());
            course.setCategory(courseDetails.getCategory());
            course.setImageUrl(courseDetails.getImageUrl());
            course.setLevel(courseDetails.getLevel());
            course.setRating(courseDetails.getRating());
            course.setDuration(courseDetails.getDuration());
            course.setTeacherEmail(courseDetails.getTeacherEmail());

            Course updatedCourse = courseService.saveCourse(course);
            return ResponseEntity.ok(updatedCourse);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // 🔹 Delete course
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCourse(@PathVariable Long id) {
        if (courseService.getCourseById(id).isPresent()) {
            courseService.deleteCourse(id);
            return ResponseEntity.ok().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // 🔹 Get courses by category
    @GetMapping("/category/{category}")
    public List<Course> getCoursesByCategory(@PathVariable String category) {
        return courseService.getCoursesByCategory(category);
    }

    // 🔹 Get courses by level
    @GetMapping("/level/{level}")
    public List<Course> getCoursesByLevel(@PathVariable String level) {
        return courseService.getCoursesByLevel(level);
    }

    // 🔹 Get courses by teacher
    @GetMapping("/teacher/{teacherEmail}")
    public List<Course> getCoursesByTeacher(@PathVariable String teacherEmail) {
        return courseService.getCoursesByTeacherEmail(teacherEmail);
    }

    // 🔹 Search courses by title
    @GetMapping("/search")
    public List<Course> searchCourses(@RequestParam String title) {
        return courseService.searchCoursesByTitle(title);
    }


    @GetMapping("/get/enrollment/courses/{studentEmail}")
    public ResponseEntity<?> getEnrollmentCourses(@PathVariable String studentEmail) {

        try {
            return ResponseEntity.ok().body(courseService.getEnrollmentCousesByStudentEmail(studentEmail));
        }
        catch (Exception e) {
            return ResponseEntity.internalServerError().body(e.getMessage());
        }



    }
}