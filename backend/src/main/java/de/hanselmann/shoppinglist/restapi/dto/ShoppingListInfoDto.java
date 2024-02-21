package de.hanselmann.shoppinglist.restapi.dto;

import java.util.List;

public class ShoppingListInfoDto {
    private final long id;
    private final String name;
    private final ShoppingListPermissionsDto permissions;
    private final List<ShoppingListUserReferenceDto> otherUsers;

    /**
     * Required to run the test in eclipse
     */
    protected ShoppingListInfoDto() {
        this(0, null, null, null);
    }

    public ShoppingListInfoDto(
            long id,
            String name,
            ShoppingListPermissionsDto permissions,
            List<ShoppingListUserReferenceDto> otherUsers) {
        this.name = name;
        this.id = id;
        this.permissions = permissions;
        this.otherUsers = otherUsers;
    }

    /**
     * Id of the list
     */
    public long getId() {
        return id;
    }

    /**
     * Display name of the list.
     */
    public String getName() {
        return name;
    }

    /**
     * Permissions of the user who requests this info object.
     */
    public ShoppingListPermissionsDto getPermissions() {
        return permissions;
    }

    /**
     * Other users with whom the user that requests this info object shares the
     * list.
     */
    public List<ShoppingListUserReferenceDto> getOtherUsers() {
        return otherUsers;
    }
}
