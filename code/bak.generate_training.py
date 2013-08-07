#!/usr/bin/env python
import os
import sys

# Script to generate training dataset
# usage: ./generate_training.py <in dblp ids > <negative ids> <profile features> <content features> <network features> <output directory>

# Read command line arguments
if len(sys.argv) == 6:
	user_file_positive = sys.argv[1]
	user_file_negative = sys.argv[2]
	profile_file = sys.argv[3]
	content_file = sys.argv[4]
	network_file = sys.argv[5]
	output_dir = sys.argv[6]


# Absolute path to output file
if output_dir.ends_with("/"):
	output_dir = os.getcwd() + output_dir
else:
	output_dir = os.getcwd() + output_dir + "/"
	

user_ids_positive = set([])
with open(user_file_positive, "r") as f:
	for line in f:
		user_ids_positive.add( line.strip() )

user_ids_negative = set([])
with open(user_file_negative, "r") as f:
	for line in f:
		user_ids_negative.add( line.strip() )

profile_features = {}
with open(profile_file, "r") as f:
	for line in f:
		parts = line.strip().split("\t")
		partition = parts[0]
		userid = parts[1]
		if (userid in user_ids_positive and partition == 'user') or (userid in user_ids_negative and partition == 'conf' or partition == 'rand'):
			profile_features[part[1]] = parts
# user with no profile features
null_profile_features = ["NA" for feature in profile_features[profile_features.keys()[0]]]

content_features = {}
with open(content_file, "r") as f:
	for line in f:
		parts = line.split("\t")
			content_features[part[1]] = line.strip()
# user with no content features
null_content_features = ["NA" for feature in content_features[content_features.keys()[0]]]

network_features = {}
with open(network_file, "r") as f:
	for line in f:
		parts = line.split("\t")
			network_features[part[1]] = line.strip()
# user with no network features
null_network_features = ["NA" for feature in network_features[network_features.keys()[0]]]

# Append missing features
for user_id in user_ids:
	if not user_id in profile_features:
		profile_features[user_id] = null_profile_features
	if not user_id in content_features:
		contnet_features[user_id] = null_contnet_features
	if not user_id in network_features:
		network_features[user_id] = null_network_features

# write output to files
with open(output_dir + "training.all.features", "w") as f:
	for user_id in user_ids:
		f.write( "\t".join( profile_features[user_id]) + "\t" + "\t".join( content_features[user_id] ) + "\t" + "\t".join( network_features[user_id] ) + "\n" )


