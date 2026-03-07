#!/bin/bash

# -------------------------------------------------------------------------
# file paths to Spark installations on each machine
# -------------------------------------------------------------------------

MASTER="spark://macbook-pro:7077"

MBP_SPARK="/Users/mbp-homepath/.spark"
TRASH_SPARK="/Users/trashcan-homepath/.spark"
IMAC_SPARK="/Users/imac-homepath/.spark"

# -------------------------------------------------------------------------
# Start the Master Node and Worker Nodes
# -------------------------------------------------------------------------

echo "Starting Spark Master on MBP..."
$MBP_SPARK/sbin/start-master.sh --host macbook-pro

sleep 3

# this can be commented out if you don't want to a worker on the master node
echo "Starting worker on MBP..."
$MBP_SPARK/sbin/start-worker.sh $MASTER

echo "Starting worker on Trashcan..."
ssh user@trashcan "$TRASH_SPARK/sbin/start-worker.sh $MASTER"

echo "Starting worker on iMac..."
ssh user@imac "$IMAC_SPARK/sbin/start-worker.sh $MASTER"

sleep 5

# -------------------------------------------------------------------------
# Start the Spark Connect Server
    # This is optional, but it allows you to connect a Jupyter notebook 
# -------------------------------------------------------------------------

echo "Starting Spark Connect server..."
~/.spark/sbin/start-connect-server.sh \
--master spark://macbook-pro:7077 \
--conf spark.cores.max=12

# -------------------------------------------------------------------------
# Final message
# -------------------------------------------------------------------------

echo ""
echo "Cluster startup complete."
echo "Spark UI: http://macbook-pro:8080"

