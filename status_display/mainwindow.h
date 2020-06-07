#pragma once

#include <QMainWindow>
#include <QThread>
#include <QTimer>

#include <memory>

namespace Ui {
class MainWindow;
}

class QNetworkAccessManager;
class QUrl;
class QAuthenticator;
class ShoppingListStatusPoller;

class MainWindow : public QMainWindow {
  Q_OBJECT

public:
  MainWindow(const QUrl &url, const QAuthenticator &authenticator,
             QWidget *parent = nullptr);
  ~MainWindow() override;

private slots:
  void handleNewShoppingListStatus(int numOpenItems);

private:
  QTimer pollingThreadTimer;
  QThread pollingThread;
  std::unique_ptr<QNetworkAccessManager> network;
  std::unique_ptr<ShoppingListStatusPoller> poller;
  std::unique_ptr<Ui::MainWindow> ui;
};
