package com.us.togoisperf.login.model;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "oauth_sessions", schema = "login")
@Data
public class OAuthSession {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne
    @JoinColumn(name = "oauth_provider_id", nullable = false)
    private OAuthProvider oauthProvider;

    @Column(name = "provider_user_id", nullable = false)
    private String providerUserId;

    @OneToMany(mappedBy = "oauthSession", cascade = CascadeType.ALL)
    private List<OAuthToken> oauthTokens;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;
}
