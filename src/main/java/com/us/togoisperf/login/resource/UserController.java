package com.us.togoisperf.login.resource;

import com.us.togoisperf.login.dto.ChangePasswordRequest;
import com.us.togoisperf.login.dto.UpdateProfileRequest;
import com.us.togoisperf.login.dto.UserDTO;
import com.us.togoisperf.login.model.User;
import com.us.togoisperf.login.service.UserService;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/user")
@AllArgsConstructor
public class UserController {
    private final UserService userService;

    @GetMapping("/profile")
    public ResponseEntity<UserDTO> getProfile(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(UserDTO.from(user));
    }

    @PutMapping("/profile")
    public ResponseEntity<UserDTO> updateProfile(
            @AuthenticationPrincipal User user,
            @RequestBody UpdateProfileRequest request) {
        return ResponseEntity.ok(userService.updateProfile(user, request));
    }

    @PostMapping("/change-password")
    public ResponseEntity<Void> changePassword(
            @AuthenticationPrincipal User user,
            @RequestBody ChangePasswordRequest request) {
        userService.changePassword(user, request);
        return ResponseEntity.ok().build();
    }
}
