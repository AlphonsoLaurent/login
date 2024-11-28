package com.us.togoisperf.login.resource;

import com.us.togoisperf.login.dto.AuthResponse;
import com.us.togoisperf.login.dto.LoginRequest;
import com.us.togoisperf.login.dto.RegisterRequest;
import com.us.togoisperf.login.service.AuthenticationService;
import com.us.togoisperf.login.service.PasswordResetService;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/auth")
@AllArgsConstructor
@Slf4j
public class AuthResource {
    private final AuthenticationService authenticationService;
    private final PasswordResetService passwordResetService;

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@RequestBody RegisterRequest request) {
        log.info("Register request received for email: {}", request.getEmail());
        return ResponseEntity.ok(authenticationService.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody LoginRequest request) {
        log.info("Login request received for email: {}", request.getEmail());
        return ResponseEntity.ok(authenticationService.login(request));
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<Void> forgotPassword(@RequestParam String email) {
        log.info("Password reset requested for email: {}", email);
        passwordResetService.requestPasswordReset(email);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/reset-password")
    public ResponseEntity<Void> resetPassword(
            @RequestParam String token,
            @RequestBody String newPassword) {
        log.info("Password reset attempt with token");
        passwordResetService.resetPassword(token, newPassword);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/verify")
    public ResponseEntity<Void> verifyToken() {
        // El token será validado por el filtro JWT
        return ResponseEntity.ok().build();
    }
}
