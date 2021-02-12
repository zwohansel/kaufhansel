# Kaufhansel

![Build Flutter FrontEnd](https://github.com/zwohansel/kaufhansel/workflows/Build%20Flutter%20FrontEnd/badge.svg)

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
3. Open a bash and `cd` into the backend folder.
4. Execute `init_dev_database.sh` to create and initialize the local development database with a test user.
5. Execute `run_dev_database.sh` to start the database (do this everytime before you start the backend server for local development).
6. Download and start [Inbucket](https://www.inbucket.org/) and open `http://localhost:9000/monitor` to receive mails sent from the backend.
7. Start the backend with the `localhost` profile.

Always start the mongo database and the mail server before starting the backend application.

### App-Frontend

Install [Flutter](https://flutter.dev/) open the flutter project in `flutter_frontend` and start the application.
In debug mode the application will run against `localhost` where you dev-backend should be running.

### Web-Frontend

[Aria Roles](https://github.com/A11yance/aria-query#elements-to-roles)

[Testing Library](https://github.com/testing-library/jest-dom)
