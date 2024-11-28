package com.us.togoisperf.login.repository;
import com.us.togoisperf.login.model.Session;
import com.us.togoisperf.login.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
@Repository
public interface SessionRepository extends JpaRepository<Session, Long> {
    Optional<Session> findBySessionToken(String sessionToken);
    List<Session> findByUserAndExpirationAfter(User user, LocalDateTime date);
    void deleteByExpirationBefore(LocalDateTime date);
}