package com.us.togoisperf.login.exception;

public class TGPBadRequestException extends TGPException{
    public TGPBadRequestException(String code, String title, String message) {
        super(code, title, message);
    }
}
