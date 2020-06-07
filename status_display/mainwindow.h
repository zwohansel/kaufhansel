#pragma once

#include <QMainWindow>
#include <QThread>
#include <QTimer>
#include <QUrl>

#include <memory>

namespace Ui {
class MainWindow;
}

class QNetworkAccessManager;
class ShoppingListStatusPoller;

class MainWindow : public QMainWindow {
  Q_OBJECT

public:
  MainWindow(const QUrl url, QWidget *parent = nullptr);
  ~MainWindow() override;

private slots:
  void handleNewShoppingListStatus(int numOpenItems);

private:
  QTimer pollingThreadTimer;
  QThread pollingThread;
  std::unique_ptr<QNetworkAccessManager> network;
  QUrl url;
  std::unique_ptr<ShoppingListStatusPoller> poller;
  std::unique_ptr<Ui::MainWindow> ui;
};
