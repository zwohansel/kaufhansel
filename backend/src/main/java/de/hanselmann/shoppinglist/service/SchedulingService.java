package de.hanselmann.shoppinglist.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import de.hanselmann.shoppinglist.repository.ListInviteRepository;
import de.hanselmann.shoppinglist.repository.PendingRegistrationsRepository;
import de.hanselmann.shoppinglist.security.TokenService;

@Component
public class SchedulingService {
    private static final Logger LOGGER = LoggerFactory.getLogger(SchedulingService.class);
    private final ListInviteRepository inviteRepository;
    private final PendingRegistrationsRepository pendingRegistrationRepository;
    private final ShoppingListUserService userService;
    private final TokenService tokenService;

    @Autowired
    public SchedulingService(ListInviteRepository inviteRepository,
            PendingRegistrationsRepository pendingRegistrationRepository, ShoppingListUserService userService,
            TokenService tokenService) {
        this.inviteRepository = inviteRepository;
        this.pendingRegistrationRepository = pendingRegistrationRepository;
        this.userService = userService;
        this.tokenService = tokenService;
    }

    @Scheduled(cron = "0 0 2 * * *") // every night at 2:00:00am
    public void cleanupInvites() {
        int numberDeleted = inviteRepository.deleteInvitesOlderThanDays(7);
        LOGGER.info("Deleted {} expired invites", numberDeleted);
    }

    @Scheduled(cron = "0 0 3 * * *") // every night at 3:00:00am
    public void cleanupPendingRegistrations() {
        int numberDeleted = pendingRegistrationRepository.deletePendingRegistrationsOlderThanDays(2);
        LOGGER.info("Deleted {} expired pending registrations", numberDeleted);
    }

    @Scheduled(cron = "0 0 4 * * *") // every night at 4:00:00am
    public void cleanupInvalidTokens() {
        int numberDeleted = tokenService.deleteInvalidTokens();
        LOGGER.info("Deleted {} invalid tokens", numberDeleted);
    }

    @Scheduled(fixedDelay = 1000 * 60 * 15, initialDelay = 1000 * 15)
    public void cleanupPendingPasswordResetRequests() {
        long numberOfResets = userService.resetPendingPasswordResetRequestsOlderThanMinutes(60);
        if (numberOfResets > 0) {
            LOGGER.info("Reset {} expired pending password reset requests", numberOfResets);
        }
    }

}
