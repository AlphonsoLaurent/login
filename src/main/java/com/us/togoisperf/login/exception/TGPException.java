package com.us.togoisperf.login.exception;

import com.fasterxml.jackson.annotation.JsonValue;
import lombok.*;

import java.util.Map;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@EqualsAndHashCode(callSuper = false)
public class TGPException extends RuntimeException{
    public static final String DEFAULT_ERROR_MESSAGE="Something went wrong while processing your request. Please try again. If you continue experiencing issues, please contact the help desk at: 678-978-7443";
    private String code;
    private String title;
    private String message;

    public TGPException(Throwable cause, String code, String title, String message) {
        super(cause);
        this.code = code;
        this.title = title;
        this.message = message;
    }
    @Override
    public String getMessage() {
        return this.message != null ? this.message:DEFAULT_ERROR_MESSAGE;
    }

    @JsonValue
    public Map<String, String> getJson(){
        return Map.of("code",this.code, "title",this.title, "message",this.message);
    }

}
