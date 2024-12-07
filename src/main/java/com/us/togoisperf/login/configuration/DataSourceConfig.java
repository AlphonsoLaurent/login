package com.us.togoisperf.login.configuration;

import com.us.togoisperf.login.configuration.properties.SQLProperties;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;


@RequiredArgsConstructor
@Configuration
public class DataSourceConfig {
    private final SQLProperties sqlProperties;

    @Bean
    public HikariDataSource dataSource() {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(sqlProperties.getUrl());
        config.setUsername(sqlProperties.getUsername());
        config.setPassword(sqlProperties.getPassword());
        config.setDriverClassName(sqlProperties.getDriverClassName());
        config.setMaximumPoolSize(sqlProperties.getMaximumPoolSize());
        config.setMinimumIdle(sqlProperties.getMinimumIdle());
        config.setIdleTimeout(sqlProperties.getIdleTimeout());
        config.setConnectionTimeout(sqlProperties.getConnectionTimeout());
        config.setMaxLifetime(sqlProperties.getMaxLifetime());
        config.setAutoCommit(sqlProperties.isAutoCommit());
        config.setSchema(sqlProperties.getSchemaDefault());
        config.setPoolName(sqlProperties.getPoolName());
        return new HikariDataSource(config);
    }
}
