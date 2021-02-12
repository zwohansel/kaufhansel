#!/bin/bash

# Starts a replica set of three mongodb instances
# See: https://docs.mongodb.com/manual/tutorial/deploy-replica-set-for-testing/

# Exit immediately if a command exits with a non-zero status.
set -e

# Kill all jobs spawned in this script on exit
trap 'kill $(jobs -p)' EXIT

# Print each command before executing it
set -x

# Start 3 mongodb instances (replica set) as background jobs
mongod --replSet rs0 --port 27017 --bind_ip localhost --dbpath mongodb_data/rs0-0  --oplogSize 128 &
mongod --replSet rs0 --port 27018 --bind_ip localhost --dbpath mongodb_data/rs0-1  --oplogSize 128 &
mongod --replSet rs0 --port 27019 --bind_ip localhost --dbpath mongodb_data/rs0-2  --oplogSize 128 &

# wait until one of the three instances finished (wait will return its error code)

wait -n