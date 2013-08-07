#!/usr/bin/Rscript
# title: "twitter scholar"

# clean workspace
rm(list=ls())

# Accept file names from command line argument
accept_arguments <- function(){
  # Accept command line arguments
  args <- commandArgs(trailingOnly=TRUE)
  if(length(args) != 2) stop("usage: ./experiments.R <dataset file> <output model file> <output report directory>")
  
  dataset_file = args[1] 
  model_file = args[2]
  #output_dir = args[3]
  #input_file = dataset_file # copy for naming output files
 
  # Change relative path to absolute path
  current_dir = getwd()
  dataset_file = paste(current_dir, dataset_file, sep="/")
  model_file = paste(current_dir, model_file, sep="/")
  #output_dir = paste(current_dir, output_dir, sep="/")

  #file_names = list('current_dir'=current_dir, 'dataset_file'=dataset_file, 'model_file'=model_file, 'output_dir'=output_dir, 'input_file'=input_file)
  file_names = list('current_dir'=current_dir, 'dataset_file'=dataset_file, 'model_file'=model_file)
  return (file_names)
}

# Load required packages 
load_packages <- function(){
  # Load packages: 
  # rpart - recursive partitioning, implements CART, algorithm
  # e1071 - implementation of SVM
  # randomForest - implements random forest algorithm
  # party - conditional inference trees
  # ipred - bagging (bootstrap aggregating)
  # glm - Generalized Linear Models for logistic regression
  if( !require("rpart")) stop("could not load rpart package.")
  if( !require("e1071")) stop("Could not load e1071 package.")
  if(!require("randomForest")) stop("could not load randomForest package.")
}

# Function to compute performance measures
compute_performance <- function(confusion_matrix){
  measures <- NULL
  tp <- confusion_matrix[1,1]
  fn <- confusion_matrix[1,2]
  fp <- confusion_matrix[2,1]
  tn <- confusion_matrix[2,2]
  
  precision <- tp / (tp + fp)
  recall <- tp / (tp + fn)
  accuracy <- (tp + tn) / (tp + tn + fp + fn)
  true_nagative_rate <- tn / (tn + fp )
  
  measures <- c('precision'=precision, 'recall'=recall, 'accuracy'=accuracy, 'true_negative_rate'=true_nagative_rate)
  
  return (measures)
}

# Train a model
train_model <- function(algorithm, training_set){
  if (algorithm == 'svm'){
    model <- svm(class ~., data=training_set, cost=100, gamma=1, probability=TRUE)
  }else if (algorithm == 'rpart'){
    model <- rpart(class ~., data=training_set, method="class")
  }else if (algorithm == 'randomforest'){
    model <- randomForest(class ~., data=training_set, ntree=500)
  }else{
    stop ("Algorithm not supported.")
  }
  return (model)
}

# Perform Stratified sampling
stratified_sampler <- function(dataset, K){
  # Split dataset by postive(dblp), negative(confs, rand)
  dataset_splits = split(dataset, dataset$stratum)
  blocks <- NULL # to keep strata membership
  dataset <- NULL # to keep dataset in order of strata groups
  nof_splits = length(dataset_splits)
  # Assign block id for users in each split
  for ( ind in 1 : nof_splits){
    dataset_split <- dataset_splits[[ind]]
    n <- nrow(dataset_split) # number of observations
    size <- n %/% K # size of each group
    rdm <- runif(n)
    ranked <- rank(rdm)
    block <- (ranked-1) %/% size+1
    blocks <- c(blocks, block)
    dataset <- rbind(dataset, dataset_split[, !names(dataset_split) %in% c("stratum")] )
  }
  
  result <- list('dataset'=dataset, 'block'=blocks)
  return (result)
}

# Perform K-fold cross validation
perform_Kfold_crossvalidation <- function(dataset, algorithms, K=10){  
  # Perfrom Stratified sampling
  stratified <- stratified_sampler(dataset, K)
  dataset <- stratified$dataset
  block <- stratified$block

  # encode class as factor for classification
  dataset$class <- as.factor(dataset$class)
  str(dataset)

  # Variable to store performance
  performance_result <- list()
  
  # Perform K fold cross-validation
  for (k in 1:K) {
    # Partition dataset
    training_set = dataset[block != k, ]
    testing_set = dataset[block == k, ]
    #debugging
    str(training_set)
    str(testing_set )
    iteration_result = NULL
    for (algorithm in algorithms){
      model <- train_model(algorithm, training_set)
      pred <- predict(model, newdata=testing_set, probability=TRUE, type="class" )
      algorithm_performance = compute_performance(table(true=testing_set$class, pred=pred))
      iteration_result = rbind(iteration_result, algorithm_performance)
      rownames(iteration_result)[ dim(iteration_result)[1] ] = algorithm
    }
    print(iteration_result)
    performance_result[[k]] = iteration_result
  }
  
  # Sum result of each iteration
  aggregated_result = Reduce('+', performance_result)
  # Compute the arithmetic mean
  aggregated_result = aggregated_result / length(performance_result)
  ### Save performance results for inspection
  ##detailed_result=paste(output_dir, paste( input_file, "detailed", sep="_"), sep="/")
  ##write.table(do.call(rbind, performance_result), file=detailed_result, quote=FALSE, sep="\t")
  ##summary_result=paste(output_dir, paste(input_file, "summary", sep="_"), sep="/")
  ##write.table(aggregated_result, summary_result, quote=FALSE, sep="\t")

  write ("\n\n##Aggregated result", "")
  print (format(aggregated_result, digits=4, justify="right"), quote=FALSE)

  result = list('dataset'=dataset, 'performance'=aggregated_result)  
  return (result)
}

main <- function(){
  
  # Parse file names from command line argument
  attach( accept_arguments() )
  
  # Load requried packages
  load_packages()
  
  # Read dataset
  dataset <- read.table(dataset_file, sep="\t", header=TRUE, row.names=2)
  str(dataset)

  # Train models and perform 10-fold cross validation
  algorithms <- c('svm', 'randomforest', 'rpart')
  result <- perform_Kfold_crossvalidation(dataset, algorithms)
  dataset <- result$dataset
  performance <- result$performance
  
  # Choose best model, based on overall accuracy
  best_algorithm = names( which.max(performance[,'accuracy']) )
  write (paste("\n\n##Best algorithm \n", best_algorithm), "")
  
  # Re-train best algorithm with all dataset
  best_model = train_model(best_algorithm, dataset)
  
  # Save best model to score new data
  save(best_model, file=model_file)
}

# Kick off main function
main()
