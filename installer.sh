#!/bin/bash

# Exit on error
set -e

# Update the system
echo "Updating system packages..."
sudo dnf update -y  # or use `sudo yum update -y` for older systems

# Install essential tools
echo "Installing essential tools..."
sudo dnf install -y python3 python3-pip java-11-openjdk-devel git wget tar docker

sudo yum install java-22-amazon-corretto
sudo dnf install python3-pip 
sudo dnf install docker
sudo dnf install git

# Verify installations
echo "Verifying installations..."
python3 --version
pip3 --version
java -version
git --version
docker --version

# Configure Spark
SPARK_VERSION="3.5.0"
HADOOP_VERSION="3"
SPARK_DIR="/opt/spark"
SPARK_ARCHIVE="spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz"
SPARK_URL="https://downloads.apache.org/spark/spark-${SPARK_VERSION}/${SPARK_ARCHIVE}"

# Download and extract Spark
echo "Downloading and extracting Apache Spark..."
wget -q $SPARK_URL -P /tmp/
sudo tar -xvzf /tmp/$SPARK_ARCHIVE -C /opt/
sudo ln -s /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} $SPARK_DIR

# Set up Spark environment variables
echo "Configuring environment variables for Spark..."
{
    echo "export SPARK_HOME=${SPARK_DIR}"
    echo 'export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin'
    echo 'export PYSPARK_PYTHON=python3'
} >> ~/.bashrc
source ~/.bashrc

# Install Python libraries for PySpark and MLlib
echo "Installing PySpark and related libraries..."
pip3 install --quiet pyspark pandas scikit-learn

# Verify Spark installation
echo "Verifying Spark installation..."
spark-submit --version

# Docker setup for the prediction application
echo "Configuring Docker..."
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Output installation success message
echo "Environment setup complete. Please log out and log back in for Docker group changes to take effect."