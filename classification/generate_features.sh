#!/bin/bash

# Script to generate features

function profile_features_and_prefix {
   data_set=$1
   stratum=$2
   DESCRIPTION_KEY_WORDS=output_preprocessing/description.keywords
   code/profile_features.py $data_set $DESCRIPTION_KEY_WORDS | awk -F"\t" -v prefix=$stratum '{ if( tolower($1) == "id") {print "stratum\t"$0}else{print prefix"\t"$0} }'
}

function add_prefix { 
  prefix=$1
  while read data
  do 
    printf "$data\n" | awk -F"\t" -v stratum=$prefix '{ if( tolower($1) == "id") {print "stratum\t"$0}else{print stratum"\t"$0} }'
  done
}

function add_prefix {     prefix=$1;    while read data;    do       printf "$data\n" | awk -F"\t" -v stratum=$prefix '{ if( tolower($1) == "id") {print "stratum\t"$0}else{print stratum"\t"$0} }';    done; }

#--------------------------
# Profile features
function profile_features{
  # Learning
  profile_features_and_prefix dblp/user.info "dblp" > __profile.features
  profile_features_and_prefix conferences/conf.info "conf" >> __profile.features
  profile_features_and_prefix random/negative.info "rand" >> __profile.features
  sort -u __profile.features | sort -t$'\t' -k2,2n > output_features/features.profile
  # Users
  profile_features_and_prefix users/user.info "user" > output_features/user.features.profile
}

#--------------------------
# Content features
function content_features{
  ACADEMIC_HASHTAGS="output_preprocessing/hashtags.boosted"
  ACADEMIC_MENTIONS="output_preprocessing/mentions.boosted"
  # user
  code/content_features.py input_content/user.tweets input_content/user.retweets input_content/user.hashtags input_content/user.mentions input_content/user.urls $ACADEMIC_HASHTAGS $ACADEMIC_MENTIONS | add_prefix "user" > output_features/features.user.content
  # dblp
  cut -f2- output_features/features.user.content |sort -t$'\t' -k1,1 | join -t$'\t' -1 1 -2 1 - <(sort -t$'\t' -k1,1 dblp/user.ids) | add_prefix "dblp" > __content.features
  # Conf
  code/content_features.py input_content/conf.tweets input_content/conf.retweets input_content/conf.hashtags input_content/conf.mentions input_content/conf.urls $ACADEMIC_HASHTAGS $ACADEMIC_MENTIONS | add_prefix "conf" >> __content.features
  # Rand
  code/content_features.py input_content/rand.tweets input_content/rand.retweets input_content/rand.hashtags input_content/rand.mentions input_content/rand.urls $ACADEMIC_HASHTAGS $ACADEMIC_MENTIONS | add_prefix "rand" >> __content.features
  ##
  sort -u __content.features | sort -t$'\t' -k2,2n - > output_features/features.content
}

#--------------------------
# Network features
function network_features{
  CONF_IDS="output_preprocessing/conf.ids"
  SMALL_NETWORK="output_preprocessing/small.network.ids"
  # users
  code/network_features_helper.sh input_network/user.network.retweet input_network/user.network.mention input_network/user.network.friends input_network/user.network.followers $CONF_IDS $SMALL_NETWORK | add_prefix "user" > output_features/user.features.network
  # dblp
  cut -f2- output_features/user.features.network | sort -t$'\t' -k1,1 | join -t$'\t' -1 1 -2 1 - <(sort -t$'\t' -k1,1 dblp/user.ids) | add_prefix "dblp" > __network.features
  # Conf
  code/network_features_helper.sh input_network/conf.network.retweet input_network/conf.network.mention input_network/conf.network.friends input_network/conf.network.followers $CONF_IDS $SMALL_NETWORK | add_prefix "conf" >> __network.features
  # rand
  code/network_features_helper.sh input_network/rand.network.retweet input_network/rand.network.mention input_network/rand.network.friends input_network/rand.network.followers $CONF_IDS $SMALL_NETWORK | add_prefix "rand" >> __network.features
  ##
  sort -u __network.features | sort -t$'\t' -k2,2n - > output_features/features.network
}

#--------------------------
# Kick off script from here
if [[ $# -eq 1 ]]
then
  option=$1
else
  echo "usage: generate_features.sh <otpion 1 profile 2 content 3 network 0 all>"
fi

if [[ $option -eq "1" ]]
then
   profile_features
elif [[ $option -eq "2" ]]
then
   content_features
elif [[ $option -eq "3" ]]
then
   network_features
elif [[ $option -eq "0" ]]
then
   profile_features
   content_features
   network_features
else
   echo "Wrong <option [0-3]"
fi
