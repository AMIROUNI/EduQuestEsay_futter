package com.eduquesteasy.models;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "news")
public class News {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;

    private String description;

    private String imageUrl;

    private String link; // Optional: link to detailed page

    private LocalDateTime createdAt;

    private String category ;

    @PrePersist
    public void prePersist() {
        createdAt = LocalDateTime.now();
    }
}
