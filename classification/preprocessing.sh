#!/bin/bash

# Script to perfrom preprocessing

#-------------------------------------
# Directories to keep parsed userinfo and tweets
mkdir -p users conferences dblp random

# Select DBLP users
../dblp_data/code/match_users.sh ../users/user.info ../dblp_data/data/authors.lst dblp/user.ids

# Parse user info
code/parse_userinfo.sh

# Parse tweets
code/parse_tweets.sh

#-------------------------------------
# Directory to keep output for feature generation
mkdir -p output_preprocessing

# key words in user bio
code/generate_description_keywords.sh dblp/user.info conferences/conf.info random/rand.info 

# Bootstrapping hashtags
code/generate_hashtag-featurevector.sh dblp/user.hashtags conferences/conf.hashtags random/rand.hashtags dblp/user.tweets random/rand.tweets

# Bootstrapping mentions

#-------------------------------------
# Directory to keep parsed network and content inputs
mkdir -p input_network input_content
code/prepare_content_network_input.sh

echo "Done."
