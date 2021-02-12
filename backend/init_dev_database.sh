#!/bin/bash

# Creates a replica set of three mongodb instances running on localhost
# and an initial user with
# EMail:    test@test.de
# Password: test
#
# When the init script was finished successfully you can use the 
# ./run_dev_database.sh to start the development database

# Exit immediately if a command exits with a non-zero status.
set -e

# Kill all jobs spawned in this script on exit
trap 'kill $(jobs -p)' EXIT

# Create data folders for all replicas
mkdir -p mongodb_data/rs0-0
mkdir -p mongodb_data/rs0-1
mkdir -p mongodb_data/rs0-2

# Start all replicas
./run_dev_database.sh &

mongo --nodb wait_until_started.js

echo "======================================================================================="
echo "                                  Initialize replicas"
echo "======================================================================================="

mongo --port 27017 init_replica_set.js


echo "======================================================================================="
echo "                                  Initialize users"
echo "======================================================================================="

mongo --port 27017 init_user.js


kill $(jobs -p)

wait -n