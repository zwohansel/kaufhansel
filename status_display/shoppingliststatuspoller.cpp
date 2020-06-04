#include "shoppingliststatuspoller.h"

ShoppingListStatusPoller::ShoppingListStatusPoller() : counter(0) {}

void ShoppingListStatusPoller::pollShoppingListStatus() {
  emit newShoppingListStatus(counter);
  counter++;
}
