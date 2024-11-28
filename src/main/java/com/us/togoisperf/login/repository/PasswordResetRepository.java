package com.us.togoisperf.login.repository;

import com.us.togoisperf.login.model.PasswordReset;
import com.us.togoisperf.login.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface PasswordResetRepository extends JpaRepository<PasswordReset, Long> {
    Optional<PasswordReset> findByResetToken(String resetToken);

    Optional<PasswordReset> findByUserAndExpirationAfter(User user, LocalDateTime date);

    void deleteByExpirationBefore(LocalDateTime date);
}