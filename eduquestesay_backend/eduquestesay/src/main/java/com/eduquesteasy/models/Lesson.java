    package com.eduquesteasy.models;

    import com.fasterxml.jackson.annotation.JsonBackReference;
    import com.fasterxml.jackson.annotation.JsonIgnore;
    import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
    import com.fasterxml.jackson.annotation.JsonManagedReference;
    import jakarta.persistence.*;
    import lombok.Data;

    @Data
    @Entity
    @Table(name = "lessons")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})

    public class    Lesson {

        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private Long id;

        private String title;
        private String content;
        private String videoUrl;
        private String pdfFile;
        private int orderIndex;

        @ManyToOne
        @JoinColumn(name = "course_id")
        @JsonIgnore
        @JsonBackReference // Add this
        private Course course;


    }
