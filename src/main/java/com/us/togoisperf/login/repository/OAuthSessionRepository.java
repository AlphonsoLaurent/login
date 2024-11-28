package com.us.togoisperf.login.repository;
import com.us.togoisperf.login.model.OAuthProvider;
import com.us.togoisperf.login.model.OAuthSession;
import com.us.togoisperf.login.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface OAuthSessionRepository extends JpaRepository<OAuthSession, Long> {
    Optional<OAuthSession> findByUserAndOauthProvider(User user, OAuthProvider provider);
    Optional<OAuthSession> findByProviderUserIdAndOauthProvider(String providerUserId, OAuthProvider provider);
}