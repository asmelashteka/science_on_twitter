#!/usr/bin/Rscript
# title: "twitter scholar"

# clean workspace
rm(list=ls())

# Change directory
dirName <- "~/PROJECTS_ON_TWITTER/Researchers/classification/"
setwd(dirName)

# Performance measures
perf_measure <- function(confusion_matrix){
  measures <- NULL
  tp <- confusion_matrix[2,2]
  fp <- confusion_matrix[2,1]
  tn <- confusion_matrix[1,1]
  fn <- confusion_matrix[1,2]
  
  precision <- tp / (tp + fp)
  recall <- tp / (tp + fn)
  accuracy <- (tp + tn) / (tp + tn + fp + fn)
  true_nagative_rate <- (tp + tn) / (tp + tn + fp + fn)
  
  measures <- c(precision, recall, accuracy, true_nagative_rate)
  
  return (measures)
}

# Read data set
training_set <- read.table('training_set', sep="\t", header=T, row.names=1)
testing_set <- read.table('testing_set', sep="\t", header=T, row.names=1)

# encode class as factor for classification
training_set$class <- as.factor(training_set$class)
testing_set$class <- as.factor(testing_set$class)
######################################################################################
# Load packages: rpart - recursive partitioning, implements CART, Classification And Regression Tree Algorithm
#                e1071 - implementation of SVM
#                randomForest - implements random forest algorithm
#                party - conditional inference trees
#                ipred - bagging (bootstrap aggregating)
#                glm - Generalized Linear Models for logistic regression
if( !require("rpart")) stop("could not load rpart package.")
if( !require("e1071")) stop("Could not load e1071 package.")
if(!require("randomForest")) stop("could not load randomForest package.")

# modeling prection
#svm
svm.model <- svm(class ~., data=training_set, cost=100, gamma=1, probability=TRUE)
svm.pred <- predict(svm.model, testing_set[,!names(testing_set) %in% c('class')], probability=TRUE )
#rpart
rpart.model <- rpart(class ~., data=training_set, method="class")
rpart.pred <- predict( rpart.model, testing_set[,!names(testing_set) %in% c('class')], type="class")
#randomforest
rforest.model <- randomForest(class ~., data=training_set, ntree=500)
rforest.pred <- predict(rforest.model, newdata=testing_set[,!names(testing_set) %in% c('class')], type="class")

# Compute performance
# TODO: Multiple runs
print("Algorithm Precision Recall Accuracy TrueNegativeRate")
print("svm")
sv.cmatrix <- table(pred=svm.pred, true=testing_set$class)
perf_measure(sv.cmatrix)
print("rpart")
rpart.cmatrix <- table(pred=rpart.pred, true=testing_set$class)
perf_measure(rpart.cmatrix)
print("randomforest")
rforest.cmatrix <- table(pred=rforest.pred, true=testing_set$class)
perf_measure(rforest.cmatrix)

# Graphical comparison using ROCR
# # Loack package for performance
# if( !require("ROCR")) stop("Could not load ROCR")
# probs <- attr(svm.pred, "probabilities")[,1]
# pred <- prediction(probs, testing_set$class)
# perf <- performance(pred, measure="tpr", x.measure="fpr")
# plot(perf)

# Save best model for scoring new data
model=rforest.model
save(model, file="model.rda")


