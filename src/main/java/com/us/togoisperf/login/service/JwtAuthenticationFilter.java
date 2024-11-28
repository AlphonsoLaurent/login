package com.us.togoisperf.login.service;

import com.us.togoisperf.login.exception.TGPNotFoundException;
import com.us.togoisperf.login.model.Session;
import com.us.togoisperf.login.model.User;
import com.us.togoisperf.login.repository.SessionRepository;
import com.us.togoisperf.login.repository.UserRepository;
import com.us.togoisperf.login.security.JwtTokenProvider;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    private final JwtTokenProvider jwtTokenProvider;
    private final UserRepository userRepository;
    private final SessionRepository sessionRepository;

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {

        final String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        try {
            final String jwt = authHeader.substring(7);
            if (jwtTokenProvider.validateToken(jwt)) {
                String userId = jwtTokenProvider.getUserIdFromToken(jwt);
                String sessionToken = jwtTokenProvider.getSessionTokenFromToken(jwt);

                User user = userRepository.findById(Long.parseLong(userId))
                        .orElseThrow(() -> new TGPNotFoundException("", "", "User not found"));

                Optional<Session> session = sessionRepository.findBySessionToken(sessionToken);
                if (session.isPresent() && session.get().getExpiration().isAfter(LocalDateTime.now())) {
                    UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                            user,
                            null,
                            List.of(new SimpleGrantedAuthority("USER"))
                    );
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                }
            }
        } catch (Exception e) {
            // Token inválido o expirado
            SecurityContextHolder.clearContext();
        }

        filterChain.doFilter(request, response);
    }
}
