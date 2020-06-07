#pragma once

#include <QAuthenticator>
#include <QObject>
#include <QUrl>

class QNetworkAccessManager;
class QNetworkReply;

class ShoppingListStatusPoller : public QObject {
  Q_OBJECT

public:
  ShoppingListStatusPoller(QNetworkAccessManager *network, const QUrl &url,
                           const QAuthenticator &authenticator);
public slots:
  void pollShoppingListStatus();
private slots:
  void statusRequestFinished(QNetworkReply *reply);
  void statusRequestsAuthenticationRequired(QNetworkReply *reply,
                                            QAuthenticator *authenticator);
signals:
  void newShoppingListStatus(int numOpenItems);

private:
  QNetworkAccessManager *network;
  const QUrl url;
  const QAuthenticator authenticator;
};
