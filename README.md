# Kaufhansel

[![Build & Deploy](https://github.com/zwohansel/kaufhansel/actions/workflows/build.yml/badge.svg)](https://github.com/zwohansel/kaufhansel/actions/workflows/build.yml)

Create shopping lists and share them with your friends.

Supported Platforms: Linux, Android

## Development

The Stack:

* Backend: Springboot + MongoDB
* Web-Frontend: React + Typescript + GraphQL
* App-Frontend: Flutter

### Getting started

Prerequisites:
 * Linux
 * Bash

Lets start with the backend first:


1. Load the gradle project in `backend/` in the IDE of your choice and make sure it compiles.
2. Download and install the comunity version of [MongoDB](https://docs.mongodb.com/manual/administration/install-community/).
3. Open a bash and `cd` into the `backend/` folder.
4. Execute `init_dev_database.sh` to create and initialize the local development database with a test user.
5. Execute `run_dev_database.sh` to start the database.
6. Download and start [Inbucket](https://www.inbucket.org/) and open `http://localhost:9000/monitor` to receive mails sent from the backend.
7. Start the backend with the `localhost` profile.

> Always start the mongo database and the mail server before starting the backend application.

#### Build the flutter frontend application

1. Install [Flutter](https://flutter.dev/).
2. Open the flutter project in `flutter_frontend`.
3. Start the application in debug mode.
4. Login with the test user:
   ```
   EMail:    test@test.de
   Password: test
   ```

> In debug mode the application will run against `localhost` where your dev-backend should be running.

##### Code coverage

[![Coverage Status](https://coveralls.io/repos/github/zwohansel/kaufhansel/badge.svg?branch=master)](https://coveralls.io/github/zwohansel/kaufhansel?branch=master)

1. Install lcov
2. In ``flutter_frontend`` run:
   ```
   flutter test --coverage && lcov --remove coverage/lcov.info '*/generated/*' -o coverage/lcov_filter.info && genhtml coverage/lcov_filter.info --output-directory=./coverage/lcov_report
   ```
3. Open ``flutter_frontend/coverage/lcov_report/index.html``

#### Web-Frontend

> Work in progress


[Aria Roles](https://github.com/A11yance/aria-query#elements-to-roles)

[Testing Library](https://github.com/testing-library/jest-dom)

### Deployment

We use GitHub actions for deployment. 
The workflow files in `.github/workflows` document the deployment process.

To test the backend deployment locally execute `./gradlew -PbackendVersion=<version> bundle` in the root directory (e.g. with `<version>=1.0.0`).
Find the assembled jar file in `backend/build/libs` and run it locally with `java -Dspring.profiles.active=localhost -jar kaufhansel_backend.jar`.

#### Prepare your server

1. Create a new group `kaufhansel_admin`
2. Create the install folder `sudo mkdir /opt/kaufhansel/ && sudo chown root:kaufhansel_admin /opt/kaufhansel`
3. Put the backend jar into the install folder
4. Write your mongodb connection string (which contains the password), your email server connection info and the
   path, password and key alias of your keystore which contains the SSL certificate for your domain into the `kaufhansel_service_config`
5. Put the `kaufhansel_service_config` into the install directory
6. Install the `kaufhansel.service` into `/etc/systemd/system`
7. Reload the service configurations `sudo systemctl daemon-reload`
8. Create user `kaufhansel_deploybot` and add him to the `kaufhansel_admin` group
9. Create a public and a private ssh key. 
10. Add the private key as a GitHub secret named `DEPLOY_SSH_KEY`.
11. Add the public key into `/home/kaufhansel_deploybot/.ssh/authorized_keys`
12. Add the IP or host name of your service as a GitHub secret named `DEPLOY_SSH_HOST`
13. Open `visudo` and add
```
# Allow members of group kaufhansel_admin to restart the kaufhansel service
Cmnd_Alias KAUFHANSEL_CMNDS = /bin/systemctl restart kaufhansel
%kaufhansel_admin ALL=(ALL) NOPASSWD: KAUFHANSEL_CMNDS
```
