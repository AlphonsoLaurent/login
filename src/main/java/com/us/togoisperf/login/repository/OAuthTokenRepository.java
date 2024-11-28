package com.us.togoisperf.login.repository;

import com.us.togoisperf.login.model.OAuthSession;
import com.us.togoisperf.login.model.OAuthToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
@Repository
public interface OAuthTokenRepository extends JpaRepository<OAuthToken, Long> {
    List<OAuthToken> findByOauthSessionAndExpiresAtAfter(OAuthSession session, LocalDateTime date);
    void deleteByExpiresAtBefore(LocalDateTime date);
}