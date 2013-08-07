#!/bin/bash

# Script to generate network features

if [ $# -eq 6 ]
then
   retweet_network=$1
   mention_network=$2
   friend_network=$3
   follower_network=$4
   conf_ids=$5
   small_network_ids=$6
else
  echo "usage: network_features_helper.sh <retweet network> <menation network> <friend network> <follower network> <conf ids> <small network ids>"
   exit 1 
fi

############################################
# FEATURE 2 - Network Features
############################################

#--------------------------------------------
##echo "Computing conf. related network features..."
code/network_features.py $retweet_network $conf_ids | sort -t$'\t' -k1,1 > __nof.confs.retweeted
code/network_features.py $mention_network $conf_ids | sort -t$'\t' -k1,1 > __nof.confs.mentioned
code/network_features.py $friend_network $conf_ids | sort -t$'\t' -k1,1 > __nof.conf.friends
##echo "Done."

# Combining conf features
join -t$'\t' -1 1 -2 1 -a1 -a2 -e 'NA' -o '0 1.2 2.2' <(sort -t$'\t' -k1,1 __nof.confs.retweeted) <(sort -t$'\t' -k1,1 __nof.confs.mentioned) | join -t$'\t' -1 1 -2 1 -a1 -a2 -e 'NA' -o '0 1.2 1.3 2.2' - <(sort -t$'\t' -k1,1 __nof.conf.friends) | sort -t$'\t' -k1,1 > __features.network.conf

#--------------------------------------------
##echo "Computing small network related features..."
code/network_features.py $retweet_network $small_network_ids | sort -t$'\t' -k1,1  > __nof.users_retweeted
code/network_features.py $mention_network $small_network_ids | sort -t$'\t' -k1,1  > __nof.users_mentioned
code/network_features.py $friend_network $small_network_ids | sort -t$'\t' -k1,1 > __nof.users_friends
code/network_features.py $follower_network $small_network_ids | sort -t$'\t' -k1,1 > __nof.users_followers
##echo "Done."

# Combining user features
join -t$'\t' -1 1 -2 1 -a1 -a2 -e 'NA' -o '0 1.2 2.2' <(sort -t$'\t' -k1,1 __nof.users_retweeted) <(sort -t$'\t' -k1,1 __nof.users_mentioned) | join -t$'\t' -1 1 -2 1 -a1 -a2 -e 'NA' -o '0 1.2 1.3 2.2' - <(sort -t$'\t' -k1,1  __nof.users_friends) | join -t$'\t' -1 1 -2 1 -a1 -a2 -e 'NA' -o '0 1.2 1.3 1.4 2.2' - <(sort -t$'\t' -k1,1 __nof.users_followers) | sort -t$'\t' -k1,1 > __features.network.small.world

#-------------------------------------------------
# Merging netwok features
# Header info.
echo -e "Id\tnof.confs.retweeted\tnof.confs.mentioned\tnof.conf.friends\tnof.users.retweeted\tnof.users.mentioned\tnof.user.friends\tnof.user.followers"
join -t$'\t' -1 1 -2 1 -a1 -a2 -e 'NA' -o '0 1.2 1.3 1.4 2.2 2.3 2.4 2.5' __features.network.conf __features.network.small.world

