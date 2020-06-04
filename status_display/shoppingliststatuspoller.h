#pragma once

#include <QObject>

class ShoppingListStatusPoller : public QObject {
  Q_OBJECT

public:
  ShoppingListStatusPoller();
public slots:
  void pollShoppingListStatus();
signals:
  void newShoppingListStatus(int numOpenItems);

private:
  int counter;
};
