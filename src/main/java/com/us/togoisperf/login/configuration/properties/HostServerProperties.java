package com.us.togoisperf.login.configuration.properties;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Getter
@Setter
@Configuration
@ConfigurationProperties(prefix = "app.host")
public class HostServerProperties {
    private String frontendUrl;
    private String backendUrl;
    private int passwordResetTokenExpirationHours;
}
