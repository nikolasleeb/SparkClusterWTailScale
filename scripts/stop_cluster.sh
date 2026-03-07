#!/bin/bash

echo "Stopping Spark Connect server..."
~/.spark/sbin/stop-connect-server.sh

echo "Stopping workers..."

ssh user@trashcan "~/.spark/sbin/stop-worker.sh"
ssh user@imac "~/.spark/sbin/stop-worker.sh"

echo "Stopping local worker..."
~/.spark/sbin/stop-worker.sh

echo "Stopping master..."
~/.spark/sbin/stop-master.sh

echo "Cluster shutdown complete."
