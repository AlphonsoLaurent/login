package com.us.togoisperf.login.service;

import com.us.togoisperf.login.configuration.properties.HostServerProperties;
import com.us.togoisperf.login.exception.TGPException;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

@Service
@Slf4j
@AllArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;
    private final HostServerProperties hostServerProperties;


    public void sendPasswordResetEmail(String toEmail, String resetToken) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true);

            helper.setTo(toEmail);
            helper.setSubject("Password Reset Request");

            String resetLink = hostServerProperties.getUrl() + "/reset-password?token=" + resetToken;
            String emailContent = buildPasswordResetEmailContent(resetLink);

            helper.setText(emailContent, true);

            mailSender.send(message);
            log.info("Password reset email sent successfully to: {}", toEmail);
        } catch (MessagingException e) {
            log.error("Error sending password reset email to: {}", toEmail, e);
            throw new TGPException("", "", "Failed to send password reset email");
        }
    }

    private String buildPasswordResetEmailContent(String resetLink) {
        return String.format("""
                        <html>
                        <body>
                            <h2>Password Reset Request</h2>
                            <p>You have requested to reset your password. Click the link below to proceed:</p>
                            <p><a href="%s">Reset Password</a></p>
                            <p>If you did not request a password reset, please ignore this email.</p>
                            <p>This link will expire in 1 hour.</p>
                            <p>If the button above doesn't work, copy and paste this URL into your browser:</p>
                            <p>%s</p>
                        </body>
                        </html>
                        """,
                resetLink,
                resetLink
        );
    }

    public void sendWelcomeEmail(String toEmail, String name) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true);
            helper.setTo(toEmail);
            helper.setSubject("Welcome to Our Platform!");

            String emailContent = buildWelcomeEmailContent(name);

            helper.setText(emailContent, true);

            mailSender.send(message);
            log.info("Welcome email sent successfully to: {}", toEmail);
        } catch (MessagingException e) {
            log.error("Error sending welcome email to: {}", toEmail, e);
            throw new TGPException("", "", "Failed to send welcome email");
        }
    }

    private String buildWelcomeEmailContent(String name) {
        return String.format("""
                        <html>
                        <body>
                            <h2>Welcome to Our Platform, %s!</h2>
                            <p>Thank you for joining us. We're excited to have you on board!</p>
                            <p>If you have any questions or need assistance, feel free to contact our support team.</p>
                        </body>
                        </html>
                        """,
                name
        );
    }
}


