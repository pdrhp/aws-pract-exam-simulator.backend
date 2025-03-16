package com.pedroh.awspractexamsimulator.auth.domain.contract;

public record AuthenticationResult(
        String accessToken,
        String refreshToken,
        Long expiresIn
) { }
