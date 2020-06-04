#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <shoppingliststatuspoller.h>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent), ui(std::make_unique<Ui::MainWindow>()) {
  ui->setupUi(this);

  poller = std::make_unique<ShoppingListStatusPoller>();
  poller->moveToThread(&pollingThread);

  connect(poller.get(), &ShoppingListStatusPoller::newShoppingListStatus, this,
          &MainWindow::handleNewShoppingListStatus);

  pollingThread.start();

  connect(&pollingThreadTimer, &QTimer::timeout, poller.get(),
          &ShoppingListStatusPoller::pollShoppingListStatus);

  pollingThreadTimer.start(std::chrono::seconds(1));
}

void MainWindow::handleNewShoppingListStatus(int numOpenItems) {
  ui->lcdNumber->display(numOpenItems);
}

MainWindow::~MainWindow() = default;
