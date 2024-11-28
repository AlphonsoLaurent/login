package com.us.togoisperf.login.service;

import com.us.togoisperf.login.exception.TGPException;
import com.us.togoisperf.login.model.PasswordReset;
import com.us.togoisperf.login.model.User;
import com.us.togoisperf.login.repository.PasswordResetRepository;
import com.us.togoisperf.login.repository.UserRepository;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@Slf4j
@Transactional
@AllArgsConstructor
public class PasswordResetService {
    private final UserRepository userRepository;
    private final PasswordResetRepository passwordResetRepository;
    private final EmailService emailService;
    private final PasswordEncoder passwordEncoder;

    public void requestPasswordReset(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new TGPException("", "","User not found"));

        // Invalidar tokens anteriores
        passwordResetRepository.findByUserAndExpirationAfter(user, LocalDateTime.now())
                .ifPresent(token -> {
                    token.setExpiration(LocalDateTime.now());
                    passwordResetRepository.save(token);
                });

        // Crear nuevo token
        PasswordReset passwordReset = new PasswordReset();
        passwordReset.setUser(user);
        passwordReset.setResetToken(UUID.randomUUID().toString());
        passwordReset.setExpiration(LocalDateTime.now().plusHours(1));
        passwordResetRepository.save(passwordReset);

        // Enviar email
        emailService.sendPasswordResetEmail(user.getEmail(), passwordReset.getResetToken());
    }

    public void resetPassword(String token, String newPassword) {
        PasswordReset passwordReset = passwordResetRepository.findByResetToken(token)
                .orElseThrow(() -> new TGPException("", "","Invalid or expired token"));

        if (passwordReset.getExpiration().isBefore(LocalDateTime.now())) {
            throw new TGPException("", "","Token has expired");
        }

        User user = passwordReset.getUser();
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);

        // Invalidar token
        passwordReset.setExpiration(LocalDateTime.now());
        passwordResetRepository.save(passwordReset);
    }

    @Scheduled(cron = "0 0 * * * *") // Cada hora
    public void cleanupExpiredTokens() {
        LocalDateTime now = LocalDateTime.now();
        passwordResetRepository.deleteByExpirationBefore(now);
        log.info("Cleaned up expired password reset tokens");
    }
}
