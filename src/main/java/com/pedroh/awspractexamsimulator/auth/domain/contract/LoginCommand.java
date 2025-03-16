package com.pedroh.awspractexamsimulator.auth.domain.contract;

public record LoginCommand(
    String username,
    String password
) { }
