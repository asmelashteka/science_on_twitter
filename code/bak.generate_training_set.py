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
   userid = parts[0]
   parts = parts[2:]
   if userid == "Id":
      key = "Id\tstratum"
      parts.append('class')
   elif userid in user_ids_positive:
      key = userid + "\t" + stratum
      parts.append("1")
   elif userid in user_ids_negative:
      key = userid + "\t" + stratum
      parts.append("0")
   else:
      key = None
      parts = None
   return (userid, key, parts)

def construct_featurevector(list1, list2, list3=None):
   """ Get list1, list2 ... are Lists of features
       Construct full feature vector concatenating them"""
   
def main():
   # Read command line arguments
   if len(sys.argv) == 7:
      user_file_positive = sys.argv[1]
      user_file_negative = sys.argv[2]
      profile_file = sys.argv[3]
      content_file = sys.argv[4]
      network_file = sys.argv[5]
      output_dir = sys.argv[6]
      # Absolute path to output file
      if output_dir[-1] != "/":
         output_dir += "/"
      output_dir = os.getcwd() + "/" + output_dir
   else:
      print "usage: ./generate_training_set.py <in dblp ids > <negative ids> <profile features> <content features> <network features> <output directory>"
      return

   # Read input files
   global user_ids_positive
   global user_ids_negative   

   user_ids_positive = set([])
   with open(user_file_positive, "r") as f:
      for line in f:
         user_ids_positive.add( line.strip() )
   user_ids_negative = set([])
   with open(user_file_negative, "r") as f:
      for line in f:
         user_ids_negative.add( line.strip() )
   # Filter profile features
   profile_features = {}
   with open(profile_file, "r") as f:
      for line in f:
         userid, key, features = check_status(line)
         if features is not None:
            profile_features[userid] = features
   # NULL profile feature vector
   null_profile_features = ["NA" for feature in profile_features[ profile_features.keys()[0] ] ]
   
   content_features = {}
   with open(content_file, "r") as f:
      for line in f:
         userid, key, features = check_status(line)
         if features != None:
            content_features[userid] = features
   # NULL content feature vector
   null_content_features = ["NA" for feature in content_features[content_features.keys()[0]]]
   
   network_features = {}
   with open(network_file, "r") as f:
      for line in f:
         userid, key, features = check_status(line)
         if features != None:
            network_features[userid] = features
   # NULL network feature vector
   null_network_features = ["NA" for feature in network_features[network_features.keys()[0]]]
   
   # Append missing features
   for user_id in user_ids_positive:
      if not user_id in profile_features:
         profile_features[user_id] = null_profile_features
      if not user_id in content_features:
         content_features[user_id] = null_content_features
      if not user_id in network_features:
         network_features[user_id] = null_network_features
   
   for user_id in user_ids_negative:
      if not user_id in profile_features:
         profile_features[user_id] = null_profile_features
      if not user_id in content_features:
         content_features[user_id] = null_content_features
      if not user_id in network_features:
         network_features[user_id] = null_network_features
   
   # write output to files
   with open(output_dir + "training.features.all", "w") as f:
      for user_id in user_ids_positive:
         f.write( user_id + "\t" + "\t".join( profile_features[user_id][:-1]) + "\t" + "\t".join( content_features[user_id][:-1] ) + "\t" + "\t".join( network_features[user_id] ) + "\n" )
      for user_id in user_ids_negative:
         f.write( user_id + "\t" + "\t".join( profile_features[user_id][:-1]) + "\t" + "\t".join( content_features[user_id][:-1] ) + "\t" + "\t".join( network_features[user_id] ) + "\n" )
   
   with open(output_dir + "training.features.without.network", "w") as f:
      for user_id in user_ids_positive:
         f.write( user_id + "\t" + "\t".join( profile_features[user_id][:-1]) + "\t" + "\t".join( content_features[user_id] ) + "\n" )
      for user_id in user_ids_negative:
         f.write( user_id + "\t" + "\t".join( profile_features[user_id][:-1]) + "\t" + "\t".join( content_features[user_id] ) + "\n" )
   
   with open(output_dir + "training.features.without.content", "w") as f:
      for user_id in user_ids_positive:
         f.write( user_id + "\t" + "\t".join( profile_features[user_id][:-1]) + "\t" + "\t".join( network_features[user_id] ) + "\n" )
      for user_id in user_ids_negative:
         f.write( user_id + "\t" + "\t".join( profile_features[user_id][:-1]) + "\t" + "\t".join( network_features[user_id] ) + "\n" )
   
   with open(output_dir + "training.features.without.profile", "w") as f:
      for user_id in user_ids_positive:
         f.write( user_id + "\t" + "\t".join( content_features[user_id][:-1] ) + "\t" + "\t".join( network_features[user_id] ) + "\n" )
      for user_id in user_ids_negative:
         f.write( user_id + "\t" + "\t".join( content_features[user_id][:-1] ) + "\t" + "\t".join( network_features[user_id] ) + "\n" )
   
   with open(output_dir + "training.features.profile", "w") as f:
      for user_id in user_ids_positive:
         f.write( user_id + "\t" + "\t".join( profile_features[user_id]) + "\n" )
      for user_id in user_ids_negative:
         f.write( user_id + "\t" + "\t".join( profile_features[user_id]) + "\n" )
   
   with open(output_dir + "training.features.content", "w") as f:
      for user_id in user_ids_positive:
         f.write( user_id + "\t" + "\t".join( content_features[user_id] ) + "\n" )
      for user_id in user_ids_negative:
         f.write( user_id + "\t" + "\t".join( content_features[user_id] ) + "\n" )
   
   with open(output_dir + "training.features.network", "w") as f:
      for user_id in user_ids_positive:
         f.write( user_id + "\t" + "\t".join( network_features[user_id] ) + "\n" )
      for user_id in user_ids_negative:
         f.write( user_id + "\t" + "\t".join( network_features[user_id] ) + "\n" )
     
if __name__ == '__main__':
   main()
