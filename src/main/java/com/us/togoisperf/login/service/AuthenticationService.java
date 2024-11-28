package com.us.togoisperf.login.service;
import com.us.togoisperf.login.exception.TGPException;
import com.us.togoisperf.login.security.JwtTokenProvider;
import jakarta.annotation.PostConstruct;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.UUID;

// Tus clases personalizadas (ajusta los paquetes según tu estructura)
//import com.us.togoisperf.login.exception.AuthenticationException;
//import com.us.togoisperf.login.exception.EmailAlreadyExistsException;
//import com.us.togoisperf.login.exception.UsernameAlreadyExistsException;
import com.us.togoisperf.login.model.User;
import com.us.togoisperf.login.model.Session;
import com.us.togoisperf.login.repository.UserRepository;
import com.us.togoisperf.login.repository.SessionRepository;
import com.us.togoisperf.login.dto.AuthResponse;
import com.us.togoisperf.login.dto.LoginRequest;
import com.us.togoisperf.login.dto.RegisterRequest;
import com.us.togoisperf.login.dto.UserDTO;


@Service
@Slf4j
@Transactional
@AllArgsConstructor
public class AuthenticationService {
    private final UserRepository userRepository;
    private final SessionRepository sessionRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new TGPException("", "","Email already registered");
        }

        if (userRepository.existsByName(request.getName())) {
            throw new TGPException("", "","Username already taken");
        }

        User user = new User();
        user.setEmail(request.getEmail());
        user.setName(request.getName());
        user.setPassword(passwordEncoder.encode(request.getPassword()));

        user = userRepository.save(user);

        String token = createSession(user);

        return AuthResponse.builder()
                .token(token)
                .user(UserDTO.from(user))
                .build();
    }

    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new TGPException("", "","Invalid credentials"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new TGPException("", "","Invalid credentials");
        }

        String token = createSession(user);

        return AuthResponse.builder()
                .token(token)
                .user(UserDTO.from(user))
                .build();
    }

    private String createSession(User user) {
        Session session = new Session();
        session.setUser(user);
        session.setSessionToken(UUID.randomUUID().toString());
        session.setExpiration(LocalDateTime.now().plusDays(7));

        sessionRepository.save(session);

        return jwtTokenProvider.generateToken(user.getId(), session.getSessionToken());
    }

    @Scheduled(cron = "0 0 * * * *") // Cada hora
    public void cleanupExpiredSessions() {
        LocalDateTime now = LocalDateTime.now();
        sessionRepository.deleteByExpirationBefore(now);
        log.info("Cleaned up expired sessions");
    }
}
