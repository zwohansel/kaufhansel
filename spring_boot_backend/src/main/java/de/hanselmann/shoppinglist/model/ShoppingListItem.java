package de.hanselmann.shoppinglist.model;

public class ShoppingListItem {
	private final String id;
	private final String name;
	private boolean checked;

	public ShoppingListItem(String id, String name) {
		this.id = id;
		this.name = name;
		this.checked = false;
	}

	public boolean isChecked() {
		return checked;
	}

	public void setChecked(boolean checked) {
		this.checked = checked;
	}

	public String getId() {
		return id;
	}

	public String getName() {
		return name;
	}

}
