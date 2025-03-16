package com.pedroh.awspractexamsimulator.auth.infrastructure.adapter.keycloak.error;

import com.pedroh.awspractexamsimulator.auth.infrastructure.web.exception.AuthErrorCode;
import com.pedroh.awspractexamsimulator.shared.infrastructure.web.exception.ApiException;
import org.springframework.http.HttpStatus;

public class KeycloakServerException extends ApiException {
    public KeycloakServerException(String message) {
        super(message, AuthErrorCode.KEYCLOAK_ERROR, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
