package com.pedroh.awspractexamsimulator.auth.domain.port.output;

import com.pedroh.awspractexamsimulator.auth.domain.contract.AuthenticationResult;
import com.pedroh.awspractexamsimulator.auth.domain.contract.LoginCommand;
import com.pedroh.awspractexamsimulator.auth.domain.contract.RegisterUserCommand;

import java.util.concurrent.CompletableFuture;


public interface AuthenticationPort {
    CompletableFuture<AuthenticationResult> authenticate(LoginCommand command);
    CompletableFuture<AuthenticationResult> refreshToken(String refreshToken);
    CompletableFuture<Void> registerUser(RegisterUserCommand command);
}

