package com.pedroh.awspractexamsimulator.auth.infrastructure.adapter.keycloak.error;

import com.pedroh.awspractexamsimulator.auth.infrastructure.web.exception.AuthErrorCode;
import com.pedroh.awspractexamsimulator.shared.infrastructure.web.exception.ApiException;
import org.springframework.http.HttpStatus;

public class KeycloakRegistrationException extends ApiException {
    public KeycloakRegistrationException(String message) {
        super(message, AuthErrorCode.REGISTRATION_ERROR, HttpStatus.BAD_REQUEST);
    }
}
