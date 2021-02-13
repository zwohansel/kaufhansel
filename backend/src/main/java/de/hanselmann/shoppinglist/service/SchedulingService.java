package de.hanselmann.shoppinglist.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import de.hanselmann.shoppinglist.repository.InviteRepository;
import de.hanselmann.shoppinglist.repository.PendingRegistrationRepository;

@Component
public class SchedulingService {
    private final static Logger LOGGER = LoggerFactory.getLogger(SchedulingService.class);
    private final InviteRepository inviteRepository;
    private final PendingRegistrationRepository pendingRegistrationRepository;
    private final ShoppingListUserService userService;

    @Autowired
    public SchedulingService(InviteRepository inviteRepository,
            PendingRegistrationRepository pendingRegistrationRepository, ShoppingListUserService userService) {
        this.inviteRepository = inviteRepository;
        this.pendingRegistrationRepository = pendingRegistrationRepository;
        this.userService = userService;
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

    @Scheduled(fixedDelay = 1000 * 60 * 15, initialDelay = 1000 * 15)
    public void cleanupPendingPasswordResetRequests() {
        long numberReset = userService.resetPendingPasswordResetRequestsOlderThanMinutes(60);
        LOGGER.info("Reset {} expired pending password reset requests", numberReset);
    }

}
