package de.hanselmann.shoppinglist.service;

import java.util.Random;

import org.springframework.stereotype.Component;

import com.aventrix.jnanoid.jnanoid.NanoIdUtils;

import de.hanselmann.shoppinglist.repository.PendingRegistrationsRepository;

@Component
public class CodeGenerator {
    private static final char[] alphabet = new char[] { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N',
            'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '1', '2', '3', '4', '5', '6', '7', '8', '9' };

    private final PendingRegistrationsRepository pendingRegistrationRepository;
    private final Random random;

    public CodeGenerator(PendingRegistrationsRepository pendingRegistrationRepository) {
        this.pendingRegistrationRepository = pendingRegistrationRepository;
        random = new Random();
    }

    public String generateRegistrationActivationCode() {
        String code = NanoIdUtils.randomNanoId();
        while (pendingRegistrationRepository.existsByActivationCode(code)) {
            code = NanoIdUtils.randomNanoId();
        }
        return code;
    }

    public String generatePasswordResetCode() {
        return NanoIdUtils.randomNanoId(random, alphabet, 8);
    }

}
