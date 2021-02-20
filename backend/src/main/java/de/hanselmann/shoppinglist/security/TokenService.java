package de.hanselmann.shoppinglist.security;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.Base64;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.model.Token;
import de.hanselmann.shoppinglist.repository.TokenRepository;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.JwtParser;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;

@Service
public class TokenService {
    private final TokenRepository tokenRepository;
    private static final Duration DURATION_VALID = Duration.ofDays(28);
    private final String secret;
    private final JwtParser parser;

    @Autowired
    public TokenService(@Value("${jwt.secret}") String secret, TokenRepository tokenRepository) {
        this.secret = Base64.getEncoder().encodeToString(secret.getBytes());
        this.parser = Jwts.parserBuilder().setSigningKey(this.secret).build();
        this.tokenRepository = tokenRepository;
    }

    Optional<ObjectId> getUserIdFromTokenIfValid(String token) {
        return tokenRepository.findByValue(token).filter(this::isValid).map(Token::getUserId);
    }

    private boolean isValid(Token token) {
        try {
            return getAllClaimsFromToken(token.getValue()) != null;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }

    private boolean isInvalid(Token token) {
        return !isValid(token);
    }

    private Claims getAllClaimsFromToken(String token) {
        return parser.parseClaimsJws(token).getBody();
    }

    public String generateToken(ShoppingListUser user) {
        final Date createdDate = new Date();
        final LocalDateTime expirationDate = LocalDateTime.now().plus(DURATION_VALID);

        String tokenValue = Jwts.builder().setClaims(new HashMap<>()).setSubject(user.getEmailAddress())
                .setIssuedAt(createdDate).setIssuer("de.zwohansel.kaufhansel")
                .setExpiration(Date.from(expirationDate.toInstant(ZoneOffset.UTC)))
                .signWith(SignatureAlgorithm.HS512, secret).compact();

        tokenRepository.save(new Token(tokenValue, user.getId(), expirationDate));

        return tokenValue;
    }

    public int deleteInvalidTokens() {
        List<Token> invalidTokens = tokenRepository.findAll().stream().filter(this::isInvalid)
                .collect(Collectors.toList());
        tokenRepository.deleteAll(invalidTokens);
        return invalidTokens.size();
    }
}
