#!/usr/bin/env python
import sys
from sklearn.metrics import *

# Script to check result of validation

def main():
   # Arguments
   if len(sys.argv) == 3:
      validation_input_file = sys.argv[1]
      validation_output_file = sys.argv[2]
   else:
      print "usage check_validation.py <input validation> <output validation>"
      return

   # Read input validation file
   ground_truth_by_id={}
   with open(validation_input_file, "r") as f:
      for line in f:
         parts = line.strip().split("\t")
         user_id = parts[1]
         ground_truth = parts[-1]
         if user_id.isdigit():
            ground_truth_by_id[ user_id ] = ground_truth
   # Read output validation file
   prediction_by_id={}
   with open(validation_output_file, "r") as f:
      for line in f:
         user_id, prediction = line.strip().split("\t")
         if user_id.isdigit():
            prediction_by_id[ user_id ] = prediction

   # Check prediction exists for all users
   assert sorted(ground_truth_by_id.keys()) == sorted(prediction_by_id.keys())

   true_value = []
   pred_value = []
   for key,value in ground_truth_by_id.iteritems():
      true_value.append(value)
      pred_value.append(prediction_by_id[key])
      
   # Count correct / wrong predictions
   # result = confusion_matrix(ground_truth_by_id, prediction_by_id)
   cf = confusion_matrix(true_value, pred_value)
   accuracy = accuracy_score(true_value, pred_value)
   # Report standard output
   print "############################################"
   file_name = validation_input_file.split("/")[-1]
   print "Validation result for " + file_name
   print "confusion matrix"
   print cf
   print "Accuracy"
   print accuracy
   print
   #print classification_report(true_value, pred_value)
if __name__=='__main__':
   main()
