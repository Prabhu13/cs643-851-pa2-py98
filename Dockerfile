# Use Amazon Linux 2023 as the base image
FROM amazonlinux:2023

# Set the working directory in the container
WORKDIR /app

# Install system dependencies
RUN dnf update -y && dnf install -y \
    java-22-amazon-corretto \
    python3-pip \
    wget \
    tar \
    gzip \
    && dnf clean all

# Set JAVA_HOME environment variable
ENV JAVA_HOME /usr/lib/jvm/java-22-amazon-corretto

# Download and install Spark with improved error handling
ENV SPARK_VERSION=3.5.0
ENV HADOOP_VERSION=3
ENV SPARK_HOME=/opt/spark

# Use Apache archive mirror if the main site fails
RUN set -x \
    && SPARK_DOWNLOAD_URL="https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" \
    && wget -q --tries=3 --timeout=60 $SPARK_DOWNLOAD_URL -O /tmp/spark.tgz \
    && tar -xzf /tmp/spark.tgz -C /opt \
    && ln -s /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} ${SPARK_HOME} \
    && rm /tmp/spark.tgz \
    && mkdir -p ${SPARK_HOME}/logs

# Add Spark to PATH
ENV PATH $PATH:$SPARK_HOME/bin

# Copy the entire machine learning project
COPY machine-learning/ /app/

# Upgrade pip and install setuptools
RUN pip3 install --quiet \
    setuptools

# Install Python dependencies
RUN pip3 install --quiet \
    pyspark \
    pandas \
    scikit-learn

# Set PYTHONPATH to include the current directory
ENV PYTHONPATH="${PYTHONPATH}:/app"

# Ensure data and models directories exist
RUN mkdir -p /app/data /app/models

# Check available Python versions and manually create a symlink
RUN if [ -f /usr/bin/python3 ]; then ln -sf /usr/bin/python3 /usr/bin/python; fi

# Command to run the application
CMD ["python3", "/app/main.py"]