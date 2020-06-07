#pragma once

#include <QObject>
#include <QUrl>

class QNetworkAccessManager;
class QNetworkReply;
class ShoppingListStatusPoller : public QObject {
  Q_OBJECT

public:
  ShoppingListStatusPoller(QNetworkAccessManager *network, const QUrl url);
public slots:
  void pollShoppingListStatus();
private slots:
  void statusRequestFinished(QNetworkReply *reply);
signals:
  void newShoppingListStatus(int numOpenItems);

private:
  QNetworkAccessManager *network;
  const QUrl url;
};
