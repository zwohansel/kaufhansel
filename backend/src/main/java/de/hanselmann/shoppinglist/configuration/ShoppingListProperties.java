package de.hanselmann.shoppinglist.configuration;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.context.properties.ConstructorBinding;

@ConstructorBinding
@ConfigurationProperties(prefix = "shoppinglist")
public class ShoppingListProperties {

	private final boolean secureCookie;
	
	public ShoppingListProperties(boolean secureCookie) {
		this.secureCookie = secureCookie;
	}

	public boolean isSecureCookie() {
		return secureCookie;
	}
	
}
