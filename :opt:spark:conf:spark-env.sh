#!/usr/bin/env bash

# Master Node Configuration
SPARK_MASTER_HOST="ip-172-31-17-94.ec2.internal"
SPARK_MASTER_PORT=7078
SPARK_MASTER_WEBUI_PORT=8081

# Public DNS for external access
SPARK_PUBLIC_DNS="54.234.124.25"

# Memory and CPU Configuration (t2.large has 2 vCPUs, 8GB RAM)
SPARK_EXECUTOR_MEMORY="4G"   # Use half of available memory
SPARK_DRIVER_MEMORY="2G"
SPARK_EXECUTOR_CORES=2
SPARK_WORKER_CORES=2
SPARK_WORKER_MEMORY="4G"

# Worker Configuration
SPARK_WORKER_DIR="/mnt/spark/work"
SPARK_WORKER_WEBUI_PORT=8081

# Logging and PID
SPARK_LOG_DIR="${SPARK_HOME}/logs"
SPARK_PID_DIR="/tmp/spark"

# Network Configuration
SPARK_DAEMON_JAVA_OPTS="-Dspark.worker.network.timeout=60"



# Master URL
SPARK_MASTER_URL="spark://$SPARK_MASTER_HOST:$SPARK_MASTER_PORT"

# Export variables
export SPARK_MASTER_HOST
export SPARK_MASTER_URL