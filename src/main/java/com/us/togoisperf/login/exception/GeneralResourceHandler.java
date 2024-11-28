package com.us.togoisperf.login.exception;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.context.request.WebRequest;

@ControllerAdvice(basePackages = "com.us.togoisperf.login.resource")
public class GeneralResourceHandler extends RestResourceAdvice {
    @Override
    public String getErrorCodeInitial() {
        return "TGP_000";
    }

    @ExceptionHandler({HttpClientErrorException.Unauthorized.class})
    public final ResponseEntity<TGPException> handleUnauthorizedException(HttpClientErrorException.Unauthorized exception, WebRequest request) {
        return handleGeneralException(exception, request);
    }
}
