package com.pedroh.awspractexamsimulator.auth.domain.port.input;

import com.pedroh.awspractexamsimulator.auth.domain.contract.AuthenticationResult;
import com.pedroh.awspractexamsimulator.auth.domain.contract.LoginCommand;
import com.pedroh.awspractexamsimulator.auth.domain.contract.RegisterUserCommand;

import java.util.concurrent.CompletableFuture;


public interface AuthenticationUseCase {
    CompletableFuture<AuthenticationResult> authenticate(LoginCommand command);
    CompletableFuture<AuthenticationResult> refreshToken(String refreshToken);
    CompletableFuture<Void> registerUser(RegisterUserCommand registerUser);
}
