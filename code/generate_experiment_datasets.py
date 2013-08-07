#!/usr/bin/env python
import os
import sys

# Script to generate training/test dataset for experiment

def get_ground_truth(key):
   """ Return 1 or 0 depending on whether stratum is dblp, conf or rand"""
   stratum, userid = key
   if userid.lower() == 'id':
       class_value = 'class'
   elif stratum.lower() == 'dblp':
       class_value = '1'
   elif stratum.lower() == 'conf' or stratum.lower() == 'rand':
       class_value = '0'
   else:
       class_value = '0'

   return class_value
 
def get_key_value(key):
   """  Return a string key"""
   key_val = "\t".join(key)
   stratum, userid = key
   if userid.lower() == 'id':
      key_val = "stratum\tid"
   return key_val

def write_dataset( indexed_features, file_name, training=True):
    """ Get a list of indexed features
    Construct full feature vector concatenating them
    Write them to file, file_name"""
   
    # All keys
    keys = []
    for indexed_feature in indexed_features:
        keys.extend( indexed_feature.keys() )
    keys = set(keys)
    keys = sorted(keys, reverse=True)

    # Open file for writing
    with open(file_name, "w") as f:
        for key in keys:
            # feature_vector keeps the complete vector represenation of the features
            feature_vector = get_key_value(key)
            for indexed_feature in indexed_features:
                 feature_vector = feature_vector + "\t" + "\t".join( indexed_feature[key] )
            # If generating training set, add class value
            if training.lower() in ['t', 'true', '1']:
                 class_value = get_ground_truth(key)
                 if class_value is not None:
                     feature_vector = feature_vector + "\t" + class_value
                 else:
                     print "BAD key: " + key
                     continue
            f.write( feature_vector + "\n")

def generate_datasets (output_dir, profile_features, content_features, network_features, training):
   file_name = output_dir + "training.features.all"
   write_dataset( [profile_features, content_features, network_features], file_name, training)
   file_name = output_dir + "training.features.without.network"
   write_dataset( [profile_features, content_features], file_name, training)
   file_name = output_dir + "training.features.without.content"
   write_dataset( [profile_features, network_features], file_name, training)
   file_name = output_dir + "training.features.without.profile"
   write_dataset( [content_features, network_features], file_name, training)
   file_name = output_dir + "training.features.profile"
   write_dataset( [profile_features], file_name, training)
   file_name = output_dir + "training.features.content"
   write_dataset( [content_features], file_name, training)
   file_name = output_dir + "training.features.network"
   write_dataset( [network_features], file_name, training)
   
   return
 
def add_null_feature_vector(keys, indexed_features, null_feature_vector):
   for key in keys:
      if not key in indexed_features:
          indexed_features[key] = null_feature_vector
   return indexed_features

def get_null_feature_vector(indexed_feature):
   """ Return NA values with the same dimension as indexed_feature"""
   return  ["NA" for feature in indexed_feature[ indexed_feature.keys()[0] ] ]

def append_missing_features(profile_features, content_features, network_features):
   """ dicts of features indexed by keys
       gather all keys and append missing features if any.
       return original dicts with missing features filled."""
   # NULL feature vector
   null_profile_feature = get_null_feature_vector( profile_features )
   null_content_feature = get_null_feature_vector( content_features )
   null_network_feature = get_null_feature_vector( network_features )
  
   # All keys
   all_keys = set( profile_features.keys() + content_features.keys() + network_features.keys() )
 
   # Append missing features
   profile_features = add_null_feature_vector(all_keys, profile_features, null_profile_feature)
   content_features = add_null_feature_vector(all_keys, content_features, null_content_feature)
   network_features = add_null_feature_vector(all_keys, network_features, null_network_feature)
 
   return (profile_features, content_features, network_features) 

def index_features(file_names, key=2, separator="\t"):
   """ file_name String name of file to index
       returns a dict of file indexed by first key columns"""
   indexed_files = []
   for file_name in file_names:
       # output dict.
       indexed_file = {}
       with open(file_name, "r") as f:
          for line in f:
             try:
                parts = line.strip().split(separator)
                index_key = tuple(parts[0:key])
                feature_vector = parts[key:]
                indexed_file[index_key] = feature_vector
             except:
                print "WARNING: WRONG FORMATTING. " + line
                continue
       indexed_files.append(indexed_file)
 
   return indexed_files

def accept_commandline_arguments():
   if len(sys.argv) == 6:
      profile_file = sys.argv[1]
      content_file = sys.argv[2]
      network_file = sys.argv[3]
      training = sys.argv[4]
      output_dir = sys.argv[5]
      # Absolute path to output file
      if output_dir[-1] != "/":
         output_dir += "/"
      output_dir = os.getcwd() + "/" + output_dir
      return (profile_file, content_file, network_file, training, output_dir)
   else:
      print "usage: ./generate_experiment_datasets.py <profile features> <content features> <network features> <training? True> <output directory>"
      exit(1)
 
def main():
   # Accept command line arguments
   profile_file, content_file, network_file, training, output_dir = accept_commandline_arguments()

   # Index input feature files
   profile_features, content_features, network_features = index_features((profile_file, content_file, network_file))
 
   # Append missing features
   profile_features, content_features, network_features = append_missing_features(profile_features, content_features, network_features)

   # write generated data set to file  
   generate_datasets (output_dir, profile_features, content_features, network_features, training)

if __name__ == '__main__':
   main()
