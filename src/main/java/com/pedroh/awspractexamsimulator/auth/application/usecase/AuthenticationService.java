package com.pedroh.awspractexamsimulator.auth.application.usecase;


import com.pedroh.awspractexamsimulator.auth.domain.contract.AuthenticationResult;
import com.pedroh.awspractexamsimulator.auth.domain.contract.LoginCommand;
import com.pedroh.awspractexamsimulator.auth.domain.contract.RegisterUserCommand;
import com.pedroh.awspractexamsimulator.auth.domain.port.input.AuthenticationUseCase;
import com.pedroh.awspractexamsimulator.auth.domain.port.output.AuthenticationPort;
import org.springframework.stereotype.Service;

import java.util.concurrent.CompletableFuture;

@Service
public class AuthenticationService implements AuthenticationUseCase {

    private final AuthenticationPort authenticationPort;

    public AuthenticationService(AuthenticationPort authenticationPort) {
        this.authenticationPort = authenticationPort;
    }

    @Override
    public CompletableFuture<AuthenticationResult> authenticate(LoginCommand command) {
        return authenticationPort.authenticate(command);
    }

    @Override
    public CompletableFuture<AuthenticationResult> refreshToken(String refreshToken) {
        if (refreshToken == null || refreshToken.isBlank()) {
            throw new IllegalArgumentException("Refresh token não pode ser nulo ou vazio");
        }
        return authenticationPort.refreshToken(refreshToken);
    }

    @Override
    public CompletableFuture<Void> registerUser(RegisterUserCommand command) {
        return authenticationPort.registerUser(command);
    }
}
