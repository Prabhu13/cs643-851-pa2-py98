# Github:

https://github.com/Prabhu13/cs643-851-pa2-py98

# DockerHub : 

https://hub.docker.com/r/prabhu13/wine-quality-prediction

# Scripts : 

https://github.com/Prabhu13/cs643-851-pa2-py98/blob/main/machine-learning/scripts/preprocess.py

![image](https://github.com/user-attachments/assets/da9ac6f8-328f-4737-9ed3-3cecf45fe302)



# Distributed Wine Quality Prediction with Apache Spark

## Prerequisites
- 4 EC2 Instances (1 Master, 3 Worker nodes)
- Amazon Linux 2023 or similar Linux distribution
- Docker
- Apache Spark 3.5.x
- Python 3.9+

Set up 4 EC2 instances for Spark, designating one as the master node and the others as worker nodes (Node1, Node2, Node3), with security group rules allowing full communication between all EC2 instances to enable Spark’s functionality.

## System Preparation (Run on ALL Instances)

### 1. System Update and Dependencies
```bash
# Update system packages
sudo dnf update -y

# Install essential dependencies
sudo dnf install -y \
    java-22-amazon-corretto \
    python3-pip \
    docker \
    wget \
    tar \
    gzip

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add current user to docker group
sudo usermod -aG docker $USER
newgrp docker


### 2. Install Spark (Run on ALL Instances)

# Download Spark (use latest compatible version)
wget https://archive.apache.org/dist/spark/spark-3.5.3/spark-3.5.3-bin-hadoop3.tgz -P /tmp

# Extract Spark
sudo tar -xvzf /tmp/spark-3.5.3-bin-hadoop3.tgz -C /opt/
sudo ln -s /opt/spark-3.5.3-bin-hadoop3 /opt/spark

# Set environment variables
echo "export SPARK_HOME=/opt/spark" >> ~/.bashrc
echo "export PATH=\$PATH:\$SPARK_HOME/bin:\$SPARK_HOME/sbin" >> ~/.bashrc
echo "export PYSPARK_PYTHON=python3" >> ~/.bashrc
source ~/.bashrc

  3. Clone Project Repository


git clone <your-project-repository-url>
cd <project-directory>


  Distributed Setup (Specific Configurations)
Master Node Configuration

# Start Spark Master
$SPARK_HOME/bin/spark-class org.apache.spark.deploy.master.Master &

# View master logs
tail -f /opt/spark/logs/spark-*-org.apache.spark.deploy.master.Master-*.out


###  Worker Node Configuration


# Replace with your Master Node's internal IP, dynamically generated
MASTER_IP="ip-172-31-XX-XX.ec2.internal"

# Start Worker and connect to Master
$SPARK_HOME/sbin/start-worker.sh spark://$MASTER_IP:7077 # might change sometimes


###  Docker Build and Push (Optional)

# Build Docker Image
docker build -t wine-quality-prediction:v1 .

# Tag for Docker Hub
docker tag wine-quality-prediction:v1 <your-dockerhub-username>/wine-quality-prediction:v1

# Push to Docker Hub
docker push <your-dockerhub-username>/wine-quality-prediction:v1

### Stopping Spark Cluster

# Stop workers
$SPARK_HOME/sbin/stop-worker.sh

# Stop master (on master node only)
$SPARK_HOME/sbin/stop-master.sh


