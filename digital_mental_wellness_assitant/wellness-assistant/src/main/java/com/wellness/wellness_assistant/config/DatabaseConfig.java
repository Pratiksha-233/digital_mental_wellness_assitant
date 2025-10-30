package com.wellness.wellness_assistant.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import javax.sql.DataSource;

@Configuration
@EnableTransactionManagement
public class DatabaseConfig {

    @Bean
    @Primary
    @Profile("dev")
    @ConfigurationProperties(prefix = "spring.datasource")
    public DataSource devDataSource() {
        return DataSourceBuilder.create().build();
    }

    @Bean
    @Primary
    @Profile("prod")
    @ConfigurationProperties(prefix = "spring.datasource")
    public DataSource prodDataSource() {
        return DataSourceBuilder.create().build();
    }

    @Bean
    @Primary
    @Profile("test")
    @ConfigurationProperties(prefix = "spring.datasource")
    public DataSource testDataSource() {
        return DataSourceBuilder.create().build();
    }
}