def main():
    # Create Spark session
    spark = create_spark_session(is_distributed=True)
    
    try:
        # File paths
        training_file = "data/TrainingDataset.csv"
        validation_file = "data/ValidationDataset.csv"
        
        # Load data
        training_data = load_data(spark, training_file)
        validation_data = load_data(spark, validation_file)
        
        # Preprocess data
        processed_training_data = preprocess_data(training_data)
        processed_validation_data = preprocess_data(validation_data)
        
        # Train and evaluate models
        model_results = train_and_evaluate_models(
            processed_training_data, 
            processed_validation_data
        )
        
        # Print results
        print("Model Performance Comparison:")
        for model_name, result in model_results.items():
            print(f"{model_name} - F1 Score: {result['f1_score']:.4f}")
        
        # Optionally, save the best model
        best_model_name = max(
            model_results, 
            key=lambda x: model_results[x]['f1_score']
        )
        best_model = model_results[best_model_name]['model']
        
        # Save the best model
        model_save_path = "models/wine_quality_model"
        best_model.write.overwrite().save(model_save_path)
        print(f"Best model ({best_model_name}) saved to {model_save_path}")
    
    except Exception as e:
        print(f"An error occurred: {e}")
    
    finally:
        spark.stop()

if __name__ == "__main__":
    main()