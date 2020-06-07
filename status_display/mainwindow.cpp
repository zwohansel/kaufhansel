#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QNetworkAccessManager>
#include <shoppingliststatuspoller.h>

MainWindow::MainWindow(const QUrl url, QWidget *parent)
    : QMainWindow(parent), url(url), ui(std::make_unique<Ui::MainWindow>()) {
  ui->setupUi(this);

  network = std::make_unique<QNetworkAccessManager>();
  network->moveToThread(&pollingThread);

  poller = std::make_unique<ShoppingListStatusPoller>(network.get(), url);
  poller->moveToThread(&pollingThread);

  connect(poller.get(), &ShoppingListStatusPoller::newShoppingListStatus, this,
          &MainWindow::handleNewShoppingListStatus);

  pollingThread.start();

  connect(&pollingThreadTimer, &QTimer::timeout, poller.get(),
          &ShoppingListStatusPoller::pollShoppingListStatus);

  pollingThreadTimer.start(std::chrono::seconds(5));
}

void MainWindow::handleNewShoppingListStatus(int numOpenItems) {
  ui->lcdNumber->display(numOpenItems);
}

MainWindow::~MainWindow() = default;
