#include <QApplication>
#include <QCommandLineParser>
#include <QDebug>
#include <QUrl>
#include <mainwindow.h>

int main(int argc, char **args) {
  QApplication app(argc, args);
  QApplication::setApplicationVersion("1.0.0");
  QApplication::setApplicationName("Shopping List Status Display");

  QCommandLineParser parser;
  parser.setApplicationDescription(
      "Display Shopping List status information. Tell us about Kaufhansel!");
  parser.addHelpOption();
  parser.addVersionOption();
  parser.addPositionalArgument("url",
                               "Shopping List service status endpoint url");
  parser.process(app);

  QStringList argumentList = parser.positionalArguments();
  if (argumentList.isEmpty()) {
    qDebug() << "Initialization error: missing arguments. See --help";
    return 42;
  }

  QString urlString = parser.positionalArguments().first();
  QUrl url(urlString);

  if (!url.isValid()) {
    qDebug() << "Initialization error: invalid url argument: " << urlString;
    return 42;
  }

  MainWindow mainWindow(url);
  mainWindow.showMaximized();

  return app.exec();
}
