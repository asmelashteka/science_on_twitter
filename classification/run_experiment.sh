#!/bin/bash

# Script to perfrom experiments
# Accept command line arguments
if [[ $# -eq 4 ]]
then
   input_experiment_dir=$1
   input_validation_dir=$2
   output_experiment_dir=$3
   output_validation_dir=$4
else
   echo "usage: ./run_experiments.sh <input experiment> <input validation> <output experiment> <output validation>"
   exit 1
fi

# Make output directories if they don't exist
mkdir -p $output_validation_dir
mkdir -p $output_experiment_dir

# Check if output directories end with /
[[ $output_validation_dir != */ ]] && output_validation_dir="$output_validation_dir"/
[[ $output_experiment_dir != */ ]] && output_experiment_dir="$output_experiment_dir"/

echo "$input_experiment_dir and $input_validation_dir"

for training_file in `ls $input_experiment_dir`
do
   for validation_file in `ls $input_validation_dir`
   do
      if [[ $training_file = $validation_file ]]
      then
         # Train model
         #------------------------------------------------------
         # Prepare dataset for training
         # Header on top, replace missing values, avoid blank features
         input_training=`echo $input_experiment_dir$training_file`
         sort -t$'\t' -k2,2n $input_training | grep -v $'\t\t' |sed 's/NA/0/g' > __training.data
         echo "building model on: $input_training"
         # Build model
         output_file=`echo $output_experiment_dir$training_file`
         code/experiments.R __training.data model.rda > $output_file
         # Validate model
         #------------------------------------------------------
         # Prepare dataset for training
         # Header on top, replace missing values, avoid blank features
         input_validation=`echo $input_validation_dir$validation_file`
         sort -t$'\t' -k2,2n $input_validation | grep -v $'\t\t' | sed 's/NA/0/g' > __validation.data
         echo "Validating model on: $input_validation"
         # Validate model
         output_file=`echo $output_validation_dir$validation_file`
         code/score.R model.rda __validation.data $output_file
         echo "Done with feature group $output_file"
      fi
   done
done

# Report on validation
output_file=`echo $output_validation_dir"summary"`
echo "Summary" > $output_file

for output_validation in `ls $output_validation_dir`
do
   for input_validation in `ls $input_validation_dir`
   do
      if [[ $output_validation = $input_validation ]]
      then
         input="$input_validation_dir$input_validation"
         output="$output_validation_dir$output_validation"
         ./code/check_validation.py $input $output >> $output_file
      fi
   done
done

### Count classification on validation set
##output_file=`echo $output_validation_dir"summary"`
##for validation_output in `ls $output_validation_dir`
##do
##   echo "##################" >> $output_file
##   echo "$validation_output" >> $output_file
##   validation_file=`echo $output_validation_dir$validation_output`
##   cut -f2 $validation_file | sort | uniq -c >> $output_file
##done


      
rm __*
