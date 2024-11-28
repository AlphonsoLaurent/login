package com.us.togoisperf.login.repository;

import com.us.togoisperf.login.model.OAuthProvider;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface OAuthProviderRepository extends JpaRepository<OAuthProvider, Long> {
    Optional<OAuthProvider> findByName(String name);
}