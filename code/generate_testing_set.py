#!/usr/bin/env python
import os
import sys

# Script to generate training dataset

def check_status(line):
   """
   Check if line should be included in training set
   Retrun parts if it does or None otherwise.
   """
   parts = line.strip().split("\t")
   partition = parts[0]
   userid = parts[1]
   parts = parts[2:]
  
   result = [ userid, None ]
   if (userid in user_ids) and (partition == 'user'):
      result = [ userid, parts]
   return result

def main():
   # Read command line arguments
   if len(sys.argv) == 6:
      user_ids_file = sys.argv[1]
      profile_file = sys.argv[2]
      content_file = sys.argv[3]
      network_file = sys.argv[4]
      output_dir = sys.argv[5]
      # Absolute path to output file
      if output_dir[-1] == "/":
         output_dir = os.getcwd() + "/" + output_dir
      else:
         output_dir = os.getcwd() + "/" + output_dir + "/"
   else:
      print "usage: ./generate_testing_set.py <user ids >  <profile features> <content features> <network features> <output directory>"
      return

   # Read input files
   global user_ids
   user_ids = set([])
   with open(user_ids_file, "r") as f:
      for line in f:
         user_ids.add( line.strip() )
   # Filter profile features
   profile_features = {}
   with open(profile_file, "r") as f:
      for line in f:
         userid, features = check_status(line)
         if features != None:
            profile_features[userid] = features
   
   # user with no profile features
   null_profile_features = ["NA" for feature in profile_features[ profile_features.keys()[0] ] ]
   
   content_features = {}
   with open(content_file, "r") as f:
      for line in f:
         userid, features = check_status(line)
         if features != None:
            content_features[userid] = features
   # user with no content features
   null_content_features = ["NA" for feature in content_features[content_features.keys()[0]]]
   
   network_features = {}
   with open(network_file, "r") as f:
      for line in f:
         userid, features = check_status(line)
         if features != None:
            network_features[userid] = features
   # user with no network features
   null_network_features = ["NA" for feature in network_features[network_features.keys()[0]]]
   
   # Append missing features
   for user_id in user_ids:
      if not user_id in profile_features:
         profile_features[user_id] = null_profile_features
      if not user_id in content_features:
         content_features[user_id] = null_content_features
      if not user_id in network_features:
         network_features[user_id] = null_network_features
   
      # write output to files
   with open(output_dir + "training.features.all", "w") as f:
      for user_id in user_ids:
         f.write( user_id + "\t" + "\t".join( profile_features[user_id]) + "\t" + "\t".join( content_features[user_id] ) + "\t" + "\t".join( network_features[user_id] ) + "\n" )
         
   with open(output_dir + "training.features.without.network", "w") as f:
      for user_id in user_ids:
         f.write( user_id + "\t" + "\t".join( profile_features[user_id]) + "\t" + "\t".join( content_features[user_id] ) + "\n" )
         
   with open(output_dir + "training.features.without.content", "w") as f:
      for user_id in user_ids:
         f.write( user_id + "\t" + "\t".join( profile_features[user_id]) + "\t" + "\t".join( network_features[user_id] ) + "\n" )
         
   with open(output_dir + "training.features.without.profile", "w") as f:
      for user_id in user_ids:
         f.write( user_id + "\t" + "\t".join( content_features[user_id] ) + "\t" + "\t".join( network_features[user_id] ) + "\n" )
         
   with open(output_dir + "training.features.profile", "w") as f:
      for user_id in user_ids:
         f.write( user_id + "\t" + "\t".join( profile_features[user_id]) + "\n" )
         
   with open(output_dir + "training.features.content", "w") as f:
      for user_id in user_ids:
         f.write( user_id + "\t" + "\t".join( content_features[user_id] ) + "\n" )
         
   with open(output_dir + "training.features.network", "w") as f:
      for user_id in user_ids:
         f.write( user_id + "\t" + "\t".join( network_features[user_id] ) + "\n" )
           
if __name__ == '__main__':
   main()
