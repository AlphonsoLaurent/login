package com.us.togoisperf.login.service;

import com.us.togoisperf.login.dto.ChangePasswordRequest;
import com.us.togoisperf.login.dto.UpdateProfileRequest;
import com.us.togoisperf.login.dto.UserDTO;
import com.us.togoisperf.login.exception.TGPException;
import com.us.togoisperf.login.model.User;
import com.us.togoisperf.login.repository.UserRepository;
import lombok.AllArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
@AllArgsConstructor
@Transactional
public class UserService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserDTO updateProfile(User user, UpdateProfileRequest request) {
        if (StringUtils.hasText(request.getEmail()) &&
                !request.getEmail().equals(user.getEmail()) &&
                userRepository.existsByEmail(request.getEmail())) {
            throw new TGPException("", "","Email already in use");
        }

        if (StringUtils.hasText(request.getName())) {
            user.setName(request.getName());
        }
        if (StringUtils.hasText(request.getEmail())) {
            user.setEmail(request.getEmail());
        }

        user = userRepository.save(user);
        return UserDTO.from(user);
    }

    public void changePassword(User user, ChangePasswordRequest request) {
        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            throw new TGPException("", "","Current password is incorrect");
        }

        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            throw new TGPException("", "","New passwords don't match");
        }

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }
}
