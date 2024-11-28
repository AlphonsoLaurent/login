package com.us.togoisperf.login.configuration;


import com.us.togoisperf.login.configuration.properties.MailProperties;
import lombok.AllArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.JavaMailSenderImpl;

@AllArgsConstructor
@Configuration
public class MailConfig {
    private final MailProperties mailProperties;
    @Bean
    public JavaMailSender javaMailSender() {

        JavaMailSenderImpl mailSender = new JavaMailSenderImpl();
        mailSender.setHost(mailProperties.getHost());
        mailSender.setPort(mailProperties.getPort());
        mailSender.setUsername("togoperf@gmail.com");
        mailSender.setPassword("nbbl xzmz sxru wxys");
        mailSender.setJavaMailProperties(mailProperties.getProperties());
        return mailSender;
    }
}
