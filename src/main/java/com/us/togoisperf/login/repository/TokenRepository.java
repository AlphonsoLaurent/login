package com.us.togoisperf.login.repository;

import com.us.togoisperf.login.model.Token;
import com.us.togoisperf.login.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
@Repository
public interface TokenRepository extends JpaRepository<Token, Long> {
    Optional<Token> findByToken(String token);
    List<Token> findByUserAndExpirationAfter(User user, LocalDateTime date);
    void deleteByExpirationBefore(LocalDateTime date);
}