import os
from pyspark.sql import SparkSession
from pyspark.sql.functions import col
from pyspark.ml.feature import VectorAssembler

def create_spark_session(is_distributed=False):
    """
    Create a Spark session with appropriate configuration
    """
    builder = SparkSession.builder.appName("WineQualityPrediction")
    
    if is_distributed:
        # Distributed configuration
        master_url = os.getenv("SPARK_MASTER_URL", "spark://ip-172-31-17-94.ec2.internal:7078")
        builder = builder.master(master_url) \
            .config("spark.executor.cores", "2") \
            .config("spark.executor.instances", "3") \
            .config("spark.executor.memory", "4g") \
            .config("spark.driver.memory", "4g")
    else:
        # Local mode with more cores
        builder = builder.master("local[*]")
    
    return builder.getOrCreate()

def load_data(spark, file_path):
    """
    Load data with improved error handling
    """
    try:
        data = spark.read.csv(file_path, header=True, inferSchema=True)
        return data
    except Exception as e:
        print(f"Error loading data from {file_path}: {e}")
        raise

def preprocess_data(data):
    """
    Preprocess the data for machine learning
    """
    # Convert the "quality" column to an integer type for classification
    data = data.withColumn("quality", col("quality").cast("integer"))
    
    # Select all columns except 'quality' for features
    feature_columns = [col for col in data.columns if col != 'quality']
    
    # Create VectorAssembler
    assembler = VectorAssembler(inputCols=feature_columns, outputCol="features")
    
    # Transform the data
    processed_data = assembler.transform(data)
    
    return processed_data