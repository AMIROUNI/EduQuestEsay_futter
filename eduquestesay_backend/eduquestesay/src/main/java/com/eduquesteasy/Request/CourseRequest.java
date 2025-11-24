package com.eduquesteasy.Request;


import lombok.Data;

@Data
public class CourseRequest {
    private String title;
    private String description;
    private String category;
    private String imageUrl;
    private String level;
    private double rating;
    private int duration;
    private String teacherEmail;

    public CourseRequest() {
    }
}
