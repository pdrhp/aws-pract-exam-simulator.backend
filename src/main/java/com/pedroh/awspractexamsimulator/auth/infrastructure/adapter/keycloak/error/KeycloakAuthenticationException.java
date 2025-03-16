package com.pedroh.awspractexamsimulator.auth.infrastructure.adapter.keycloak.error;

import com.pedroh.awspractexamsimulator.auth.infrastructure.web.exception.AuthErrorCode;
import com.pedroh.awspractexamsimulator.shared.infrastructure.web.exception.ApiException;
import org.springframework.http.HttpStatus;

public class KeycloakAuthenticationException extends ApiException {

    public KeycloakAuthenticationException(String message) {
        super(message, AuthErrorCode.INVALID_CREDENTIALS, HttpStatus.UNAUTHORIZED);
    }
}