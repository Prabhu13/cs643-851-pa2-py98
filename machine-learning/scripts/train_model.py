from pyspark.ml.classification import RandomForestClassifier, LogisticRegression
from pyspark.ml.evaluation import MulticlassClassificationEvaluator
from pyspark.ml.tuning import ParamGridBuilder, CrossValidator

def train_models(training_data):
    """
    Train multiple models and return them with their evaluators
    """
    # Random Forest Classifier
    rf_classifier = RandomForestClassifier(
        labelCol="quality", 
        featuresCol="features", 
        numTrees=100, 
        maxDepth=10
    )
    
    # Logistic Regression
    lr_classifier = LogisticRegression(
        labelCol="quality", 
        featuresCol="features", 
        maxIter=100
    )
    
    # Define parameter grids for both models
    rf_param_grid = ParamGridBuilder() \
        .addGrid(rf_classifier.numTrees, [50, 100, 150]) \
        .addGrid(rf_classifier.maxDepth, [5, 10, 15]) \
        .build()
    
    lr_param_grid = ParamGridBuilder() \
        .addGrid(lr_classifier.regParam, [0.01, 0.1, 1.0]) \
        .addGrid(lr_classifier.elasticNetParam, [0.0, 0.5, 1.0]) \
        .build()
    
    # Evaluator
    evaluator = MulticlassClassificationEvaluator(
        labelCol="quality", 
        predictionCol="prediction", 
        metricName="f1"  # Using F1 score as requested
    )
    
    # Cross-validators
    rf_cv = CrossValidator(
        estimator=rf_classifier,
        estimatorParamMaps=rf_param_grid,
        evaluator=evaluator,
        numFolds=5
    )
    
    lr_cv = CrossValidator(
        estimator=lr_classifier,
        estimatorParamMaps=lr_param_grid,
        evaluator=evaluator,
        numFolds=5
    )
    
    return {
        "RandomForest": (rf_classifier, rf_cv),
        "LogisticRegression": (lr_classifier, lr_cv)
    }

def train_and_evaluate_models(training_data, validation_data):
    """
    Train multiple models and return their performance
    """
    models = train_models(training_data)
    
    results = {}
    for model_name, (classifier, cv) in models.items():
        # Fit cross-validator
        cv_model = cv.fit(training_data)
        
        # Get best model
        best_model = cv_model.bestModel
        
        # Evaluate on validation data
        predictions = best_model.transform(validation_data)
        
        evaluator = MulticlassClassificationEvaluator(
            labelCol="quality", 
            predictionCol="prediction", 
            metricName="f1"
        )
        
        f1_score = evaluator.evaluate(predictions)
        
        results[model_name] = {
            "model": best_model,
            "f1_score": f1_score
        }
    
    return results