package com.us.togoisperf.login.configuration.properties;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Data
@Component
@ConfigurationProperties(prefix = "spring.datasource")
public class SQLProperties {

    private String url;
    private String username;
    private String password;
    private String driverClassName;
    private int maximumPoolSize;
    private int minimumIdle;
    private long idleTimeout;
    private long connectionTimeout;
    private long maxLifetime;
    private boolean autoCommit;
    private String poolName;
    private String schemaDefault;

}
