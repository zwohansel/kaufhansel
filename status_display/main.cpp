#include <QApplication>
#include <QAuthenticator>
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
  const QCommandLineOption userNameOption(
      {"u", "user"}, "The name of the shopping list service user", "username");
  parser.addOption(userNameOption);
  const QCommandLineOption passwordOption(
      {"p", "password"}, "The password of the shopping list service user",
      "password");
  parser.addOption(passwordOption);

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

  QAuthenticator authenticator;
  authenticator.setUser(parser.value(userNameOption));
  authenticator.setPassword(parser.value(passwordOption));

  MainWindow mainWindow(url, authenticator);
  mainWindow.showMaximized();

  return app.exec();
}
