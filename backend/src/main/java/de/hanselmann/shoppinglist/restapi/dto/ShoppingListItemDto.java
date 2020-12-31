package de.hanselmann.shoppinglist.restapi.dto;

public class ShoppingListItemDto {
	private final String id;
	private final String name;
	private final boolean checked;

	public ShoppingListItemDto(String id, String name, boolean checked) {
		this.id = id;
		this.name = name;
		this.checked = checked;
	}

	public String getId() {
		return id;
	}

	public String getName() {
		return name;
	}

	public boolean isChecked() {
		return checked;
	}

}
