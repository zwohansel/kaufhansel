# Kaufhansel

[![Build & Deploy](https://github.com/zwohansel/kaufhansel/actions/workflows/build.yml/badge.svg)](https://github.com/zwohansel/kaufhansel/actions/workflows/build.yml)

Create shopping lists and share them with your friends.

Supported Platforms: Linux, Android

## Development

The Stack:

* Backend: Spring Boot + SQLite
* App-Frontend: Flutter

### Getting started

Prerequisites:
 * Linux
 * Bash
 * JDK 25
 * Docker
 * [Flutter](https://flutter.dev/)
 * libsecret (`libsecret-1-dev`) to build the Linux app

Let's start with the backend:

1. Start mailpit to receive mails sent from the backend: `docker run --rm -p 1025:1025 -p 8025:8025 axllent/mailpit:latest`
2. Start the backend locally: in `backend` run `./gradlew bootRun --args='--spring.profiles.active=localhost'`

> Always start the mail server before starting the backend application.

The backend is now reachable at `https://<your-ip>:8080/api/` and serves a self-signed certificate.
The mails it sends can be read in the mailpit web interface at `http://localhost:8025`.

#### Build the Flutter frontend application

1. Open the Flutter project in `flutter_frontend`.
2. Start the application in debug mode and point it at your dev-backend:
   ```
   flutter run --dart-define=KAUFHANSEL_SERVER_URL=https://<your-ip>:8080/api/
   ```
   In debug mode the application accepts the self-signed certificate of the dev-backend.
3. Register a new user and open the activation link from the mail that mailpit received.
4. Log in with the registered user.

> The define can also be set in the run configuration of your IDE.

##### Code coverage

[![Coverage Status](https://coveralls.io/repos/github/zwohansel/kaufhansel/badge.svg?branch=master)](https://coveralls.io/github/zwohansel/kaufhansel?branch=master)

1. Install lcov
2. In `flutter_frontend` run:
   ```
   flutter test --coverage && lcov --remove coverage/lcov.info '*/generated/*' -o coverage/lcov_filter.info && genhtml coverage/lcov_filter.info --output-directory=./coverage/lcov_report
   ```
3. Open `flutter_frontend/coverage/lcov_report/index.html`


### Deployment

We use GitHub actions for deployment.
The workflow files in `.github/workflows` document the deployment process.

To test the backend deployment locally execute `./gradlew -PbackendVersion=<version> build` in the `backend` directory (e.g. with `<version>=1.0.0`).
Find the assembled jar file in `backend/build/libs` and run it locally with `java -Dspring.profiles.active=localhost -jar kaufhansel_backend.jar`.
