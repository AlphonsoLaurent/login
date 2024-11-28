package com.us.togoisperf.login.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class AuthResponse {
    private String token;
    private UserDTO user;
    private LocalDateTime expiresAt;
    private String sessionToken;
}

