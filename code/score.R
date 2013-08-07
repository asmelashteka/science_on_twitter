#!/usr/bin/Rscript

# Accept command line arguments
args <- commandArgs(trailingOnly=TRUE)
if(length(args) != 3) stop("usage: score.R <model file> <file to score> <output file>")
model_file = args[1]
input_file = args[2]
output_file = args[3]

# Change relative path to absolute path
current_dir = getwd()
model_file = paste(current_dir, model_file, sep="/") 
input_file = paste(current_dir, input_file, sep="/")
output_file = paste(current_dir, output_file, sep="/")

# Read newdata
my_data <- read.table(input_file, sep="\t", header=TRUE, row.names=2)
my_data <- my_data[, !names(my_data) %in% c("stratum")]
str(my_data)
# Load model
if(! require("randomForest", quietly=TRUE)) stop("could not load randomForest package.")
load(model_file)

# Write model predictions to file
model.pred <- predict(best_model, newdata=my_data, type="class")
write.table(model.pred, file=output_file, sep="\t", col.names=FALSE, quote=FALSE)

print ("Done!")
