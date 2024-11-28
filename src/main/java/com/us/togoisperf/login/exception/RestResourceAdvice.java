package com.us.togoisperf.login.exception;


import lombok.extern.slf4j.Slf4j;
import org.hibernate.exception.ConstraintViolationException;
import org.springframework.beans.TypeMismatchException;
import org.springframework.context.support.DefaultMessageSourceResolvable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static com.us.togoisperf.login.exception.TGPException.DEFAULT_ERROR_MESSAGE;


@Slf4j
public abstract class RestResourceAdvice extends ResponseEntityExceptionHandler {

    public RestResourceAdvice() {
    }

    public abstract String getErrorCodeInitial();

    @ExceptionHandler({Exception.class})
    public final ResponseEntity<TGPException> handleGeneralException(Exception exception, WebRequest request) {
        String code = this.getErrorCodeInitial() + "001";
        String errorMessage = exception.getMessage();
        Pattern pattern = Pattern.compile("Key \\((.+?)\\)=\\((.+?)\\)");
        Matcher matcher = pattern.matcher(errorMessage);
        if (matcher.find()) {
            String field = matcher.group(1);
            String value = matcher.group(2);
            errorMessage = String.format("The %s %s is already registered", field, value);
            TGPException tgpException = new TGPException(exception, code, "General Exception", errorMessage);
            return new ResponseEntity<>(tgpException, HttpStatus.INTERNAL_SERVER_ERROR);
        }
        log.error("{}|An error occurred while trying to invoke with:{}", code,
                request.getDescription(false),
                exception);
        TGPException tgpException = new TGPException(exception, code, "General Exception", DEFAULT_ERROR_MESSAGE);
        return new ResponseEntity<>(tgpException, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    public final ResponseEntity<Object> handleMethodArgumentNotValid(MethodArgumentNotValidException exception, HttpHeaders headers, HttpStatus status, WebRequest request) {
        return this.handleCustomerTGPInputValidationError(
                exception.getBindingResult().getAllErrors().stream().findFirst().map(DefaultMessageSourceResolvable::getDefaultMessage).orElse(""),
                exception,
                request.getDescription(false));
    }

    public final ResponseEntity<Object> handleTypeMismatch(TypeMismatchException exception, HttpHeaders headers, HttpStatus status, WebRequest request) {
        return this.handleCustomerTGPInputValidationError(exception.getMessage(), exception, request.getDescription(false));
    }

    public final ResponseEntity<Object> handleHttpMessageNotReadable(HttpMessageNotReadableException exception, HttpHeaders headers, HttpStatus status, WebRequest request) {
        return this.handleCustomerTGPInputValidationError(exception.getMessage(), exception, request.getDescription(false));
    }

    @ExceptionHandler({ConstraintViolationException.class})
    public final ResponseEntity<Object> handleConstraintViolationException(ConstraintViolationException exception, WebRequest request) {
        return this.handleCustomerTGPInputValidationError(exception.getMessage(), exception, request.getDescription(false));
    }

    @ExceptionHandler({TGPException.class})
    public final ResponseEntity<TGPException> handleTGPException(TGPException exception, WebRequest request) {
        String code = this.getErrorCodeInitial() + "_003";
        log.error("{}| A 400 bad request error occurred while trying to invoke with: {}", code, request.getDescription(false), exception);
        HttpStatus status = this.isBadRequest(exception.getTitle()) ? HttpStatus.BAD_REQUEST : HttpStatus.INTERNAL_SERVER_ERROR;
        return new ResponseEntity<>(exception, status);
    }

    @ExceptionHandler({TGPNotFoundException.class})
    public final ResponseEntity<TGPNotFoundException> handleTGPNotFoundRequestException(TGPNotFoundException exception, WebRequest request) {
        String code = this.getErrorCodeInitial() + "_004";
        log.error("{}| A 400 bad request error occurred while trying to invoke with: {}", code, request.getDescription(false), exception);
        return new ResponseEntity<>(exception, HttpStatus.NOT_FOUND);
    }


    @ExceptionHandler({TGPBadRequestException.class})
    public final ResponseEntity<TGPBadRequestException> handleTGPBadRequestException(TGPBadRequestException exception, WebRequest request) {
        log.error("{}| A 400 bad request error occurred while trying to invoke with: {}", exception.getCode(), request.getDescription(false), exception);
        String code = this.getErrorCodeInitial() + "_005";
        return new ResponseEntity<>(exception, HttpStatus.BAD_REQUEST);
    }


    public final ResponseEntity<Object> handleCustomerTGPInputValidationError(String message, Exception exception, String url) {
        String code = this.getErrorCodeInitial() + "002";
        log.info("{}|An error occurred while trying to invoke the URL:{} {}", code, url, exception);
        return new ResponseEntity<>(TGPException.builder().code(code).title("Input validation Error").message(message).build(), HttpStatus.BAD_REQUEST);
    }

    private boolean isBadRequest(String errorTitle) {
        return Optional.ofNullable(errorTitle).filter((title) -> title.contains("validation")).isPresent();
    }

}
