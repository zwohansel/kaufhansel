package de.hanselmann.shoppinglist.security;

import java.security.SecureRandom;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.model.Token;
import de.hanselmann.shoppinglist.model.TokenType;
import de.hanselmann.shoppinglist.repository.TokenRepository;
import de.hanselmann.shoppinglist.service.TimeService;

@Service
public class TokenService {
    private static final Duration ACCESS_TOKEN_DURATION_VALID = Duration.ofHours(8);

    /**
     * A refresh token expires if it has not been used for this duration.
     */
    private static final Duration REFRESH_TOKEN_DURATION_VALID = Duration.ofDays(365);
    private static final int TOKEN_LENGTH_IN_BYTES = 32;

    private final TokenRepository tokenRepository;
    private final TimeService timeService;
    private final SecureRandom random = new SecureRandom();

    @Autowired
    public TokenService(TokenRepository tokenRepository, TimeService timeService) {
        this.tokenRepository = tokenRepository;
        this.timeService = timeService;
    }

    /**
     * Returns the user the given access token belongs to or an empty optional if
     * the token is unknown or expired.
     */
    Optional<ShoppingListUser> getUserFromAccessTokenIfValid(String token) {
        return findValidToken(token, TokenType.ACCESS).map(Token::getUser);
    }

    /**
     * Returns the user the given refresh token belongs to or an empty optional if
     * the token is unknown or expired. A refresh token expires only if it is
     * not used: every use extends its lifetime.
     */
    @Transactional
    public Optional<ShoppingListUser> useRefreshToken(String token) {
        final LocalDateTime now = timeService.now();
        return findValidToken(token, TokenType.REFRESH).map(storedToken -> {
            storedToken.setExpirationDate(now.plus(REFRESH_TOKEN_DURATION_VALID));
            return tokenRepository.save(storedToken).getUser();
        });
    }

    private Optional<Token> findValidToken(String token, TokenType type) {
        final LocalDateTime now = timeService.now();
        return tokenRepository.findByValueAndType(token, type)
                .filter(storedToken -> !storedToken.isExpired(now));
    }

    /**
     * Creates a token that authenticates the requests of the given user.
     * The client has to be told when the token expires so that it knows
     * when it has to obtain a new one.
     */
    public Token generateAccessToken(ShoppingListUser user) {
        return generateToken(user, TokenType.ACCESS, ACCESS_TOKEN_DURATION_VALID);
    }

    /**
     * Creates a long lived token with which the given user can obtain a new access
     * token without logging in again.
     */
    public Token generateRefreshToken(ShoppingListUser user) {
        return generateToken(user, TokenType.REFRESH, REFRESH_TOKEN_DURATION_VALID);
    }

    /**
     * Tokens are random values: only this service can tell to whom a token belongs.
     */
    private Token generateToken(ShoppingListUser user, TokenType type, Duration durationValid) {
        final byte[] tokenBytes = new byte[TOKEN_LENGTH_IN_BYTES];
        random.nextBytes(tokenBytes);
        final String tokenValue = Base64.getUrlEncoder().withoutPadding().encodeToString(tokenBytes);

        return tokenRepository.save(
                new Token(tokenValue, type, user, timeService.now().plus(durationValid)));
    }

    /**
     * Invalidates the given refresh token. Returns false if the token is unknown.
     */
    @Transactional
    public boolean deleteRefreshToken(String token) {
        return tokenRepository.deleteByValueAndType(token, TokenType.REFRESH) > 0;
    }

    /**
     * Invalidates all tokens of the given user. The user has to log in again
     * on all of his devices.
     */
    @Transactional
    public int deleteTokensOfUser(ShoppingListUser user) {
        return tokenRepository.deleteByUser(user);
    }

    @Transactional
    public int deleteExpiredTokens() {
        return tokenRepository.deleteByExpirationDateLessThan(timeService.now());
    }
}
