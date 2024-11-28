package com.us.togoisperf.login.dto;

import lombok.Data;

@Data
public class RegisterRequest {
    private String email;
    private String name;
    private String password;
}


