#include "shoppingliststatuspoller.h"

#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>

ShoppingListStatusPoller::ShoppingListStatusPoller(
    QNetworkAccessManager *network, const QUrl url)
    : network(network), url(url) {
  connect(network, &QNetworkAccessManager::finished, this,
          &ShoppingListStatusPoller::statusRequestFinished);
}

void ShoppingListStatusPoller::pollShoppingListStatus() {
  network->get(QNetworkRequest(url));
}

void ShoppingListStatusPoller::statusRequestFinished(QNetworkReply *reply) {
  if (reply->error() != QNetworkReply::NetworkError::NoError) {
    qDebug() << "Network error: " << reply->errorString();
    emit newShoppingListStatus(-1);
    return;
  }

  const QByteArray data = reply->readAll();

  QJsonParseError jsonError;
  const QJsonDocument json = QJsonDocument::fromJson(data, &jsonError);

  if (jsonError.error != QJsonParseError::ParseError::NoError) {
    qDebug() << "JSON parse error: " << jsonError.errorString();
    emit newShoppingListStatus(-2);
    return;
  }

  QJsonObject status = json.object();
  int numberOfOpenItems = status.value("numberOfOpenItems").toInt(-3);

  emit newShoppingListStatus(numberOfOpenItems);
  reply->deleteLater();
}
